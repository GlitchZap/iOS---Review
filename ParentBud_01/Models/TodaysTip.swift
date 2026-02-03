//
//  TodaysTip.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 12/11/25.
//

import Foundation

// MARK: - Today's Tip Model
struct TodaysTip: Codable {
    let id: String
    let title: String
    let content: String
    let category: TipCategory
    let ageGroups: [AgeGroup]
    
    enum TipCategory: String, Codable {
        case behavior = "Behavior"
        case sleep = "Sleep"
        case nutrition = "Nutrition"
        case development = "Development"
        case screenTime = "Screen Time"
        case social = "Social Skills"
        case emotional = "Emotional"
        case safety = "Safety"
    }
    
    enum AgeGroup: String, Codable {
        case toddler = "2-4 years (toddler & preschool years)"
        case earlySchool = "5-7 years (early school years)"
        case growing = "8-10 years (growing independence years)"
        case all = "all"
    }
}

// MARK: - Today's Tip Manager
class TodaysTipManager {
    static let shared = TodaysTipManager()
    
    private let lastTipDateKey = "last_tip_date"
    private let currentTipIdKey = "current_tip_id"
    
    private let allTips: [TodaysTip] = [
        // Toddler Tips (2-4 years)
        TodaysTip(
            id: "tip_001",
            title: "Today's Tip",
            content: "Screen time battles? Create a visual timer so kids can see when it's ending - transitions become easy.....",
            category: .screenTime,
            ageGroups: [.toddler, .all]
        ),
        TodaysTip(
            id: "tip_002",
            title: "Today's Tip",
            content: "Struggling with bedtime? Create a calming routine: bath, story, song. Consistency helps toddlers feel secure and ready for sleep.",
            category: .sleep,
            ageGroups: [.toddler, .all]
        ),
        TodaysTip(
            id: "tip_003",
            title: "Today's Tip",
            content: "Picky eater? Let them help prepare meals. Kids are more likely to try foods they've 'cooked' themselves!",
            category: .nutrition,
            ageGroups: [.toddler, .all]
        ),
        TodaysTip(
            id: "tip_004",
            title: "Today's Tip",
            content: "Tantrums hitting hard? Name the emotion: 'You seem frustrated.' This helps toddlers learn to identify and express feelings.",
            category: .emotional,
            ageGroups: [.toddler, .all]
        ),
        TodaysTip(
            id: "tip_005",
            title: "Today's Tip",
            content: "Potty training tip: Let them pick special underwear. This gives them ownership and makes the transition exciting!",
            category: .development,
            ageGroups: [.toddler]
        ),
        TodaysTip(
            id: "tip_006",
            title: "Today's Tip",
            content: "Build language skills through play! Narrate daily activities: 'Now we're washing hands. The water is warm!'",
            category: .development,
            ageGroups: [.toddler, .all]
        ),
        TodaysTip(
            id: "tip_007",
            title: "Today's Tip",
            content: "Sharing struggles? Practice turn-taking with a timer. 'Your turn for 2 minutes, then Sam's turn.' Visual cues help!",
            category: .social,
            ageGroups: [.toddler, .earlySchool]
        ),
        TodaysTip(
            id: "tip_008",
            title: "Today's Tip",
            content: "Create a 'calm corner' with soft toys and books. Teach your toddler it's okay to take space when feeling overwhelmed.",
            category: .emotional,
            ageGroups: [.toddler, .earlySchool, .all]
        ),
        
        // Early School Tips (5-7 years)
        TodaysTip(
            id: "tip_009",
            title: "Today's Tip",
            content: "Homework resistance? Set up a dedicated study spot with minimal distractions. Routine builds focus!",
            category: .behavior,
            ageGroups: [.earlySchool, .growing]
        ),
        TodaysTip(
            id: "tip_010",
            title: "Today's Tip",
            content: "Build confidence by letting them solve problems. Instead of fixing, ask: 'What do you think you could try?'",
            category: .development,
            ageGroups: [.earlySchool, .growing, .all]
        ),
        TodaysTip(
            id: "tip_011",
            title: "Today's Tip",
            content: "Peer pressure starting? Role-play saying 'no' at home. Practice makes it easier in real situations.",
            category: .social,
            ageGroups: [.earlySchool, .growing]
        ),
        TodaysTip(
            id: "tip_012",
            title: "Today's Tip",
            content: "Screen time negotiation: Use 'when-then' language. 'When homework is done, then you can have 30 mins of screen time.'",
            category: .screenTime,
            ageGroups: [.earlySchool, .growing, .all]
        ),
        TodaysTip(
            id: "tip_013",
            title: "Today's Tip",
            content: "Encourage reading by letting them stay up 15 mins later if they're reading. Make books a privilege, not a chore!",
            category: .development,
            ageGroups: [.earlySchool, .growing]
        ),
        TodaysTip(
            id: "tip_014",
            title: "Today's Tip",
            content: "Separation anxiety at school drop-off? Create a goodbye ritual: hug, kiss, special phrase. Keep it short and upbeat!",
            category: .emotional,
            ageGroups: [.earlySchool]
        ),
        TodaysTip(
            id: "tip_015",
            title: "Today's Tip",
            content: "Teach responsibility with age-appropriate chores. Make a visual chart and celebrate completed tasks!",
            category: .behavior,
            ageGroups: [.earlySchool, .growing, .all]
        ),
        
        // Growing Independence Tips (8-10 years)
        TodaysTip(
            id: "tip_016",
            title: "Today's Tip",
            content: "Pre-teen mood swings? Validate feelings: 'That sounds really tough.' Don't minimize—connection builds trust.",
            category: .emotional,
            ageGroups: [.growing, .all]
        ),
        TodaysTip(
            id: "tip_017",
            title: "Today's Tip",
            content: "Screen time addiction? Set 'no phone zones' (dinner table, bedrooms). Model the behavior you want to see!",
            category: .screenTime,
            ageGroups: [.growing, .all]
        ),
        TodaysTip(
            id: "tip_018",
            title: "Today's Tip",
            content: "Foster independence: Let them pack their own school bag. Natural consequences teach responsibility better than nagging.",
            category: .behavior,
            ageGroups: [.growing]
        ),
        TodaysTip(
            id: "tip_019",
            title: "Today's Tip",
            content: "Friendship drama? Listen more than you advise. Sometimes they just need to vent, not solve.",
            category: .social,
            ageGroups: [.growing, .all]
        ),
        TodaysTip(
            id: "tip_020",
            title: "Today's Tip",
            content: "Build critical thinking: Ask 'Why do you think that happened?' instead of giving answers. Let them reason it out.",
            category: .development,
            ageGroups: [.growing, .all]
        ),
        TodaysTip(
            id: "tip_021",
            title: "Today's Tip",
            content: "Teach digital citizenship early. Discuss online safety, kindness, and the permanence of what they post.",
            category: .safety,
            ageGroups: [.growing]
        ),
        TodaysTip(
            id: "tip_022",
            title: "Today's Tip",
            content: "Encourage healthy habits: Let them plan one family meal per week. Nutrition becomes fun, not a lecture!",
            category: .nutrition,
            ageGroups: [.growing, .all]
        ),
        
        // Universal Tips (All Ages)
        TodaysTip(
            id: "tip_023",
            title: "Today's Tip",
            content: "Catch them being good! Specific praise ('I love how you shared your toy') works better than generic 'good job.'",
            category: .behavior,
            ageGroups: [.all]
        ),
        TodaysTip(
            id: "tip_024",
            title: "Today's Tip",
            content: "Consistency is key. Set clear boundaries and stick to them. Kids feel safer when they know what to expect.",
            category: .behavior,
            ageGroups: [.all]
        ),
        TodaysTip(
            id: "tip_025",
            title: "Today's Tip",
            content: "Self-care isn't selfish! Take 10 minutes daily for yourself. A calm parent = a calm home.",
            category: .emotional,
            ageGroups: [.all]
        ),
        TodaysTip(
            id: "tip_026",
            title: "Today's Tip",
            content: "Quality over quantity: 15 mins of focused one-on-one time daily beats hours of distracted 'together time.'",
            category: .emotional,
            ageGroups: [.all]
        ),
        TodaysTip(
            id: "tip_027",
            title: "Today's Tip",
            content: "Apologize when you mess up. Modeling humility teaches kids accountability and emotional intelligence.",
            category: .emotional,
            ageGroups: [.all]
        ),
        TodaysTip(
            id: "tip_028",
            title: "Today's Tip",
            content: "Create a bedtime wind-down: dim lights, quiet activities 30 mins before sleep. Helps bodies produce melatonin naturally.",
            category: .sleep,
            ageGroups: [.all]
        ),
        TodaysTip(
            id: "tip_029",
            title: "Today's Tip",
            content: "Limit choices to avoid overwhelm. 'Do you want the red or blue shirt?' works better than 'What do you want to wear?'",
            category: .behavior,
            ageGroups: [.all]
        ),
        TodaysTip(
            id: "tip_030",
            title: "Today's Tip",
            content: "Celebrate effort, not just results. 'You worked so hard on that!' builds a growth mindset.",
            category: .development,
            ageGroups: [.all]
        )
    ]
    
