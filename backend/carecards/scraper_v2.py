"""
ParentBud Enhanced Scraper V2
-----------------------------
Scrapes curated URLs with age-group awareness.
Generates multiple card variations per topic for personalization.

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
AGE_DIR = os.path.join(DATA_DIR, "by_age")
os.makedirs(RAW_DIR, exist_ok=True)
os.makedirs(TOPIC_DIR, exist_ok=True)
os.makedirs(AGE_DIR, exist_ok=True)

# ─────────────────────────────────────────────────────────────
# LOAD CURATED URLS V2
# ─────────────────────────────────────────────────────────────
CONFIG_FILE = os.path.join(BASE_DIR, 'curated_urls_v2.json')
with open(CONFIG_FILE, 'r') as f:
    CURATED_URLS = json.load(f)

# ─────────────────────────────────────────────────────────────
# AGE GROUP KEYWORDS FOR CLASSIFICATION
# ─────────────────────────────────────────────────────────────
AGE_KEYWORDS = {
    "2-4": [
        "toddler", "2 year", "3 year", "two year", "three year",
        "terrible twos", "preschool", "daycare", "potty", "diaper",
        "nap", "tantrum", "meltdown", "clingy", "separation"
    ],
    "4-6": [
        "preschool", "4 year", "5 year", "four year", "five year",
        "kindergarten", "pre-k", "school readiness", "learning",
        "playdates", "sharing", "cooperation"
    ],
    "6-8": [
        "school age", "6 year", "7 year", "six year", "seven year",
        "elementary", "homework", "reading", "friends", "sports",
        "responsibility", "chores"
    ],
    "8-10": [
        "tween", "8 year", "9 year", "10 year", "eight year", "nine year",
        "preteen", "independence", "peer pressure", "social media",
        "puberty", "growing up"
    ]
}

# ─────────────────────────────────────────────────────────────
# SETTINGS
# ─────────────────────────────────────────────────────────────
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
}
REQUEST_DELAY = (1.5, 3)  # Be polite

# ─────────────────────────────────────────────────────────────
# ROBOTS.TXT CHECKER
# ─────────────────────────────────────────────────────────────
_robots_cache = {}

def can_fetch(url):
    """Check robots.txt - be lenient if can't check"""
    try:
        parsed = urlparse(url)
        base = f"{parsed.scheme}://{parsed.netloc}"
        
        if base not in _robots_cache:
            rp = RobotFileParser()
            rp.set_url(f"{base}/robots.txt")
            rp.read()
            _robots_cache[base] = rp
        
        rp = _robots_cache[base]
        # Be more lenient - only block if explicitly disallowed
        return rp.can_fetch('*', url)
    except:
        return True  # Allow if can't check


def polite_delay():
    time.sleep(random.uniform(*REQUEST_DELAY))


# ─────────────────────────────────────────────────────────────
# FETCHING FUNCTIONS
# ─────────────────────────────────────────────────────────────
def fetch_html(url, skip_robots=False):
    """Fetch HTML content from URL"""
    if not skip_robots and not can_fetch(url):
        print(f"   ⛔ Blocked by robots.txt: {url[:50]}...")
        return None
    
    try:
        polite_delay()
        session = requests.Session()
        response = session.get(url, headers=HEADERS, timeout=30, allow_redirects=True)
        response.raise_for_status()
        return response.text
    except requests.exceptions.Timeout:
        print(f"   ⏱️  Timeout: {url[:50]}...")
        return None
    except requests.exceptions.HTTPError as e:
        print(f"   ❌ HTTP {e.response.status_code}: {url[:50]}...")
        return None
    except Exception as e:
        print(f"   ❌ Failed: {url[:50]}... - {str(e)[:30]}")
        return None


