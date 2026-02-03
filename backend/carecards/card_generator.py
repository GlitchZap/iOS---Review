"""
ParentBud Card Generator
------------------------
Step 2 of the pipeline: Scrape → AI Summarize → Store

Takes raw scraped articles and uses AI to generate:
- 5 actionable, parent-friendly cards per topic
- Original rewritten content (no copyright issues)
- Age-appropriate language

The output is what gets stored in Supabase and shown in the app.
"""

import os
import json
import openai
from datetime import datetime

# ─────────────────────────────────────────────────────────────
# DIRECTORIES
# ─────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(__file__)
TOPIC_DATA_DIR = os.path.join(BASE_DIR, "data", "by_topic")
CARDS_OUTPUT_DIR = os.path.join(BASE_DIR, "data", "cards")
os.makedirs(CARDS_OUTPUT_DIR, exist_ok=True)

# ─────────────────────────────────────────────────────────────
# LOAD TOPICS CONFIG
# ─────────────────────────────────────────────────────────────
with open(os.path.join(BASE_DIR, 'topics.json'), 'r') as f:
    TOPICS = json.load(f)

# ─────────────────────────────────────────────────────────────
# AI CONFIGURATION
# ─────────────────────────────────────────────────────────────
# Set your OpenAI API key in environment variable OPENAI_API_KEY
# Or uncomment and set directly (not recommended for production):
# openai.api_key = "sk-..."

SYSTEM_PROMPT = """You are a child development expert and parenting coach. 
Your job is to take raw parenting articles and create simple, actionable advice cards.

RULES:
1. Create exactly 5 cards per topic
2. Each card should be 1-2 sentences maximum
3. Use simple, warm, non-judgmental language
4. Focus on actionable advice or key understanding
5. Never copy text directly - always rewrite in original words
6. Make content appropriate for parents of children ages 2-10
7. Be encouraging, not preachy

OUTPUT FORMAT:
Return a JSON object with this structure:
{
  "cards": [
    {"text": "Card 1 content here", "type": "insight"},
    {"text": "Card 2 content here", "type": "action"},
    {"text": "Card 3 content here", "type": "action"},
    {"text": "Card 4 content here", "type": "insight"},
    {"text": "Card 5 content here", "type": "tip"}
  ]
}

Card types:
- "insight": Understanding WHY something happens
- "action": Specific thing parent can DO
- "tip": Quick practical advice
"""


def load_topic_articles(topic_id):
    """Load all scraped articles for a topic"""
    topic_dir = os.path.join(TOPIC_DATA_DIR, topic_id)
    
    if not os.path.exists(topic_dir):
        print(f"⚠️  No data found for topic: {topic_id}")
        return []
    
    articles = []
    for filename in os.listdir(topic_dir):
        if filename.endswith('.json'):
            filepath = os.path.join(topic_dir, filename)
            with open(filepath, 'r') as f:
                articles.append(json.load(f))
    
    return articles


def combine_article_texts(articles, max_chars=8000):
    """Combine article texts into a single knowledge blob for AI"""
    combined = []
    total_chars = 0
    
    for article in articles:
        text = article.get('text', '')
        title = article.get('title', '')
        
        # Add title and excerpt
        excerpt = f"ARTICLE: {title}\n{text[:1500]}\n\n"
        
        if total_chars + len(excerpt) > max_chars:
            break
        
        combined.append(excerpt)
        total_chars += len(excerpt)
    
    return "\n".join(combined)


