# ParentBud Content Scraping System V2

## Overview

This system collects parenting knowledge from curated expert sources, organizes it by age group, and generates AI-summarized care cards and suggested articles for the ParentBud app.

**Key Features:**
- 🎯 **Age-Specific Content** - Cards tagged for ages 2-4, 4-6, 6-8, 8-10
- 🔄 **Shuffle-Ready** - 10-12 card variations per topic for personalization
- 🤖 **AI-Powered** - Uses Gemini API for intelligent summarization
- 📚 **11 Topics** - Including mixed topics like emotional development
- 📰 **Suggested Articles** - Curated articles with AI summaries

---

## 🆕 Suggested Articles (for "Suggested" section)

### Quick Start

```bash
# Scrape all suggested articles
python3 suggested_articles_scraper.py

# Scrape single category
python3 suggested_articles_scraper.py sleep

# Re-summarize with Gemini when API quota resets
export GEMINI_API_KEY=your-key-here
python3 resummary_with_gemini.py
```

### Output Location
```
data/suggested_articles/
├── all_suggested_articles.json   # Master file (64 articles)
├── sleep.json                    # 8 articles
├── tantrums.json                 # 4 articles
├── screen_time.json              # 3 articles
├── eating.json                   # 7 articles
├── potty_training.json           # 10 articles
├── social_skills.json            # 10 articles
├── separation_anxiety.json       # 11 articles
├── behavior_management.json      # 11 articles
└── scrape_summary.json           # Stats
```

### Article Format
```json
{
  "id": "d5ab32919cbd",
  "url": "https://example.com/article",
  "domain": "example.com",
  "category_id": "sleep",
  "category_title": "Sleep & Bedtime",
  "title": "Article Title",
  "summary": "2-3 sentence summary for parents...",
  "key_takeaways": ["Tip 1", "Tip 2", "Tip 3"],
  "reading_time_minutes": 5,
  "age_groups": ["2-4", "4-6"],
  "emoji": "🌙",
  "color": "#6B5B95",
  "top_image": "https://example.com/image.jpg",
  "scraped_at": "2026-01-26T16:01:19Z"
}
```

---

## Care Cards (for "Recommended" section)

| Topic | Age Groups | Cards |
|-------|-----------|-------|
| Tantrums | 2-4, 4-6, 6-8, 8-10 | 12 |
| Sleep Routines | 2-4, 4-6, 6-8, 8-10 | 12 |
| Screen Time | 2-4, 4-6, 6-8, 8-10 | 10 |
| Eating Habits | 2-4, 4-6, 6-8, 8-10 | 12 |
| Potty Training | 2-4, 4-6 | 10 |
| Social Skills | 2-4, 4-6, 6-8, 8-10 | 10 |
| Separation Anxiety | 2-4, 4-6, 6-8 | 10 |
| Behavior Management | 2-4, 4-6, 6-8, 8-10 | 12 |
| **Mixed: Emotional Development** | 2-4, 4-6, 6-8, 8-10 | 10 |
| **Mixed: Confidence & Independence** | 2-4, 4-6, 6-8, 8-10 | 10 |
| **Mixed: Sibling & Family** | 2-4, 4-6, 6-8, 8-10 | 10 |

## Quick Start

### 1. Install Dependencies
```bash
cd backend/scraping
pip3 install -r requirements.txt
```

### 2. Run the Scraper (All Topics)
```bash
python3 scraper_v2.py
```

### 3. Scrape Single Topic
```bash
python3 scraper_v2.py tantrums
python3 scraper_v2.py sleep_routines
python3 scraper_v2.py screen_time
```

### 4. Generate Cards
```bash
# With AI (requires OPENAI_API_KEY)
export OPENAI_API_KEY=your-key-here
python3 card_generator_v2.py

# Without AI (uses templates)
python3 card_generator_v2.py
```

### 5. Generate Cards for Single Topic
```bash
python3 card_generator_v2.py tantrums
```

## Directory Structure

```
backend/scraping/
├── scraper_v2.py           # Enhanced scraper with age tagging
├── card_generator_v2.py    # Multi-card generator with templates
├── curated_urls_v2.json    # Age-organized URL sources
├── requirements.txt        # Python dependencies
├── data/
│   ├── raw/               # All scraped articles
│   ├── by_topic/          # Articles organized by topic
│   │   ├── tantrums/
│   │   ├── sleep_routines/
│   │   └── ...
│   ├── by_age/            # Articles organized by age
│   │   ├── 2_4/
│   │   ├── 4_6/
│   │   ├── 6_8/
│   │   └── 8_10/
│   └── cards_v2/          # Generated care cards
│       ├── all_cards.json
│       ├── tantrums.json
│       ├── age_2_4/       # Age-filtered cards
│       ├── age_4_6/
│       └── ...
```

## Card Format

Each card follows this structure:
```json
{
  "id": "uuid",
  "topic_id": "tantrums",
  "title": "Stay Calm First",
  "subtitle": "Your calm is their anchor",
  "tips": [
    "Tip 1...",
    "Tip 2...",
    "Tip 3...",
    "Tip 4...",
    "Tip 5..."
  ],
  "age_groups": ["2-4", "4-6"],
  "emoji": "🌪️",
  "color_theme": "calm_orange",
  "source_articles": ["url1", "url2"],
  "variation": 1,
  "generated_at": "2024-01-15T10:00:00Z"
}
```

## Files

| File | Purpose |
|------|---------|
| `scraper_v2.py` | Main scraper with age detection |
| `card_generator_v2.py` | Card generation with 118 template cards |
| `curated_urls_v2.json` | 100+ curated URLs organized by topic & age |
| `scraper.py` | Original discovery scraper |
| `curated_scraper.py` | V1 curated scraper |
| `card_generator.py` | V1 card generator |

## Age Group Keywords

The scraper automatically detects age relevance based on keywords:

- **2-4**: toddler, terrible twos, potty, diaper, tantrum, clingy
- **4-6**: preschool, kindergarten, pre-k, playdates, sharing
- **6-8**: elementary, homework, friends, sports, chores
- **8-10**: tween, preteen, peer pressure, independence, puberty

## Usage in iOS App

```swift
// Fetch cards for user's child age
let age = "4-6"
let cards = loadCards(forAge: age, topic: "tantrums")

// Shuffle for personalization  
let shuffledCards = cards.shuffled()
let todaysCards = Array(shuffledCards.prefix(3))
```

## Ethical Guidelines

✅ We ONLY scrape from reputable sources (AAP, Zero to Three, universities)
✅ We summarize and rewrite content - no direct copying
✅ We respect robots.txt
✅ We add polite delays between requests
✅ Generated cards are original summaries, not quotes

## Troubleshooting

### "No module named 'newspaper'"
```bash
pip3 install newspaper3k
```

### "OPENAI_API_KEY not set"
Cards will be generated using built-in templates (no AI needed).

### Some URLs blocked
Normal - some sites block scrapers. The system continues with available sources.

### PDF extraction issues
```bash
pip3 install PyPDF2
```

## Stats

- **118 Template Cards** - Ready to use without AI
- **11 Topics** - Including 3 mixed trait topics
- **4 Age Groups** - Personalized for 2-4, 4-6, 6-8, 8-10
- **100+ Curated URLs** - Expert-vetted sources only