def fetch_pdf(url):
    """Fetch and extract text from PDF"""
    try:
        polite_delay()
        response = requests.get(url, headers=HEADERS, timeout=30)
        response.raise_for_status()
        
        content = response.content
        text = ""
        
        try:
            import io
            import PyPDF2
            pdf_reader = PyPDF2.PdfReader(io.BytesIO(content))
            for page in pdf_reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
        except ImportError:
            # Fallback: extract readable strings
            text = re.sub(rb'[^\x20-\x7E\n]', b' ', content).decode('utf-8', errors='ignore')
            text = ' '.join(text.split())
        except Exception as e:
            print(f"   ⚠️  PDF parse error: {str(e)[:30]}")
            return None
        
        return text if len(text) > 100 else None
    except Exception as e:
        print(f"   ❌ PDF failed: {url[:50]}... - {str(e)[:30]}")
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
                         'aside', 'form', 'iframe', 'noscript', 'ad', 
                         '.advertisement', '.sidebar', '.comments']):
            if hasattr(tag, 'decompose'):
                tag.decompose()
        
        # Try to find main content
        main_content = None
        for selector in ['article', 'main', '[role="main"]', '.content', 
                        '.article-body', '.post-content', '#content',
                        '.entry-content', '.article-content']:
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
        lines = [line.strip() for line in text.split('\n') if line.strip() and len(line.strip()) > 10]
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


def extract_article(url, skip_robots=False):
    """Try multiple extraction methods"""
    # Method 1: newspaper3k (best for news/blog articles)
    result = extract_with_newspaper(url)
    if result and len(result.get('text', '')) > 300:
        return result
    
    # Method 2: Fetch HTML and try readability
    html = fetch_html(url, skip_robots=skip_robots)
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
# AGE GROUP DETECTION
# ─────────────────────────────────────────────────────────────
def detect_age_groups(text, topic_age_groups):
    """Detect which age groups the content is relevant for"""
    text_lower = text.lower()
    detected = []
    
    # Check each age group
    for age_group, keywords in AGE_KEYWORDS.items():
        if age_group not in topic_age_groups:
            continue
        score = sum(1 for kw in keywords if kw in text_lower)
        if score >= 1:
            detected.append(age_group)
    
    # If no specific age detected, use all topic age groups
    if not detected:
        detected = list(topic_age_groups.keys())
    
    return detected


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
        r'Advertisement.*',
        r'Loading\.\.\.',
    ]
    for pattern in boilerplate:
        text = re.sub(pattern, '', text, flags=re.IGNORECASE)
    
    return text.strip()


def save_article(record, topic_id, age_groups):
    """Save scraped article to multiple locations"""
    fp = record.get('fingerprint', fingerprint(record.get('text', '')[:1000]))
    record['fingerprint'] = fp
    record['age_groups'] = age_groups
    
    # Save to raw directory
    raw_path = os.path.join(RAW_DIR, f"{fp}.json")
    with open(raw_path, 'w', encoding='utf-8') as f:
        json.dump(record, f, indent=2, ensure_ascii=False)
    
    # Save to topic directory
    topic_path = os.path.join(TOPIC_DIR, topic_id)
    os.makedirs(topic_path, exist_ok=True)
    with open(os.path.join(topic_path, f"{fp}.json"), 'w', encoding='utf-8') as f:
        json.dump(record, f, indent=2, ensure_ascii=False)
    
    # Save to each age group directory
    for age in age_groups:
        age_path = os.path.join(AGE_DIR, age.replace("-", "_"))
        os.makedirs(age_path, exist_ok=True)
        with open(os.path.join(age_path, f"{fp}.json"), 'w', encoding='utf-8') as f:
            json.dump(record, f, indent=2, ensure_ascii=False)
    
    return fp


