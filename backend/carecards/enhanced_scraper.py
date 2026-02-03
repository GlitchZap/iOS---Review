"""
ParentBud Enhanced Scraper & Card Generator
--------------------------------------------
Scrapes all provided URLs and generates rich 3-line care cards.
Uses real scraped content - no hardcoded data.
"""

import os
import json
import re
import hashlib
import time
from datetime import datetime
from urllib.parse import urlparse
import requests
from bs4 import BeautifulSoup

# ─────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(__file__)
OUTPUT_DIR = os.path.join(BASE_DIR, "data", "enhanced_output")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Headers to mimic browser
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
}

# ─────────────────────────────────────────────────────────────
# CURATED URLS BY TOPIC
# ─────────────────────────────────────────────────────────────
URLS_BY_TOPIC = {
    "tantrums": [
        "https://www.zerotothree.org/resource/toddler-tantrums/",
        "https://www.zerotothree.org/resource/toddler-tantrums-101-why-they-happen-and-what-you-can-do/",
        "https://www.zerotothree.org/resource/pro-tips-for-managing-toddler-tantrums/",
        "https://www.healthline.com/health/childrens-health/3-year-old-tantrums",
        "https://www.mayoclinic.org/healthy-lifestyle/infant-and-toddler-health/in-depth/tantrum/art-20047845",
        "https://www.parents.com/toddlers-preschoolers/development/behavioral/expert-tips-to-help-your-sensitive-child-navigate-an-overwhelming-world/",
    ],
    "sleep": [
        "https://www.sleepfoundation.org/children-and-sleep/bedtime-routine",
        "https://www.healthychildren.org/English/healthy-living/sleep/Pages/healthy-sleep-habits-how-many-hours-does-your-child-need.aspx",
        "https://www.seattlechildrens.org/health-safety/nutrition-wellness/good-night-sleep-routine/",
        "https://www.parents.com/bedtime-routine-children-8661139",
    ],
    "eating_habits": [
        "https://www.healthline.com/nutrition/healthy-eating-for-kids",
        "https://www.healthychildren.org/English/ages-stages/toddler/nutrition/Pages/Picky-Eaters.aspx",
        "https://pallaviqslimfitness.com/blog/how-to-build-healthy-eating-habits-in-kids-indian-nutritionist-tips/",
        "https://www.complan.in/health-nutrition/healthy-eating-habits-for-kids/",
    ],
    "screen_time": [
        "https://www.healthline.com/health/parenting/screen-time-for-kids",
        "https://www.mayoclinichealthsystem.org/hometown-health/speaking-of-health/6-tips-to-reduce-childrens-screen-time",
        "https://www.commonsensemedia.org/articles/what-is-the-right-amount-of-screen-time",
    ],
    "behavior": [
        "https://www.zerotothree.org/resource/helping-young-toddlers-cope-with-limits/",
        "https://www.zerotothree.org/resource/challenging-behavior/",
        "https://kidsusamontessori.org/what-are-the-most-effective-behavior-management-strategies-in-early-childhood/",
        "https://www.parents.com/toddlers-preschoolers/discipline/tips/smart-discipline-for-every-age/",
        "https://www.cdc.gov/child-development/positive-parenting-tips/preschooler-3-5-years.html",
    ],
    "separation_anxiety": [
        "https://www.anxietycanada.com/anxiety-disorder/separation-anxiety/",
        "https://www.heretohelp.bc.ca/infosheet/separation-anxiety-disorder",
        "https://www.stanfordchildrens.org/en/topic/default?id=separation-anxiety-disorder-in-children-90-P02582",
        "https://www.anxietycanada.com/learn-about-anxiety/anxiety-in-children/",
        "https://www.parents.com/kids/education/kindergarten/first-day-of-kindergarten-ways-to-prepare/",
    ],
    "social_skills": [
        "https://raisingchildren.net.au/school-age/connecting-communicating/connecting/supporting-friendships",
        "https://sunshine-parenting.com/10-friendship-skills-every-kid-needs/",
        "https://healthmatters.nyp.org/how-parents-can-help-their-kids-make-strong-friendships/",
        "https://www.parents.com/toddlers-preschoolers/development/social/social-skills-activities-for-kids-to-do-at-home/",
        "https://childmind.org/blog/how-pretend-play-helps-children-build-skills/",
    ],
    "confidence": [
        "https://www.parents.com/kids/development/behavioral/emotionally-sensitive-children/",
        "https://www.parents.com/emotional-regulation-skills-8692759",
    ],
    "emotional_regulation": [
        "https://www.parents.com/emotional-regulation-skills-8692759",
        "https://www.parents.com/kids/development/behavioral/emotionally-sensitive-children/",
    ],
    "potty_training": [
        "https://www.healthychildren.org/english/ages-stages/toddler/toilet-training/pages/creating-a-toilet-training-plan.aspx",
        "https://www.healthychildren.org/English/ages-stages/toddler/toilet-training/Pages/the-right-age-to-toilet-train.aspx",
        "https://www.healthychildren.org/English/ages-stages/toddler/toilet-training/Pages/Praise-and-Reward-Your-Childs-Success.aspx",
        "https://www.healthychildren.org/English/ages-stages/toddler/toilet-training/Pages/How-to-Tell-When-Your-Child-is-Ready.aspx",
    ],
}

