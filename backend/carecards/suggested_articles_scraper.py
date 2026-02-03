"""
ParentBud Suggested Articles Scraper
------------------------------------
Scrapes curated article URLs and generates AI summaries using Gemini API.
Output is used for the "Suggested Articles" section in the app.

Usage:
    python3 suggested_articles_scraper.py              # Scrape all
    python3 suggested_articles_scraper.py sleep        # Scrape single category
    python3 suggested_articles_scraper.py --dry-run    # Test without API calls
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
from datetime import datetime

# ─────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(__file__)
DATA_DIR = os.path.join(BASE_DIR, "data")
ARTICLES_DIR = os.path.join(DATA_DIR, "suggested_articles")
os.makedirs(ARTICLES_DIR, exist_ok=True)

# Gemini API Configuration
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY', "AIzaSyDZvASZsvPn9zkhUFn5-0EcV4OfdRwpG-E")
GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
USE_AI_SUMMARIES = False  # Set to True when API quota is available

# Request settings
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
}
REQUEST_DELAY = (1.0, 2.0)

# ─────────────────────────────────────────────────────────────
# SUGGESTED ARTICLES URLS BY CATEGORY
# ─────────────────────────────────────────────────────────────
SUGGESTED_URLS = {
    "sleep": {
        "title": "Sleep & Bedtime",
        "emoji": "🌙",
        "color": "#6B5B95",
        "urls": [
            "https://www.brown.edu/news/2025-10-02/kids-sleep-study",
            "https://www.sleepfoundation.org/children-and-sleep/bedtime-routine",
            "https://raisingchildren.net.au/toddlers/sleep/better-sleep-settling/bedtime-routines",
            "https://www.themanthanschool.co.in/blog/bedtime-routines-that-help-kids-sleep-better/",
            "https://www.frontiersin.org/journals/sleep/articles/10.3389/frsle.2025.1722530/full",
            "https://www.healthychildren.org/English/healthy-living/sleep/Pages/healthy-sleep-habits-how-many-hours-does-your-child-need.aspx",
            "https://www.seattlechildrens.org/health-safety/nutrition-wellness/good-night-sleep-routine/",
            "https://www.chop.edu/primary-care/healthy-sleep-habits",
            "https://www.babysleepscience.com"
        ]
    },
    "tantrums": {
        "title": "Tantrums & Behavior",
        "emoji": "🌪️",
        "color": "#F7786B",
        "urls": [
            "https://www.zerotothree.org/resource/toddlers-and-challenging-behavior-why-they-do-it-and-how-to-respond/",
            "https://www.zerotothree.org/resource/toddler-tantrums-101-why-they-happen-and-what-you-can-do/",
            "https://www.zerotothree.org/resource/toddler-tantrums/",
            "https://www.zerotothree.org/resource/pro-tips-for-managing-toddler-tantrums/",
            "https://www.zerotothree.org/resource/your-calm-is-their-calm-co-regulation-strategies-for-infants-and-toddlers/",
            "https://www.zerotothree.org/resource/coping-with-defiance-birth-to-three-years/",
            "https://www.zerotothree.org/resource/aggressive-behavior-in-toddlers/",
            "https://www.zerotothree.org/resource/helping-young-toddlers-cope-with-limits/",
            "https://www.zerotothree.org/resource/challenging-behavior/",
            "https://www.zerotothree.org/resource/developing-self-control-from-24-36-months/",
            "https://behavioralhealthnews.org/supporting-childhood-behavior-early-strategies-for-success/",
            "https://www.biglittlefeelings.com",
            "https://www.positivediscipline.com",
            "https://www.childmind.org"
        ]
    },
    "screen_time": {
        "title": "Screen Time",
        "emoji": "📱",
        "color": "#88B04B",
        "urls": [
            "https://www.healthychildren.org/English/tips-tools/ask-the-pediatrician/Pages/is-screen-time-ok-for-young-children-on-a-long-flight-to-help-keep-them-calm.aspx",
            "https://www.healthychildren.org/English/tips-tools/healthy-children-podcast/Pages/ep-045%E2%80%93video-games-choosing-kid-friendly-games.aspx",
            "https://www.healthychildren.org/English/family-life/Media/Pages/school-cell-phone-policies-tips-for-families.aspx",
            "https://www.commonsensemedia.org",
            "https://www.aap.org/en/patient-care/media-and-children/center-of-excellence-on-social-media-and-youth-mental-health/qa-portal/qa",
            "https://www.cdc.gov/childrensmentalhealth"
        ]
    },
    "eating": {
        "title": "Healthy Eating",
        "emoji": "🥗",
        "color": "#009B77",
        "urls": [
            "https://pmc.ncbi.nlm.nih.gov/articles/PMC6398579/",
            "https://onlinelibrary.wiley.com/doi/full/10.1002/fsn3.70967",
            "https://youthclinic.com/getting-picky-eaters-eat-healthy/",
            "https://www.chop.edu/news/dos-and-donts-feeding-picky-eaters",
            "https://www.kauveryhospital.com/blog/paediatrics/dinner-habits-and-kids-disinterest-in-food/",
            "https://pallaviqslimfitness.com/blog/how-to-build-healthy-eating-habits-in-kids-indian-nutritionist-tips/",
            "https://www.complan.in/health-nutrition/healthy-eating-habits-for-kids/",
            "https://www.myplate.gov",
            "https://www.eatright.org",
            "https://www.nutritionforkids.ca"
        ]
    },
    "potty_training": {
        "title": "Potty Training",
        "emoji": "🚽",
        "color": "#EFC050",
        "urls": [
            "https://www.contemporarypediatrics.com/view/study-potty-training-challenges-common-with-anxiety-and-setbacks-affecting-many-fami",
            "https://babylovenappies.com.au/blog/top-three-toilet-training-techniques-in-2025",
            "https://parentingscience.com/potty-training-tips/",
            "https://www.ucc-today.com/journals/issue/launch-edition/article/back-track-tackling-problem-toilet-training",
            "https://www.nationwidechildrens.org/family-resources-education/700childrens/2018/03/6-things-every-parent-should-know-about-toilet-training",
            "https://www.healthychildren.org/english/ages-stages/toddler/toilet-training/pages/creating-a-toilet-training-plan.aspx",
            "https://www.healthychildren.org/English/ages-stages/toddler/toilet-training/Pages/the-right-age-to-toilet-train.aspx",
            "https://www.healthychildren.org/English/ages-stages/toddler/toilet-training/Pages/Praise-and-Reward-Your-Childs-Success.aspx",
            "https://www.healthychildren.org/English/ages-stages/toddler/toilet-training/Pages/How-to-Tell-When-Your-Child-is-Ready.aspx",
            "https://www.healthychildren.org/English/ages-stages/toddler/toilet-training/Pages/default.aspx",
            "https://www.whattoexpect.com",
            "https://www.positivepotty.com"
        ]
    },
    "social_skills": {
        "title": "Social Skills & Friendships",
        "emoji": "👥",
        "color": "#DD4124",
        "urls": [
            "https://ccaeducate.me/blog/how-to-help-child-with-social-skills/",
            "https://www.edweek.org/leadership/want-to-improve-tweens-social-skills-enlist-senior-citizens-help/2026/01",
            "https://raisingchildren.net.au/school-age/behaviour/behaviour-management-tips-tools/changing-environment",
            "https://fairgaze.com/educationnews/future-skills-students-need-2026-for-changing-world-now.html",
            "https://cisedu.com/en-gb/world-of-cis/news/education_in_2025_2026_9_trends/",
            "https://raisingchildren.net.au/school-age/connecting-communicating/connecting/supporting-friendships",
            "https://www.friendshipcircle.com/friendship-skills-every-child-needs-and-how-to-build-them/",
            "https://sunshine-parenting.com/10-friendship-skills-every-kid-needs/",
            "https://healthmatters.nyp.org/how-parents-can-help-their-kids-make-strong-friendships/",
            "https://www.sws.ac.in/blog/social-skills-for-young-learners-building-friendships-and-teamwork",
            "https://www.childmind.org",
            "https://www.psychologytoday.com"
        ]
    },
    "separation_anxiety": {
        "title": "Separation Anxiety",
        "emoji": "🤗",
        "color": "#B565A7",
        "urls": [
            "https://www.indiatoday.in/education-today/parenting-toddlers/story/helping-kids-overcome-separation-anxiety-tips-for-their-first-day-of-school",
            "https://www.childrensmercy.org/parent-ish/2025/09/separation-anxiety/",
            "https://themeadows.net/blog/separation-anxiety-in-children-parental-guide/",
            "https://counselclinic.com/blog/sepanx/",
            "https://www.healthychildren.org/English/ages-stages/toddler/Pages/Soothing-Your-Childs-Separation-Anxiety.aspx",
            "https://www.anxietycanada.com/learn-about-anxiety/anxiety-in-children/",
            "https://www.anxietycanada.com/anxiety-disorder/separation-anxiety/",
            "https://www.anxietycanada.com/wp-content/uploads/2019/08/hm_Separation.pdf",
            "https://www.anxietycanada.com/downloadables/helping-your-child-sleep-alone-or-away-from-home/",
            "https://www.anxietycanada.com/wp-content/uploads/2019/08/CopingwithBacktoSchool.pdf",
            "https://www.heretohelp.bc.ca/infosheet/separation-anxiety-disorder",
            "https://www.stanfordchildrens.org/en/topic/default?id=separation-anxiety-disorder-in-children-90-P02582",
            "https://www.anxietycanada.com/sites/default/files/dealing_with_co_sleeping.pdf",
            "https://www.anxietycanada.com/wp-content/uploads/2018/08/Separation-Anxiety-Doc-FINAL-2.pdf"
        ]
    },
    "behavior_management": {
        "title": "Behavior Management",
        "emoji": "⭐",
        "color": "#5B5EA6",
        "urls": [
            "https://behavioralhealthnews.org/supporting-childhood-behavior-early-strategies-for-success/",
            "https://www.positiveaction.net/blog/behavior-management-strategies",
            "https://raisingchildren.net.au/school-age/behaviour/behaviour-management-tips-tools/changing-environment",
            "https://www.rasmussen.edu/degrees/education/blog/early-childhood-behavior-management-strategies/",
            "https://www.jocpd.com/articles/10.22514/jocpd.2025.091",
            "https://www.positivediscipline.com",
            "https://www.handinhandparenting.com",
            "https://www.biglittlefeelings.com",
            "https://www.childmind.org",
            "https://kidsusamontessori.org/what-are-the-most-effective-behavior-management-strategies-in-early-childhood/",
            "https://headstart.gov/mental-health/article/understanding-managing-childrens-behaviors",
            "https://parentingmatters.in/programs/workshops",
            "https://www.zerotothree.org/resource/helping-young-toddlers-cope-with-limits/",
            "https://www.zerotothree.org/resource/challenging-behavior/",
            "https://prism.ku.edu/project/child-mind-institute-managing-child-behavior-at-home/"
        ]
    }
}


# ─────────────────────────────────────────────────────────────
# GEMINI API FUNCTIONS
# ─────────────────────────────────────────────────────────────
GEMINI_DELAY = 2.0  # Delay between Gemini API calls to avoid rate limits
GEMINI_MAX_RETRIES = 3

def generate_summary_with_gemini(title: str, content: str, category: str, retry_count: int = 0) -> dict:
    """
    Use Gemini API to generate article summary for Suggested Articles section.
    Returns: { summary, key_takeaways, reading_time, age_groups }
    """
    # Rate limiting delay
    time.sleep(GEMINI_DELAY)
    
    # Truncate content to avoid token limits
    content_truncated = content[:6000] if len(content) > 6000 else content
    
    prompt = f"""You are a parenting expert summarizing an article for the ParentBud app's "Suggested Articles" section.

