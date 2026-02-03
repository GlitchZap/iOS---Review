"""
ParentBud Card Generator V2
---------------------------
Generates age-specific, shuffle-able care cards from scraped articles.
Creates 10+ cards per topic with variations for personalization.

Output Format:
{
    "id": "unique-uuid",
    "topic_id": "tantrums",
    "age_groups": ["2-4", "4-6"],
    "title": "Short Title",
    "subtitle": "One line description",
    "tips": ["Tip 1", "Tip 2", "Tip 3", "Tip 4", "Tip 5"],
    "emoji": "🧘",
    "color_theme": "calm_blue",
    "source_articles": ["url1", "url2"],
    "variation": 1,
    "generated_at": "2024-01-15T10:00:00Z"
}
"""

import os
import json
import uuid
import random
from datetime import datetime
from typing import List, Dict, Optional

# ─────────────────────────────────────────────────────────────
# DIRECTORIES
# ─────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(__file__)
DATA_DIR = os.path.join(BASE_DIR, "data")
TOPIC_DIR = os.path.join(DATA_DIR, "by_topic")
AGE_DIR = os.path.join(DATA_DIR, "by_age")
CARDS_DIR = os.path.join(DATA_DIR, "cards_v2")
os.makedirs(CARDS_DIR, exist_ok=True)

# ─────────────────────────────────────────────────────────────
# LOAD OPENAI (OPTIONAL)
# ─────────────────────────────────────────────────────────────
OPENAI_API_KEY = os.environ.get('OPENAI_API_KEY')
openai_client = None
if OPENAI_API_KEY:
    try:
        from openai import OpenAI
        openai_client = OpenAI(api_key=OPENAI_API_KEY)
        print("✅ OpenAI client initialized")
    except ImportError:
        print("⚠️  openai package not installed, using fallback templates")
else:
    print("⚠️  OPENAI_API_KEY not set, using fallback templates")

# ─────────────────────────────────────────────────────────────
# TOPIC METADATA
# ─────────────────────────────────────────────────────────────
TOPIC_METADATA = {
    "tantrums": {
        "title": "Managing Tantrums",
        "emoji": "🌪️",
        "color_theme": "calm_orange",
        "variations": 12
    },
    "sleep_routines": {
        "title": "Sleep & Bedtime",
        "emoji": "🌙",
        "color_theme": "peaceful_purple",
        "variations": 12
    },
    "screen_time": {
        "title": "Screen Time Balance",
        "emoji": "📱",
        "color_theme": "tech_blue",
        "variations": 10
    },
    "eating_habits": {
        "title": "Healthy Eating",
        "emoji": "🥗",
        "color_theme": "fresh_green",
        "variations": 12
    },
    "potty_training": {
        "title": "Potty Training",
        "emoji": "🚽",
        "color_theme": "sunny_yellow",
        "variations": 10
    },
    "social_skills": {
        "title": "Social Skills",
        "emoji": "👥",
        "color_theme": "friendly_orange",
        "variations": 10
    },
    "separation_anxiety": {
        "title": "Separation Anxiety",
        "emoji": "🤗",
        "color_theme": "warm_pink",
        "variations": 10
    },
    "behavior_management": {
        "title": "Positive Discipline",
        "emoji": "⭐",
        "color_theme": "wise_blue",
        "variations": 12
    },
    "mixed_emotional_development": {
        "title": "Emotional Growth",
        "emoji": "❤️",
        "color_theme": "heart_red",
        "variations": 10
    },
    "mixed_confidence_independence": {
        "title": "Building Confidence",
        "emoji": "💪",
        "color_theme": "power_gold",
        "variations": 10
    },
    "mixed_sibling_family": {
        "title": "Family Harmony",
        "emoji": "👨‍👩‍👧‍👦",
        "color_theme": "family_teal",
        "variations": 10
    }
}

