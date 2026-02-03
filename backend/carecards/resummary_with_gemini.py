"""
ParentBud Suggested Articles - Re-summarize with Gemini
-------------------------------------------------------
Run this script when your Gemini API quota resets to add AI-powered summaries.

Usage:
    python3 resummary_with_gemini.py              # Re-summarize all
    python3 resummary_with_gemini.py sleep        # Re-summarize single category
"""

import os
import json
import time
import requests
from datetime import datetime

BASE_DIR = os.path.dirname(__file__)
ARTICLES_DIR = os.path.join(BASE_DIR, "data", "suggested_articles")

# Gemini API Configuration
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY', "AIzaSyDZvASZsvPn9zkhUFn5-0EcV4OfdRwpG-E")
GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
GEMINI_DELAY = 3.0  # Delay between API calls


def generate_gemini_summary(title: str, full_text: str, category: str) -> dict:
    """Call Gemini API to generate a better summary"""
    time.sleep(GEMINI_DELAY)
    
    content_truncated = full_text[:5000] if len(full_text) > 5000 else full_text
    
    prompt = f"""You are a parenting expert. Summarize this article for the ParentBud app's "Suggested Articles" section.

Article Title: {title}
Category: {category}

Content:
{content_truncated}

Provide:
1. A concise 2-3 sentence summary (max 150 words) for busy parents
2. 3 specific, actionable key takeaways
3. Estimated reading time (minutes)
4. Most relevant age groups: choose from 2-4, 4-6, 6-8, 8-10

Return ONLY valid JSON:
{{
    "summary": "...",
    "key_takeaways": ["tip1", "tip2", "tip3"],
    "reading_time_minutes": 5,
    "age_groups": ["2-4", "4-6"]
}}"""

    try:
        response = requests.post(
            f"{GEMINI_API_URL}?key={GEMINI_API_KEY}",
            headers={'Content-Type': 'application/json'},
            json={
                "contents": [{"parts": [{"text": prompt}]}],
                "generationConfig": {"temperature": 0.7, "maxOutputTokens": 800}
            },
            timeout=30
        )
        
        if response.status_code == 429:
            print(f"   ⚠️  Rate limited - waiting 30s...")
            time.sleep(30)
            return None
        
        if response.status_code != 200:
            print(f"   ❌ API error: {response.status_code}")
            return None
        
        data = response.json()
        text = data.get('candidates', [{}])[0].get('content', {}).get('parts', [{}])[0].get('text', '')
        
        # Clean JSON from response
        text = text.strip()
        if text.startswith('```'):
            text = text.split('```')[1]
            if text.startswith('json'):
                text = text[4:]
        text = text.strip()
        
        return json.loads(text)
        
    except json.JSONDecodeError:
        print(f"   ⚠️  Could not parse response")
        return None
    except Exception as e:
        print(f"   ❌ Error: {str(e)[:50]}")
        return None


def resummary_category(category_file: str):
    """Re-summarize articles in a category file using Gemini"""
    filepath = os.path.join(ARTICLES_DIR, category_file)
    if not os.path.exists(filepath):
        print(f"❌ File not found: {filepath}")
        return
    
    with open(filepath, 'r') as f:
        articles = json.load(f)
    
    category = category_file.replace('.json', '')
    print(f"\n📝 Re-summarizing: {category} ({len(articles)} articles)")
    
    updated = 0
    for i, article in enumerate(articles, 1):
        title = article.get('title', 'Untitled')
        
        # Skip videos/PDFs with no real content
        if article.get('is_video') or article.get('is_pdf'):
            continue
        
        # Skip if already has AI summary
        if article.get('gemini_summary'):
            print(f"   [{i}] ✓ Already has AI summary")
            continue
        
        print(f"   [{i}] {title[:40]}...")
        
        # We need the full text - for now use what we have
        # In production, you'd re-scrape or store full text
        full_text = f"{title}. {article.get('summary', '')}"
        
        result = generate_gemini_summary(title, full_text, category)
        
        if result:
            article['summary'] = result.get('summary', article['summary'])
            article['key_takeaways'] = result.get('key_takeaways', article['key_takeaways'])
            article['reading_time_minutes'] = result.get('reading_time_minutes', article['reading_time_minutes'])
            article['age_groups'] = result.get('age_groups', article['age_groups'])
            article['gemini_summary'] = True
            article['updated_at'] = datetime.now().isoformat()
            updated += 1
            print(f"      ✅ Updated with AI summary")
        else:
            print(f"      ⚠️  Skipped")
    
    # Save updated file
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(articles, f, indent=2, ensure_ascii=False)
    
    print(f"\n   📊 Updated {updated}/{len(articles)} articles")


def resummary_all():
    """Re-summarize all category files"""
    print("\n" + "="*60)
    print("🤖 GEMINI RE-SUMMARIZATION")
    print("="*60)
    
    for filename in os.listdir(ARTICLES_DIR):
        if filename.endswith('.json') and filename not in ['all_suggested_articles.json', 'scrape_summary.json']:
            resummary_category(filename)
    
    # Rebuild master file
    all_articles = []
    for filename in os.listdir(ARTICLES_DIR):
        if filename.endswith('.json') and filename not in ['all_suggested_articles.json', 'scrape_summary.json']:
            with open(os.path.join(ARTICLES_DIR, filename), 'r') as f:
                all_articles.extend(json.load(f))
    
    with open(os.path.join(ARTICLES_DIR, 'all_suggested_articles.json'), 'w', encoding='utf-8') as f:
        json.dump(all_articles, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Master file updated with {len(all_articles)} articles")


if __name__ == '__main__':
    import sys
    
    if len(sys.argv) > 1:
        category = sys.argv[1]
        if not category.endswith('.json'):
            category += '.json'
        resummary_category(category)
    else:
        resummary_all()