Article Title: {title}
Category: {category}

Article Content:
{content_truncated}

Please provide:
1. A concise 2-3 sentence summary (max 150 words) that parents can quickly read
2. 3 key takeaways as bullet points (actionable tips)
3. Estimated reading time for the full article (in minutes)
4. Which age groups this is most relevant for (choose from: 2-4, 4-6, 6-8, 8-10)

Return as JSON:
{{
    "summary": "Brief engaging summary...",
    "key_takeaways": ["Takeaway 1", "Takeaway 2", "Takeaway 3"],
    "reading_time_minutes": 5,
    "age_groups": ["2-4", "4-6"],
    "tone": "informative"
}}

Be warm, supportive, and practical. Focus on what parents can actually do."""

    try:
        response = requests.post(
            f"{GEMINI_API_URL}?key={GEMINI_API_KEY}",
            headers={'Content-Type': 'application/json'},
            json={
                "contents": [
                    {
                        "parts": [
                            {"text": prompt}
                        ]
                    }
                ],
                "generationConfig": {
                    "temperature": 0.7,
                    "maxOutputTokens": 1024
                }
            },
            timeout=30
        )
        
        if response.status_code == 429:
            # Rate limited - wait and retry
            if retry_count < GEMINI_MAX_RETRIES:
                wait_time = (retry_count + 1) * 5  # 5s, 10s, 15s
                print(f"      ⏳ Rate limited, waiting {wait_time}s...")
                time.sleep(wait_time)
                return generate_summary_with_gemini(title, content, category, retry_count + 1)
            else:
                print(f"      ❌ Gemini API rate limit exceeded after retries")
                return None
        
        if response.status_code != 200:
            print(f"      ❌ Gemini API error: {response.status_code}")
            return None
        
        data = response.json()
        
        # Extract text from Gemini response
        text = data.get('candidates', [{}])[0].get('content', {}).get('parts', [{}])[0].get('text', '')
        
        # Parse JSON from response
        # Clean up the response - remove markdown code blocks if present
        text = text.strip()
        if text.startswith('```'):
            text = text.split('```')[1]
            if text.startswith('json'):
                text = text[4:]
        text = text.strip()
        
        result = json.loads(text)
        return result
        
    except json.JSONDecodeError as e:
        print(f"      ⚠️  Failed to parse Gemini response as JSON")
        # Return a basic structure with extracted text
        return {
            "summary": text[:300] if text else "Summary unavailable",
            "key_takeaways": ["Read the full article for details"],
            "reading_time_minutes": 5,
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        }
    except Exception as e:
        print(f"      ❌ Gemini API error: {str(e)[:50]}")
        return None


# ─────────────────────────────────────────────────────────────
# SCRAPING FUNCTIONS
# ─────────────────────────────────────────────────────────────
def polite_delay():
    time.sleep(random.uniform(*REQUEST_DELAY))


def fetch_html(url):
    """Fetch HTML content from URL"""
    try:
        polite_delay()
        session = requests.Session()
        response = session.get(url, headers=HEADERS, timeout=30, allow_redirects=True)
        response.raise_for_status()
        return response.text
    except requests.exceptions.Timeout:
        print(f"      ⏱️  Timeout")
        return None
    except requests.exceptions.HTTPError as e:
        print(f"      ❌ HTTP {e.response.status_code}")
        return None
    except Exception as e:
        print(f"      ❌ Failed: {str(e)[:40]}")
        return None


def extract_with_newspaper(url):
    """Extract article using newspaper3k library"""
    try:
        article = Article(url)
        article.download()
        article.parse()
        
        if article.text and len(article.text) > 200:
            return {
                'title': article.title or 'Untitled',
                'text': article.text,
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
        
        # Find main content
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
        lines = [line.strip() for line in text.split('\n') if line.strip() and len(line.strip()) > 10]
        text = '\n'.join(lines)
        
        if len(text) > 200:
            return {
                'title': title or 'Untitled',
                'text': text,
                'method': 'beautifulsoup'
            }
    except Exception as e:
        pass
    return None


def extract_article(url):
    """Try multiple extraction methods"""
    # Skip YouTube and PDF URLs for now
    if 'youtube.com' in url or 'youtu.be' in url:
        return {
            'title': 'YouTube Video',
            'text': 'Video content - watch for parenting tips',
            'is_video': True,
            'method': 'video'
        }
    
    if url.endswith('.pdf'):
        return {
            'title': url.split('/')[-1].replace('.pdf', '').replace('-', ' ').replace('_', ' ').title(),
            'text': 'PDF Document - download for detailed information',
            'is_pdf': True,
            'method': 'pdf'
        }
    
    # Method 1: newspaper3k
    result = extract_with_newspaper(url)
    if result and len(result.get('text', '')) > 300:
        return result
    
    # Method 2: Fetch HTML and try readability
    html = fetch_html(url)
    if html:
        result = extract_with_readability(html, url)
        if result and len(result.get('text', '')) > 300:
            return result
        
        # Method 3: BeautifulSoup
        result = extract_with_beautifulsoup(html, url)
        if result and len(result.get('text', '')) > 300:
            return result
    
    return None


def clean_text(text):
    """Clean extracted text"""
    if not text:
        return ""
    
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = re.sub(r' {2,}', ' ', text)
    
    # Remove boilerplate
    boilerplate = [
        r'Subscribe to our newsletter.*',
        r'Share this article.*',
        r'Follow us on.*',
        r'Cookie policy.*',
        r'Privacy policy.*',
        r'All rights reserved.*',
        r'Copyright ©.*',
    ]
    for pattern in boilerplate:
        text = re.sub(pattern, '', text, flags=re.IGNORECASE)
    
    return text.strip()


def fingerprint(url):
    """Create URL-based fingerprint"""
    return hashlib.sha256(url.encode('utf-8')).hexdigest()[:12]


def create_smart_fallback_summary(title: str, text: str, category: str) -> dict:
    """Create a smart summary from the article content when AI is unavailable"""
    # Get first few sentences for summary
    sentences = re.split(r'[.!?]+', text)
    sentences = [s.strip() for s in sentences if len(s.strip()) > 30]
    
    # Take first 2-3 meaningful sentences as summary
    summary_sentences = sentences[:3] if len(sentences) >= 3 else sentences
    summary = '. '.join(summary_sentences)
    if len(summary) > 250:
        summary = summary[:247] + '...'
    if summary and not summary.endswith('.'):
        summary += '.'
    
    # Extract potential key takeaways (look for bullet points or numbered items)
    takeaways = []
    lines = text.split('\n')
    for line in lines:
        line = line.strip()
        # Look for bullet points or numbered lists
        if re.match(r'^[\d•\-\*]+[\.\)]\s*', line) or line.startswith('•') or line.startswith('-'):
            clean_line = re.sub(r'^[\d•\-\*]+[\.\)]\s*', '', line).strip()
            if 20 < len(clean_line) < 150:
                takeaways.append(clean_line)
        # Also look for short actionable sentences
        elif len(line) > 30 and len(line) < 120 and any(word in line.lower() for word in ['try', 'make sure', 'remember', 'avoid', 'don\'t', 'always', 'never', 'tip:', 'important']):
            takeaways.append(line)
        
        if len(takeaways) >= 3:
            break
    
    # If no takeaways found, create generic ones based on category
    if len(takeaways) < 3:
        category_tips = {
            'sleep': ['Establish a consistent bedtime routine', 'Create a calm sleep environment', 'Limit screens before bed'],
            'tantrums': ['Stay calm during outbursts', 'Validate their feelings', 'Set clear boundaries with empathy'],
            'eating': ['Offer variety without pressure', 'Make mealtimes positive', 'Model healthy eating habits'],
            'potty_training': ['Watch for readiness signs', 'Stay patient and positive', 'Celebrate small successes'],
            'social_skills': ['Practice through play', 'Model kind interactions', 'Give them space to learn'],
            'separation_anxiety': ['Keep goodbyes brief and positive', 'Build trust through consistency', 'Validate their feelings'],
            'behavior_management': ['Focus on positive reinforcement', 'Set clear expectations', 'Stay consistent with rules']
        }
        default_tips = takeaways + category_tips.get(category, ['Read the full article for detailed tips'])
        takeaways = default_tips[:3]
    
    # Estimate reading time (average 200 words per minute)
    word_count = len(text.split())
    reading_time = max(1, round(word_count / 200))
    
    # Guess age groups based on content
    text_lower = text.lower()
    age_groups = []
    if any(word in text_lower for word in ['toddler', 'potty', '2 year', '3 year', 'preschool']):
        age_groups.append('2-4')
    if any(word in text_lower for word in ['preschool', '4 year', '5 year', 'kindergarten']):
        age_groups.append('4-6')
    if any(word in text_lower for word in ['school', '6 year', '7 year', 'elementary', 'homework']):
        age_groups.append('6-8')
    if any(word in text_lower for word in ['tween', '8 year', '9 year', '10 year', 'preteen']):
        age_groups.append('8-10')
    
    if not age_groups:
        age_groups = ['2-4', '4-6', '6-8', '8-10']  # Default to all ages
    
    return {
        'summary': summary if summary else f"Expert guidance on {title.lower()}. Read the full article for comprehensive tips and strategies.",
        'key_takeaways': takeaways[:3],
        'reading_time_minutes': reading_time,
        'age_groups': age_groups
    }


# ─────────────────────────────────────────────────────────────
# MAIN SCRAPING FUNCTION
# ─────────────────────────────────────────────────────────────
def scrape_category(category_id: str, category_data: dict, dry_run: bool = False) -> list:
    """Scrape all URLs for a single category and generate Gemini summaries"""
    title = category_data.get('title', category_id)
    emoji = category_data.get('emoji', '📖')
    color = category_data.get('color', '#333333')
    urls = category_data.get('urls', [])
    
    print(f"\n{'='*60}")
    print(f"{emoji} CATEGORY: {title}")
    print(f"{'='*60}")
    print(f"   URLs to scrape: {len(urls)}")
    
    articles = []
    
    for i, url in enumerate(urls, 1):
        domain = urlparse(url).netloc
        print(f"\n   [{i}/{len(urls)}] {domain}")
        
        # Extract article content
        article = extract_article(url)
        
        if not article:
            print(f"      ⚠️  Could not extract content")
            continue
        
        article['text'] = clean_text(article.get('text', ''))
        
        if article.get('is_video') or article.get('is_pdf'):
            # Skip AI summary for video/PDF but still include
            record = {
                'id': fingerprint(url),
                'url': url,
                'domain': domain,
                'category_id': category_id,
                'category_title': title,
                'title': article.get('title', 'Untitled'),
                'is_video': article.get('is_video', False),
                'is_pdf': article.get('is_pdf', False),
                'summary': article.get('text', ''),
                'key_takeaways': [],
                'reading_time_minutes': 0,
                'age_groups': ["2-4", "4-6", "6-8", "8-10"],
                'emoji': emoji,
                'color': color,
                'scraped_at': datetime.now().isoformat()
            }
            articles.append(record)
            print(f"      📎 {'Video' if article.get('is_video') else 'PDF'}: {article.get('title', 'Untitled')[:40]}...")
            continue
        
        print(f"      📄 Extracted: {article.get('title', 'Untitled')[:40]}...")
        print(f"         Content: {len(article.get('text', ''))} chars")
        
        # Generate summary with Gemini
        if dry_run:
            summary_data = {
                "summary": f"[DRY RUN] Summary for: {article.get('title', 'Untitled')}",
                "key_takeaways": ["Takeaway 1", "Takeaway 2", "Takeaway 3"],
                "reading_time_minutes": 5,
                "age_groups": ["2-4", "4-6"]
            }
        elif USE_AI_SUMMARIES:
            print(f"      🤖 Generating Gemini summary...")
            summary_data = generate_summary_with_gemini(
                article.get('title', 'Untitled'),
                article.get('text', ''),
                title
            )
            if summary_data:
                print(f"      ✅ AI Summary generated!")
            else:
                # Fall back to smart extraction
                print(f"      ⚠️  AI unavailable, using smart extraction...")
                summary_data = create_smart_fallback_summary(
                    article.get('title', 'Untitled'),
                    article.get('text', ''),
                    category_id
                )
                print(f"      📝 Smart summary created!")
        else:
            # Skip AI, use smart extraction directly
            summary_data = create_smart_fallback_summary(
                article.get('title', 'Untitled'),
                article.get('text', ''),
                category_id
            )
            print(f"      📝 Summary extracted from content")
        
        # Build final record
        record = {
            'id': fingerprint(url),
            'url': url,
            'domain': domain,
            'category_id': category_id,
            'category_title': title,
            'title': article.get('title', 'Untitled'),
            'authors': article.get('authors', []),
            'publish_date': article.get('publish_date'),
            'top_image': article.get('top_image'),
            'summary': summary_data.get('summary', ''),
            'key_takeaways': summary_data.get('key_takeaways', []),
            'reading_time_minutes': summary_data.get('reading_time_minutes', 5),
            'age_groups': summary_data.get('age_groups', ["2-4", "4-6", "6-8", "8-10"]),
            'emoji': emoji,
            'color': color,
            'full_text_length': len(article.get('text', '')),
            'extraction_method': article.get('method', 'unknown'),
            'scraped_at': datetime.now().isoformat()
        }
        
        articles.append(record)
    
    # Save category articles
    if articles:
        category_path = os.path.join(ARTICLES_DIR, f"{category_id}.json")
        with open(category_path, 'w', encoding='utf-8') as f:
            json.dump(articles, f, indent=2, ensure_ascii=False)
        print(f"\n   💾 Saved: {category_path}")
    
    print(f"\n   📊 Category '{title}': {len(articles)}/{len(urls)} articles processed")
    return articles


def scrape_all(dry_run: bool = False):
    """Scrape all categories"""
    print("\n" + "="*60)
    print("🚀 PARENTBUD SUGGESTED ARTICLES SCRAPER")
    print("="*60)
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Categories: {len(SUGGESTED_URLS)}")
    print(f"Dry run: {dry_run}")
    
    total_urls = sum(len(cat['urls']) for cat in SUGGESTED_URLS.values())
    print(f"Total URLs: {total_urls}")
    
    all_articles = {}
    total_collected = 0
    
    for category_id, category_data in SUGGESTED_URLS.items():
        articles = scrape_category(category_id, category_data, dry_run)
        all_articles[category_id] = articles
        total_collected += len(articles)
    
    # Save master file with all articles
    all_flat = []
    for articles in all_articles.values():
        all_flat.extend(articles)
    
    master_path = os.path.join(ARTICLES_DIR, "all_suggested_articles.json")
    with open(master_path, 'w', encoding='utf-8') as f:
        json.dump(all_flat, f, indent=2, ensure_ascii=False)
    
    # Save summary
    summary = {
        'scraped_at': datetime.now().isoformat(),
        'total_articles': total_collected,
        'categories': {
            cat_id: {
                'title': SUGGESTED_URLS[cat_id]['title'],
                'emoji': SUGGESTED_URLS[cat_id]['emoji'],
                'count': len(articles),
                'urls_attempted': len(SUGGESTED_URLS[cat_id]['urls'])
            }
            for cat_id, articles in all_articles.items()
        }
    }
    
    summary_path = os.path.join(ARTICLES_DIR, "scrape_summary.json")
    with open(summary_path, 'w') as f:
        json.dump(summary, f, indent=2)
    
    # Print summary
    print("\n" + "="*60)
    print("✅ SCRAPING COMPLETE")
    print("="*60)
    for cat_id, articles in all_articles.items():
        cat = SUGGESTED_URLS[cat_id]
        print(f"   {cat['emoji']} {cat['title']}: {len(articles)}/{len(cat['urls'])} articles")
    print(f"\n   Total: {total_collected} articles with Gemini summaries")
    print(f"   Saved to: {ARTICLES_DIR}")
    
    return all_articles


def scrape_single_category(category_id: str, dry_run: bool = False):
    """Scrape a single category"""
    if category_id not in SUGGESTED_URLS:
        print(f"❌ Category '{category_id}' not found!")
        print(f"Available: {list(SUGGESTED_URLS.keys())}")
        return []
    
    return scrape_category(category_id, SUGGESTED_URLS[category_id], dry_run)


# ─────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────
if __name__ == '__main__':
    import sys
    
    dry_run = '--dry-run' in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    
    if args:
        category = args[0]
        scrape_single_category(category, dry_run)
    else:
        scrape_all(dry_run)