# ─────────────────────────────────────────────────────────────
# FALLBACK CARD TEMPLATES (when no AI)
# ─────────────────────────────────────────────────────────────
FALLBACK_CARDS = {
    "tantrums": [
        {
            "title": "Stay Calm First",
            "subtitle": "Your calm is their anchor during a storm",
            "tips": [
                "Take 3 deep breaths before responding",
                "Lower your body to their eye level",
                "Speak in a slow, quiet voice",
                "Remember: they're not giving you a hard time, they're having one",
                "Model the calm you want them to feel"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Validate Feelings",
            "subtitle": "Big feelings need acknowledgment",
            "tips": [
                "Say 'I see you're really upset right now'",
                "Name the emotion: 'You seem frustrated'",
                "Avoid saying 'calm down' or 'stop crying'",
                "Use phrases like 'It's hard when...'",
                "Show you understand before solving"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "Create a Calm-Down Space",
            "subtitle": "A special spot for big emotions",
            "tips": [
                "Set up a cozy corner with soft items",
                "Include sensory tools like stress balls",
                "Make it inviting, not a punishment zone",
                "Practice going there when calm",
                "Let them help decorate it"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Prevent Before It Starts",
            "subtitle": "Catch triggers before the meltdown",
            "tips": [
                "Notice hunger, tiredness, overstimulation",
                "Give transition warnings: '5 more minutes'",
                "Keep routines predictable",
                "Offer choices to give control",
                "Avoid stores when they're tired"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "The STOP Method",
            "subtitle": "A simple framework for meltdowns",
            "tips": [
                "S - Stop and stay calm yourself",
                "T - Take a breath together",
                "O - Observe what triggered this",
                "P - Proceed with empathy first",
                "Practice when things are calm"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Connect Before Correct",
            "subtitle": "Relationship first, lesson second",
            "tips": [
                "Wait until they're calm to discuss",
                "Get physical: hug, hand on shoulder",
                "Avoid lecturing in the moment",
                "Say 'I'm here' and wait",
                "Save the teaching for later"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Toddler Tantrum Survival",
            "subtitle": "What to do in the heat of the moment",
            "tips": [
                "Stay close but don't crowd",
                "Keep them safe from harm",
                "Don't give in to stop the tantrum",
                "Ignore the audience (they understand)",
                "This phase will pass"
            ],
            "age_groups": ["2-4"]
        },
        {
            "title": "Teaching Emotional Words",
            "subtitle": "Help them express instead of explode",
            "tips": [
                "Read books about emotions together",
                "Use feeling charts with faces",
                "Model naming your own feelings",
                "Play 'how would you feel if...' games",
                "Celebrate when they use words"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Older Kid Meltdowns",
            "subtitle": "When big kids have big feelings",
            "tips": [
                "Give space if they need it",
                "Don't embarrass them in front of others",
                "Have a code word for 'I need help'",
                "Discuss triggers when calm",
                "Teach self-regulation strategies"
            ],
            "age_groups": ["6-8", "8-10"]
        },
        {
            "title": "Physical Reset Techniques",
            "subtitle": "Help the body release big energy",
            "tips": [
                "Jumping jacks or silly dancing",
                "Bear hugs or squeeze balls",
                "Running outside or stomping feet",
                "Blowing bubbles for calm breathing",
                "Shaking it off like a wet dog"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "After the Storm",
            "subtitle": "What to do when calm returns",
            "tips": [
                "Reconnect with a hug or snuggle",
                "Briefly talk about what happened",
                "Problem-solve together for next time",
                "Don't hold grudges",
                "Move on and start fresh"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Know Your Triggers Too",
            "subtitle": "Parent self-care matters",
            "tips": [
                "Notice what sets YOU off",
                "Have your own calm-down strategy",
                "It's okay to walk away briefly",
                "Tag team with your partner",
                "You're doing better than you think"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        }
    ],
    "sleep_routines": [
        {
            "title": "Consistent Bedtime Routine",
            "subtitle": "Same steps, every night",
            "tips": [
                "Bath → PJs → Brush teeth → Stories → Bed",
                "Keep the routine 20-30 minutes",
                "Same order helps their brain wind down",
                "Start at the same time each night",
                "Weekend bedtimes within 30 min of weekday"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Create a Sleep Sanctuary",
            "subtitle": "Make the bedroom invitation to sleep",
            "tips": [
                "Keep the room cool (65-70°F)",
                "Use blackout curtains",
                "Try a white noise machine",
                "Remove screens and stimulating toys",
                "Make the bed cozy and inviting"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Wind Down Hour",
            "subtitle": "Calm activities before bed",
            "tips": [
                "No screens 1 hour before bed",
                "Dim the lights in the house",
                "Read books or tell quiet stories",
                "Gentle stretching or yoga",
                "Avoid sugar and heavy foods"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Toddler Sleep Tips",
            "subtitle": "Ages 2-4 sleep challenges",
            "tips": [
                "Handle the transition from crib carefully",
                "Use a toddler clock for 'okay to wake'",
                "Keep one comfort object allowed",
                "Be boring when they get up",
                "Praise staying in bed"
            ],
            "age_groups": ["2-4"]
        },
        {
            "title": "Bedtime Battles",
            "subtitle": "When they resist sleep",
            "tips": [
                "Give choices: 'Blue PJs or green?'",
                "Use a visual bedtime chart",
                "Set a timer for each step",
                "Stay calm and consistent",
                "Reward good nights, not perfect nights"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Night Waking Solutions",
            "subtitle": "When they wake in the night",
            "tips": [
                "Keep interactions brief and boring",
                "Don't turn on bright lights",
                "Comfort quickly, then leave",
                "Check for genuine needs first",
                "Be consistent with your response"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "Early Risers",
            "subtitle": "When 5am feels like morning",
            "tips": [
                "Use a color-changing toddler clock",
                "Keep the room dark in morning",
                "Put out quiet activities",
                "Gradually shift bedtime later",
                "Don't start the day until 'wake time'"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Monster Fears & Nightmares",
            "subtitle": "Calming bedtime anxieties",
            "tips": [
                "Take their fears seriously",
                "Create 'monster spray' (water + lavender)",
                "Read books about brave characters",
                "Check the room together",
                "Leave a dim nightlight on"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "School-Age Sleep",
            "subtitle": "Sleep needs for 6-10 year olds",
            "tips": [
                "They still need 9-12 hours",
                "Keep electronics charging outside bedroom",
                "Maintain bedtime routine even as they grow",
                "Allow some reading time in bed",
                "Watch for homework eating into sleep"
            ],
            "age_groups": ["6-8", "8-10"]
        },
        {
            "title": "Nap Transitions",
            "subtitle": "When naps change or end",
            "tips": [
                "Watch for signs they're ready",
                "Try quiet time instead of nap",
                "Move bedtime earlier temporarily",
                "Be prepared for cranky afternoons",
                "Most kids drop naps by age 5"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Travel & Time Changes",
            "subtitle": "Keeping sleep on track away from home",
            "tips": [
                "Bring familiar items: blanket, pillow",
                "Stick to routine as much as possible",
                "Adjust time zones gradually",
                "Expect some regression",
                "Get back on track quickly at home"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Sleep Regression Survival",
            "subtitle": "When good sleepers stop sleeping",
            "tips": [
                "Stay consistent with routines",
                "Don't create new habits you'll regret",
                "Check for underlying issues",
                "This too shall pass",
                "Ask for help if you're exhausted"
            ],
            "age_groups": ["2-4", "4-6"]
        }
    ],
    "screen_time": [
        {
            "title": "Set Clear Screen Limits",
            "subtitle": "Boundaries everyone understands",
            "tips": [
                "AAP recommends 1 hour/day for 2-5, 2 hours for 6+",
                "Use visual timers they can see",
                "Be consistent with rules",
                "Include all screens in the count",
                "Post the rules where everyone can see"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Co-View When Possible",
            "subtitle": "Screen time together is better",
            "tips": [
                "Watch shows together and discuss",
                "Play video games as a family",
                "Ask questions about what they're watching",
                "Connect content to real life",
                "Your presence makes it educational"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "Screen-Free Zones",
            "subtitle": "Protected spaces without screens",
            "tips": [
                "No screens at the dinner table",
                "Bedrooms are screen-free zones",
                "Car rides can be screen-free time",
                "Outdoor play is device-free",
                "Create a charging station outside bedrooms"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Quality Over Quantity",
            "subtitle": "Not all screen time is equal",
            "tips": [
                "Educational apps > passive videos",
                "Creative apps (art, music) are better",
                "Interactive > passive consumption",
                "Video calls with family count differently",
                "Preview content before allowing"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Transition Warnings",
            "subtitle": "End screen time without meltdowns",
            "tips": [
                "Give 10 min, 5 min, 2 min warnings",
                "Let them finish the level/episode",
                "Have an appealing next activity ready",
                "Use visual or audio timers",
                "Praise good transitions"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "Model Good Screen Habits",
            "subtitle": "They're watching your phone use too",
            "tips": [
                "Put your phone away during family time",
                "Have screen-free periods yourself",
                "Don't scroll while talking to them",
                "Show them you have other interests",
                "Announce when you're done with your phone"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Alternative Activities",
            "subtitle": "Fun things that aren't screens",
            "tips": [
                "Board games and puzzles",
                "Outdoor play and nature walks",
                "Arts and crafts projects",
                "Reading together",
                "Imaginative play and dress-up"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "Online Safety Basics",
            "subtitle": "Keeping older kids safe online",
            "tips": [
                "Keep devices in common areas",
                "Know their passwords",
                "Check in on what they're watching",
                "Have open conversations about content",
                "Use parental controls appropriately"
            ],
            "age_groups": ["6-8", "8-10"]
        },
        {
            "title": "Earning Screen Time",
            "subtitle": "Screens as privilege, not right",
            "tips": [
                "Complete responsibilities first",
                "Tie screen time to outdoor play time",
                "Use apps that track and reward",
                "Be consistent with the system",
                "Don't use screens as only reward"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Managing Screen Addiction Signs",
            "subtitle": "When screens become a problem",
            "tips": [
                "Watch for withdrawal when screens removed",
                "Notice if they only want screen activities",
                "Check for sleep and mood changes",
                "Gradually reduce, don't go cold turkey",
                "Seek help if needed"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        }
    ],
    "eating_habits": [
        {
            "title": "Division of Responsibility",
            "subtitle": "You decide what/when, they decide how much",
            "tips": [
                "You choose the foods offered",
                "You set meal and snack times",
                "They decide how much to eat",
                "They decide whether to eat at all",
                "Trust their hunger cues"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "No Pressure Mealtimes",
            "subtitle": "Relax—pressure backfires",
            "tips": [
                "No 'just one more bite'",
                "Don't bribe with dessert",
                "Keep mealtime pleasant",
                "Ignore what they don't eat",
                "Praise trying, not finishing"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "Exposure, Exposure, Exposure",
            "subtitle": "It takes 15-20 tries to like a food",
            "tips": [
                "Offer new foods alongside familiar ones",
                "Let them explore without eating",
                "Touching and smelling counts",
                "Don't give up after a few rejections",
                "Keep offering without pressure"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "Picky Eater Strategies",
            "subtitle": "Expand their palate gently",
            "tips": [
                "Serve at least one 'safe' food",
                "Let them help cook",
                "Make food fun with shapes/arrangements",
                "Eat together as a family",
                "Try dips and sauces"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Family Meals Matter",
            "subtitle": "Eating together changes everything",
            "tips": [
                "Aim for 5+ family meals per week",
                "Turn off screens during meals",
                "Make conversation the focus",
                "Everyone eats the same meal",
                "Keep it short if needed"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Smart Snacking",
            "subtitle": "Healthy fuel between meals",
            "tips": [
                "Set snack times, not all-day grazing",
                "Offer fruits, veggies, protein",
                "Don't use snacks as rewards",
                "Keep portions small",
                "Close kitchen between times"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Involve Kids in Food",
            "subtitle": "From store to table",
            "tips": [
                "Let them pick produce at the store",
                "Give age-appropriate kitchen tasks",
                "Grow a small herb or veggie garden",
                "Let them choose from 2-3 options",
                "Make cooking a fun activity"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Handle Sweets Wisely",
            "subtitle": "No forbidden foods",
            "tips": [
                "Don't make sweets 'forbidden'",
                "Serve dessert with the meal sometimes",
                "Keep portion sizes appropriate",
                "Don't use sweets as reward",
                "Teach moderation, not restriction"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Texture & Sensory Issues",
            "subtitle": "When it's more than picky eating",
            "tips": [
                "Respect genuine sensory aversions",
                "Introduce new textures slowly",
                "Offer foods in preferred textures",
                "Consider feeding therapy if severe",
                "Don't force gagging foods"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Healthy Relationship with Food",
            "subtitle": "Building lifelong habits",
            "tips": [
                "Avoid labeling foods 'good' or 'bad'",
                "Don't use food to comfort emotions",
                "Model enjoying variety yourself",
                "Talk positively about your body",
                "Focus on health, not weight"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Mealtime Structure",
            "subtitle": "Predictable meal rhythm",
            "tips": [
                "3 meals + 2-3 snacks daily",
                "Same times each day roughly",
                "2-3 hours between eating times",
                "Don't skip meals",
                "End meals after reasonable time"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Toddler Eating Reality",
            "subtitle": "What's normal at 2-4",
            "tips": [
                "Appetite varies wildly day to day",
                "Food jags are normal",
                "Growth slows, so does eating",
                "Messes are part of learning",
                "They won't starve themselves"
            ],
            "age_groups": ["2-4"]
        }
    ],
    "potty_training": [
        {
            "title": "Signs of Readiness",
            "subtitle": "Is your child ready?",
            "tips": [
                "Stays dry for 2+ hours",
                "Shows interest in the bathroom",
                "Can follow simple instructions",
                "Can pull pants up and down",
                "Tells you when diaper is wet/dirty"
            ],
            "age_groups": ["2-4"]
        },
        {
            "title": "Get the Right Gear",
            "subtitle": "Set up for success",
            "tips": [
                "Child-size potty or seat adapter",
                "Step stool for regular toilet",
                "Easy on/off pants (no buttons)",
                "Training underwear or pull-ups",
                "Books about potty for kids"
            ],
            "age_groups": ["2-4"]
        },
        {
            "title": "The 3-Day Method",
            "subtitle": "Intensive training approach",
            "tips": [
                "Clear your schedule for 3 days",
                "Stay home and near the potty",
                "Ditch diapers completely",
                "Watch for signs and rush to potty",
                "Celebrate every success"
            ],
            "age_groups": ["2-4"]
        },
        {
            "title": "Gentle Potty Training",
            "subtitle": "A slower, no-pressure approach",
            "tips": [
                "Let them sit on potty during routine",
                "No pressure to produce",
                "Follow their lead and interest",
                "Use pull-ups as transition",
                "May take weeks or months"
            ],
            "age_groups": ["2-4"]
        },
        {
            "title": "Handle Accidents Well",
            "subtitle": "They're part of learning",
            "tips": [
                "Stay calm and neutral",
                "Clean up matter-of-factly",
                "Say 'Accidents happen, let's try again'",
                "Never shame or punish",
                "Keep spare clothes everywhere"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Motivation & Rewards",
            "subtitle": "Celebrate progress",
            "tips": [
                "Sticker charts work for many kids",
                "Small treats for initial success",
                "Praise effort, not just results",
                "Special 'big kid' underwear",
                "Fade rewards as it becomes habit"
            ],
            "age_groups": ["2-4"]
        },
        {
            "title": "Nighttime Training",
            "subtitle": "A separate milestone",
            "tips": [
                "Nighttime dryness comes later",
                "Use waterproof mattress protector",
                "Limit fluids before bed",
                "Wake them to pee before you sleep",
                "Some kids aren't ready until 5-7"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Public Restroom Bravery",
            "subtitle": "Handling bathrooms out and about",
            "tips": [
                "Bring potty seat adapter in diaper bag",
                "Carry disposable seat covers",
                "Warn about loud flush sounds",
                "Let them cover ears for auto-flush",
                "Practice at quiet public restrooms"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Regression Solutions",
            "subtitle": "When trained kids have setbacks",
            "tips": [
                "Look for stressors (new sibling, school)",
                "Rule out medical issues (UTI)",
                "Go back to basics without shame",
                "Increase potty reminders",
                "Stay patient—it usually passes"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Wiping & Hygiene",
            "subtitle": "Teaching clean-up skills",
            "tips": [
                "Girls wipe front to back",
                "Teach proper amount of toilet paper",
                "Check their work for a while",
                "Hand washing is non-negotiable",
                "Full independence by kindergarten"
            ],
            "age_groups": ["2-4", "4-6"]
        }
    ],
    "social_skills": [
        {
            "title": "Teaching Sharing",
            "subtitle": "It's harder than you think",
            "tips": [
                "Start with turn-taking, not sharing",
                "Use a timer for turns",
                "Let them have some 'special' toys",
                "Model sharing yourself",
                "Praise sharing when you see it"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Playdate Success",
            "subtitle": "Setting up for good play",
            "tips": [
                "Start with short playdates",
                "One friend at a time is easier",
                "Have activities planned",
                "Stay nearby for younger kids",
                "End before it falls apart"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Making Friends",
            "subtitle": "Helping them connect",
            "tips": [
                "Teach simple openers: 'Can I play?'",
                "Role play social situations at home",
                "Find activities based on interests",
                "Arrange one-on-one time with peers",
                "Quality over quantity of friends"
            ],
            "age_groups": ["4-6", "6-8"]
        },
        {
            "title": "Handling Conflicts",
            "subtitle": "When friends disagree",
            "tips": [
                "Coach, don't solve for them",
                "Teach 'I feel' statements",
                "Help them see other perspectives",
                "Role play solutions",
                "Celebrate when they work it out"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Parallel Play Is Normal",
            "subtitle": "Toddlers play 'beside' not 'with'",
            "tips": [
                "Playing near each other is a stage",
                "Don't force interaction",
                "Provide duplicate toys",
                "Interactive play develops over time",
                "Celebrate any positive interaction"
            ],
            "age_groups": ["2-4"]
        },
        {
            "title": "Being a Good Friend",
            "subtitle": "Teaching friendship skills",
            "tips": [
                "Talk about what good friends do",
                "Read books about friendship",
                "Point out kind actions",
                "Discuss how actions affect others",
                "Model good friendships yourself"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Shy & Introverted Kids",
            "subtitle": "Support without pushing",
            "tips": [
                "Respect their temperament",
                "Give them warm-up time in groups",
                "Small groups work better",
                "Don't label them 'shy' to others",
                "Celebrate their social wins"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Dealing with Exclusion",
            "subtitle": "When they're left out",
            "tips": [
                "Validate their feelings first",
                "Problem-solve together",
                "Help them find other friends",
                "Talk to teachers if ongoing",
                "Build confidence in other areas"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Manners & Kindness",
            "subtitle": "Social graces matter",
            "tips": [
                "Model please/thank you always",
                "Practice greetings and eye contact",
                "Teach about personal space",
                "Role play polite behavior",
                "Praise kind actions you observe"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "Navigating Group Dynamics",
            "subtitle": "Older kids' social world",
            "tips": [
                "Stay curious about their social life",
                "Don't dismiss their drama",
                "Help them think through situations",
                "Watch for signs of bullying",
                "Keep communication open"
            ],
            "age_groups": ["6-8", "8-10"]
        }
    ],
    "separation_anxiety": [
        {
            "title": "Quick Confident Goodbyes",
            "subtitle": "Short and sweet works best",
            "tips": [
                "Keep goodbyes brief and upbeat",
                "Don't sneak away—always say goodbye",
                "Create a goodbye ritual",
                "Stay confident (they sense your worry)",
                "Trust that they'll be okay"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Practice Separations",
            "subtitle": "Build up slowly",
            "tips": [
                "Start with short separations",
                "Leave with familiar caregivers first",
                "Gradually increase time apart",
                "Celebrate reunions calmly",
                "Be consistent with pickup times"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Transition Objects",
            "subtitle": "A piece of you to hold",
            "tips": [
                "Let them keep a special lovey",
                "Give them a photo of family",
                "Your scarf or small item can help",
                "Draw a heart on their hand",
                "Promise to think of them"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "First Day of School/Care",
            "subtitle": "Making transitions easier",
            "tips": [
                "Visit the new place beforehand",
                "Meet the teacher/caregiver early",
                "Read books about school",
                "Keep morning routine calm",
                "Stay positive about the experience"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Bedtime Separation Anxiety",
            "subtitle": "When they can't let you go at night",
            "tips": [
                "Establish a predictable routine",
                "One more hug/kiss rule",
                "Offer a nightlight or lovey",
                "Check back in 5 minutes (and keep promise)",
                "Stay boring during check-ins"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Parent Drop-off Tips",
            "subtitle": "Making morning goodbye easier",
            "tips": [
                "Arrive with enough time, but don't linger",
                "Engage them in an activity before leaving",
                "Trust the caregiver's experience",
                "Don't come back if they cry",
                "They usually calm quickly"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Regression at Transitions",
            "subtitle": "When anxiety returns",
            "tips": [
                "New baby, new school can trigger it",
                "Return to basics that worked before",
                "Extra connection time helps",
                "Don't shame the regression",
                "This phase will pass again"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "Older Kids & Separation",
            "subtitle": "When bigger kids struggle",
            "tips": [
                "Take their fears seriously",
                "Talk through worries together",
                "Problem-solve coping strategies",
                "Check in with school counselor",
                "Consider if anxiety needs more support"
            ],
            "age_groups": ["6-8", "8-10"]
        },
        {
            "title": "Your Own Separation Anxiety",
            "subtitle": "Managing your feelings too",
            "tips": [
                "Your anxiety transfers to them",
                "Find support for your feelings",
                "Trust that they're capable",
                "Stay busy after drop-off",
                "Celebrate their independence"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Building Independence",
            "subtitle": "Confidence grows with practice",
            "tips": [
                "Give age-appropriate freedom",
                "Let them do things themselves",
                "Praise brave behavior",
                "Tell stories about their courage",
                "Trust their growing capability"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        }
    ],
    "behavior_management": [
        {
            "title": "Positive Attention First",
            "subtitle": "Catch them being good",
            "tips": [
                "Notice and praise good behavior",
                "Aim for 5 positive to 1 correction",
                "Be specific: 'I love how you shared'",
                "Attention drives behavior",
                "What you focus on grows"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Clear, Simple Rules",
            "subtitle": "They can't follow what they don't know",
            "tips": [
                "Keep rules to 3-5 key ones",
                "State positively: 'Walk inside'",
                "Post rules where everyone sees",
                "Review and practice regularly",
                "Be consistent with enforcement"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Natural Consequences",
            "subtitle": "Let reality teach the lesson",
            "tips": [
                "Don't bring forgotten homework",
                "Let them feel cold without coat",
                "Broken toys stay broken",
                "Make sure it's safe first",
                "Empathize without rescuing"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Logical Consequences",
            "subtitle": "Consequences that make sense",
            "tips": [
                "Related: misuse toy, lose toy",
                "Reasonable: short time period",
                "Respectful: not shaming",
                "Given with empathy, not anger",
                "Follow through every time"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Time-In vs Time-Out",
            "subtitle": "Connection, not isolation",
            "tips": [
                "Sit together to calm down",
                "Help them regulate with your calm",
                "Talk after they're calm",
                "Time-out works for some kids",
                "Choose what works for your child"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "The Power of Choices",
            "subtitle": "Give control within limits",
            "tips": [
                "Offer 2 acceptable choices",
                "'Red shirt or blue shirt?'",
                "Accept their choice gracefully",
                "Avoid too many options",
                "Builds cooperation and autonomy"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "Effective Requests",
            "subtitle": "How you ask matters",
            "tips": [
                "Get down to their eye level",
                "Use their name first",
                "Make it a statement, not question",
                "Give one instruction at a time",
                "Wait and expect compliance"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "When You Lose Your Cool",
            "subtitle": "Repair and move forward",
            "tips": [
                "Everyone yells sometimes",
                "Apologize sincerely",
                "Explain what you should have done",
                "Move on without guilt",
                "Model making amends"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Sibling Conflicts",
            "subtitle": "When they fight constantly",
            "tips": [
                "Don't always referee",
                "Give them tools to solve it",
                "Avoid comparing siblings",
                "One-on-one time with each child",
                "Sometimes separate is okay"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Token Economy Systems",
            "subtitle": "Earning rewards for good behavior",
            "tips": [
                "Clear behaviors earn tokens/points",
                "Choose meaningful rewards together",
                "Start simple and build up",
                "Be consistent with giving tokens",
                "Fade system as behaviors stick"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Defiance & Power Struggles",
            "subtitle": "When they test every limit",
            "tips": [
                "Pick your battles wisely",
                "Stay calm—don't engage in battle",
                "Give thinking time before consequences",
                "Look for underlying needs",
                "Connection often defuses defiance"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Consistency Is Key",
            "subtitle": "Same rules, all caregivers",
            "tips": [
                "Get on same page with partner",
                "Brief babysitters/grandparents",
                "Follow through even when tired",
                "Inconsistency increases testing",
                "Exceptions create more testing"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        }
    ],
    "mixed_emotional_development": [
        {
            "title": "Naming Emotions",
            "subtitle": "Build their feelings vocabulary",
            "tips": [
                "Use emotion words often",
                "Read books about feelings",
                "Name your own emotions out loud",
                "Use feeling charts and faces",
                "Ask 'How did that make you feel?'"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "Validating All Feelings",
            "subtitle": "No emotion is 'bad'",
            "tips": [
                "Say 'All feelings are okay'",
                "Don't say 'Don't be sad/mad'",
                "Acknowledge before solving",
                "Let them feel disappointed",
                "Feelings pass when allowed"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Calming Strategies",
            "subtitle": "Tools for emotional regulation",
            "tips": [
                "Deep belly breaths together",
                "Count to 10 slowly",
                "Squeeze and release muscles",
                "Use a calm-down kit",
                "Practice when calm"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Handling Frustration",
            "subtitle": "When things don't go their way",
            "tips": [
                "Empathize first: 'That's frustrating'",
                "Model patience yourself",
                "Break tasks into smaller steps",
                "Teach self-talk: 'I can try again'",
                "Celebrate effort over outcome"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "Building Empathy",
            "subtitle": "Understanding others' feelings",
            "tips": [
                "Ask 'How do you think they feel?'",
                "Point out emotions in others",
                "Discuss characters in books/shows",
                "Model caring for others",
                "Volunteer together"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Worry & Anxiety Support",
            "subtitle": "When worry takes over",
            "tips": [
                "Take worries seriously",
                "Teach 'worry time' - dedicated time",
                "Challenge anxious thoughts gently",
                "Create a worry box or journal",
                "Seek help if it impacts daily life"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Emotional Safety at Home",
            "subtitle": "Create a feelings-friendly space",
            "tips": [
                "Listen without judgment",
                "Don't mock their emotions",
                "Keep reactions calm",
                "Show unconditional love",
                "Make sharing feelings safe"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Age-Appropriate Emotions",
            "subtitle": "What's normal for their stage",
            "tips": [
                "Toddlers have intense, quick emotions",
                "Preschoolers fear monsters and dark",
                "School-age kids worry about friends",
                "Tweens may hide feelings",
                "Adjust your approach for their age"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Mindfulness for Kids",
            "subtitle": "Present-moment awareness",
            "tips": [
                "Do body scans together",
                "Practice noticing 5 senses",
                "Use kids' meditation apps",
                "Make it playful and short",
                "Build it into daily routine"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "When to Get Help",
            "subtitle": "Recognizing when more support is needed",
            "tips": [
                "Persistent sadness or anxiety",
                "Behavior changes significantly",
                "Sleep or appetite problems",
                "Talk of self-harm",
                "Trust your instincts—get help"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        }
    ],
    "mixed_confidence_independence": [
        {
            "title": "Let Them Struggle",
            "subtitle": "Resist the urge to rescue",
            "tips": [
                "Watch them figure it out",
                "Offer encouragement, not solutions",
                "Celebrate the effort, not outcome",
                "Mistakes are learning moments",
                "Building frustration tolerance"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Age-Appropriate Independence",
            "subtitle": "What they can do themselves",
            "tips": [
                "Toddlers: choose clothes, help clean",
                "Preschool: dress self, simple chores",
                "School-age: homework, morning routine",
                "Tweens: manage schedule, money basics",
                "Gradually increase responsibility"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Encourage Risk-Taking",
            "subtitle": "Safe risks build confidence",
            "tips": [
                "Let them climb a bit higher",
                "Support trying new activities",
                "Praise brave attempts",
                "Don't project your fears",
                "Accept minor scrapes and failures"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Growth Mindset Language",
            "subtitle": "Words that build resilience",
            "tips": [
                "Say 'You worked hard' not 'You're smart'",
                "Add 'yet' to 'I can't do it'",
                "Celebrate effort and improvement",
                "Talk about brain growth",
                "Share your own learning struggles"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Self-Care Skills",
            "subtitle": "Tending to their own needs",
            "tips": [
                "Teach hand washing, teeth brushing",
                "Practice getting dressed independently",
                "Learn to pour drinks, prepare snacks",
                "Build up to showering alone",
                "Pride comes from doing it themselves"
            ],
            "age_groups": ["2-4", "4-6", "6-8"]
        },
        {
            "title": "Handling Failure",
            "subtitle": "Bounce back after setbacks",
            "tips": [
                "Normalize failure as learning",
                "Share your own failures",
                "Ask 'What would you do differently?'",
                "Focus on what they can control",
                "Help them try again"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Building Self-Esteem",
            "subtitle": "Help them feel capable and loved",
            "tips": [
                "Show unconditional love always",
                "Point out their unique strengths",
                "Avoid comparing to others",
                "Listen to their opinions",
                "Let them make choices"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Decision Making Practice",
            "subtitle": "Build judgment through experience",
            "tips": [
                "Start with small decisions",
                "Let them face natural consequences",
                "Talk through decisions together",
                "Respect their choices when safe",
                "Increase stakes as they mature"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Advocacy Skills",
            "subtitle": "Speaking up for themselves",
            "tips": [
                "Teach 'I need help with...'",
                "Role play asking teachers questions",
                "Let them order at restaurants",
                "Practice polite assertiveness",
                "Step back and let them lead"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Celebrating Uniqueness",
            "subtitle": "Confidence in who they are",
            "tips": [
                "Accept their personality",
                "Don't try to change core traits",
                "Find their interests and support them",
                "Diverse role models matter",
                "They don't need to be like everyone"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        }
    ],
    "mixed_sibling_family": [
        {
            "title": "Preparing for New Baby",
            "subtitle": "Help older sibling adjust",
            "tips": [
                "Read books about new siblings",
                "Let them help with preparations",
                "Maintain their routines",
                "Have special one-on-one time",
                "Expect some regression"
            ],
            "age_groups": ["2-4", "4-6"]
        },
        {
            "title": "Stopping Sibling Fights",
            "subtitle": "When to intervene",
            "tips": [
                "Safety first—separate if needed",
                "Let them try to solve it first",
                "Don't take sides",
                "Teach conflict resolution",
                "Praise cooperation when you see it"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Avoiding Favoritism",
            "subtitle": "Equal love, different needs",
            "tips": [
                "Fair doesn't mean identical",
                "Give each what they need",
                "Never compare siblings",
                "One-on-one time with each",
                "Celebrate each child's uniqueness"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Building Sibling Friendship",
            "subtitle": "Help them actually like each other",
            "tips": [
                "Create opportunities for fun together",
                "Team them up against you in games",
                "Notice and praise kind moments",
                "Don't force togetherness",
                "Shared experiences build bonds"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Family Meetings",
            "subtitle": "Everyone gets a voice",
            "tips": [
                "Regular weekly time",
                "Let kids contribute agenda items",
                "Problem-solve together",
                "Celebrate wins as a family",
                "Keep it brief and positive"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Creating Family Rituals",
            "subtitle": "Traditions that connect",
            "tips": [
                "Weekly pizza/movie night",
                "Birthday traditions",
                "Seasonal family activities",
                "Daily connection rituals",
                "Involve kids in creating them"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Blended Family Transitions",
            "subtitle": "Navigating step-families",
            "tips": [
                "Go slow with new relationships",
                "Don't force 'mom/dad' titles",
                "Maintain individual relationships",
                "Be patient with adjustment",
                "Create new traditions together"
            ],
            "age_groups": ["4-6", "6-8", "8-10"]
        },
        {
            "title": "Only Child Dynamics",
            "subtitle": "Building social skills without siblings",
            "tips": [
                "Plenty of peer interaction",
                "Don't over-compensate with attention",
                "Teach sharing and cooperation",
                "Avoid adult-ifying them",
                "They're okay being an only!"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "When Grandparents Undermine",
            "subtitle": "Managing extended family",
            "tips": [
                "Clear conversation about rules",
                "Pick your battles",
                "Some spoiling is okay",
                "Present united front to kids",
                "Focus on relationship benefits"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        },
        {
            "title": "Quality Time on Budget",
            "subtitle": "Connection doesn't cost money",
            "tips": [
                "Play board games together",
                "Cook meals as a family",
                "Nature walks and park visits",
                "Reading together at bedtime",
                "Dance parties in the kitchen"
            ],
            "age_groups": ["2-4", "4-6", "6-8", "8-10"]
        }
    ]
}


# ─────────────────────────────────────────────────────────────
# AI CARD GENERATION
# ─────────────────────────────────────────────────────────────
def generate_cards_with_ai(articles: List[Dict], topic_id: str, count: int = 10) -> List[Dict]:
    """Generate care cards using OpenAI from scraped articles"""
    if not openai_client:
        return []
    
    # Prepare context from articles
    context_text = ""
    source_urls = []
    for i, article in enumerate(articles[:15]):  # Limit to 15 articles
        source_urls.append(article.get('url', ''))
        title = article.get('title', 'Untitled')
        text = article.get('text', '')[:1500]  # First 1500 chars
        summary = article.get('summary', '')[:500]
        context_text += f"\n\n### Article {i+1}: {title}\n{summary}\n{text}"
    
    metadata = TOPIC_METADATA.get(topic_id, {"title": topic_id.replace('_', ' ').title(), "emoji": "📖"})
    
    prompt = f"""You are creating care cards for the ParentBud app, helping parents with children ages 2-10.

Topic: {metadata.get('title', topic_id)}

Using the expert knowledge from these articles, create {count} unique care cards. Each card should:
- Have a short, catchy title (3-5 words)
- Have a one-line subtitle
- Have exactly 5 actionable tips (1-2 sentences each)
- Specify which age groups it's most relevant for: ["2-4", "4-6", "6-8", "8-10"]
- Be original - summarize and synthesize, don't copy

Source Articles:
{context_text}

Return as JSON array:
[
  {{
    "title": "Short Title",
    "subtitle": "One line description",
    "tips": ["Tip 1", "Tip 2", "Tip 3", "Tip 4", "Tip 5"],
    "age_groups": ["2-4", "4-6"]
  }}
]

Create {count} unique, helpful cards. Ensure variety in age groups covered."""

    try:
        response = openai_client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are a parenting expert creating helpful, evidence-based care cards for parents. Always return valid JSON."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=4000
        )
        
        content = response.choices[0].message.content
        # Extract JSON from response
        content = content.strip()
        if content.startswith("```"):
            content = content.split("```")[1]
            if content.startswith("json"):
                content = content[4:]
        content = content.strip()
        
        cards_data = json.loads(content)
        
        # Enrich cards with metadata
        cards = []
        for i, card in enumerate(cards_data):
            cards.append({
                "id": str(uuid.uuid4()),
                "topic_id": topic_id,
                "title": card.get("title", f"Card {i+1}"),
                "subtitle": card.get("subtitle", ""),
                "tips": card.get("tips", []),
                "age_groups": card.get("age_groups", ["2-4", "4-6", "6-8", "8-10"]),
                "emoji": metadata.get("emoji", "📖"),
                "color_theme": metadata.get("color_theme", "default"),
                "source_articles": source_urls[:5],
                "variation": i + 1,
                "generated_at": datetime.now().isoformat(),
                "generation_method": "ai"
            })
        
        return cards
    
    except Exception as e:
        print(f"   ❌ AI generation failed: {e}")
        return []


def generate_cards_fallback(topic_id: str) -> List[Dict]:
    """Generate cards using fallback templates"""
    if topic_id not in FALLBACK_CARDS:
        # For unknown topics, return empty (shouldn't happen)
        print(f"   ⚠️  No fallback templates for: {topic_id}")
        return []
    
    metadata = TOPIC_METADATA.get(topic_id, {"title": topic_id.replace('_', ' ').title(), "emoji": "📖"})
    templates = FALLBACK_CARDS[topic_id]
    
    cards = []
    for i, template in enumerate(templates):
        cards.append({
            "id": str(uuid.uuid4()),
            "topic_id": topic_id,
            "title": template["title"],
            "subtitle": template["subtitle"],
            "tips": template["tips"],
            "age_groups": template["age_groups"],
            "emoji": metadata.get("emoji", "📖"),
            "color_theme": metadata.get("color_theme", "default"),
            "source_articles": [],
            "variation": i + 1,
            "generated_at": datetime.now().isoformat(),
            "generation_method": "template"
        })
    
    return cards


# ─────────────────────────────────────────────────────────────
# CARD GENERATION FUNCTIONS
# ─────────────────────────────────────────────────────────────
def load_topic_articles(topic_id: str) -> List[Dict]:
    """Load all scraped articles for a topic"""
    topic_path = os.path.join(TOPIC_DIR, topic_id)
    if not os.path.exists(topic_path):
        return []
    
    articles = []
    for filename in os.listdir(topic_path):
        if filename.endswith('.json'):
            with open(os.path.join(topic_path, filename), 'r') as f:
                articles.append(json.load(f))
    
    return articles


def generate_topic_cards(topic_id: str, use_ai: bool = True) -> List[Dict]:
    """Generate all cards for a single topic"""
    metadata = TOPIC_METADATA.get(topic_id, {"title": topic_id, "variations": 10})
    title = metadata.get("title", topic_id)
    target_count = metadata.get("variations", 10)
    
    print(f"\n📝 Generating cards for: {title}")
    print(f"   Target: {target_count} cards")
    
    cards = []
    
    # Try AI generation if enabled and articles exist
    if use_ai and openai_client:
        articles = load_topic_articles(topic_id)
        print(f"   Articles found: {len(articles)}")
        
        if articles:
            ai_cards = generate_cards_with_ai(articles, topic_id, target_count)
            if ai_cards:
                print(f"   ✅ AI generated: {len(ai_cards)} cards")
                cards.extend(ai_cards)
    
    # Fill remaining with fallback templates
    if len(cards) < target_count:
        fallback = generate_cards_fallback(topic_id)
        remaining = target_count - len(cards)
        cards.extend(fallback[:remaining])
        print(f"   📋 Template cards: {min(remaining, len(fallback))}")
    
    # Save cards
    if cards:
        # Save all cards for topic
        topic_cards_path = os.path.join(CARDS_DIR, f"{topic_id}.json")
        with open(topic_cards_path, 'w') as f:
            json.dump(cards, f, indent=2)
        print(f"   💾 Saved: {topic_cards_path}")
        
        # Also save by age group
        for age in ["2-4", "4-6", "6-8", "8-10"]:
            age_cards = [c for c in cards if age in c.get("age_groups", [])]
            if age_cards:
                age_folder = os.path.join(CARDS_DIR, f"age_{age.replace('-', '_')}")
                os.makedirs(age_folder, exist_ok=True)
                with open(os.path.join(age_folder, f"{topic_id}.json"), 'w') as f:
                    json.dump(age_cards, f, indent=2)
    
    return cards


def generate_all_cards(use_ai: bool = True):
    """Generate cards for all topics"""
    print("\n" + "="*60)
    print("🎨 PARENTBUD CARD GENERATOR V2")
    print("="*60)
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"AI enabled: {use_ai and openai_client is not None}")
    print(f"Topics: {len(TOPIC_METADATA)}")
    
    all_cards = {}
    total = 0
    
    for topic_id in TOPIC_METADATA.keys():
        cards = generate_topic_cards(topic_id, use_ai)
        all_cards[topic_id] = cards
        total += len(cards)
    
    # Save master cards file
    master_path = os.path.join(CARDS_DIR, "all_cards.json")
    flat_cards = []
    for cards in all_cards.values():
        flat_cards.extend(cards)
    with open(master_path, 'w') as f:
        json.dump(flat_cards, f, indent=2)
    
    # Save summary
    summary = {
        "generated_at": datetime.now().isoformat(),
        "total_cards": total,
        "topics": {
            tid: {
                "title": TOPIC_METADATA.get(tid, {}).get("title", tid),
                "count": len(cards),
                "age_distribution": {
                    age: len([c for c in cards if age in c.get("age_groups", [])])
                    for age in ["2-4", "4-6", "6-8", "8-10"]
                }
            }
            for tid, cards in all_cards.items()
        }
    }
    with open(os.path.join(CARDS_DIR, "generation_summary.json"), 'w') as f:
        json.dump(summary, f, indent=2)
    
    # Print summary
    print("\n" + "="*60)
    print("✅ CARD GENERATION COMPLETE")
    print("="*60)
    for tid, cards in all_cards.items():
        title = TOPIC_METADATA.get(tid, {}).get("title", tid)
        ages = set()
        for c in cards:
            ages.update(c.get("age_groups", []))
        ages_str = ', '.join(sorted(ages))
        print(f"   {title}: {len(cards)} cards | Ages: [{ages_str}]")
    print(f"\n   Total: {total} cards generated")
    print(f"   Saved to: {CARDS_DIR}")
    
    return all_cards


def get_cards_for_age(age_group: str, topic_id: Optional[str] = None, count: int = 5) -> List[Dict]:
    """Get random cards for a specific age group"""
    age_folder = os.path.join(CARDS_DIR, f"age_{age_group.replace('-', '_')}")
    cards = []
    
    if os.path.exists(age_folder):
        files = os.listdir(age_folder)
        if topic_id:
            files = [f for f in files if f.startswith(topic_id)]
        
        for filename in files:
            with open(os.path.join(age_folder, filename), 'r') as f:
                cards.extend(json.load(f))
    
    # Shuffle and return requested count
    random.shuffle(cards)
    return cards[:count]


# ─────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────
if __name__ == '__main__':
    import sys
    
    if len(sys.argv) > 1:
        topic = sys.argv[1]
        if topic in TOPIC_METADATA:
            generate_topic_cards(topic)
        else:
            print(f"Unknown topic: {topic}")
            print(f"Available: {list(TOPIC_METADATA.keys())}")
    else:
        generate_all_cards()
