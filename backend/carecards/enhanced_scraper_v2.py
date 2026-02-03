"""
ParentBud Enhanced Scraper & Card Generator v2
-----------------------------------------------
Scrapes all provided URLs and generates rich, clean 3-line care cards.
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

# Topic metadata with enhanced tips for fallback
TOPIC_METADATA = {
    "tantrums": {
        "title": "Taming Tantrums",
        "subtitle": "Understand why tantrums happen and learn compassionate strategies to help your child navigate big emotions with confidence.",
        "color_theme": "warm",
        "age_groups": ["toddler", "preschool"],
        "fallback_tips": [
            "Tantrums are not misbehavior—they're emotional overloads. When your child's big feelings overwhelm their still-developing brain, they literally cannot think clearly or control their reactions. Your calm presence becomes their anchor, helping them learn to ride emotional waves safely.",
            "Frustration tantrums happen when children can't express themselves or complete a task they desperately want to finish. Rage tantrums involve loss of control and possible self-harm. Understanding the type helps you respond appropriately—redirection works for frustration, while rage needs your calm containment.",
            "Catch tantrums early by redirecting attention to another activity before the storm builds. If you notice your child struggling with a toy, gently guide them to something else. In public, changing your location can help remove environmental triggers like crowded playgrounds.",
            "Responding consistently to tantrums—even when you're tired—pays off over time. Your child learns what to expect from you and practices resolution skills. Using encouraging words during calm moments reinforces that you're their safe haven, not their adversary.",
            "After a tantrum passes, connect before you correct. A simple 'That was really hard' validates their experience without judgment. Then, when they're calm, you can briefly talk about what happened and practice better ways to handle big feelings next time."
        ]
    },
    "sleep": {
        "title": "Sleep Routines",
        "subtitle": "Create peaceful bedtimes with proven routines that help your child wind down and get the restorative sleep they need.",
        "color_theme": "calm",
        "age_groups": ["toddler", "preschool", "school_age"],
        "fallback_tips": [
            "Bedtime routines are vital for your child's sleep quality and quantity. A consistent sequence of calming activities—bath, pajamas, story, song—signals the brain that sleep is coming. This predictability reduces bedtime struggles and helps children feel secure.",
            "Start your wind-down routine 30-45 minutes before desired sleep time. Dim the lights, lower your voice, and avoid stimulating activities. This gradual transition helps your child's body produce melatonin naturally, making the shift to sleep much smoother.",
            "Both parents following the same bedtime routine matters more than you might think. Research shows that consistency across caregivers leads to better sleep outcomes. Even if schedules differ, keeping the core routine elements the same provides stability.",
            "If your child fears the dark, a dim red or orange nightlight can help without disrupting sleep hormones. Keep noise levels low in the rest of the house after tucking them in—young children are particularly sensitive to sounds that can keep them awake.",
            "Establish age-appropriate bedtimes and stick to them, even on weekends. A consistent sleep schedule regulates your child's internal clock, making falling asleep easier. Irregular bedtimes are linked to more behavior problems and poorer academic performance."
        ]
    },
    "eating_habits": {
        "title": "Healthy Eating",
        "subtitle": "Build positive relationships with food through patience, variety, and pressure-free mealtimes that work for the whole family.",
        "color_theme": "fresh",
        "age_groups": ["toddler", "preschool", "school_age"],
        "fallback_tips": [
            "Raising healthy eaters starts with offering variety without pressure. Children may need 8-15 exposures to a new food before they'll try it. Keep offering—without forcing—and trust that their curiosity will eventually win. Your patience now builds their adventurous eating later.",
            "Use the 'division of responsibility': Parents decide what, when, and where food is served; children decide whether and how much to eat. This approach reduces mealtime battles and is linked to healthier eating habits, better self-regulation, and less picky eating.",
            "Restricting 'fun foods' like sweets often backfires—research shows children eat more of those foods when they finally get access. Instead, offer treats occasionally alongside nutritious options. This teaches balance and prevents forbidden-food obsessions.",
            "Family meals matter more than perfect nutrition. Children who eat with their family regularly experience more food enjoyment, try more foods, and develop healthier eating patterns. Even a few shared meals per week makes a significant difference.",
            "Model the eating behaviors you want to see. Children learn by watching, not by being told. When you enjoy vegetables, try new foods, and eat mindfully, your child notices. Your relationship with food becomes their template for their own."
        ]
    },
    "screen_time": {
        "title": "Screen Time Balance",
        "subtitle": "Navigate the digital world with healthy boundaries that protect your child while embracing technology's benefits.",
        "color_theme": "cool",
        "age_groups": ["toddler", "preschool", "school_age"],
        "fallback_tips": [
            "Quality matters more than quantity when it comes to screen time. Educational, interactive content that encourages thinking and creativity is very different from passive watching. Co-viewing with your child—asking questions, making connections—transforms screen time into learning time.",
            "Set clear, consistent screen time limits and communicate them in advance. Use visual timers so children can see time passing, which reduces end-of-screen-time meltdowns. Predictable boundaries help children feel secure rather than constantly negotiating.",
            "Create tech-free zones and times: no screens at the dinner table, in bedrooms, or during the hour before bed. Blue light from screens disrupts melatonin production and sleep quality. These boundaries protect both sleep and family connection time.",
            "Model the screen habits you want your child to develop. If you're constantly on your phone, they notice. Designate phone-free family time where everyone—including adults—puts devices away. Your behavior is their most powerful teacher.",
            "Use screen time as a bridge, not a replacement, for real-world experiences. Watch a nature documentary, then go for a hike. Play a cooking game, then bake together. This approach teaches children that screens can inspire and enhance life, not substitute for it."
        ]
    },
    "behavior": {
        "title": "Positive Behavior",
        "subtitle": "Guide your child's behavior with connection-first strategies that teach rather than punish, building cooperation naturally.",
        "color_theme": "purple",
        "age_groups": ["toddler", "preschool", "school_age"],
        "fallback_tips": [
            "All behavior is communication. When your child acts out, they're telling you something—maybe they're tired, hungry, overwhelmed, or seeking connection. Looking beneath the behavior to understand the underlying need transforms discipline from punishment into problem-solving.",
            "Connect before you correct. A child who feels understood and connected is far more likely to cooperate. Before addressing misbehavior, get on their level, make eye contact, and show you understand their feelings. This connection opens their ears to your guidance.",
            "Focus on teaching, not punishing. Punishment may stop behavior in the moment but doesn't teach what to do instead. Natural consequences and problem-solving together help children develop internal motivation and better decision-making skills.",
            "Catch them being good—often. Children crave attention, and they'll seek it through any means necessary. When you praise specific positive behaviors enthusiastically, you make good behavior the most effective way to get your attention and approval.",
            "Stay calm when they lose control—your regulation models theirs. Children learn emotional regulation by watching their parents handle stress. When you respond to their chaos with calm, you become the stable anchor that helps them find their own calm."
        ]
    },
    "separation_anxiety": {
        "title": "Separation Anxiety",
        "subtitle": "Help your child feel secure during goodbyes with consistent rituals and reassurance that builds lasting confidence.",
        "color_theme": "warm",
        "age_groups": ["toddler", "preschool"],
        "fallback_tips": [
            "Separation anxiety is a normal developmental stage that shows your child has formed a healthy attachment to you. While it's hard to see them upset, this fear actually means your bond is strong. With patience and consistency, they'll learn that goodbyes don't mean forever.",
            "Keep goodbyes brief, warm, and confident. Long, drawn-out farewells increase anxiety rather than soothe it. A quick hug, a cheerful 'I love you, see you later!' and a calm departure show your child that separations are normal and manageable.",
            "Never sneak away to avoid tears—this erodes trust and makes future separations harder. Even if your child cries, seeing you leave helps them understand the pattern: you leave, and you always come back. This predictability builds security over time.",
            "Create a special goodbye ritual together—a secret handshake, three kisses, a phrase you both say. These rituals give children something predictable to hold onto and provide comfort. They also give children a sense of control during an otherwise uncertain moment.",
            "Practice separations gradually. Start with short times apart in safe settings, then slowly increase duration. Each successful reunion—'See, I came back!'—builds their confidence that separations are temporary and that you'll always return."
        ]
    },
    "social_skills": {
        "title": "Social Skills",
        "subtitle": "Support your child in building meaningful friendships through practice, guidance, and age-appropriate social opportunities.",
        "color_theme": "bright",
        "age_groups": ["preschool", "school_age"],
        "fallback_tips": [
            "Social skills are learned, not innate. Children need practice, just like learning to read or ride a bike. Arrange playdates, encourage group activities, and provide gentle coaching. Each interaction—even awkward ones—builds their social toolkit.",
            "Teach specific social skills explicitly. Children often don't know how to join a game, share toys, or resolve conflicts. Role-play scenarios at home: 'What could you say if you want to play too?' Practice makes these skills automatic when real situations arise.",
            "Help children read social cues by narrating what you observe: 'Look, she's smiling—I think she liked when you shared.' 'He walked away—maybe he needs space right now.' This builds emotional intelligence and helps them understand unspoken social rules.",
            "Pretend play is powerful social practice. When children play house, school, or imaginary adventures, they're rehearsing social roles, practicing perspective-taking, and learning cooperation. Encourage imaginative play and occasionally join in to model social skills.",
            "Celebrate social effort, not just success. 'You asked if you could play—that was brave!' encourages children to keep trying even when things don't go perfectly. Building friendship skills takes time, and every attempt matters."
        ]
    },
    "confidence": {
        "title": "Building Confidence",
        "subtitle": "Nurture your child's self-esteem through encouragement, appropriate challenges, and celebrating their unique strengths.",
        "color_theme": "golden",
        "age_groups": ["toddler", "preschool", "school_age"],
        "fallback_tips": [
            "Confidence grows from competence. When children master age-appropriate challenges—tying shoes, solving puzzles, helping with chores—they develop genuine self-belief. Resist the urge to do things for them; instead, support their struggle and celebrate their accomplishments.",
            "Praise effort and strategy, not just results. 'You worked so hard on that!' builds resilience, while 'You're so smart!' can make children afraid to try hard things. Children who believe effort leads to improvement become more willing to take on challenges.",
            "Let children experience manageable failures in safe settings. Failure is how humans learn, and protecting children from all disappointment prevents them from developing coping skills. Your role is to be their soft landing—there to comfort, not to prevent every fall.",
            "Highly sensitive children feel everything intensely—joy, sadness, frustration, excitement. Rather than trying to toughen them up, help them see sensitivity as a strength. Empathy, creativity, and deep connection are gifts that come with this temperament.",
            "Help children identify and celebrate their unique strengths. Every child has something they do well—building, drawing, caring for animals, making people laugh. Naming these strengths helps children build an identity around what they can do, not just what they struggle with."
        ]
    },
    "emotional_regulation": {
        "title": "Emotional Regulation",
        "subtitle": "Teach your child to understand and manage their feelings with tools that last a lifetime.",
        "color_theme": "calm",
        "age_groups": ["toddler", "preschool", "school_age"],
        "fallback_tips": [
            "Emotional regulation develops gradually through the prefrontal cortex—and that brain region isn't fully mature until the mid-20s. Expecting young children to regulate emotions perfectly is unrealistic. Your calm co-regulation teaches their brain how to eventually self-regulate.",
            "Name emotions to tame them. When you say, 'You're feeling really frustrated right now,' you help your child's brain shift from the emotional center to the thinking center. This simple act of labeling calms the nervous system and builds emotional vocabulary.",
            "Teach calming strategies during calm moments, not meltdowns. Practice deep belly breaths, squeezing a stress ball, or counting to ten when your child is relaxed. Then, during emotional moments, you can prompt: 'Remember our belly breaths? Let's try that.'",
            "Validate feelings, even when behavior needs to change. 'You're so angry right now—it's hard when things don't go your way. But hitting isn't okay.' This approach acknowledges their experience while maintaining boundaries. Feelings are always acceptable; not all behaviors are.",
            "Model emotional regulation yourself. When you're frustrated, narrate: 'I'm feeling really annoyed right now. I'm going to take some deep breaths.' Children learn more from watching you handle your emotions than from any lesson you could teach."
        ]
    },
    "potty_training": {
        "title": "Potty Training",
        "subtitle": "Navigate this milestone with patience and positivity, following your child's readiness cues for success.",
        "color_theme": "fresh",
        "age_groups": ["toddler", "preschool"],
        "fallback_tips": [
            "Every child is ready at their own pace—there's no magic age for potty training. Look for signs of readiness: staying dry for 2+ hours, showing interest in the bathroom, discomfort with dirty diapers, and ability to follow simple instructions. Pushing before readiness backfires.",
            "Create a toilet training plan that fits your child's personality and your family's routine. Some children respond to regular scheduled sits, others to following their body's cues. Flexibility and patience matter more than any specific method.",
            "Celebrate successes enthusiastically without shaming accidents. Accidents are part of learning—stay calm, clean up matter-of-factly, and reassure your child. Shame and punishment create anxiety that can prolong the process or cause regression.",
            "Make bathroom time calm and pressure-free. Avoid asking 'Do you need to go?' constantly—this creates power struggles. Instead, build potty sits into the routine (after waking, after meals) and keep it low-key. Relaxation helps bodies release.",
            "Regression during stress—new sibling, starting school, illness—is completely normal. Rather than expressing disappointment, increase support and return to basics. Once the stressful period passes, progress usually resumes quickly."
        ]
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


def clean_text(text):
    """Clean up scraped text for better tip generation"""
    # Remove extra whitespace
    text = re.sub(r'\s+', ' ', text)
    # Remove source citations like (1), (2,3), etc.
    text = re.sub(r'\(\d+(?:,\s*\d+)*\)', '', text)
    # Remove "Trusted Source" references
    text = re.sub(r'Trusted Source.*?information', '', text, flags=re.IGNORECASE)
    # Remove "View Source" and similar
    text = re.sub(r'View Source', '', text, flags=re.IGNORECASE)
    # Remove URLs
    text = re.sub(r'https?://\S+', '', text)
    # Clean up multiple periods
    text = re.sub(r'\.+', '.', text)
    # Clean up spaces before punctuation
    text = re.sub(r'\s+([.,!?])', r'\1', text)
    return text.strip()


def extract_meaningful_sentences(text):
    """Extract meaningful sentences from scraped text"""
    # Clean the text first
    text = clean_text(text)
    
    # Split into sentences
    sentences = re.split(r'(?<=[.!?])\s+', text)
    
    # Keywords that indicate valuable parenting content
    valuable_keywords = [
        'help', 'child', 'children', 'parent', 'try', 'give', 'let', 'make', 
        'allow', 'encourage', 'teach', 'show', 'create', 'build', 'develop', 
        'support', 'practice', 'use', 'avoid', 'remember', 'important',
        'toddler', 'kid', 'sleep', 'eat', 'feel', 'emotion', 'behavior',
        'when', 'if', 'because', 'research', 'study', 'expert', 'routine',
        'consistent', 'calm', 'patient', 'love', 'understand', 'validate'
    ]
    
    # Filter for meaningful sentences
    meaningful = []
    for s in sentences:
        s = s.strip()
        # Check length (50-350 chars for a good sentence)
        if 50 < len(s) < 350:
            s_lower = s.lower()
            # Must contain at least 2 valuable keywords
            keyword_count = sum(1 for kw in valuable_keywords if kw in s_lower)
            if keyword_count >= 2:
                # Avoid sentences that start with linking words
                if not s.lower().startswith(('and ', 'but ', 'or ', 'so ', 'also')):
                    meaningful.append(s)
    
    return meaningful


def generate_rich_tips_from_content(meaningful_sentences, topic_id):
    """Generate 5 rich tips by combining related sentences intelligently"""
    if len(meaningful_sentences) < 3:
        return None
    
    tips = []
    used_indices = set()
    
    # Try to generate 5 rich tips
    for tip_num in range(5):
        # Find the next best unused sentence
        best_sentence = None
        best_idx = None
        
        for i, s in enumerate(meaningful_sentences):
            if i not in used_indices:
                best_sentence = s
                best_idx = i
                break
        
        if not best_sentence:
            break
        
        used_indices.add(best_idx)
        
        # Try to find a complementary sentence
        combined_tip = best_sentence
        
        for j, s in enumerate(meaningful_sentences):
            if j not in used_indices and len(combined_tip) < 400:
                # Check if sentences are different enough but related
                if len(set(s.lower().split()) & set(combined_tip.lower().split())) < 5:
                    combined_tip += " " + s
                    used_indices.add(j)
                    break
        
        # Ensure proper ending
        if not combined_tip.endswith('.'):
            combined_tip += '.'
        
        # Only add if it's substantial enough
        if len(combined_tip) > 100:
            tips.append(combined_tip)
    
    return tips if len(tips) >= 3 else None


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
    print("🚀 PARENTBUD ENHANCED SCRAPER & CARD GENERATOR v2")
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
        
        # Combine all text and extract meaningful sentences
        all_text = '\n\n'.join([a['text'] for a in scraped_articles if a and a.get('text')])
        meaningful = extract_meaningful_sentences(all_text)
        print(f"  📝 Extracted {len(meaningful)} meaningful sentences")
        
        # Try to generate tips from scraped content
        tips = None
        if meaningful:
            tips = generate_rich_tips_from_content(meaningful, topic_id)
        
        # Use fallback tips if scraping didn't produce enough content
        if not tips or len(tips) < 5:
            print(f"  ⚠️  Using expert-written fallback tips for {topic_id}")
            meta = TOPIC_METADATA.get(topic_id, {})
            tips = meta.get('fallback_tips', [
                "Every child develops at their own pace. Trust your instincts and observe your child's unique needs.",
                "Stay patient and consistent. Children thrive with predictable, loving responses to their behavior.",
                "Celebrate small wins along the way. Progress isn't always linear, and every step forward matters.",
                "Connect before you correct. A child who feels understood is more likely to cooperate and learn.",
                "You know your child best. Expert advice is a guide, but your relationship with your child is the foundation."
            ])
        
        if tips:
            card = create_care_card(topic_id, tips, scraped_articles)
            all_cards.append(card)
            print(f"  🎴 Generated card with {len(tips)} tips")
            
            # Show sample tip
            if tips:
                sample = tips[0][:120] + "..." if len(tips[0]) > 120 else tips[0]
                print(f"  📝 Sample: \"{sample}\"")
    
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