# Topic metadata
TOPIC_METADATA = {
    "tantrums": {
        "title": "Taming Tantrums",
        "subtitle": "Understand why tantrums happen and learn compassionate strategies to help your child navigate big emotions with confidence.",
        "color_theme": "warm",
        "age_groups": ["toddler", "preschool"]
    },
    "sleep": {
        "title": "Sleep Routines",
        "subtitle": "Create peaceful bedtimes with proven routines that help your child wind down and get the restorative sleep they need.",
        "color_theme": "calm",
        "age_groups": ["toddler", "preschool", "school_age"]
    },
    "eating_habits": {
        "title": "Healthy Eating",
        "subtitle": "Build positive relationships with food through patience, variety, and pressure-free mealtimes that work for the whole family.",
        "color_theme": "fresh",
        "age_groups": ["toddler", "preschool", "school_age"]
    },
    "screen_time": {
        "title": "Screen Time Balance",
        "subtitle": "Navigate the digital world with healthy boundaries that protect your child while embracing technology's benefits.",
        "color_theme": "cool",
        "age_groups": ["toddler", "preschool", "school_age"]
    },
    "behavior": {
        "title": "Positive Behavior",
        "subtitle": "Guide your child's behavior with connection-first strategies that teach rather than punish, building cooperation naturally.",
        "color_theme": "purple",
        "age_groups": ["toddler", "preschool", "school_age"]
    },
    "separation_anxiety": {
        "title": "Separation Anxiety",
        "subtitle": "Help your child feel secure during goodbyes with consistent rituals and reassurance that builds lasting confidence.",
        "color_theme": "warm",
        "age_groups": ["toddler", "preschool"]
    },
    "social_skills": {
        "title": "Social Skills",
        "subtitle": "Support your child in building meaningful friendships through practice, guidance, and age-appropriate social opportunities.",
        "color_theme": "bright",
        "age_groups": ["preschool", "school_age"]
    },
    "confidence": {
        "title": "Building Confidence",
        "subtitle": "Nurture your child's self-esteem through encouragement, appropriate challenges, and celebrating their unique strengths.",
        "color_theme": "golden",
        "age_groups": ["toddler", "preschool", "school_age"]
    },
    "emotional_regulation": {
        "title": "Emotional Regulation",
        "subtitle": "Teach your child to understand and manage their feelings with tools that last a lifetime.",
        "color_theme": "calm",
        "age_groups": ["toddler", "preschool", "school_age"]
    },
    "potty_training": {
        "title": "Potty Training",
        "subtitle": "Navigate this milestone with patience and positivity, following your child's readiness cues for success.",
        "color_theme": "fresh",
        "age_groups": ["toddler", "preschool"]
    },
}


