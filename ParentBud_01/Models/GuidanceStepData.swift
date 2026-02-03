//
//  GuidanceStepsData.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-14
//

import Foundation

struct GuidanceStepData: Codable, Identifiable {
    let id: UUID
    let struggleTag: String
    let approach: String
    let steps: [StepDetail]
    
    init(id: UUID = UUID(), struggleTag: String, approach: String, steps: [StepDetail]) {
        self.id = id
        self.struggleTag = struggleTag
        self.approach = approach
        self.steps = steps
    }
}

struct StepDetail: Codable, Identifiable {
    let id: UUID
    let stepNumber: Int
    let title: String
    let description: String
    var isCompleted: Bool
    
    init(id: UUID = UUID(), stepNumber: Int, title: String, description: String, isCompleted: Bool = false) {
        self.id = id
        self.stepNumber = stepNumber
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
    }
}

// MARK: - Struggle Titles Mapping
// MARK: - Struggle Titles Mapping
struct StruggleTitles {
    static func getTitle(for struggle: String) -> String {
        let mapping: [String: String] = [
            "Tantrums": "Taming the Tantrum Storm",
            "Sleep Routines": "Mastering the Bedtime Ritual",
            "Eating Habits": "Conquering Mealtime Battles",
            "Screen Time": "Navigating the Digital World",
            "Potty Training": "The Potty Training Adventure",
            "Separation Anxiety": "Building Goodbye Confidence",
            "Social Skills": "Growing Social Butterflies",
            "Behaviour Management": "Shaping Positive Behavior",
            "Focus and Attention": "Unlocking Focus & Flow",
            "Homework Resistance": "Making Homework Happen",
            "Sibling Rivalry": "Harmony Among Siblings",
            "Morning Routines": "Smooth Morning Magic",
            
            // ✅ ADD MORE VARIATIONS FOR COMMON USER INPUTS
            "bedtime issues": "Mastering Bedtime Peace",
            "bedtime resistance": "Conquering Bedtime Battles",
            "bedtime struggles": "Bedtime Victory Journey",
            "sleep problems": "Sleep Success Guide",
            "won't sleep": "Journey to Dreamland",
            
            "won't eat": "Mealtime Success Strategy",
            "picky eater": "Expanding Food Horizons",
            "food refusal": "Nourishment Navigation",
            
            "hitting": "Teaching Gentle Hands",
            "biting": "Building Kind Behavior",
            "aggressive": "Channeling Energy Positively",
            
            "whining": "Clear Communication Guide",
            "crying": "Emotional Expression Journey",
            "complaining": "Positive Outlook Building",
            
            "homework battles": "Homework Harmony",
            "won't do homework": "Academic Motivation Guide",
            
            "sibling fighting": "Peaceful Sibling Relations",
            "sibling jealousy": "Building Sibling Bonds",
            
            "morning chaos": "Calm Morning Routine",
            "morning battles": "Morning Peace Strategy",
            
            "listening": "Building Better Listening",
            "following directions": "Direction Success Guide",
            "ignoring": "Attention & Response Training"
        ]
        
        // Check for exact match (case-insensitive)
        let lowercaseStruggle = struggle.lowercased()
        if let customTitle = mapping[lowercaseStruggle] {
            return customTitle
        }
        
        // Check if mapping has the original case version
        if let customTitle = mapping[struggle] {
            return customTitle
        }
        
        // ✅ Generate attractive title for any custom input
        return generateAttractiveTitle(from: struggle)
    }
    
    // ✅ Generate attractive title for custom inputs
    private static func generateAttractiveTitle(from input: String) -> String {
        let words = input.split(separator: " ").map { $0.capitalized }
        let capitalizedInput = words.joined(separator: " ")
        
        // Check if input contains certain keywords
        let lowercaseInput = input.lowercased()
        
        if lowercaseInput.contains("tantrum") {
            return "Managing \(capitalizedInput)"
        } else if lowercaseInput.contains("sleep") || lowercaseInput.contains("bed") {
            return "Peaceful \(capitalizedInput) Solution"
        } else if lowercaseInput.contains("eat") || lowercaseInput.contains("food") || lowercaseInput.contains("meal") {
            return "Nourishing \(capitalizedInput) Journey"
        } else if lowercaseInput.contains("homework") || lowercaseInput.contains("study") {
            return "\(capitalizedInput) Success"
        } else if lowercaseInput.contains("sibling") || lowercaseInput.contains("brother") || lowercaseInput.contains("sister") {
            return "Harmony in \(capitalizedInput)"
        } else if lowercaseInput.contains("morning") {
            return "Smooth \(capitalizedInput) Flow"
        } else if lowercaseInput.contains("potty") || lowercaseInput.contains("toilet") {
            return "\(capitalizedInput) Triumph"
        } else if lowercaseInput.contains("screen") || lowercaseInput.contains("tv") || lowercaseInput.contains("ipad") {
            return "Balanced \(capitalizedInput) Guide"
        } else if lowercaseInput.contains("behavior") || lowercaseInput.contains("behaviour") {
            return "Shaping \(capitalizedInput)"
        } else {
            // Default: "Navigating [Input]"
            return "Navigating \(capitalizedInput)"
        }
    }
}

