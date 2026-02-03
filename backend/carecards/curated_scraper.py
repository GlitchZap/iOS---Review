"""
ParentBud Curated Scraper
-------------------------
Scrapes specific curated URLs for parenting content.
This is the production scraper that targets verified, high-quality sources.

Pipeline: Scrape → AI Summarize → Store → Show in App
"""

import requests
from bs4 import BeautifulSoup
from newspaper import Article
from readability import Document
import json
import os
import hashlib
import time
import random
import re
from urllib.parse import urlparse
from urllib.robotparser import RobotFileParser
from datetime import datetime

# ─────────────────────────────────────────────────────────────
# DIRECTORIES
# ─────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(__file__)
DATA_DIR = os.path.join(BASE_DIR, "data")
RAW_DIR = os.path.join(DATA_DIR, "raw")
TOPIC_DIR = os.path.join(DATA_DIR, "by_topic")
os.makedirs(RAW_DIR, exist_ok=True)
os.makedirs(TOPIC_DIR, exist_ok=True)

# ─────────────────────────────────────────────────────────────
# LOAD CURATED URLS
# ─────────────────────────────────────────────────────────────
with open(os.path.join(BASE_DIR, 'curated_urls.json'), 'r') as f:
    CURATED_URLS = json.load(f)

# ─────────────────────────────────────────────────────────────
# SETTINGS
# ─────────────────────────────────────────────────────────────
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
}
REQUEST_DELAY = (2, 4)  # Be polite: 2-4 seconds between requests

# ─────────────────────────────────────────────────────────────
# ROBOTS.TXT CHECKER
# ─────────────────────────────────────────────────────────────
_robots_cache = {}

def can_fetch(url):
    """Check if we're allowed to fetch this URL per robots.txt"""
    try:
        parsed = urlparse(url)
        base = f"{parsed.scheme}://{parsed.netloc}"
        
        if base not in _robots_cache:
            rp = RobotFileParser()
            rp.set_url(f"{base}/robots.txt")
            rp.read()
            _robots_cache[base] = rp
        
        rp = _robots_cache[base]
        return rp.can_fetch('*', url)
    except:
        return True  # If can't check, assume allowed


def polite_delay():
    """Wait between requests to be respectful"""
    time.sleep(random.uniform(*REQUEST_DELAY))


# ─────────────────────────────────────────────────────────────
# FETCHING FUNCTIONS
# ─────────────────────────────────────────────────────────────
def fetch_html(url):
    """Fetch HTML content from URL"""
    if not can_fetch(url):
        print(f"   ⛔ Blocked by robots.txt: {url}")
        return None
    
    try:
        polite_delay()
        session = requests.Session()
        response = session.get(url, headers=HEADERS, timeout=30, allow_redirects=True)
        response.raise_for_status()
        return response.text
    except requests.exceptions.Timeout:
        print(f"   ⏱️  Timeout: {url}")
        return None
    except requests.exceptions.HTTPError as e:
        print(f"   ❌ HTTP Error {e.response.status_code}: {url}")
        return None
    except Exception as e:
        print(f"   ❌ Failed: {url} - {str(e)[:50]}")
        return None


def fetch_pdf(url):
    """Fetch and extract text from PDF"""
    try:
        polite_delay()
        response = requests.get(url, headers=HEADERS, timeout=30)
        response.raise_for_status()
        
        # Try to extract text from PDF using basic method
        # For better results, you'd use PyPDF2 or pdfplumber
        content = response.content
        
        # Basic text extraction from PDF (works for simple PDFs)
        text = ""
        try:
            import io
            # Try PyPDF2 if available
            try:
                import PyPDF2
                pdf_reader = PyPDF2.PdfReader(io.BytesIO(content))
                for page in pdf_reader.pages:
                    text += page.extract_text() + "\n"
            except ImportError:
                # Fallback: extract readable strings
                text = re.sub(rb'[^\x20-\x7E\n]', b' ', content).decode('utf-8', errors='ignore')
                text = ' '.join(text.split())
        except:
            pass
        
        return text if len(text) > 100 else None
    except Exception as e:
        print(f"   ❌ PDF failed: {url} - {str(e)[:50]}")
        return None


# ─────────────────────────────────────────────────────────────
# EXTRACTION FUNCTIONS
# ─────────────────────────────────────────────────────────────
def extract_with_newspaper(url):
    """Extract article using newspaper3k library"""
    try:
        article = Article(url)
        article.download()
        article.parse()
        
        if article.text and len(article.text) > 200:
            # Also try NLP for summary
            try:
                article.nlp()
                summary = article.summary
            except:
                summary = article.text[:500]
            
            return {
                'title': article.title or 'Untitled',
                'text': article.text,
                'summary': summary,
                'authors': article.authors,
                'publish_date': article.publish_date.isoformat() if article.publish_date else None,
                'top_image': article.top_image,
                'method': 'newspaper3k'
            }
    except Exception as e:
        pass
    return None


