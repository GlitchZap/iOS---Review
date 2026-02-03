"""
Enhanced ParentBud Card Generator
---------------------------------
Scrapes curated URLs and generates rich 3-line content cards
using Gemini AI for summarization.

Each card now has:
- Title (catchy headline)
- Subtitle (context)
- 5 detailed tips (3+ lines each)
"""

import os
import json
import hashlib
import requests
import time
import re
from datetime import datetime
from bs4 import BeautifulSoup
from urllib.parse import urlparse

# Try to import newspaper for better extraction
try:
    from newspaper import Article
    HAS_NEWSPAPER = True
except ImportError:
    HAS_NEWSPAPER = False
    print("⚠️ newspaper3k not installed, using basic extraction")

# Try to import Google Gemini
try:
    import google.generativeai as genai
    HAS_GEMINI = True
except ImportError:
    HAS_GEMINI = False
    print("⚠️ google-generativeai not installed, using templates")

# ─────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(__file__)
OUTPUT_DIR = os.path.join(BASE_DIR, "data", "enhanced_cards")
CACHE_DIR = os.path.join(BASE_DIR, "data", "url_cache")
os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(CACHE_DIR, exist_ok=True)

# Gemini API Key (set in environment)
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")

# Request headers
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
}

# ─────────────────────────────────────────────────────────────
# CURATED URLS BY TOPIC
# ─────────────────────────────────────────────────────────────
TOPIC_URLS = {
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
        "https://www.commonsensemedia.org/screen-time",
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
        "https://www.parents.com/expert-approved-sneaky-tips-to-get-your-kid-reading-11810979",
    ],
    "emotional_regulation": [
        "https://www.parents.com/emotional-regulation-skills-8692759",
        "https://www.parents.com/kids/development/behavioral/emotionally-sensitive-children/",
        "https://www.zerotothree.org/resource/toddler-tantrums-101-why-they-happen-and-what-you-can-do/",
    ],
}

# Topic metadata
TOPIC_META = {
    "tantrums": {
        "title": "Tantrums",
        "emoji": "🌪️",
        "color_theme": "calm_orange",
        "age_groups": ["2-4", "4-6", "6-8"]
    },
    "sleep": {
        "title": "Sleep & Bedtime",
        "emoji": "🌙",
        "color_theme": "gentle_blue",
        "age_groups": ["2-4", "4-6", "6-8", "8-10"]
    },
    "eating_habits": {
        "title": "Eating Habits",
        "emoji": "🥦",
        "color_theme": "soft_green",
        "age_groups": ["2-4", "4-6", "6-8", "8-10"]
    },
    "screen_time": {
        "title": "Screen Time",
        "emoji": "📱",
        "color_theme": "sky_blue",
        "age_groups": ["2-4", "4-6", "6-8", "8-10"]
    },
    "behavior": {
        "title": "Behavior Management",
        "emoji": "🎯",
        "color_theme": "warm_purple",
        "age_groups": ["2-4", "4-6", "6-8", "8-10"]
    },
    "separation_anxiety": {
        "title": "Separation Anxiety",
        "emoji": "💙",
        "color_theme": "peach",
        "age_groups": ["2-4", "4-6"]
    },
    "social_skills": {
        "title": "Social Skills",
        "emoji": "🤝",
        "color_theme": "teal",
        "age_groups": ["2-4", "4-6", "6-8", "8-10"]
    },
    "confidence": {
        "title": "Building Confidence",
        "emoji": "⭐",
        "color_theme": "sunny_yellow",
        "age_groups": ["4-6", "6-8", "8-10"]
    },
    "emotional_regulation": {
        "title": "Emotional Regulation",
        "emoji": "🧠",
        "color_theme": "lavender",
        "age_groups": ["2-4", "4-6", "6-8"]
    },
}

# ─────────────────────────────────────────────────────────────
# URL SCRAPING
# ─────────────────────────────────────────────────────────────

def get_cache_path(url):
    """Generate cache file path for URL"""
    url_hash = hashlib.md5(url.encode()).hexdigest()[:12]
    return os.path.join(CACHE_DIR, f"{url_hash}.json")

def scrape_url(url):
    """Scrape content from URL with caching"""
    cache_path = get_cache_path(url)
    
    # Check cache first
    if os.path.exists(cache_path):
        with open(cache_path, 'r') as f:
            cached = json.load(f)
            print(f"  📦 Using cached: {url[:50]}...")
            return cached
    
    print(f"  🌐 Scraping: {url[:50]}...")
    
    try:
        # Skip PDFs and videos
        if url.endswith('.pdf') or 'youtube.com' in url:
            return {"url": url, "text": "", "title": "", "error": "Skipped (PDF/Video)"}
        
        if HAS_NEWSPAPER:
            article = Article(url)
            article.download()
            article.parse()
            
            result = {
                "url": url,
                "title": article.title,
                "text": article.text[:8000],
                "domain": urlparse(url).netloc
            }
        else:
            # Fallback to basic scraping
            response = requests.get(url, headers=HEADERS, timeout=15)
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Remove script and style
            for tag in soup(['script', 'style', 'nav', 'footer', 'header']):
                tag.decompose()
            
            title = soup.find('title')
            title = title.text.strip() if title else ""
            
            # Get main content
            text = ' '.join(soup.stripped_strings)[:8000]
            
            result = {
                "url": url,
                "title": title,
                "text": text,
                "domain": urlparse(url).netloc
            }
        
        # Cache the result
        with open(cache_path, 'w') as f:
            json.dump(result, f)
        
        time.sleep(1)  # Be nice to servers
        return result
        
    except Exception as e:
        print(f"  ❌ Failed: {e}")
        return {"url": url, "text": "", "title": "", "error": str(e)}

