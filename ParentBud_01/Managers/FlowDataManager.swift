//
//  FlowDataManager.swift
//  ParentBud_01
//
//  Created by GlitchZap on 12/11/25.
//

import Foundation

class FlowDataManager {
    
    static let shared = FlowDataManager()
    
    private init() {
        loadLogs()
        loadGuidanceSessions()
    }
    
    // MARK: - Properties
    
    private var logs: [LogEntry] = []
    private var guidanceSessions: [GuidanceSession] = []
    
    // MARK: - Common Struggles
    
    func getCommonStruggles(for ageGroup: AgeGroup?) -> [CommonStruggle] {
        let allStruggles = [
            CommonStruggle(
                title: "Sleep Routines",
                icon: "moon.stars.fill",
                color: "#E6DFFD",
                ageGroups: [ .toddler, .preschool, .schoolAge]
            ),
            CommonStruggle(
                title: "Separation Anxiety",
                icon: "heart.fill",
                color: "#FFD1E3",
                ageGroups: [.toddler, .preschool, .schoolAge]
            ),
            CommonStruggle(
                title: "Eating Habits",
                icon: "fork.knife",
                color: "#C4E8E0",
                ageGroups: [.toddler, .preschool, .schoolAge]
            ),
            CommonStruggle(
                title: "Focus and Attention",
                icon: "target",
                color: "#FFE5B4",
                ageGroups: [.preschool, .schoolAge]
            ),
            CommonStruggle(
                title: "Tantrums",
                icon: "exclamationmark.triangle.fill",
                color: "#FFB6C1",
                ageGroups: [.toddler, .preschool, .schoolAge]
            ),
            CommonStruggle(
                title: "Screen Time",
                icon: "tv.fill",
                color: "#B6E4FF",
                ageGroups: [.toddler, .preschool, .schoolAge]
            ),
            CommonStruggle(
                title: "Potty Training",
                icon: "toilet.fill",
                color: "#D4F1F4",
                ageGroups: [.toddler, .preschool]
            ),
            CommonStruggle(
                title: "Social Skills",
                icon: "person.3.fill",
                color: "#FFE194",
                ageGroups: [.toddler, .preschool, .schoolAge]
            ),
            CommonStruggle(
                title: "Behaviour Management",
                icon: "star.fill",
                color: "#E8D5F2",
                ageGroups: [.toddler, .preschool, .schoolAge]
            ),
            CommonStruggle(
                title: "Homework Resistance",
                icon: "book.fill",
                color: "#FFDAB9",
                ageGroups: [.schoolAge]
            ),
            CommonStruggle(
                title: "Sibling Rivalry",
                icon: "person.2.fill",
                color: "#E0BBE4",
                ageGroups: [.toddler, .preschool, .schoolAge]
            ),
            CommonStruggle(
                title: "Morning Routines",
                icon: "sunrise.fill",
                color: "#FFDFD3",
                ageGroups: [.preschool, .schoolAge]
            )
        ]
        
        guard let ageGroup = ageGroup else {
            return Array(allStruggles.prefix(4))
        }
        
        let filtered = allStruggles.filter { $0.ageGroups.contains(ageGroup) }
        return Array(filtered.prefix(4))
    }
    
    // MARK: - Log Management
    
    func addLog(_ log: LogEntry) {
        logs.append(log)
        saveLogs()
    }
    