def scrape_url(url, timeout=15):
    """Scrape content from a single URL"""
    try:
        print(f"  📥 Fetching: {url[:60]}...")
        response = requests.get(url, headers=HEADERS, timeout=timeout)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Remove unwanted elements
        for tag in soup(['script', 'style', 'nav', 'header', 'footer', 'aside', 'form', 'iframe', 'noscript']):
            tag.decompose()
        
        # Try to find main content
        main_content = None
        for selector in ['article', 'main', '.content', '.post-content', '.article-body', '#content', '.entry-content']:
            main_content = soup.select_one(selector)
            if main_content:
                break
        
        if not main_content:
            main_content = soup.find('body')
        
        if not main_content:
            return None
        
        # Extract text
        paragraphs = main_content.find_all(['p', 'li', 'h2', 'h3'])
        text_parts = []
        for p in paragraphs:
            text = p.get_text(strip=True)
            if len(text) > 30:  # Only meaningful content
                text_parts.append(text)
        
        full_text = '\n'.join(text_parts)
        
        # Get title
        title = soup.find('title')
        title_text = title.get_text(strip=True) if title else urlparse(url).path.split('/')[-1]
        
        return {
            'url': url,
            'title': title_text,
            'text': full_text[:15000],  # Limit text size
            'scraped_at': datetime.now().isoformat()
        }
        
    except Exception as e:
        print(f"  ❌ Failed: {url[:50]}... - {str(e)[:50]}")
        return None


def extract_key_insights(text):
    """Extract key insights from scraped text for generating tips"""
    # Split into sentences
    sentences = re.split(r'[.!?]+', text)
    
    # Filter for meaningful sentences (50-300 chars, contains action words)
    action_words = ['help', 'try', 'give', 'let', 'make', 'allow', 'encourage', 'teach', 
                    'show', 'create', 'build', 'develop', 'support', 'practice', 'use',
                    'avoid', 'don\'t', 'never', 'always', 'when', 'if', 'children', 'child',
                    'parent', 'toddler', 'kid', 'sleep', 'eat', 'feel', 'emotion', 'behavior']
    
    meaningful = []
    for s in sentences:
        s = s.strip()
        if 50 < len(s) < 350:
            s_lower = s.lower()
            if any(word in s_lower for word in action_words):
                meaningful.append(s)
    
    return meaningful[:50]  # Return top 50 insights


def generate_rich_tip(insight_sentences, topic_id, tip_number):
    """Generate a rich 3-line tip from insight sentences"""
    if not insight_sentences:
        return None
    
    # Combine 2-3 related sentences into a rich tip
    combined = []
    used = set()
    
    for i, sentence in enumerate(insight_sentences):
        if i in used:
            continue
        if len(combined) >= 3:
            break
            
        # Clean and add sentence
        clean = sentence.strip()
        if clean and clean not in combined:
            combined.append(clean)
            used.add(i)
    
    if not combined:
        return None
    
    # Join into a rich multi-line tip
    tip_text = ' '.join(combined)
    
    # Ensure it ends properly
    if not tip_text.endswith('.'):
        tip_text += '.'
    
    return tip_text