def scrape_topic_urls(topic_id):
    """Scrape all URLs for a topic"""
    urls = TOPIC_URLS.get(topic_id, [])
    results = []
    
    for url in urls:
        result = scrape_url(url)
        if result.get('text'):
            results.append(result)
    
    return results

# ─────────────────────────────────────────────────────────────
# AI CARD GENERATION
# ─────────────────────────────────────────────────────────────

def generate_cards_with_gemini(topic_id, scraped_content):
    """Use Gemini to generate rich card content"""
    if not HAS_GEMINI or not GEMINI_API_KEY:
        print("  ⚠️ Gemini not available, using templates")
        return None
    
    try:
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel('gemini-1.5-flash')
        
        meta = TOPIC_META.get(topic_id, {})
        topic_title = meta.get('title', topic_id)
        
        # Combine scraped content
        knowledge = "\n\n".join([
            f"SOURCE: {c.get('title', 'Unknown')}\n{c.get('text', '')[:2000]}"
            for c in scraped_content[:5]
        ])
        
        prompt = f"""You are a child development expert creating parenting advice cards.

TOPIC: {topic_title}
AGE GROUPS: {', '.join(meta.get('age_groups', ['2-10']))}

Based on this research knowledge, create 10 unique parenting advice cards.

KNOWLEDGE:
{knowledge}

REQUIREMENTS:
1. Each card needs a catchy TITLE (3-5 words)
2. Each card needs a SUBTITLE (one sentence context)
3. Each card needs exactly 5 TIPS - each tip must be 2-3 sentences long, detailed and actionable
4. Tips should be warm, encouraging, and practical
5. Use "you/your" language speaking directly to parents
6. Never copy directly - rewrite in original words
7. Include specific examples where helpful

OUTPUT FORMAT (JSON):
{{
  "cards": [
    {{
      "title": "Stay Calm First",
      "subtitle": "Your calm is their anchor during a storm",
      "tips": [
        "Take 3 deep breaths before responding to your child's outburst. This brief pause activates your parasympathetic nervous system, helping you respond thoughtfully rather than react emotionally.",
        "Lower your body to their eye level and speak in a slow, quiet voice. Children mirror our energy, so your calm presence helps regulate their nervous system.",
        "Remember: they're not giving you a hard time, they're having one. This mindset shift helps you approach tantrums with empathy rather than frustration.",
        "Model the calm you want them to feel by keeping your facial expressions soft. Children are incredibly attuned to our nonverbal cues and will pick up on tension.",
        "If you feel yourself getting frustrated, it's okay to say 'Mommy/Daddy needs a moment' and step back briefly. Modeling self-regulation teaches them the skill too."
      ]
    }}
  ]
}}

Generate 10 diverse cards covering different aspects of {topic_title}. Make tips detailed (2-3 sentences each)."""

        response = model.generate_content(prompt)
        text = response.text
        
        # Parse JSON from response
        if "```json" in text:
            text = text.split("```json")[1].split("```")[0]
        elif "```" in text:
            text = text.split("```")[1].split("```")[0]
        
        data = json.loads(text)
        return data.get('cards', [])
        
    except Exception as e:
        print(f"  ❌ Gemini error: {e}")
        return None

# ─────────────────────────────────────────────────────────────
# RICH FALLBACK TEMPLATES (3+ lines per tip)
# ─────────────────────────────────────────────────────────────