def extract_with_readability(html, url):
    """Extract article using readability library"""
    try:
        doc = Document(html)
        content_html = doc.summary()
        soup = BeautifulSoup(content_html, 'html.parser')
        text = soup.get_text(separator='\n', strip=True)
        
        if text and len(text) > 200:
            return {
                'title': doc.title() or 'Untitled',
                'text': text,
                'summary': text[:500],
                'method': 'readability'
            }
    except Exception as e:
        pass
    return None


def extract_with_beautifulsoup(html, url):
    """Manual extraction using BeautifulSoup"""
    try:
        soup = BeautifulSoup(html, 'html.parser')
        
        # Remove unwanted elements
        for tag in soup(['script', 'style', 'nav', 'header', 'footer', 
                         'aside', 'form', 'iframe', 'noscript']):
            tag.decompose()
        
        # Try to find main content
        main_content = None
        for selector in ['article', 'main', '[role="main"]', '.content', 
                        '.article-body', '.post-content', '#content']:
            main_content = soup.select_one(selector)
            if main_content:
                break
        
        if not main_content:
            main_content = soup.body if soup.body else soup
        
        # Get title
        title = ''
        title_tag = soup.find('h1') or soup.find('title')
        if title_tag:
            title = title_tag.get_text(strip=True)
        
        # Get text
        text = main_content.get_text(separator='\n', strip=True)
        
        # Clean up
        lines = [line.strip() for line in text.split('\n') if line.strip()]
        text = '\n'.join(lines)
        
        if len(text) > 200:
            return {
                'title': title or 'Untitled',
                'text': text,
                'summary': text[:500],
                'method': 'beautifulsoup'
            }
    except Exception as e:
        pass
    return None


def extract_article(url):
    """Try multiple extraction methods"""
    # Method 1: newspaper3k (best for news/blog articles)
    result = extract_with_newspaper(url)
    if result and len(result.get('text', '')) > 300:
        return result
    
    # Method 2: Fetch HTML and try readability
    html = fetch_html(url)
    if html:
        result = extract_with_readability(html, url)
        if result and len(result.get('text', '')) > 300:
            return result
        
        # Method 3: BeautifulSoup manual extraction
        result = extract_with_beautifulsoup(html, url)
        if result and len(result.get('text', '')) > 300:
            return result
    
    return None


# ─────────────────────────────────────────────────────────────
# UTILITIES
# ─────────────────────────────────────────────────────────────
def fingerprint(text):
    """Create content hash for deduplication"""
    return hashlib.sha256(text.encode('utf-8')).hexdigest()[:16]


def clean_text(text):
    """Clean extracted text"""
    if not text:
        return ""
    
    # Remove excessive whitespace
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = re.sub(r' {2,}', ' ', text)
    
    # Remove common boilerplate phrases
    boilerplate = [
        r'Subscribe to our newsletter.*',
        r'Share this article.*',
        r'Follow us on.*',
        r'Cookie policy.*',
        r'Privacy policy.*',
        r'Terms of use.*',
        r'All rights reserved.*',
        r'Copyright ©.*',
    ]
    for pattern in boilerplate:
        text = re.sub(pattern, '', text, flags=re.IGNORECASE)
    
    return text.strip()


def save_article(record, topic_id):
    """Save scraped article to JSON files"""
    fp = record.get('fingerprint', fingerprint(record.get('text', '')[:1000]))
    record['fingerprint'] = fp
    
    # Save to raw directory
    raw_path = os.path.join(RAW_DIR, f"{fp}.json")
    with open(raw_path, 'w', encoding='utf-8') as f:
        json.dump(record, f, indent=2, ensure_ascii=False)
    
    # Save to topic directory
    topic_path = os.path.join(TOPIC_DIR, topic_id)
    os.makedirs(topic_path, exist_ok=True)
    with open(os.path.join(topic_path, f"{fp}.json"), 'w', encoding='utf-8') as f:
        json.dump(record, f, indent=2, ensure_ascii=False)
    
    return fp