// MARK: - Guidance Steps Repository
class GuidanceStepsRepository {
    static let shared = GuidanceStepsRepository()
    
    private init() {}
    
    // MARK: - Get Steps for Struggle
    func getSteps(for struggle: String, approach: String = "CBT+PCIT") -> [StepDetail] {
        let normalizedStruggle = struggle.trimmingCharacters(in: .whitespaces)
        
        if approach == "CBT+PCIT" {
            return getCBTPCITSteps(for: normalizedStruggle)
        } else {
            return getAlternativeSteps(for: normalizedStruggle)
        }
    }
    
    // MARK: - CBT + PCIT Steps
    private func getCBTPCITSteps(for struggle: String) -> [StepDetail] {
        switch struggle {
        case "Tantrums":
            return [
                StepDetail(stepNumber: 1, title: "Pause & Breathe", description: "Take a deep breath. Stay calm before responding. It helps your child mirror your energy."),
                StepDetail(stepNumber: 2, title: "Acknowledge Feelings", description: "Say: \"I see you're upset. It's okay to feel angry.\" Naming emotions helps kids feel understood."),
                StepDetail(stepNumber: 3, title: "Set Clear Boundaries", description: "Gently but firmly state the limit: \"We can't throw toys. They could break.\""),
                StepDetail(stepNumber: 4, title: "Offer Choices", description: "Give 2 simple, positive options: \"We can draw or we can build blocks.\" Choices restore their sense of control."),
                StepDetail(stepNumber: 5, title: "Follow Through Calmly", description: "If behavior continues, calmly implement consequence. Consistency teaches boundaries.")
            ]
            
        case "Sleep Routines":
            return [
                StepDetail(stepNumber: 1, title: "Dim the Lights", description: "Create a calming environment 30 minutes before bed. Dim lights, keep room cool and quiet."),
                StepDetail(stepNumber: 2, title: "Bedtime Ritual", description: "Same sequence every night: bath, story, song. Predictability signals sleep time."),
                StepDetail(stepNumber: 3, title: "Set Clear Sleep Time", description: "Establish non-negotiable bedtime. Use visual clock for younger kids."),
                StepDetail(stepNumber: 4, title: "Stay Present but Calm", description: "Sit nearby until drowsy, then leave. Return briefly if they call, but don't engage."),
                StepDetail(stepNumber: 5, title: "Celebrate Morning Success", description: "Praise staying in bed: \"You did it! You stayed in your bed all night!\"")
            ]
            
        case "Eating Habits":
            return [
                StepDetail(stepNumber: 1, title: "Consistent Meal Times", description: "Serve meals and snacks at same times daily. Predictable hunger = better eating."),
                StepDetail(stepNumber: 2, title: "Make Food Fun", description: "Use colorful plates, cut shapes, let them help. No pressure to finish."),
                StepDetail(stepNumber: 3, title: "Family Meals Together", description: "Model healthy eating yourself. Make mealtime pleasant, not stressful."),
                StepDetail(stepNumber: 4, title: "Don't Force or Bribe", description: "Offer food neutrally. No 'eat veggies for dessert.' Respect refusal."),
                StepDetail(stepNumber: 5, title: "Praise Trying New Foods", description: "Celebrate exploration: 'Great job trying a bite!' Focus on attempt, not amount.")
            ]
            
        case "Screen Time":
            return [
                StepDetail(stepNumber: 1, title: "Set Clear Daily Limits", description: "Decide max screen time (e.g., 1 hour/day). Write it down together."),
                StepDetail(stepNumber: 2, title: "Use Visual Timer", description: "Show them timer so they see time counting down. Makes transition easier."),
                StepDetail(stepNumber: 3, title: "Screen-Free Zones", description: "No screens in bedrooms or during meals. Family follows same rules."),
                StepDetail(stepNumber: 4, title: "Prepare Fun Alternatives", description: "Have art supplies, books, outdoor toys ready for after screen time."),
                StepDetail(stepNumber: 5, title: "Give 5-Minute Warning", description: "Always warn before time ends: 'Screen time ends in 5 minutes.'")
            ]
            
        case "Separation Anxiety":
            return [
                StepDetail(stepNumber: 1, title: "Consistent Goodbye Ritual", description: "Create special goodbye: hug, kiss, wave. Same every time."),
                StepDetail(stepNumber: 2, title: "Keep Goodbyes Brief", description: "Quick hug and go. Long goodbyes make it harder for everyone."),
                StepDetail(stepNumber: 3, title: "Validate Their Feelings", description: "Say: 'I'll miss you too. I know this is hard.' Don't dismiss emotions."),
                StepDetail(stepNumber: 4, title: "Give Comfort Object", description: "Photo of family, special stuffed animal, or item with your scent."),
                StepDetail(stepNumber: 5, title: "Always Return on Time", description: "Build trust by being reliable. Greet enthusiastically when back.")
            ]
            
        case "Potty Training":
            return [
                StepDetail(stepNumber: 1, title: "Regular Potty Intervals", description: "Take to potty every 2 hours. After meals and before outings."),
                StepDetail(stepNumber: 2, title: "Celebrate Successes", description: "Cheer enthusiastically! Use stickers or small rewards."),
                StepDetail(stepNumber: 3, title: "Stay Calm About Accidents", description: "Say calmly: 'It's okay, accidents happen.' Clean up together matter-of-factly."),
                StepDetail(stepNumber: 4, title: "Read Potty Books Together", description: "Use books to normalize potty training. Make it fun and pressure-free."),
                StepDetail(stepNumber: 5, title: "Let Them Pick Underwear", description: "Shop together for favorite characters. Make it exciting transition.")
            ]
            
        case "Social Skills":
            return [
                StepDetail(stepNumber: 1, title: "Model Sharing Yourself", description: "Demonstrate turn-taking and sharing in daily interactions."),
                StepDetail(stepNumber: 2, title: "Use 'We' Language", description: "Say 'We take turns' instead of 'You have to share.' Inclusive language helps."),
                StepDetail(stepNumber: 3, title: "Set Timer for Turns", description: "Use visual timer for fair turn-taking. Makes waiting easier."),
                StepDetail(stepNumber: 4, title: "Praise Positive Interactions", description: "Catch them being kind: 'I saw you share your toy! That was thoughtful.'"),
                StepDetail(stepNumber: 5, title: "Arrange Structured Playdates", description: "Start with short, supervised playdates to practice social skills.")
            ]
            
        case "Behaviour Management":
            return [
                StepDetail(stepNumber: 1, title: "Set Clear Expectations", description: "State rules simply and positively: 'We use gentle hands.'"),
                StepDetail(stepNumber: 2, title: "Immediate Positive Reinforcement", description: "Praise good behavior instantly: 'Thank you for listening!'"),
                StepDetail(stepNumber: 3, title: "Focus on Desired Behavior", description: "Tell them what to do, not just what not to do."),
                StepDetail(stepNumber: 4, title: "Natural Consequences", description: "Let them experience results: toy breaks when thrown = no more toy."),
                StepDetail(stepNumber: 5, title: "Consistent Follow-Through", description: "Always follow through on consequences. Consistency builds trust.")
            ]
            
        case "Focus and Attention":
            return [
                StepDetail(stepNumber: 1, title: "Break Tasks into Small Steps", description: "Divide homework or chores into tiny, manageable chunks."),
                StepDetail(stepNumber: 2, title: "Use Timers for Focus", description: "Work for 10 minutes, break for 2. Repeat. Makes tasks feel doable."),
                StepDetail(stepNumber: 3, title: "Create Distraction-Free Zone", description: "Clear workspace. Remove toys, screens, noise. One task at a time."),
                StepDetail(stepNumber: 4, title: "Praise Effort, Not Results", description: "Say: 'You worked so hard!' Not 'You're so smart!' Builds resilience."),
                StepDetail(stepNumber: 5, title: "Allow Movement Breaks", description: "Let them jump, stretch, run between tasks. Movement helps focus.")
            ]
            
        case "Homework Resistance":
            return [
                StepDetail(stepNumber: 1, title: "Dedicated Study Space", description: "Create homework spot with good lighting and minimal distractions."),
                StepDetail(stepNumber: 2, title: "Consistent Homework Time", description: "Same time daily. After snack, before play. Routine reduces resistance."),
                StepDetail(stepNumber: 3, title: "Break It Down", description: "Divide homework into small chunks. Celebrate completing each piece."),
                StepDetail(stepNumber: 4, title: "Be Nearby, Not Hovering", description: "Available for help but don't do it for them. Build independence."),
                StepDetail(stepNumber: 5, title: "Reward Effort, Not Perfection", description: "Praise hard work: 'You stuck with that tough problem!' Growth mindset.")
            ]
            
        case "Sibling Rivalry":
            return [
                StepDetail(stepNumber: 1, title: "Don't Take Sides", description: "Stay neutral in conflicts. 'I see two upset kids. Let's solve this together.'"),
                StepDetail(stepNumber: 2, title: "Teach Problem-Solving", description: "Guide them: 'What could you both do so everyone feels fair?'"),
                StepDetail(stepNumber: 3, title: "Celebrate Teamwork", description: "Notice cooperation: 'You two worked together so well!' Reinforce positive."),
                StepDetail(stepNumber: 4, title: "One-on-One Time", description: "Spend individual time with each child daily. Reduces competition for attention."),
                StepDetail(stepNumber: 5, title: "Teach Respectful Disagreement", description: "Model: 'I disagree, but I respect your opinion.' Healthy conflict resolution.")
            ]
            
        case "Morning Routines":
            return [
                StepDetail(stepNumber: 1, title: "Visual Morning Checklist", description: "Create picture chart: brush teeth, get dressed, eat breakfast. Let them check off."),
                StepDetail(stepNumber: 2, title: "Prepare Night Before", description: "Lay out clothes, pack backpack, prep breakfast items. Less morning chaos."),
                StepDetail(stepNumber: 3, title: "Wake Up Earlier", description: "Extra 15 minutes reduces rushing. Calm mornings = better days."),
                StepDetail(stepNumber: 4, title: "Use Timers for Tasks", description: "Set timer for getting dressed, eating. Makes it a game, not a nag."),
                StepDetail(stepNumber: 5, title: "Positive Send-Off", description: "End with hug and encouragement: 'Have a great day!' Sets positive tone.")
            ]
            
        default:
            return getGeneralCBTPCITSteps()
        }
    }
    