    func getLogs(for userId: UUID, status: LogStatus? = nil) -> [LogEntry] {
        var filtered = logs.filter { $0.userId == userId }
        
        if let status = status {
            filtered = filtered.filter { $0.status == status }
        }
        
        return filtered.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getLog(by id: UUID) -> LogEntry? {
        return logs.first { $0.id == id }
    }
    
    func updateLog(_ log: LogEntry) {
        if let index = logs.firstIndex(where: { $0.id == log.id }) {
            var updatedLog = log
            updatedLog.updatedAt = Date()
            logs[index] = updatedLog
            saveLogs()
        }
    }
    
    func deleteLog(_ id: UUID) {
        logs.removeAll { $0.id == id }
        saveLogs()
    }
    
    func getAllLogs() -> [LogEntry] {
        return logs.sorted { $0.createdAt > $1.createdAt }
    }
    
    // MARK: - Guidance Session Management
    
    func createGuidanceSession(for logEntry: LogEntry, approach: GuidanceApproach = .cbtPcit) -> GuidanceSession {
        let steps = generateGuidanceSteps(for: logEntry.tags, approach: approach)
        
        let session = GuidanceSession(
            logEntryId: logEntry.id,
            userId: logEntry.userId,
            struggles: logEntry.tags,
            currentApproach: approach,
            steps: steps
        )
        
        guidanceSessions.append(session)
        saveGuidanceSessions()
        
        return session
    }
    
    func getGuidanceSession(for logEntryId: UUID) -> GuidanceSession? {
        return guidanceSessions.first { $0.logEntryId == logEntryId }
    }
    
    func updateGuidanceSession(_ session: GuidanceSession) {
        if let index = guidanceSessions.firstIndex(where: { $0.id == session.id }) {
            guidanceSessions[index] = session
            saveGuidanceSessions()
        }
    }
    
    func deleteGuidanceSession(_ id: UUID) {
        guidanceSessions.removeAll { $0.id == id }
        saveGuidanceSessions()
    }
    
    // MARK: - Generate Guidance Steps
    
    func generateGuidanceSteps(for struggles: [String], approach: GuidanceApproach) -> [GuidanceStep] {
        let primaryStruggle = struggles.first ?? "General"
        
        switch approach {
        case .cbtPcit:
            return getCBTPCITSteps(for: primaryStruggle)
        case .alternative:
            return getAlternativeSteps(for: primaryStruggle)
        }
    }
    
    // MARK: - CBT + PCIT Steps
    
    private func getCBTPCITSteps(for struggle: String) -> [GuidanceStep] {
        switch struggle {
        case "Sleep Routines":
            return [
                GuidanceStep(
                    stepNumber: 1,
                    title: "Establish Consistent Routine",
                    description: "Create a predictable bedtime routine that happens at the same time every night. This helps your child's body recognize when it's time to sleep.",
                    tips: [
                        "Start routine 30-60 minutes before bedtime",
                        "Include calming activities: bath, story, lullaby",
                        "Keep the sequence the same every night",
                        "Dim lights during routine to signal sleep time"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 2,
                    title: "Create Calm Environment",
                    description: "Design a sleep-friendly bedroom that promotes relaxation and rest.",
                    tips: [
                        "Use blackout curtains or dim lighting",
                        "Keep room temperature cool (65-70°F)",
                        "Use white noise machine if helpful",
                        "Remove screens and stimulating toys from bedroom"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 3,
                    title: "Set Consistent Sleep Schedule",
                    description: "Maintain the same bedtime and wake time every day, even on weekends.",
                    tips: [
                        "Choose age-appropriate bedtime",
                        "Wake child at same time each morning",
                        "Avoid late afternoon naps",
                        "Be consistent for 2-3 weeks to see results"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 4,
                    title: "Use Positive Reinforcement",
                    description: "Praise and reward your child for staying in bed and following the routine.",
                    tips: [
                        "Use sticker chart for successful nights",
                        "Give specific praise: 'Great job staying in bed!'",
                        "Offer small morning reward for good sleep",
                        "Celebrate progress, not perfection"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 5,
                    title: "Practice Gradual Separation",
                    description: "If your child needs you to stay, gradually reduce your presence over time.",
                    tips: [
                        "Start by sitting next to bed",
                        "Move chair closer to door each night",
                        "Eventually stay just outside door",
                        "Reassure with voice instead of presence"
                    ]
                )
            ]
            
        case "Tantrums":
            return [
                GuidanceStep(
                    stepNumber: 1,
                    title: "Stay Calm and Regulated",
                    description: "Your calm presence is the anchor. Take deep breaths and regulate your own emotions first.",
                    tips: [
                        "Take 3 deep breaths before responding",
                        "Use calm, neutral tone of voice",
                        "Remind yourself: 'They're having a hard time'",
                        "Model the calm you want to see"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 2,
                    title: "Acknowledge Their Feelings",
                    description: "Validate their emotions with simple, empathetic statements.",
                    tips: [
                        "Say: 'I see you're very upset'",
                        "Name the emotion: 'You seem frustrated'",
                        "Avoid dismissing or minimizing feelings",
                        "Let them know feelings are okay"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 3,
                    title: "Ensure Physical Safety",
                    description: "Make sure everyone is safe during the tantrum.",
                    tips: [
                        "Move child away from dangerous objects",
                        "Get down to their level safely",
                        "Prevent hitting or throwing",
                        "Use calm, gentle holds if necessary"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 4,
                    title: "Use Minimal Words",
                    description: "During peak tantrum, keep talking to a minimum.",
                    tips: [
                        "Use 1-2 word phrases: 'I'm here'",
                        "Avoid explanations during meltdown",
                        "Wait until they're calmer to talk",
                        "Your presence speaks volumes"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 5,
                    title: "Offer Comfort When Ready",
                    description: "When they start to calm, offer connection and comfort.",
                    tips: [
                        "Offer hug or physical comfort",
                        "Say: 'I'm proud you calmed down'",
                        "Discuss what happened (if age-appropriate)",
                        "Problem-solve together for next time"
                    ]
                )
            ]
            
        case "Eating Habits":
            return [
                GuidanceStep(
                    stepNumber: 1,
                    title: "Consistent Meal Times",
                    description: "Serve meals and snacks at the same times each day to establish hunger patterns.",
                    tips: [
                        "Set 3 meals + 2-3 snacks daily",
                        "Space meals 2-3 hours apart",
                        "Avoid grazing between meals",
                        "Serve meals even if they skip snacks"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 2,
                    title: "Make Meals Fun and Colorful",
                    description: "Present food in appealing ways without pressure to eat.",
                    tips: [
                        "Use colorful plates and utensils",
                        "Cut food into fun shapes",
                        "Let them help prepare meals",
                        "No pressure to finish plate"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 3,
                    title: "Family Meals Together",
                    description: "Eat together as a family whenever possible.",
                    tips: [
                        "Model healthy eating yourself",
                        "Make mealtime pleasant conversation",
                        "Turn off screens during meals",
                        "Keep atmosphere relaxed and positive"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 4,
                    title: "Avoid Food as Reward",
                    description: "Don't use food as bribe, punishment, or comfort.",
                    tips: [
                        "Don't say: 'Eat veggies to get dessert'",
                        "Don't withhold food as punishment",
                        "Don't force-feed or pressure",
                        "Offer food neutrally, accept refusal"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 5,
                    title: "Praise Trying New Foods",
                    description: "Celebrate exploration and tasting, not finishing.",
                    tips: [
                        "Say: 'Great job trying a bite!'",
                        "Praise the attempt, not the amount",
                        "It may take 10-15 exposures to accept new food",
                        "Be patient and persistent"
                    ]
                )
            ]
            
        case "Screen Time":
            return [
                GuidanceStep(
                    stepNumber: 1,
                    title: "Set Clear Daily Limits",
                    description: "Establish how much screen time is allowed each day and stick to it.",
                    tips: [
                        "Under 2 = no screens, 2-5 = 1 hour, 6+ = consistent limits",
                        "Write down the rules together",
                        "Post screen time schedule visibly",
                        "Be consistent daily"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 2,
                    title: "Use Visual Timer",
                    description: "Help your child see how much time is left on screens.",
                    tips: [
                        "Use kitchen timer or phone alarm",
                        "Show timer to child frequently",
                        "Give 5-minute warning before end",
                        "Make timer, not you, the 'bad guy'"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 3,
                    title: "Create Screen-Free Zones",
                    description: "Designate certain areas and times as screen-free.",
                    tips: [
                        "No screens in bedrooms",
                        "No screens during meals",
                        "No screens 1 hour before bed",
                        "Family has same rules"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 4,
                    title: "Offer Engaging Alternatives",
                    description: "Have fun activities ready to replace screen time.",
                    tips: [
                        "Prepare art supplies, books, toys",
                        "Suggest outdoor play",
                        "Play together when screens end",
                        "Make transition easier with fun options"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 5,
                    title: "Give 5-Minute Warning",
                    description: "Always warn before screen time ends to ease the transition.",
                    tips: [
                        "Say: 'Screen time ends in 5 minutes'",
                        "Show the timer",
                        "Give second warning at 1 minute",
                        "Praise cooperation when they stop"
                    ]
                )
            ]
            
        case "Potty Training":
            return [
                GuidanceStep(
                    stepNumber: 1,
                    title: "Regular Potty Intervals",
                    description: "Take your child to the potty at consistent times throughout the day.",
                    tips: [
                        "Every 2 hours to start",
                        "After meals and before outings",
                        "Before naps and bedtime",
                        "Stay calm and patient"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 2,
                    title: "Celebrate Successes",
                    description: "Make a big deal out of every success, no matter how small.",
                    tips: [
                        "Cheer and clap enthusiastically",
                        "Use specific praise: 'You did it!'",
                        "Stickers or small rewards",
                        "Call family member to share news"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 3,
                    title: "Stay Calm About Accidents",
                    description: "Accidents are part of learning. Respond with compassion.",
                    tips: [
                        "Say calmly: 'It's okay, accidents happen'",
                        "Don't punish or shame",
                        "Clean up together matter-of-factly",
                        "Encourage trying again"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 4,
                    title: "Read Potty Books Together",
                    description: "Use books and stories to normalize potty training.",
                    tips: [
                        "Read daily during training",
                        "Let child pick favorite potty books",
                        "Talk about characters using potty",
                        "Make it fun and pressure-free"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 5,
                    title: "Big Kid Underwear Choice",
                    description: "Let them pick out special underwear to motivate them.",
                    tips: [
                        "Shop together for favorite characters",
                        "Make it exciting transition",
                        "Remind: 'These are special, keep them dry'",
                        "Celebrate wearing big kid underwear"
                    ]
                )
            ]
            
        case "Separation Anxiety":
            return [
                GuidanceStep(
                    stepNumber: 1,
                    title: "Consistent Goodbye Ritual",
                    description: "Create a predictable goodbye routine every time you leave.",
                    tips: [
                        "Same sequence every time",
                        "Special hug or handshake",
                        "Say: 'I'll be back after...'",
                        "Stay positive and confident"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 2,
                    title: "Keep Goodbyes Brief",
                    description: "Long, drawn-out goodbyes make it harder for everyone.",
                    tips: [
                        "Quick hug and go",
                        "Don't linger or sneak away",
                        "Stay upbeat and matter-of-fact",
                        "Trust caregiver to comfort after"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 3,
                    title: "Validate Their Feelings",
                    description: "Let them know their feelings are understood and normal.",
                    tips: [
                        "Say: 'I'll miss you too'",
                        "Acknowledge: 'I know this is hard'",
                        "Don't dismiss or minimize",
                        "Reassure you'll always come back"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 4,
                    title: "Comfort Object",
                    description: "Give them something special to hold while you're gone.",
                    tips: [
                        "Photo of family",
                        "Special stuffed animal",
                        "Mom's scarf with her scent",
                        "Reminder that you're thinking of them"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 5,
                    title: "Always Return When Promised",
                    description: "Build trust by being reliable about your return.",
                    tips: [
                        "Be on time to pick up",
                        "Do what you said you'd do",
                        "Greet enthusiastically when back",
                        "Trust builds over time"
                    ]
                )
            ]
            
        default:
            return getGeneralCBTPCITSteps()
        }
    }
    
    // MARK: - Alternative Approach Steps
    
    private func getAlternativeSteps(for struggle: String) -> [GuidanceStep] {
        switch struggle {
        case "Sleep Routines":
            return [
                GuidanceStep(
                    stepNumber: 1,
                    title: "Bedtime Pass System",
                    description: "Give your child one 'pass' to leave their room after bedtime.",
                    tips: [
                        "Create physical pass card",
                        "One pass per night only",
                        "Use for water, bathroom, hug",
                        "Praise if they don't use it"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 2,
                    title: "Reward Chart",
                    description: "Track successful nights with stickers and rewards.",
                    tips: [
                        "Sticker for staying in bed all night",
                        "Small reward after 5 stickers",
                        "Bigger reward after 20 stickers",
                        "Display chart prominently"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 3,
                    title: "Visual Schedule",
                    description: "Create picture schedule of bedtime routine.",
                    tips: [
                        "Draw or print pictures of each step",
                        "Let child check off each step",
                        "Keep schedule by bed",
                        "Review together each night"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 4,
                    title: "Relaxation Techniques",
                    description: "Teach calming breathing and visualization.",
                    tips: [
                        "Practice belly breathing together",
                        "Use 'balloon breath': slow inhale/exhale",
                        "Visualize calm, happy place",
                        "Progressive muscle relaxation"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 5,
                    title: "Check-In Intervals",
                    description: "Promise to check on them at set intervals.",
                    tips: [
                        "Check at 2 min, then 5 min, then 10 min",
                        "Keep checks brief and boring",
                        "Reassure and leave quickly",
                        "Gradually extend time between checks"
                    ]
                )
            ]
            
        case "Tantrums":
            return [
                GuidanceStep(
                    stepNumber: 1,
                    title: "Identify Triggers",
                    description: "Track patterns to prevent tantrums before they start.",
                    tips: [
                        "Keep journal of tantrum times",
                        "Note: hunger, tiredness, transitions?",
                        "Look for patterns over 1-2 weeks",
                        "Address triggers proactively"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 2,
                    title: "Feelings Thermometer",
                    description: "Help child recognize escalating emotions early.",
                    tips: [
                        "Draw thermometer with levels 1-5",
                        "Teach: 1=calm, 5=meltdown",
                        "Ask: 'What number are you?'",
                        "Intervene early when at 2-3"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 3,
                    title: "Teach Calming Strategies",
                    description: "Practice coping skills when child is calm.",
                    tips: [
                        "Deep breathing exercises",
                        "Counting to 10",
                        "Squeezing stress ball",
                        "Taking space in calm corner"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 4,
                    title: "Redirect Attention",
                    description: "Before tantrum peaks, distract with something engaging.",
                    tips: [
                        "Point out interesting object",
                        "Ask surprising question",
                        "Suggest favorite activity",
                        "Works best at early stages"
                    ]
                ),
                GuidanceStep(
                    stepNumber: 5,
                    title: "Praise Calm Behavior",
                    description: "Catch them being calm and point it out.",
                    tips: [
                        "Say: 'I love how calm you are right now'",
                        "Praise specific behaviors",
                        "Give attention for good behavior",
                        "More praise = more good behavior"
                    ]
                )
            ]
            
        default:
            return getGeneralAlternativeSteps()
        }
    }
    
    // MARK: - General Steps (Fallback)
    
    private func getGeneralCBTPCITSteps() -> [GuidanceStep] {
        return [
            GuidanceStep(
                stepNumber: 1,
                title: "Stay Calm First",
                description: "Regulate your own emotions before responding.",
                tips: ["Take deep breaths", "Count to 10", "Model calm behavior"]
            ),
            GuidanceStep(
                stepNumber: 2,
                title: "Validate Feelings",
                description: "Let them know their feelings are understood.",
                tips: ["Say 'I hear you'", "Name the emotion", "Don't judge feelings"]
            ),
            GuidanceStep(
                stepNumber: 3,
                title: "Use Clear Language",
                description: "Communicate expectations simply and directly.",
                tips: ["Short sentences", "Age-appropriate words", "Be specific"]
            ),
            GuidanceStep(
                stepNumber: 4,
                title: "Offer Connection",
                description: "Provide comfort and reassurance.",
                tips: ["Physical comfort if accepted", "Stay present", "Show empathy"]
            ),
            GuidanceStep(
                stepNumber: 5,
                title: "Teach, Don't Punish",
                description: "Focus on teaching better behavior for next time.",
                tips: ["Problem-solve together", "Practice alternative", "Reinforce learning"]
            )
        ]
    }
    
    private func getGeneralAlternativeSteps() -> [GuidanceStep] {
        return [
            GuidanceStep(
                stepNumber: 1,
                title: "Observe Patterns",
                description: "Track when and why behaviors happen.",
                tips: ["Keep daily log", "Note triggers", "Look for themes"]
            ),
            GuidanceStep(
                stepNumber: 2,
                title: "Creative Problem-Solving",
                description: "Brainstorm solutions together with your child.",
                tips: ["Ask their ideas", "Try their suggestions", "Make it fun"]
            ),
            GuidanceStep(
                stepNumber: 3,
                title: "Establish Routines",
                description: "Create predictable daily structures.",
                tips: ["Visual schedules", "Consistent times", "Prepare for transitions"]
            ),
            GuidanceStep(
                stepNumber: 4,
                title: "Celebrate Small Wins",
                description: "Notice and praise every bit of progress.",
                tips: ["Specific praise", "Immediate recognition", "Tangible rewards"]
            ),
            GuidanceStep(
                stepNumber: 5,
                title: "Stay Patient",
                description: "Behavior change takes time and consistency.",
                tips: ["Track progress", "Don't give up", "Adjust as needed"]
            )
        ]
    }
    
    // MARK: - Legacy Method (Keeping for backward compatibility)
    
    func getStepsForStruggle(tags: [String], approachIndex: Int) -> [StepTried] {
        let primaryTag = tags.first ?? "General"
        
        switch primaryTag {
        case "Sleep Routines":
            return getSleepRoutineSteps(approachIndex: approachIndex)
        case "Tantrums":
            return getTantrumSteps(approachIndex: approachIndex)
        case "Eating Habits":
            return getEatingHabitsSteps(approachIndex: approachIndex)
        case "Screen Time":
            return getScreenTimeSteps(approachIndex: approachIndex)
        case "Potty Training":
            return getPottyTrainingSteps(approachIndex: approachIndex)
        case "Separation Anxiety":
            return getSeparationAnxietySteps(approachIndex: approachIndex)
        case "Focus and Attention":
            return getFocusAttentionSteps(approachIndex: approachIndex)
        case "Social Skills":
            return getSocialSkillsSteps(approachIndex: approachIndex)
        case "Behaviour Management":
            return getBehaviorManagementSteps(approachIndex: approachIndex)
        default:
            return getGeneralSteps(approachIndex: approachIndex)
        }
    }
    
    // MARK: - Private Persistence
    
    private func saveLogs() {
        if let encoded = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encoded, forKey: "SavedLogs")
        }
    }
    
    private func loadLogs() {
        if let data = UserDefaults.standard.data(forKey: "SavedLogs"),
           let decoded = try? JSONDecoder().decode([LogEntry].self, from: data) {
            logs = decoded
        }
    }
    
    private func saveGuidanceSessions() {
        if let encoded = try? JSONEncoder().encode(guidanceSessions) {
            UserDefaults.standard.set(encoded, forKey: "SavedGuidanceSessions")
        }
    }
    
    private func loadGuidanceSessions() {
        if let data = UserDefaults.standard.data(forKey: "SavedGuidanceSessions"),
           let decoded = try? JSONDecoder().decode([GuidanceSession].self, from: data) {
            guidanceSessions = decoded
        }
    }
    
    // MARK: - Legacy Step Generation Methods (keeping for backward compatibility)
    
    private func getSleepRoutineSteps(approachIndex: Int) -> [StepTried] {
        if approachIndex == 0 {
            return [
                StepTried(stepDescription: "📋 Establish a consistent bedtime routine (bath, book, bed)"),
                StepTried(stepDescription: "🌙 Create a calm sleep environment (dim lights, white noise)"),
                StepTried(stepDescription: "⏰ Set a consistent bedtime and wake time"),
                StepTried(stepDescription: "🎯 Use positive reinforcement for staying in bed"),
                StepTried(stepDescription: "🤗 Practice gradual separation if needed")
            ]
        } else {
            return [
                StepTried(stepDescription: "🛏️ Try a 'bedtime pass' system (one pass to leave room)"),
                StepTried(stepDescription: "🌟 Create a reward chart for successful nights"),
                StepTried(stepDescription: "📖 Use a visual schedule for bedtime routine"),
                StepTried(stepDescription: "😴 Practice relaxation techniques (deep breathing)"),
                StepTried(stepDescription: "👨‍👩‍👧 Check in at set intervals to provide reassurance")
            ]
        }
    }
    
    private func getTantrumSteps(approachIndex: Int) -> [StepTried] {
        if approachIndex == 0 {
            return [
                StepTried(stepDescription: "🧘 Stay calm and regulate your own emotions first"),
                StepTried(stepDescription: "🗣️ Acknowledge their feelings ('I see you're upset')"),
                StepTried(stepDescription: "🛡️ Ensure physical safety for everyone"),
                StepTried(stepDescription: "⏸️ Use minimal words during the peak of the tantrum"),
                StepTried(stepDescription: "🤝 Offer comfort when they're ready to calm down")
            ]
        } else {
            return [
                StepTried(stepDescription: "🎯 Identify triggers and create a prevention plan"),
                StepTried(stepDescription: "📊 Use a 'feelings thermometer' to build awareness"),
                StepTried(stepDescription: "🌈 Teach calming strategies when they're calm"),
                StepTried(stepDescription: "⚡ Redirect attention to something engaging"),
                StepTried(stepDescription: "🎁 Praise calm behavior when you see it")
            ]
        }
    }
    
    private func getEatingHabitsSteps(approachIndex: Int) -> [StepTried] {
        if approachIndex == 0 {
            return [
                StepTried(stepDescription: "🍽️ Offer meals at consistent times each day"),
                StepTried(stepDescription: "🎨 Make meals colorful and fun (no pressure)"),
                StepTried(stepDescription: "👥 Eat together as a family when possible"),
                StepTried(stepDescription: "🚫 Avoid using food as reward or punishment"),
                StepTried(stepDescription: "✨ Praise trying new foods, not finishing plate")
            ]
        } else {
            return [
                StepTried(stepDescription: "🍴 Let them help with meal planning and prep"),
                StepTried(stepDescription: "🎲 Try 'one bite rule' with new foods"),
                StepTried(stepDescription: "🥗 Offer familiar foods alongside new ones"),
                StepTried(stepDescription: "⏰ Limit snacks 1-2 hours before meals"),
                StepTried(stepDescription: "🎭 Use play to explore foods (pretend cooking)")
            ]
        }
    }
    
    private func getScreenTimeSteps(approachIndex: Int) -> [StepTried] {
        if approachIndex == 0 {
            return [
                StepTried(stepDescription: "📱 Set clear daily screen time limits"),
                StepTried(stepDescription: "⏰ Use a visual timer for screen time"),
                StepTried(stepDescription: "🎮 Create screen-free zones (bedroom, dinner table)"),
                StepTried(stepDescription: "🎯 Offer engaging alternatives to screens"),
                StepTried(stepDescription: "⚡ Give 5-minute warning before screen time ends")
            ]
        } else {
            return [
                StepTried(stepDescription: "📊 Create a screen time schedule together"),
                StepTried(stepDescription: "🏆 Use token economy (earn screen time)"),
                StepTried(stepDescription: "👪 Plan family activities during screen-free time"),
                StepTried(stepDescription: "🎨 Encourage hobbies and creative play"),
                StepTried(stepDescription: "💬 Discuss content and co-view when possible")
            ]
        }
    }
    
    private func getPottyTrainingSteps(approachIndex: Int) -> [StepTried] {
        if approachIndex == 0 {
            return [
                StepTried(stepDescription: "🚽 Take to potty at regular intervals"),
                StepTried(stepDescription: "🎉 Celebrate successes enthusiastically"),
                StepTried(stepDescription: "😊 Stay calm about accidents ('It's okay!')"),
                StepTried(stepDescription: "📚 Read potty training books together"),
                StepTried(stepDescription: "👖 Let them pick out 'big kid' underwear")
            ]
        } else {
            return [
                StepTried(stepDescription: "⭐ Create a potty chart with stickers"),
                StepTried(stepDescription: "🎵 Use a potty song or timer"),
                StepTried(stepDescription: "👥 Let them see family members use bathroom"),
                StepTried(stepDescription: "🧸 Use a favorite toy for modeling"),
                StepTried(stepDescription: "🎁 Offer small rewards for successful tries")
            ]
        }
    }
    
    private func getSeparationAnxietySteps(approachIndex: Int) -> [StepTried] {
        if approachIndex == 0 {
            return [
                StepTried(stepDescription: "👋 Create a consistent goodbye ritual"),
                StepTried(stepDescription: "⏱️ Keep goodbyes short and positive"),
                StepTried(stepDescription: "🤗 Validate their feelings ('I'll miss you too')"),
                StepTried(stepDescription: "📸 Give them something special to hold"),
                StepTried(stepDescription: "✅ Always follow through on return promises")
            ]
        } else {
            return [
                StepTried(stepDescription: "🎭 Practice separations with play (peek-a-boo)"),
                StepTried(stepDescription: "⏰ Start with short separations, gradually increase"),
                StepTried(stepDescription: "📖 Read books about going to school/daycare"),
                StepTried(stepDescription: "🌈 Create a 'bravery chart' with rewards"),
                StepTried(stepDescription: "💌 Leave notes in their lunch/backpack")
            ]
        }
    }
    
    private func getFocusAttentionSteps(approachIndex: Int) -> [StepTried] {
        if approachIndex == 0 {
            return [
                StepTried(stepDescription: "🎯 Break tasks into smaller, manageable steps"),
                StepTried(stepDescription: "⏲️ Use timers for focused work periods"),
                StepTried(stepDescription: "🪑 Create a distraction-free workspace"),
                StepTried(stepDescription: "✨ Praise effort and focus, not just results"),
                StepTried(stepDescription: "🏃 Allow movement breaks between tasks")
            ]
        } else {
            return [
                StepTried(stepDescription: "📊 Use visual schedules and checklists"),
                StepTried(stepDescription: "🎧 Try background music or noise-canceling headphones"),
                StepTried(stepDescription: "🎲 Gamify tasks (race the timer, point system)"),
                StepTried(stepDescription: "🧘 Teach mindfulness and breathing exercises"),
                StepTried(stepDescription: "🏆 Create a reward system for completed tasks")
            ]
        }
    }
    
    private func getSocialSkillsSteps(approachIndex: Int) -> [StepTried] {
        if approachIndex == 0 {
            return [
                StepTried(stepDescription: "🎭 Model sharing and turn-taking yourself"),
                StepTried(stepDescription: "🗣️ Use 'we' language ('We take turns')"),
                StepTried(stepDescription: "⏰ Use timers for fair turn-taking"),
                StepTried(stepDescription: "🌟 Praise positive social interactions"),
                StepTried(stepDescription: "👥 Arrange structured playdates")
            ]
        } else {
            return [
                StepTried(stepDescription: "📚 Read books about friendship and sharing"),
                StepTried(stepDescription: "🎬 Role-play social situations"),
                StepTried(stepDescription: "🎨 Practice with low-stakes activities first"),
                StepTried(stepDescription: "💬 Teach specific phrases ('Can I have a turn?')"),
                StepTried(stepDescription: "🏅 Celebrate small social wins")
            ]
        }
    }
    
    private func getBehaviorManagementSteps(approachIndex: Int) -> [StepTried] {
        if approachIndex == 0 {
            return [
                StepTried(stepDescription: "📋 Set clear, consistent expectations"),
                StepTried(stepDescription: "✅ Use positive reinforcement immediately"),
                StepTried(stepDescription: "🎯 Focus on desired behavior, not just 'don'ts'"),
                StepTried(stepDescription: "⚖️ Apply natural consequences when appropriate"),
                StepTried(stepDescription: "🤝 Follow through consistently on consequences")
            ]
        } else {
            return [
                StepTried(stepDescription: "📊 Create a visual behavior chart"),
                StepTried(stepDescription: "🎁 Use a token economy system"),
                StepTried(stepDescription: "⏸️ Implement planned ignoring for attention-seeking"),
                StepTried(stepDescription: "🌈 Teach replacement behaviors"),
                StepTried(stepDescription: "💬 Have calm conversations about expectations")
            ]
        }
    }
    
    private func getGeneralSteps(approachIndex: Int) -> [StepTried] {
        if approachIndex == 0 {
            return [
                StepTried(stepDescription: "🧘 Stay calm and regulated yourself first"),
                StepTried(stepDescription: "👂 Listen and validate their feelings"),
                StepTried(stepDescription: "🗣️ Use clear, simple language"),
                StepTried(stepDescription: "🤗 Offer connection and comfort"),
                StepTried(stepDescription: "🎯 Focus on teaching, not punishing")
            ]
        } else {
            return [
                StepTried(stepDescription: "📝 Observe patterns and triggers"),
                StepTried(stepDescription: "🎨 Try creative problem-solving together"),
                StepTried(stepDescription: "⏰ Establish consistent routines"),
                StepTried(stepDescription: "✨ Celebrate small wins and progress"),
                StepTried(stepDescription: "🤝 Stay patient and consistent")
            ]
        }
    }
    
    // MARK: - CBT + PCIT Info
    
    func getTechniqueInfo() -> String {
        return """
        This guidance combines evidence-based approaches:
        
        🧠 CBT (Cognitive Behavioral Therapy):
        Helps children understand and manage their thoughts, feelings, and behaviors through structured problem-solving.
        
        👨‍👩‍👧 PCIT (Parent-Child Interaction Therapy):
        Focuses on strengthening parent-child relationships through positive reinforcement, clear communication, and consistent responses.
        
        Both approaches emphasize:
        • Connection before correction
        • Positive reinforcement
        • Consistent, predictable responses
        • Teaching new skills, not just stopping behaviors
        • Building emotional regulation
        
        Remember: Every child is unique. These steps are a starting point. Trust your instincts and adjust based on what works for your family.
        """
    }
}

// MARK: - CommonStruggle Model

struct CommonStruggle: Codable, Identifiable {
    let id: UUID
    let title: String
    let icon: String
    let color: String
    let ageGroups: [AgeGroup]
    
    init(id: UUID = UUID(), title: String, icon: String, color: String, ageGroups: [AgeGroup]) {
        self.id = id
        self.title = title
        self.icon = icon
        self.color = color
        self.ageGroups = ageGroups
    }
}