# ─────────────────────────────────────────────────────────────
# MAIN SCRAPING FUNCTION
# ─────────────────────────────────────────────────────────────
def scrape_topic(topic_id, topic_data):
    """Scrape all URLs for a single topic"""
    title = topic_data.get('title', topic_id)
    description = topic_data.get('description', '')
    age_groups = topic_data.get('age_groups', {})
    urls = topic_data.get('urls', [])
    pdfs = topic_data.get('pdfs', [])
    
    print(f"\n{'='*60}")
    print(f"📚 TOPIC: {title}")
    print(f"   {description}")
    print(f"{'='*60}")
    print(f"   Age groups: {list(age_groups.keys())}")
    print(f"   URLs to scrape: {len(urls)}")
    print(f"   PDFs to scrape: {len(pdfs)}")
    
    collected = []
    
    # Scrape regular URLs
    for i, url in enumerate(urls, 1):
        print(f"\n   [{i}/{len(urls)}] {url[:55]}...")
        
        # Try with robots check first, then without if fails
        article = extract_article(url, skip_robots=False)
        if not article:
            article = extract_article(url, skip_robots=True)
        
        if not article:
            print(f"      ⚠️  Could not extract content")
            continue
        
        # Clean and validate
        article['text'] = clean_text(article.get('text', ''))
        if len(article['text']) < 200:
            print(f"      ⚠️  Content too short ({len(article['text'])} chars)")
            continue
        
        # Detect age groups
        detected_ages = detect_age_groups(article['text'], age_groups)
        
        # Build record
        record = {
            'url': url,
            'topic_id': topic_id,
            'topic_title': title,
            'scraped_at': datetime.now().isoformat(),
            'source_type': 'web',
            **article
        }
        
        fp = save_article(record, topic_id, detected_ages)
        collected.append(record)
        ages_str = ', '.join(detected_ages)
        print(f"      ✅ Saved: {article.get('title', 'Untitled')[:35]}...")
        print(f"         Ages: [{ages_str}] | {len(article['text'])} chars")
    
    # Scrape PDFs
    for i, url in enumerate(pdfs, 1):
        print(f"\n   [PDF {i}/{len(pdfs)}] {url[:55]}...")
        
        text = fetch_pdf(url)
        if not text or len(text) < 200:
            print(f"      ⚠️  Could not extract PDF content")
            continue
        
        text = clean_text(text)
        detected_ages = detect_age_groups(text, age_groups)
        
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
        
        fp = save_article(record, topic_id, detected_ages)
        collected.append(record)
        ages_str = ', '.join(detected_ages)
        print(f"      ✅ Saved PDF: {len(text)} chars | Ages: [{ages_str}]")
    
    print(f"\n   📊 Topic '{title}': {len(collected)} articles collected")
    return collected


def scrape_all():
    """Scrape all curated URLs for all topics"""
    print("\n" + "="*60)
    print("🚀 PARENTBUD ENHANCED SCRAPER V2")
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
                'description': CURATED_URLS[tid].get('description', ''),
                'age_groups': list(CURATED_URLS[tid].get('age_groups', {}).keys()),
                'count': len(articles),
                'urls_attempted': len(CURATED_URLS[tid].get('urls', [])) + len(CURATED_URLS[tid].get('pdfs', []))
            }
            for tid, articles in all_results.items()
        }
    }
    
    summary_path = os.path.join(DATA_DIR, 'scrape_summary_v2.json')
    with open(summary_path, 'w') as f:
        json.dump(summary, f, indent=2)
    
    # Print summary
    print("\n" + "="*60)
    print("✅ SCRAPING COMPLETE")
    print("="*60)
    for tid, articles in all_results.items():
        title = CURATED_URLS[tid].get('title', tid)
        attempted = len(CURATED_URLS[tid].get('urls', [])) + len(CURATED_URLS[tid].get('pdfs', []))
        ages = list(CURATED_URLS[tid].get('age_groups', {}).keys())
        print(f"   {title}: {len(articles)}/{attempted} articles | Ages: {ages}")
    print(f"\n   Total: {total_collected} articles collected")
    print(f"   Data saved to: {DATA_DIR}")
    
    return all_results


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
        topic = sys.argv[1]
        scrape_single_topic(topic)
    else:
        scrape_all()