    // MARK: - Alternative Steps
    private func getAlternativeSteps(for struggle: String) -> [StepDetail] {
        switch struggle {
        case "Tantrums":
            return [
                StepDetail(stepNumber: 1, title: "Identify Triggers", description: "Track patterns: hunger, tiredness, transitions? Address triggers proactively."),
                StepDetail(stepNumber: 2, title: "Feelings Thermometer", description: "Teach 1-5 scale. Ask: 'What number are you?' Intervene early at 2-3."),
                StepDetail(stepNumber: 3, title: "Teach Calming Strategies", description: "Practice deep breathing, counting, stress ball when calm."),
                StepDetail(stepNumber: 4, title: "Redirect Attention Early", description: "Before tantrum peaks, distract with surprising question or activity."),
                StepDetail(stepNumber: 5, title: "Catch Them Being Calm", description: "Praise calm behavior: 'I love how calm you are right now.'")
            ]
            
        case "Sleep Routines":
            return [
                StepDetail(stepNumber: 1, title: "Bedtime Pass System", description: "Give one 'pass' to leave room. Use for water, bathroom, hug. One pass only."),
                StepDetail(stepNumber: 2, title: "Reward Chart", description: "Sticker for staying in bed. Small reward after 5 stickers."),
                StepDetail(stepNumber: 3, title: "Visual Schedule", description: "Draw/print pictures of each bedtime step. Let child check off each one."),
                StepDetail(stepNumber: 4, title: "Relaxation Techniques", description: "Practice belly breathing: slow inhale/exhale like balloon."),
                StepDetail(stepNumber: 5, title: "Gradual Check-Ins", description: "Check at 2 min, then 5 min, then 10 min. Keep checks brief.")
            ]
            
        default:
            return getGeneralAlternativeSteps()
        }
    }
    