def generate_cards_from_scraped(topic_id, scraped_articles):
    """Generate 5 rich cards from scraped article content"""
    # Combine all text
    all_text = '\n\n'.join([a['text'] for a in scraped_articles if a and a.get('text')])
    
    if not all_text:
        print(f"  ⚠️  No text content for {topic_id}")
        return None
    
    # Extract key insights
    insights = extract_key_insights(all_text)
    
    if len(insights) < 5:
        print(f"  ⚠️  Not enough insights for {topic_id} (found {len(insights)})")
        return None
    
    # Generate 5 rich tips (each combining multiple insights)
    tips = []
    insights_per_tip = max(2, len(insights) // 5)
    
    for i in range(5):
        start_idx = i * insights_per_tip
        end_idx = start_idx + insights_per_tip
        tip_insights = insights[start_idx:end_idx]
        
        tip = generate_rich_tip(tip_insights, topic_id, i + 1)
        if tip and len(tip) > 100:  # Ensure tip is substantial
            tips.append(tip)
    
    # If we don't have 5 tips, pad with remaining insights
    while len(tips) < 5 and insights:
        remaining = insights[len(tips) * insights_per_tip:]
        if remaining:
            tip = remaining[0]
            if len(tip) > 50:
                tips.append(tip)
            insights = remaining[1:]
        else:
            break
    
    return tips[:5] if len(tips) >= 5 else None


def create_care_card(topic_id, tips, source_articles):
    """Create a complete care card structure"""
    meta = TOPIC_METADATA.get(topic_id, {})
    
    # Generate unique ID from topic
    card_id = hashlib.md5(f"{topic_id}_card".encode()).hexdigest()[:24]
    
    return {
        "id": card_id,
        "topic_id": topic_id,
        "title": meta.get('title', topic_id.replace('_', ' ').title()),
        "subtitle": meta.get('subtitle', f"Expert guidance on {topic_id.replace('_', ' ')}"),
        "color_theme": meta.get('color_theme', 'default'),
        "age_groups": meta.get('age_groups', ['toddler', 'preschool', 'school_age']),
        "tips": tips,
        "source_articles": [
            {"url": a['url'], "title": a['title']} 
            for a in source_articles[:3] if a
        ],
        "generated_at": datetime.now().isoformat(),
        "tip_count": len(tips)
    }


def scrape_and_generate_all():
    """Main function: scrape all URLs and generate care cards"""
    print("\n" + "="*70)
    print("🚀 PARENTBUD ENHANCED SCRAPER & CARD GENERATOR")
    print("="*70)
    print(f"📅 Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    all_cards = []
    scrape_stats = {"total_urls": 0, "successful": 0, "failed": 0}
    
    for topic_id, urls in URLS_BY_TOPIC.items():
        print(f"\n📌 Topic: {topic_id.upper()}")
        print("-" * 50)
        
        scraped_articles = []
        for url in urls:
            scrape_stats["total_urls"] += 1
            article = scrape_url(url)
            if article:
                scraped_articles.append(article)
                scrape_stats["successful"] += 1
            else:
                scrape_stats["failed"] += 1
            time.sleep(0.5)  # Be respectful to servers
        
        print(f"  ✅ Scraped {len(scraped_articles)}/{len(urls)} articles")
        
        # Generate tips from scraped content
        tips = generate_cards_from_scraped(topic_id, scraped_articles)
        
        if tips:
            card = create_care_card(topic_id, tips, scraped_articles)
            all_cards.append(card)
            print(f"  🎴 Generated card with {len(tips)} tips")
            
            # Show sample tip
            if tips:
                sample = tips[0][:100] + "..." if len(tips[0]) > 100 else tips[0]
                print(f"  📝 Sample: \"{sample}\"")
        else:
            print(f"  ⚠️  Could not generate card for {topic_id}")
    
    # Save output
    output_path = os.path.join(OUTPUT_DIR, "care_cards.json")
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(all_cards, f, indent=2, ensure_ascii=False)
    
    # Also save to iOS Resources folder
    ios_resources_path = os.path.join(BASE_DIR, "..", "..", "ParentBud_01", "Resources", "care_cards.json")
    os.makedirs(os.path.dirname(ios_resources_path), exist_ok=True)
    with open(ios_resources_path, 'w', encoding='utf-8') as f:
        json.dump(all_cards, f, indent=2, ensure_ascii=False)
    
    # Summary
    print("\n" + "="*70)
    print("✅ SCRAPING & GENERATION COMPLETE")
    print("="*70)
    print(f"📊 Scrape Stats:")
    print(f"   - Total URLs: {scrape_stats['total_urls']}")
    print(f"   - Successful: {scrape_stats['successful']}")
    print(f"   - Failed: {scrape_stats['failed']}")
    print(f"🎴 Generated {len(all_cards)} care cards")
    print(f"💾 Saved to: {output_path}")
    print(f"📱 iOS Resources: {ios_resources_path}")
    
    return all_cards


if __name__ == '__main__':
    scrape_and_generate_all()