    private init() {}
    
    // MARK: - Get Today's Tip
    func getTodaysTip(for ageGroup: String?) -> TodaysTip {
        let today = Calendar.current.startOfDay(for: Date())
        let lastTipDate = UserDefaults.standard.object(forKey: lastTipDateKey) as? Date
        
        if lastTipDate == nil || !Calendar.current.isDate(today, inSameDayAs: lastTipDate!) {
            let newTip = getRandomTip(for: ageGroup)
            
            UserDefaults.standard.set(today, forKey: lastTipDateKey)
            UserDefaults.standard.set(newTip.id, forKey: currentTipIdKey)
            
            print("🎯 New tip for today: \(newTip.id)")
            return newTip
        }
        
        if let currentTipId = UserDefaults.standard.string(forKey: currentTipIdKey),
           let cachedTip = allTips.first(where: { $0.id == currentTipId }) {
            print("♻️ Using cached tip: \(cachedTip.id)")
            return cachedTip
        }
        
        return getRandomTip(for: ageGroup)
    }
    
    // MARK: - Get Random Tip
    private func getRandomTip(for ageGroup: String?) -> TodaysTip {
        var filteredTips = allTips
        
        if let ageGroup = ageGroup {
            filteredTips = allTips.filter { tip in
                tip.ageGroups.contains(where: { $0.rawValue == ageGroup }) ||
                tip.ageGroups.contains(.all)
            }
        }
        
        if filteredTips.isEmpty {
            filteredTips = allTips
        }
        
        return filteredTips.randomElement() ?? allTips[0]
    }
    
    // MARK: - Force New Tip (for testing)
    func forceNewTip(for ageGroup: String?) -> TodaysTip {
        UserDefaults.standard.removeObject(forKey: lastTipDateKey)
        return getTodaysTip(for: ageGroup)
    }
}