    // MARK: - General Fallback Steps
    private func getGeneralCBTPCITSteps() -> [StepDetail] {
        return [
            StepDetail(stepNumber: 1, title: "Stay Calm First", description: "Regulate your own emotions before responding. Model calm behavior."),
            StepDetail(stepNumber: 2, title: "Validate Feelings", description: "Let them know their feelings are understood. Don't judge emotions."),
            StepDetail(stepNumber: 3, title: "Use Clear Language", description: "Communicate expectations simply. Use age-appropriate words."),
            StepDetail(stepNumber: 4, title: "Offer Connection", description: "Provide comfort and reassurance. Stay present."),
            StepDetail(stepNumber: 5, title: "Teach, Don't Punish", description: "Focus on teaching better behavior for next time.")
        ]
    }
    
    private func getGeneralAlternativeSteps() -> [StepDetail] {
        return [
            StepDetail(stepNumber: 1, title: "Observe Patterns", description: "Track when and why behaviors happen. Look for themes."),
            StepDetail(stepNumber: 2, title: "Creative Problem-Solving", description: "Brainstorm solutions together with your child."),
            StepDetail(stepNumber: 3, title: "Establish Routines", description: "Create predictable daily structures with visual schedules."),
            StepDetail(stepNumber: 4, title: "Celebrate Small Wins", description: "Notice and praise every bit of progress."),
            StepDetail(stepNumber: 5, title: "Stay Patient", description: "Behavior change takes time and consistency.")
        ]
    }
}
