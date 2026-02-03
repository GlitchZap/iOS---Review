"""
ParentBud Web Scraper
---------------------
Collects parenting knowledge from trusted sources.
This is Step 1 of the pipeline:
  Scrape → AI Summarize → Store → Show in App

The scraped content is raw knowledge, NOT shown directly in the app.
AI will rewrite it into 5 actionable cards per topic.
"""

import requests
from bs4 import BeautifulSoup
from readability import Document
from newspaper import Article
import json
import os
import hashlib
import time
import random
from urllib.parse import urljoin, urlparse
from urllib.robotparser import RobotFileParser
from tqdm import tqdm

# ─────────────────────────────────────────────────────────────
# DIRECTORIES
# ─────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(__file__)
RAW_DATA_DIR = os.path.join(BASE_DIR, "data", "raw")
TOPIC_DATA_DIR = os.path.join(BASE_DIR, "data", "by_topic")
os.makedirs(RAW_DATA_DIR, exist_ok=True)
os.makedirs(TOPIC_DATA_DIR, exist_ok=True)

# ─────────────────────────────────────────────────────────────
# LOAD CONFIGS
# ─────────────────────────────────────────────────────────────
with open(os.path.join(BASE_DIR, 'sources.json'), 'r') as f:
    SOURCES = json.load(f)

with open(os.path.join(BASE_DIR, 'topics.json'), 'r') as f:
    TOPICS = json.load(f)

# ─────────────────────────────────────────────────────────────
# SETTINGS
# ─────────────────────────────────────────────────────────────
HEADERS = {
    'User-Agent': 'ParentBudBot/1.0 (Educational; +https://parentbud.app; non-commercial)'
}
REQUEST_DELAY = (1, 3)  # Random delay between requests (seconds)
MAX_ARTICLES_PER_TOPIC = 20  # Collect up to N articles per topic


# ─────────────────────────────────────────────────────────────
# ROBOTS.TXT CHECKER
# ─────────────────────────────────────────────────────────────
_robots_cache = {}

def can_fetch(url):
    """Check if we're allowed to fetch this URL per robots.txt"""
    parsed = urlparse(url)
    base = f"{parsed.scheme}://{parsed.netloc}"
    
    if base not in _robots_cache:
        rp = RobotFileParser()
        rp.set_url(f"{base}/robots.txt")
        try:
            rp.read()
            _robots_cache[base] = rp
        except:
            _robots_cache[base] = None
    
    rp = _robots_cache[base]
    if rp is None:
        return True  # No robots.txt, assume allowed
    return rp.can_fetch(HEADERS['User-Agent'], url)


def polite_delay():
    """Be polite: wait between requests"""
    time.sleep(random.uniform(*REQUEST_DELAY))


# ─────────────────────────────────────────────────────────────
# FETCHING & EXTRACTION
# ─────────────────────────────────────────────────────────────
def fetch_url(url):
    """Fetch URL content with error handling"""
    if not can_fetch(url):
        print(f"⛔ Blocked by robots.txt: {url}")
        return None
    try:
        polite_delay()
        resp = requests.get(url, headers=HEADERS, timeout=15)
        resp.raise_for_status()
        return resp.text
    except Exception as e:
        print(f"❌ Failed to fetch {url}: {e}")
        return None


def extract_article(url):
    """Extract article content using newspaper3k, fallback to readability"""
    # Try newspaper3k first (better for news/blog articles)
    try:
        art = Article(url)
        art.download()
        art.parse()
        art.nlp()
        if art.text and len(art.text) > 200:
            return {
                'title': art.title,
                'authors': art.authors,
                'publish_date': art.publish_date.isoformat() if art.publish_date else None,
                'summary': art.summary if hasattr(art, 'summary') else None,
                'text': art.text,
                'extraction_method': 'newspaper3k'
            }
    except Exception as e:
        pass
    
    # Fallback: readability
    try:
        html = fetch_url(url)
        if not html:
            return None
        doc = Document(html)
        soup = BeautifulSoup(doc.summary(), 'lxml')
        text = soup.get_text(separator='\n').strip()
        if text and len(text) > 200:
            return {
                'title': doc.title(),
                'text': text,
                'extraction_method': 'readability'
            }
    except Exception as e:
        print(f"❌ Extraction failed for {url}: {e}")
    
    return None


# ─────────────────────────────────────────────────────────────
# UTILITIES
# ─────────────────────────────────────────────────────────────
def fingerprint(text):
    """Create unique hash of content"""
    return hashlib.sha256(text.encode('utf-8')).hexdigest()[:16]


def matches_topic(text, topic):
    """Check if article text matches topic keywords"""
    text_lower = text.lower()
    keywords = topic.get('keywords', [])
    # Must match at least 2 keywords for relevance
    matches = sum(1 for kw in keywords if kw.lower() in text_lower)
    return matches >= 2


def save_raw_article(record, topic_id):
    """Save article to raw storage"""
    fid = record.get('fingerprint', fingerprint(record.get('text', '')[:1000]))
    
    # Save to raw directory
    raw_path = os.path.join(RAW_DATA_DIR, f"{fid}.json")
    with open(raw_path, 'w') as f:
        json.dump(record, f, ensure_ascii=False, indent=2)
    
    # Also organize by topic
    topic_dir = os.path.join(TOPIC_DATA_DIR, topic_id)
    os.makedirs(topic_dir, exist_ok=True)
    topic_path = os.path.join(topic_dir, f"{fid}.json")
    with open(topic_path, 'w') as f:
        json.dump(record, f, ensure_ascii=False, indent=2)
    
    return raw_path