# ─────────────────────────────────────────────────────────────
# MAIN SCRAPING FUNCTION
# ─────────────────────────────────────────────────────────────
def scrape_topic(topic_id, topic_data):
    """Scrape all URLs for a single topic"""
    title = topic_data.get('title', topic_id)
    urls = topic_data.get('urls', [])
    pdfs = topic_data.get('pdfs', [])
    
    print(f"\n{'='*60}")
    print(f"📚 TOPIC: {title}")
    print(f"{'='*60}")
    print(f"   URLs to scrape: {len(urls)}")
    print(f"   PDFs to scrape: {len(pdfs)}")
    
    collected = []
    
    # Scrape regular URLs
    for i, url in enumerate(urls, 1):
        print(f"\n   [{i}/{len(urls)}] {url[:60]}...")
        
        article = extract_article(url)
        if not article:
            print(f"      ⚠️  Could not extract content")
            continue
        
        # Clean and validate
        article['text'] = clean_text(article.get('text', ''))
        if len(article['text']) < 200:
            print(f"      ⚠️  Content too short ({len(article['text'])} chars)")
            continue
        
        # Build record
        record = {
            'url': url,
            'topic_id': topic_id,
            'topic_title': title,
            'scraped_at': datetime.now().isoformat(),
            'source_type': 'web',
            **article
        }
        
        fp = save_article(record, topic_id)
        collected.append(record)
        print(f"      ✅ Saved: {article.get('title', 'Untitled')[:40]}... ({len(article['text'])} chars)")
    
    # Scrape PDFs
    for i, url in enumerate(pdfs, 1):
        print(f"\n   [PDF {i}/{len(pdfs)}] {url[:60]}...")
        
        text = fetch_pdf(url)
        if not text or len(text) < 200:
            print(f"      ⚠️  Could not extract PDF content")
            continue
        
        text = clean_text(text)
        
        record = {
            'url': url,
            'topic_id': topic_id,
            'topic_title': title,
            'title': url.split('/')[-1].replace('.pdf', '').replace('-', ' ').replace('_', ' ').title(),
            'text': text,
            'summary': text[:500],
            'scraped_at': datetime.now().isoformat(),
            'source_type': 'pdf',
            'method': 'pdf_extraction'
        }
        
        fp = save_article(record, topic_id)
        collected.append(record)
        print(f"      ✅ Saved PDF: {len(text)} chars")
    
    print(f"\n   📊 Topic '{title}': {len(collected)} articles collected")
    return collected


def scrape_all():
    """Scrape all curated URLs for all topics"""
    print("\n" + "="*60)
    print("🚀 PARENTBUD CURATED SCRAPER")
    print("="*60)
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Topics to scrape: {len(CURATED_URLS)}")
    
    total_urls = sum(len(t.get('urls', [])) + len(t.get('pdfs', [])) for t in CURATED_URLS.values())
    print(f"Total URLs: {total_urls}")
    
    all_results = {}
    total_collected = 0
    
    for topic_id, topic_data in CURATED_URLS.items():
        results = scrape_topic(topic_id, topic_data)
        all_results[topic_id] = results
        total_collected += len(results)
    
    # Save summary
    summary = {
        'scraped_at': datetime.now().isoformat(),
        'total_articles': total_collected,
        'topics': {
            tid: {
                'title': CURATED_URLS[tid].get('title', tid),
                'count': len(articles),
                'urls_attempted': len(CURATED_URLS[tid].get('urls', [])) + len(CURATED_URLS[tid].get('pdfs', []))
            }
            for tid, articles in all_results.items()
        }
    }
    
    summary_path = os.path.join(DATA_DIR, 'scrape_summary.json')
    with open(summary_path, 'w') as f:
        json.dump(summary, f, indent=2)
    
    # Print summary
    print("\n" + "="*60)
    print("✅ SCRAPING COMPLETE")
    print("="*60)
    for tid, articles in all_results.items():
        title = CURATED_URLS[tid].get('title', tid)
        attempted = len(CURATED_URLS[tid].get('urls', [])) + len(CURATED_URLS[tid].get('pdfs', []))
        print(f"   {title}: {len(articles)}/{attempted} articles")
    print(f"\n   Total: {total_collected} articles collected")
    print(f"   Data saved to: {DATA_DIR}")
    
    return all_results


# ─────────────────────────────────────────────────────────────
# SINGLE TOPIC SCRAPER
# ─────────────────────────────────────────────────────────────
def scrape_single_topic(topic_id):
    """Scrape a single topic by ID"""
    if topic_id not in CURATED_URLS:
        print(f"❌ Topic '{topic_id}' not found!")
        print(f"Available topics: {list(CURATED_URLS.keys())}")
        return []
    
    return scrape_topic(topic_id, CURATED_URLS[topic_id])


# ─────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────
if __name__ == '__main__':
    import sys
    
    if len(sys.argv) > 1:
        # Scrape specific topic
        topic = sys.argv[1]
        scrape_single_topic(topic)
    else:
        # Scrape all topics
        scrape_all()