RICH_TEMPLATES = {
    "tantrums": [
        {
            "title": "Stay Calm First",
            "subtitle": "Your calm is their anchor during a storm",
            "tips": [
                "Take 3 deep breaths before responding to your child's outburst. This brief pause activates your parasympathetic nervous system, helping you respond thoughtfully rather than react emotionally. Your calm energy will eventually help regulate theirs.",
                "Lower your body to their eye level and speak in a slow, quiet voice. Children mirror our energy, so your calm presence helps regulate their nervous system. Avoid towering over them which can feel threatening.",
                "Remember: they're not giving you a hard time, they're having one. This mindset shift helps you approach tantrums with empathy rather than frustration. Their brain is literally overwhelmed and unable to process logic right now.",
                "Model the calm you want them to feel by keeping your facial expressions soft and open. Children are incredibly attuned to our nonverbal cues and will pick up on tension in your jaw, shoulders, and voice.",
                "If you feel yourself getting frustrated, it's perfectly okay to say 'Mommy/Daddy needs a moment' and step back briefly. Modeling self-regulation teaches them the same skill you want them to develop."
            ]
        },
        {
            "title": "Validate Their Feelings",
            "subtitle": "Big feelings need acknowledgment before solutions",
            "tips": [
                "Say 'I see you're really upset right now' before trying to fix anything. Validation doesn't mean you agree with their behavior—it means you acknowledge their emotional experience as real and valid.",
                "Name the emotion you see: 'You seem frustrated that we have to leave.' This helps children develop emotional vocabulary and understand what they're feeling. Over time, they'll use these words themselves.",
                "Avoid saying 'calm down' or 'stop crying'—these phrases dismiss their feelings and rarely work. Instead, try 'It's okay to feel upset. I'm here with you.' This builds emotional safety.",
                "Use phrases like 'It's hard when things don't go the way you wanted.' This shows understanding without giving in to unreasonable demands. You're connecting with their experience.",
                "Show you understand before jumping to solutions or lessons. Connection before correction is the key—children can't learn when their emotional brain is in overdrive."
            ]
        },
        {
            "title": "Create a Calm-Down Space",
            "subtitle": "A special spot for processing big emotions",
            "tips": [
                "Set up a cozy corner with soft pillows, blankets, and maybe a stuffed animal. This becomes their safe haven for processing big emotions—not a punishment zone but a comfort zone.",
                "Include sensory tools like stress balls, playdough, or textured fabrics. Different children need different sensory inputs to calm down—some need to squeeze, others need softness.",
                "Make it inviting by letting them help decorate it with their favorite colors or pictures. When children have ownership of the space, they're more likely to use it willingly.",
                "Practice going there together when they're calm so it becomes familiar and comforting. Read books there, do puzzles—build positive associations before using it during upsets.",
                "Never force them into the space as punishment. The goal is for them to eventually recognize their big feelings and choose to go there themselves for regulation."
            ]
        },
        {
            "title": "Prevent Before Meltdowns",
            "subtitle": "Catch the triggers before the storm hits",
            "tips": [
                "Notice patterns of hunger, tiredness, and overstimulation—these are the biggest tantrum triggers. Keep snacks handy and watch for tired cues like eye-rubbing or getting clumsy.",
                "Give transition warnings: '5 more minutes until we leave the playground.' Children struggle with sudden changes, so advance notice helps them mentally prepare for what's coming next.",
                "Keep daily routines predictable so children know what to expect. When the sequence of the day is familiar, there are fewer surprises to trigger meltdowns. Predictability creates security.",
                "Offer choices to give them some control: 'Do you want to wear the red shirt or blue shirt?' Having agency over small things reduces the need to fight for control in bigger moments.",
                "Avoid taking tired or hungry children to stores or stimulating environments. Setting them up for success means planning activities around their needs, not against them."
            ]
        },
        {
            "title": "After the Storm",
            "subtitle": "Learning happens once emotions settle",
            "tips": [
                "Wait until everyone is calm before discussing what happened—usually 20-30 minutes minimum. The learning brain can't function while the emotional brain is still activated.",
                "Reconnect first with a hug or gentle words: 'That was hard. I love you.' Shame and lectures don't teach—connection and safety do. They need to know the relationship is intact.",
                "Help them identify what they were feeling: 'It seemed like you were really disappointed when we couldn't get the toy.' This builds self-awareness for future situations.",
                "Brainstorm together what they could try next time: 'What might help when you feel that frustrated feeling coming?' Let them generate ideas—they'll be more likely to use their own solutions.",
                "Praise any small improvements you see over time: 'I noticed you took a deep breath when you got upset today—that was so grown-up!' Celebrate progress, not perfection."
            ]
        },
    ],
    "sleep": [
        {
            "title": "Consistent Bedtime Routine",
            "subtitle": "Predictability signals the brain it's time to rest",
            "tips": [
                "Start your wind-down routine 30-60 minutes before the desired sleep time. This gives your child's body time to naturally produce melatonin and transition from active play to restful state.",
                "Follow the same sequence every night: perhaps bath, pajamas, brush teeth, story, song, lights out. The predictable pattern becomes a powerful sleep cue that tells their brain 'sleep is coming.'",
                "Keep the routine calm and screen-free. Blue light from devices suppresses melatonin production for up to 2 hours. Trade screens for books, puzzles, or quiet imaginative play.",
                "Include some one-on-one connection time—a chat about their day, gratitude sharing, or cuddling. This emotional connection helps children feel secure enough to separate for the night.",
                "Be consistent even on weekends. A regular sleep schedule regulates their internal clock (circadian rhythm). More than 1 hour variation can disrupt sleep for several days."
            ]
        },
        {
            "title": "Create a Sleep Sanctuary",
            "subtitle": "The right environment makes a big difference",
            "tips": [
                "Keep the bedroom cool (65-70°F/18-21°C), dark, and quiet. Our bodies naturally drop in temperature during sleep, so a cooler room supports this biological process.",
                "Use blackout curtains to block streetlights and early morning sun. Even small amounts of light can disrupt melatonin production and cause early waking during light sleep phases.",
                "Consider a white noise machine to mask household sounds and create a consistent audio environment. The steady sound can become a sleep association that helps them fall back asleep if they wake.",
                "Remove stimulating toys and electronics from the bedroom. The bed should be associated with sleep, not play. Keep exciting toys in another room for daytime use.",
                "A comfort object like a special stuffed animal or blanket can provide security. This 'transitional object' helps children self-soothe when they wake briefly during normal sleep cycles."
            ]
        },
        {
            "title": "Handle Night Wakings",
            "subtitle": "Everyone wakes at night—the skill is falling back asleep",
            "tips": [
                "Keep night interactions boring and brief. Use a soft voice, minimal eye contact, and low lighting. You want to reassure without fully waking them or making nighttime visits rewarding.",
                "If they come to your room, walk them back to their bed calmly and consistently. Yes, you might do this many times initially, but consistency teaches them that their bed is where they sleep.",
                "Check that basic needs are met: not too hot or cold, not thirsty, not having a nightmare. Address the need simply, then back to the sleep expectation with minimal fuss.",
                "Avoid starting habits you don't want to continue—like lying with them until they fall asleep every night. Whatever method helps them fall asleep is what they'll need when they wake at 2am.",
                "Consider a 'sleep training clock' that turns green when it's okay to get up. This gives children a concrete, visual cue they can understand and gives you backup for explaining expectations."
            ]
        },
        {
            "title": "Right Amount of Sleep",
            "subtitle": "Sleep needs change as children grow",
            "tips": [
                "Toddlers (1-3 years) need 11-14 hours of sleep per 24 hours, including naps. An overtired toddler often becomes hyperactive rather than sleepy—watch for that 'second wind' as a sign they're past their window.",
                "Preschoolers (3-5 years) need 10-13 hours. Most drop their nap between 3-5 years. If bedtime becomes a battle, the nap might be too long or too late in the day.",
                "School-age children (6-12 years) need 9-12 hours. With school, activities, and homework, it's easy to underestimate how early bedtime needs to be. Count backwards from wake time.",
                "Signs of insufficient sleep include: difficulty waking, falling asleep in the car, behavioral issues, difficulty concentrating, and getting sick more often. These often improve dramatically with more sleep.",
                "Watch for your child's natural sleep window—that 15-30 minute period when they show sleepy cues. Putting them down during this window results in easier falling asleep than fighting past it."
            ]
        },
    ],
    "eating_habits": [
        {
            "title": "Division of Responsibility",
            "subtitle": "Parents decide what, children decide how much",
            "tips": [
                "Your job as a parent is to decide WHAT food is offered, WHEN meals happen, and WHERE eating takes place. Your child's job is to decide WHETHER they eat and HOW MUCH. This simple division prevents most food battles.",
                "Serve meals at consistent times so children come to the table hungry but not famished. Erratic eating schedules and constant grazing mean they're never truly hungry at mealtimes.",
                "Include at least one food you know they like at each meal, alongside new or less-preferred foods. This ensures they can eat something while being exposed to variety without pressure.",
                "Trust their hunger and fullness cues. Children are born knowing how to regulate intake—'clean your plate' pressure overrides this natural ability and can lead to overeating later in life.",
                "Avoid becoming a short-order cook. Offer one meal for the family. If they choose not to eat, that's okay—they'll eat at the next scheduled meal or snack time."
            ]
        },
        {
            "title": "Handling Picky Eaters",
            "subtitle": "Selectivity is normal and usually temporary",
            "tips": [
                "It can take 10-15 exposures to a new food before a child accepts it—without any pressure. Keep offering foods they've rejected before. Their taste preferences genuinely change over time.",
                "Celebrate small wins: touching, smelling, licking, or even just tolerating the food on their plate. Each interaction is a step toward eventual acceptance, even if they don't eat it today.",
                "Avoid labeling your child as a 'picky eater' within their hearing. Children live up to the labels we give them. Instead, try 'You're still learning about new foods.'",
                "Make one meal for everyone rather than cooking separately for your picky eater. Family-style serving where everyone takes what they want teaches that all foods are normal parts of meals.",
                "Never use dessert as a reward for eating dinner. This elevates sweet foods to 'special' status and makes vegetables seem like an obstacle. Serve small desserts alongside meals occasionally."
            ]
        },
        {
            "title": "Family Meals Matter",
            "subtitle": "Connection and nutrition come together at the table",
            "tips": [
                "Aim for at least one device-free family meal per day. Research shows children who eat with family have better nutrition, vocabulary, academic performance, and mental health outcomes.",
                "Focus on connection, not consumption. Family meals should be pleasant—avoid battles about eating. Talk about everyone's day, tell stories, play conversation games.",
                "Model healthy eating yourself—children learn more from watching than from being told. Eat your vegetables with enjoyment, try new foods openly, and show a healthy relationship with food.",
                "Let children help with meal preparation in age-appropriate ways. Children who help cook are more likely to eat the food they've made. Even toddlers can wash vegetables or tear lettuce.",
                "Keep mealtimes relatively short (15-20 minutes for younger children). Don't let meals drag on for an hour in hopes they'll eat more. When they're done, they're done."
            ]
        },
    ],
    "screen_time": [
        {
            "title": "Quality Over Quantity",
            "subtitle": "Not all screen time is created equal",
            "tips": [
                "Interactive, educational content differs from passive consumption. A video call with grandma, an age-appropriate learning game, or a creative drawing app engages children differently than endless YouTube videos.",
                "Co-view when possible—discuss what you're watching, ask questions, and connect screen content to real life. This transforms passive watching into active learning and strengthens your relationship.",
                "Preview content before allowing it. Check age ratings, reviews from Common Sense Media, and watch a few minutes yourself. What seems benign can have surprisingly mature themes.",
                "Help children understand that what they see online may not reflect reality. Talk about advertising, filters, and how videos are edited. Build media literacy from an early age.",
                "Encourage content creation over consumption when appropriate. Making videos, building in Minecraft, or coding simple games involves more learning than passively watching others."
            ]
        },
        {
            "title": "Setting Healthy Limits",
            "subtitle": "Clear boundaries prevent daily battles",
            "tips": [
                "Create consistent rules about when screens are allowed and for how long. Visual timers help children see time passing and prepare for transitions. 'When the timer goes off, we're done.'",
                "Establish screen-free zones and times: bedrooms, the dinner table, and the hour before bed. These non-negotiable boundaries protect sleep, family connection, and physical activity.",
                "Model healthy tech habits yourself. Children notice when you're scrolling instead of listening. Designate device-free family time when everyone—parents included—unplugs.",
                "Offer engaging alternatives to screens. Boredom is often behind screen requests. Have a basket of activities ready: arts and crafts, building toys, outdoor equipment, books, or puzzles.",
                "Don't use screens as the primary soothing or reward tool. If screen time becomes the go-to for every tantrum or bribe, it gains excessive power. Keep it as one option among many."
            ]
        },
        {
            "title": "Screen-Free Sleep",
            "subtitle": "Protect the golden hour before bed",
            "tips": [
                "Stop all screens at least 1 hour before bedtime. Blue light from devices suppresses melatonin production, making it harder to fall asleep and reducing sleep quality even after they do.",
                "Keep all devices—phones, tablets, TVs—out of the bedroom. Even if they're not using them, the presence and potential for use disrupts sleep. Charge devices in a common area.",
                "The stimulating content on screens keeps young brains alert and processing, the opposite of the calm wind-down state needed for sleep. Even 'calm' content is more stimulating than books or quiet play.",
                "Replace evening screen time with calming activities: bath time, reading together, gentle play, talking about the day, or listening to soft music or audiobooks.",
                "If your child struggles to sleep, the first thing to examine is their screen habits—both the timing and the content. A screen break often dramatically improves sleep within days."
            ]
        },
    ],
    "behavior": [
        {
            "title": "Connection Before Correction",
            "subtitle": "Children behave better when they feel understood",
            "tips": [
                "Get on their level, make eye contact, and acknowledge what they're feeling before addressing behavior. 'I see you're really frustrated that your tower fell' works better than 'Stop screaming!'",
                "Children who feel connected to their caregivers are naturally more cooperative. Invest in regular one-on-one time, even just 10 focused minutes daily, and behavior often improves.",
                "Remember that all behavior is communication. Ask yourself: What need is my child trying to meet? Are they tired, hungry, needing attention, feeling powerless, or overwhelmed?",
                "Stay calm during misbehavior. Your regulated nervous system helps regulate theirs. If you respond with anger, the situation escalates. If you stay calm, it contains.",
                "After addressing the behavior, reconnect with a hug or kind words. Children need to know that your love isn't conditional on perfect behavior. The relationship always comes first."
            ]
        },
        {
            "title": "Set Clear Expectations",
            "subtitle": "Children thrive with predictable boundaries",
            "tips": [
                "State expectations clearly and positively: 'We walk inside' rather than 'Don't run.' Children's brains hear the action word most clearly—tell them what TO do, not just what not to do.",
                "Keep rules simple and few. Young children can only remember 3-5 key rules. Focus on the most important ones (usually about safety and respect) and let smaller things go.",
                "Give advance warnings before transitions: 'In 5 minutes, we're going to clean up and get ready for dinner.' Sudden changes trigger resistance in children who need time to shift gears.",
                "Be consistent. If jumping on the couch isn't allowed, it's not allowed today either. Inconsistent enforcement confuses children and leads to more testing of boundaries.",
                "Use visual schedules or charts for routines. Many behavior challenges are actually about children not knowing what comes next. When they can see the sequence, they can follow it."
            ]
        },
        {
            "title": "Natural Consequences",
            "subtitle": "Let the world teach when it's safe to do so",
            "tips": [
                "Natural consequences teach more effectively than punishment. If they refuse to wear a jacket, they get cold. If they break a toy in anger, the toy is broken. Reality is the teacher.",
                "Only use natural consequences when they're safe and immediate. A consequence that happens days later or is dangerous (running into traffic) doesn't apply—you need to intervene directly.",
                "Resist the urge to say 'I told you so.' Simply empathize: 'You're cold now without your jacket. That's uncomfortable.' Let them experience the lesson without adding shame.",
                "For situations where natural consequences don't work, use logical consequences that are related, reasonable, and respectful. Losing iPad time because of fighting over the iPad makes sense.",
                "Focus on problem-solving together: 'The toy got broken when you threw it. What can we do to make this better?' This teaches responsibility better than punishment."
            ]
        },
    ],
    "separation_anxiety": [
        {
            "title": "Goodbyes That Help",
            "subtitle": "How you leave matters as much as that you leave",
            "tips": [
                "Keep goodbyes brief but warm. Long, drawn-out departures with multiple hugs and reassurances actually increase anxiety by signaling that the separation is a big deal worth worrying about.",
                "Never sneak away. It might seem easier in the moment, but it erodes trust and increases anxiety about future separations. They need to know you won't disappear without warning.",
                "Create a goodbye ritual: a special handshake, three kisses, 'I love you, I'll be back.' Predictable rituals give children something to hold onto and mark the transition clearly.",
                "Use matter-of-fact language: 'Mommy is going to work now. I'll pick you up after snack time. You're going to have fun with your friends.' Confidence is contagious—so is anxiety.",
                "Trust the caregivers. In most cases, children calm down within minutes of parents leaving. Ask them to text you an update. Knowing your child recovered quickly helps you stay calm too."
            ]
        },
        {
            "title": "Building Separation Skills",
            "subtitle": "Practice makes brave",
            "tips": [
                "Start with small separations and build up gradually. Short visits to grandma's house or a trusted friend prepare children for longer separations like school or daycare.",
                "Play peek-a-boo and hide-and-seek with younger children. These games teach the fundamental concept that people go away and come back—object permanence applied to relationships.",
                "Leave your child with trusted caregivers regularly, even if you don't need to. Children who only separate when absolutely necessary don't get practice building their 'I can do this' muscle.",
                "Read books about separation and school. Stories normalize the experience and give children language and strategies. 'The Kissing Hand' and 'Llama Llama Misses Mama' are popular favorites.",
                "Talk positively about the place you're leaving them and the people there. Your attitude shapes theirs. 'Your teacher is so kind' rather than 'I hope they treat you okay.'"
            ]
        },
        {
            "title": "When Anxiety Is Bigger",
            "subtitle": "Knowing when separation anxiety needs extra support",
            "tips": [
                "Some separation anxiety is developmentally normal and peaks around 8-14 months, and again between 18 months and 3 years. These phases pass with time and patient consistency.",
                "Concerning signs include: anxiety that lasts beyond a few minutes, physical symptoms like stomachaches or headaches, nightmares about separation, or refusal to go to previously enjoyed places.",
                "Avoid accommodating the anxiety by letting them skip school or activities. This provides short-term relief but reinforces that the situation is dangerous, making anxiety worse long-term.",
                "Work with teachers and caregivers on a consistent plan. Everyone should respond the same way to the anxiety—with warmth, confidence, and the expectation that the child can cope.",
                "If separation anxiety significantly impacts daily life for more than a few weeks, consider consulting a child psychologist. Early intervention for anxiety disorders is highly effective."
            ]
        },
    ],
    "social_skills": [
        {
            "title": "Practice Through Play",
            "subtitle": "Social skills develop through doing, not lecturing",
            "tips": [
                "Arrange regular playdates with one child at a time. Large groups can be overwhelming—one-on-one play allows children to practice sharing, turn-taking, and conflict resolution with support.",
                "Stay nearby during playdates for young children, ready to coach in the moment: 'Maya wants a turn. What could you say to her?' rather than solving it for them or just saying 'Share!'",
                "Use pretend play to practice social situations. Play 'friends at school' with stuffed animals or dolls. Act out scenarios like joining a game or dealing with someone who's mean.",
                "Board games, cooperative games, and sports teach turn-taking, winning and losing gracefully, and working toward shared goals. Choose age-appropriate options and expect learning curves.",
                "Celebrate social effort, not just successful outcomes: 'I saw you ask to join that game—that was brave!' Even if it didn't work out perfectly, they're building important skills."
            ]
        },
        {
            "title": "Teach Specific Skills",
            "subtitle": "Break down 'social skills' into learnable pieces",
            "tips": [
                "Teach conversation basics: how to start ('What are you playing?'), how to keep going (asking questions, sharing something related), and how to end ('Bye! See you tomorrow!').",
                "Role-play common situations at home: 'Let's practice what you could say if someone takes your toy.' Give them actual words to use: 'Hey, I was playing with that. Can I have a turn?'",
                "Help children read social cues: 'Look at Maya's face. Does she look like she wants to play that game, or not?' Point out body language and tone of voice as clues.",
                "Teach repair skills for when things go wrong: how to apologize sincerely, how to ask to start over, how to give space and try again later. Everyone makes social mistakes—repair is key.",
                "Model the skills you want to see. Narrate your own social interactions: 'I'm going to ask Mrs. Johnson how her day is going—that's a friendly thing to do.' Children learn from watching you."
            ]
        },
        {
            "title": "Supporting Shy Children",
            "subtitle": "Helping without pushing",
            "tips": [
                "Respect their temperament. Some children are naturally more cautious in social situations. This isn't a problem to fix—it's a trait to work with. Slow-to-warm children often become thoughtful friends.",
                "Don't force interactions or speak for them. Saying 'Say hi to Mrs. Chen' on the spot usually backfires. Instead, prepare them: 'We're going to see Mrs. Chen—you can wave or say hi if you want.'",
                "Give them time to warm up. Arrive at parties or playdates early so they can settle in before the crowd. Let them observe from the sidelines before expecting participation.",
                "Find their social strengths. Maybe they're great one-on-one but struggle in groups. Maybe they shine in structured activities but not free play. Build on what works.",
                "Avoid labeling them as 'shy' in their hearing. Children live up to labels. Instead try 'She takes her time getting to know new people—she's really observant.'"
            ]
        },
    ],
    "confidence": [
        {
            "title": "Praise Effort, Not Results",
            "subtitle": "Build a growth mindset through your words",
            "tips": [
                "Say 'You worked so hard on that!' rather than 'You're so smart!' Praising effort teaches that achievement comes from work, not fixed talent. This builds resilience when things get hard.",
                "Be specific in your praise: 'I noticed you kept trying even when the puzzle was frustrating' rather than generic 'Good job!' Specific praise tells them exactly what behavior to repeat.",
                "Celebrate the process, not just outcomes: 'What was your favorite part of making that?' 'What was tricky about it?' This shows you value their effort and learning journey, not just the finished product.",
                "Normalize failure as part of learning: 'Everyone makes mistakes when they're learning something new—that's how our brains grow!' Share your own mistakes and what you learned from them.",
                "Avoid over-praising everything. When everything gets 'amazing!' nothing feels special. Save enthusiastic praise for genuine effort and let some things simply be: 'You finished your drawing. Let's put it on the fridge.'"
            ]
        },
        {
            "title": "Let Them Struggle (a Little)",
            "subtitle": "Rescued children don't learn they can cope",
            "tips": [
                "Resist the urge to jump in and fix everything. When your child struggles with a zipper, a puzzle, or a friendship issue, pause and ask 'Would you like help, or do you want to try yourself?'",
                "Tolerate their frustration without rescuing. Say 'This is hard! I believe you can figure it out' rather than taking over. Mastering something difficult builds genuine confidence.",
                "Break challenges into smaller steps if they're overwhelmed: 'First, line up the zipper at the bottom. Good. Now try pulling up slowly.' Support without doing it for them.",
                "Celebrate struggle as much as success: 'You tried three different ways before it worked—that's exactly what scientists do!' Frame difficulty as evidence of meaningful work.",
                "Let natural consequences teach when safe. If they forget homework, don't rush to rescue. Experiencing the consequence builds responsibility and confidence in their ability to handle outcomes."
            ]
        },
        {
            "title": "Give Real Responsibility",
            "subtitle": "Contribution builds capability",
            "tips": [
                "Assign age-appropriate household tasks and treat them as real contributions: 'We need you to set the table because that's your important job in our family.' Responsibility builds competence and belonging.",
                "Let them make age-appropriate decisions: what to wear, which snack to have, which book to read. Practice making choices in low-stakes situations prepares them for bigger decisions later.",
                "Involve them in family problem-solving: 'We're always running late in the mornings. What ideas do you have?' Children who contribute to solutions feel capable and valued.",
                "Accept imperfect results. Yes, they'll put the forks on the wrong side. Yes, their bed-making will be lumpy. The goal is building capability and confidence, not perfect outcomes.",
                "Gradually increase autonomy as they demonstrate readiness. Walk them to a friend's house, then watch from down the street, then let them go alone. Build independence step by step."
            ]
        },
    ],
    "emotional_regulation": [
        {
            "title": "Name It to Tame It",
            "subtitle": "Emotions become manageable when we can label them",
            "tips": [
                "Help children build emotional vocabulary: frustrated, disappointed, nervous, excited, jealous, overwhelmed. 'It looks like you might be feeling disappointed that we can't go to the park.'",
                "Use books, shows, and daily life to discuss emotions: 'How do you think that character feels? What clues tell you that?' This builds emotional intelligence in low-stress moments.",
                "Share your own emotions appropriately: 'I'm feeling frustrated that traffic is so slow. I'm going to take some deep breaths.' This models both emotion identification and coping.",
                "Validate before you problem-solve: 'You're really sad that your friend moved away. That's such a hard feeling.' Acknowledged emotions pass more quickly than dismissed ones.",
                "Create a feelings chart or poster they can point to when they can't find words. Sometimes 'I feel like the angry emoji' is a great start when they're still developing vocabulary."
            ]
        },
        {
            "title": "Calming Strategies Toolkit",
            "subtitle": "Build a variety of coping skills to choose from",
            "tips": [
                "Teach deep breathing with kid-friendly cues: 'Smell the flowers (breathe in), blow out the candles (breathe out)' or 'Take a balloon breath—fill your belly up, then slowly let the air out.'",
                "Physical movement helps process emotions: running outside, jumping on a mini trampoline, squeezing a stress ball, or pushing against a wall. Big feelings need physical release.",
                "Create a 'calm-down kit' together: playdough, squishy toys, coloring pages, calming music playlist, photos of happy memories. Let them choose what goes in it—they know what helps them.",
                "Practice strategies when calm, not during meltdowns. You can't learn to swim while drowning. Regular practice when relaxed means the skills are accessible during upset.",
                "Different strategies work for different children—and different situations. Help them notice: 'Deep breathing works best when you're worried, but running helps more when you're angry.'"
            ]
        },
        {
            "title": "Co-Regulation First",
            "subtitle": "Children learn to self-soothe through being soothed",
            "tips": [
                "Young children can't self-regulate alone—they need a calm adult presence to borrow regulation from. Your steady breathing, soft voice, and relaxed body help regulate their nervous system.",
                "Stay physically close during big emotions if they'll let you. Sometimes silent presence—sitting nearby, a hand on their back—communicates support without requiring them to listen to words.",
                "The goal isn't to eliminate emotions but to help them move through. 'I'm right here while you feel this big feeling. It will pass.' Emotions are like waves—they rise and fall.",
                "After the emotion passes, reflect together: 'That was a big feeling. What did you notice in your body? What helped you start to feel better?' Build self-awareness over time.",
                "Take care of your own regulation. You can't pour from an empty cup. If you're frequently dysregulated, your child can't borrow calm from you. Parental self-care is child care."
            ]
        },
    ],
}