def generate_cards_with_ai(topic, knowledge_text):
    """Use OpenAI to generate 5 cards from knowledge"""
    topic_title = topic.get('title', 'Parenting Topic')
    age_groups = topic.get('age_groups', ['2-10'])
    
    user_prompt = f"""Topic: {topic_title}
Age groups: {', '.join(age_groups)}

Based on the following knowledge about "{topic_title}", create 5 parent-friendly cards.
Focus on practical advice that helps parents of children ages {', '.join(age_groups)}.

KNOWLEDGE:
{knowledge_text}

Remember: Create exactly 5 cards, each 1-2 sentences, actionable and warm.
Return ONLY valid JSON."""

    try:
        response = openai.chat.completions.create(
            model="gpt-4o-mini",  # or "gpt-4" for better quality
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": user_prompt}
            ],
            temperature=0.7,
            max_tokens=1000
        )
        
        result_text = response.choices[0].message.content.strip()
        
        # Parse JSON from response
        # Handle potential markdown code blocks
        if result_text.startswith("```"):
            result_text = result_text.split("```")[1]
            if result_text.startswith("json"):
                result_text = result_text[4:]
        
        cards_data = json.loads(result_text)
        return cards_data.get('cards', [])
    
    except Exception as e:
        print(f"❌ AI generation failed: {e}")
        return None


def generate_cards_fallback(topic):
    """Generate placeholder cards if AI fails"""
    templates = {
        "tantrums": [
            {"text": "Tantrums are emotional overloads, not misbehavior.", "type": "insight"},
            {"text": "Children lack words to express frustration.", "type": "insight"},
            {"text": "Stay calm and validate their feelings.", "type": "action"},
            {"text": "Offer small choices to reduce conflict.", "type": "tip"},
            {"text": "Teach coping skills after the tantrum passes.", "type": "action"}
        ],
        "sleep_routines": [
            {"text": "A consistent bedtime signals the brain it's time to rest.", "type": "insight"},
            {"text": "Start winding down 30 minutes before bed.", "type": "action"},
            {"text": "Keep screens off at least 1 hour before sleep.", "type": "tip"},
            {"text": "A dark, cool room helps children sleep better.", "type": "tip"},
            {"text": "Validate fears but gently encourage independence.", "type": "action"}
        ],
        "screen_time": [
            {"text": "Children learn best from real-world interaction.", "type": "insight"},
            {"text": "Watch content together and discuss what you see.", "type": "action"},
            {"text": "Set clear, consistent limits on daily screen time.", "type": "action"},
            {"text": "Model healthy tech habits yourself.", "type": "tip"},
            {"text": "Create tech-free zones like the dinner table.", "type": "tip"}
        ],
        "eating_habits": [
            {"text": "Picky eating is normal and often temporary.", "type": "insight"},
            {"text": "Offer new foods alongside familiar favorites.", "type": "action"},
            {"text": "Never force eating—it creates negative associations.", "type": "tip"},
            {"text": "Let children serve themselves to build autonomy.", "type": "action"},
            {"text": "Eating together as a family models good habits.", "type": "tip"}
        ],
        "potty_training": [
            {"text": "Every child is ready at their own pace.", "type": "insight"},
            {"text": "Look for signs of readiness, not age milestones.", "type": "tip"},
            {"text": "Celebrate successes without shaming accidents.", "type": "action"},
            {"text": "Make bathroom time calm and pressure-free.", "type": "action"},
            {"text": "Regression is normal during stress—stay patient.", "type": "insight"}
        ],
        "social_skills": [
            {"text": "Social skills develop gradually through practice.", "type": "insight"},
            {"text": "Arrange playdates to give children practice.", "type": "action"},
            {"text": "Role-play social situations at home.", "type": "tip"},
            {"text": "Teach specific phrases for common situations.", "type": "action"},
            {"text": "Praise effort in social situations, not just outcomes.", "type": "tip"}
        ],
        "separation_anxiety": [
            {"text": "Separation anxiety shows healthy attachment.", "type": "insight"},
            {"text": "Keep goodbyes brief but warm and consistent.", "type": "action"},
            {"text": "Never sneak away—it increases anxiety.", "type": "tip"},
            {"text": "Create a special goodbye ritual together.", "type": "action"},
            {"text": "Reassure them you'll always come back.", "type": "tip"}
        ],
        "behavior_management": [
            {"text": "All behavior is communication.", "type": "insight"},
            {"text": "Focus on teaching, not punishing.", "type": "tip"},
            {"text": "Set clear, age-appropriate expectations.", "type": "action"},
            {"text": "Praise specific positive behaviors you want to see.", "type": "action"},
            {"text": "Stay calm—your response models self-regulation.", "type": "tip"}
        ]
    }
    
    topic_id = topic.get('id', '')
    return templates.get(topic_id, [
        {"text": "Every child develops at their own pace.", "type": "insight"},
        {"text": "Stay patient and consistent.", "type": "action"},
        {"text": "Celebrate small wins along the way.", "type": "tip"},
        {"text": "Connect before you correct.", "type": "action"},
        {"text": "You know your child best.", "type": "insight"}
    ])