# ─────────────────────────────────────────────────────────────
# SEARCH GOOGLE FOR TOPIC (Simulated with direct URLs)
# ─────────────────────────────────────────────────────────────
def build_search_urls(topic, source):
    """Build search URLs for a topic on a source"""
    domain = source.get('domain', '')
    keywords = topic.get('keywords', [])
    
    # Common article URL patterns
    urls = []
    base = source.get('seed', '')
    
    # Try common paths with keywords
    for kw in keywords[:3]:  # Use top 3 keywords
        kw_slug = kw.replace(' ', '-').lower()
        kw_path = kw.replace(' ', '+').lower()
        
        urls.extend([
            f"{base}search?q={kw_path}",
            f"{base}topics/{kw_slug}",
            f"{base}{kw_slug}",
            f"{base}articles/{kw_slug}",
        ])
    
    return urls


def discover_articles_from_page(url, source_domain):
    """Find article links from a page"""
    html = fetch_url(url)
    if not html:
        return []
    
    soup = BeautifulSoup(html, 'lxml')
    links = set()
    
    for a in soup.find_all('a', href=True):
        href = a['href']
        
        # Normalize relative URLs
        if href.startswith('/'):
            parsed = urlparse(url)
            href = f"{parsed.scheme}://{parsed.netloc}{href}"
        
        # Only keep links from same domain
        if source_domain not in href:
            continue
        
        # Filter for article-like URLs
        if any(pattern in href.lower() for pattern in [
            '/article', '/articles', '/advice', '/tips', 
            '/how-to', '/guide', '/help', '/parenting',
            '/toddler', '/child', '/baby', '/kids'
        ]):
            links.add(href.split('#')[0].split('?')[0])  # Remove fragments & query
    
    return list(links)


# ─────────────────────────────────────────────────────────────
# MAIN SCRAPING LOGIC
# ─────────────────────────────────────────────────────────────
def scrape_topic(topic):
    """Scrape articles for a single topic from all sources"""
    topic_id = topic['id']
    topic_title = topic['title']
    
    print(f"\n{'='*60}")
    print(f"📚 TOPIC: {topic_title}")
    print(f"{'='*60}")
    
    collected = []
    seen_fingerprints = set()
    
    for source in SOURCES:
        source_name = source.get('name', source.get('domain'))
        print(f"\n🌐 Source: {source_name}")
        
        # Get URLs to explore
        search_urls = build_search_urls(topic, source)
        
        # Collect article links
        article_urls = set()
        for search_url in search_urls[:5]:  # Limit searches per source
            found = discover_articles_from_page(search_url, source.get('domain', ''))
            article_urls.update(found)
            if len(article_urls) >= 50:
                break
        
        print(f"   Found {len(article_urls)} potential article URLs")
        
        # Extract articles
        for url in tqdm(list(article_urls)[:30], desc=f"   Extracting"):
            if len(collected) >= MAX_ARTICLES_PER_TOPIC:
                break
            
            article = extract_article(url)
            if not article or not article.get('text'):
                continue
            
            # Check topic relevance
            if not matches_topic(article['text'], topic):
                continue
            
            # Deduplicate
            fp = fingerprint(article['text'][:2000])
            if fp in seen_fingerprints:
                continue
            seen_fingerprints.add(fp)
            
            # Build record
            record = {
                'url': url,
                'source': source_name,
                'topic_id': topic_id,
                'fingerprint': fp,
                'scraped_at': time.strftime('%Y-%m-%dT%H:%M:%SZ'),
                **article
            }
            
            save_raw_article(record, topic_id)
            collected.append(record)
            print(f"   ✅ Collected: {article.get('title', 'Untitled')[:50]}...")
        
        if len(collected) >= MAX_ARTICLES_PER_TOPIC:
            print(f"   ✓ Reached limit of {MAX_ARTICLES_PER_TOPIC} articles")
            break
    
    print(f"\n📊 Total collected for '{topic_title}': {len(collected)} articles")
    return collected


def scrape_all_topics():
    """Scrape all topics defined in topics.json"""
    print("\n" + "="*60)
    print("🚀 PARENTBUD SCRAPER - Starting")
    print("="*60)
    print(f"Topics to scrape: {len(TOPICS)}")
    print(f"Sources available: {len(SOURCES)}")
    
    all_results = {}
    
    for topic in TOPICS:
        results = scrape_topic(topic)
        all_results[topic['id']] = {
            'topic': topic,
            'articles': results,
            'count': len(results)
        }
    
    # Save summary
    summary_path = os.path.join(BASE_DIR, "data", "scrape_summary.json")
    with open(summary_path, 'w') as f:
        summary = {
            'scraped_at': time.strftime('%Y-%m-%dT%H:%M:%SZ'),
            'topics': {tid: {'title': d['topic']['title'], 'count': d['count']} 
                       for tid, d in all_results.items()}
        }
        json.dump(summary, f, indent=2)
    
    print("\n" + "="*60)
    print("✅ SCRAPING COMPLETE")
    print("="*60)
    for tid, data in all_results.items():
        print(f"   {data['topic']['title']}: {data['count']} articles")
    print(f"\nRaw data saved to: {RAW_DATA_DIR}")
    print(f"By-topic data saved to: {TOPIC_DATA_DIR}")
    
    return all_results


# ─────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────
if __name__ == '__main__':
    scrape_all_topics()