def get_fallback_cards(topic_id):
    """Get rich template cards if AI fails"""
    return RICH_TEMPLATES.get(topic_id, RICH_TEMPLATES.get("behavior", []))

# ─────────────────────────────────────────────────────────────
# MAIN GENERATION PIPELINE
# ─────────────────────────────────────────────────────────────

def generate_cards_for_topic(topic_id, use_ai=True):
    """Generate enhanced cards for a topic"""
    meta = TOPIC_META.get(topic_id, {"title": topic_id})
    print(f"\n📝 Generating cards for: {meta.get('title', topic_id)}")
    
    # Scrape URLs
    scraped = scrape_topic_urls(topic_id)
    print(f"  📚 Scraped {len(scraped)} articles")
    
    # Generate with AI or use templates
    cards = None
    if use_ai and scraped:
        cards = generate_cards_with_gemini(topic_id, scraped)
        if cards:
            print(f"  ✅ AI generated {len(cards)} cards")
    
    if not cards:
        print(f"  📋 Using rich templates")
        cards = get_fallback_cards(topic_id)
    
    # Format output
    output_cards = []
    for i, card in enumerate(cards):
        output_cards.append({
            "id": str(hashlib.md5(f"{topic_id}_{i}_{card.get('title', '')}".encode()).hexdigest()),
            "topic_id": topic_id,
            "title": card.get("title", f"Tip {i+1}"),
            "subtitle": card.get("subtitle", ""),
            "tips": card.get("tips", []),
            "age_groups": meta.get("age_groups", ["2-4", "4-6", "6-8"]),
            "emoji": meta.get("emoji", "📌"),
            "color_theme": meta.get("color_theme", "warm_purple"),
            "source_articles": [s.get("url", "") for s in scraped[:3]],
            "generated_at": datetime.now().isoformat(),
            "generation_method": "ai" if cards == cards else "template"
        })
    
    # Save to file
    output_path = os.path.join(OUTPUT_DIR, f"{topic_id}.json")
    with open(output_path, 'w') as f:
        json.dump(output_cards, f, indent=2, ensure_ascii=False)
    print(f"  💾 Saved {len(output_cards)} cards to {output_path}")
    
    return output_cards

def generate_all_cards(use_ai=True):
    """Generate cards for all topics"""
    print("\n" + "="*60)
    print("🎴 ENHANCED CARD GENERATOR - 3+ Line Tips")
    print("="*60)
    
    all_cards = []
    
    for topic_id in TOPIC_URLS.keys():
        cards = generate_cards_for_topic(topic_id, use_ai=use_ai)
        all_cards.extend(cards)
    
    # Save all cards to single file
    all_cards_path = os.path.join(OUTPUT_DIR, "all_enhanced_cards.json")
    with open(all_cards_path, 'w') as f:
        json.dump(all_cards, f, indent=2, ensure_ascii=False)
    
    print("\n" + "="*60)
    print("✅ GENERATION COMPLETE")
    print("="*60)
    print(f"Total cards: {len(all_cards)}")
    print(f"Output: {all_cards_path}")
    
    return all_cards

# ─────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────
if __name__ == '__main__':
    import sys
    
    use_ai = '--no-ai' not in sys.argv and HAS_GEMINI and GEMINI_API_KEY
    
    if not use_ai:
        print("⚠️ Running with templates (no AI)")
    
    generate_all_cards(use_ai=use_ai)