def save_cards(topic, cards):
    """Save generated cards to JSON file"""
    topic_id = topic.get('id')
    output = {
        "topic_id": topic_id,
        "topic_title": topic.get('title'),
        "description": topic.get('description'),
        "age_groups": topic.get('age_groups'),
        "cards": cards,
        "generated_at": datetime.now().isoformat(),
        "card_count": len(cards)
    }
    
    output_path = os.path.join(CARDS_OUTPUT_DIR, f"{topic_id}.json")
    with open(output_path, 'w') as f:
        json.dump(output, f, indent=2, ensure_ascii=False)
    
    return output_path


def generate_cards_for_topic(topic, use_ai=True):
    """Generate cards for a single topic"""
    topic_id = topic.get('id')
    topic_title = topic.get('title')
    
    print(f"\n📝 Generating cards for: {topic_title}")
    
    # Load scraped articles
    articles = load_topic_articles(topic_id)
    print(f"   Found {len(articles)} scraped articles")
    
    cards = None
    
    if use_ai and articles:
        # Combine article knowledge
        knowledge = combine_article_texts(articles)
        print(f"   Knowledge size: {len(knowledge)} chars")
        
        # Generate with AI
        cards = generate_cards_with_ai(topic, knowledge)
        if cards:
            print(f"   ✅ AI generated {len(cards)} cards")
    
    # Fallback if AI fails or no articles
    if not cards:
        print(f"   ⚠️  Using fallback templates")
        cards = generate_cards_fallback(topic)
    
    # Save cards
    output_path = save_cards(topic, cards)
    print(f"   💾 Saved to: {output_path}")
    
    return cards


def generate_all_cards(use_ai=True):
    """Generate cards for all topics"""
    print("\n" + "="*60)
    print("🎴 PARENTBUD CARD GENERATOR")
    print("="*60)
    
    all_cards = {}
    
    for topic in TOPICS:
        cards = generate_cards_for_topic(topic, use_ai=use_ai)
        all_cards[topic['id']] = cards
    
    # Save summary
    summary = {
        "generated_at": datetime.now().isoformat(),
        "topics": {tid: len(cards) for tid, cards in all_cards.items()},
        "total_cards": sum(len(c) for c in all_cards.values())
    }
    
    summary_path = os.path.join(CARDS_OUTPUT_DIR, "generation_summary.json")
    with open(summary_path, 'w') as f:
        json.dump(summary, f, indent=2)
    
    print("\n" + "="*60)
    print("✅ CARD GENERATION COMPLETE")
    print("="*60)
    print(f"Total cards generated: {summary['total_cards']}")
    print(f"Output directory: {CARDS_OUTPUT_DIR}")
    
    return all_cards


# ─────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────
if __name__ == '__main__':
    import sys
    
    # Check for --no-ai flag to use fallback templates only
    use_ai = '--no-ai' not in sys.argv
    
    if not use_ai:
        print("⚠️  Running in fallback mode (no AI)")
    
    generate_all_cards(use_ai=use_ai)
