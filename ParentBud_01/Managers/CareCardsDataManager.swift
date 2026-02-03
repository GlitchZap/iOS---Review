//
//  CareCardsDataManager.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 2025-11-15
//

import Foundation

// MARK: - JSON Models for Decoding Scraped Data

/// Represents a source article reference
private struct JSONSourceArticle: Codable {
    let url: String
    let title: String
}

/// Represents a card from the scraped JSON data
private struct JSONCareCard: Codable {
    let id: String
    let topic_id: String
    let title: String
    let subtitle: String  // Card subtitle/context
    let tips: [String]    // Contains 3-line detailed tips
    let age_groups: [String]
    let color_theme: String
    let source_articles: [JSONSourceArticle]
    let generated_at: String
    let tip_count: Int
}

/// Represents an article from the scraped JSON data
private struct JSONSuggestedArticle: Codable {
    let id: String
    let url: String
    let domain: String
    let category_id: String
    let category_title: String
    let title: String
    let authors: [String]?
    let publish_date: String?
    let top_image: String?
    let summary: String
    let key_takeaways: [String]
    let reading_time_minutes: Int
    let age_groups: [String]
    let emoji: String
    let color: String
    let full_text_length: Int?
    let extraction_method: String?
    let scraped_at: String?
}

class CareCardsDataManager {
    static let shared = CareCardsDataManager()
    
    private let userDefaults = UserDefaults.standard
    private let savedCardsKey = "savedCareCards"
    private let savedArticlesKey = "savedArticles"
    private let lastShuffleDateKey = "lastShuffleDate"
    private let shuffledCardIdsKey = "shuffledCardIds"
    private let shuffledArticleIdsKey = "shuffledArticleIds"
    
    // Cached data loaded from JSON
    private var cachedCareCards: [CareCard]?
    private var cachedSuggestedArticles: [SuggestedArticle]?
    
    private init() {
        // Pre-load data on initialization
        loadDataFromJSON()
        
        // Ensure we have data (use fallback if JSON failed)
        if cachedCareCards == nil || cachedCareCards!.isEmpty {
            print("⚠️ JSON loading failed, using fallback care cards")
            cachedCareCards = getFallbackCareCards()
        }
        if cachedSuggestedArticles == nil || cachedSuggestedArticles!.isEmpty {
            print("⚠️ JSON loading failed, using fallback articles")
            cachedSuggestedArticles = getFallbackSuggestedArticles()
        }
        
        print("✅ CareCardsDataManager ready with \(cachedCareCards?.count ?? 0) cards and \(cachedSuggestedArticles?.count ?? 0) articles")
        
        // Check if we need to shuffle for today
        checkAndRefreshShuffle()
    }
    
    // MARK: - Daily Shuffle Logic
    
    private func checkAndRefreshShuffle() {
        let calendar = Calendar.current
        let now = Date()
        
        if let lastShuffleDate = userDefaults.object(forKey: lastShuffleDateKey) as? Date {
            // Check if 24 hours have passed
            if !calendar.isDate(lastShuffleDate, inSameDayAs: now) {
                print("🔄 24 hours passed - reshuffling cards and articles")
                reshuffleContent()
            } else {
                print("✅ Using existing shuffle from today")
            }
        } else {
            // First time - create initial shuffle
            print("🆕 First launch - creating initial shuffle")
            reshuffleContent()
        }
    }
    
    private func reshuffleContent() {
        // Shuffle cards - pick one from each topic
        let diverseCards = getDiverseCardsFromAllTopics()
        let shuffledCardIds = diverseCards.shuffled().map { $0.id.uuidString }
        userDefaults.set(shuffledCardIds, forKey: shuffledCardIdsKey)
        
        // Shuffle articles - pick one from each category
        let diverseArticles = getDiverseArticlesFromAllCategories()
        let shuffledArticleIds = diverseArticles.shuffled().map { $0.id.uuidString }
        userDefaults.set(shuffledArticleIds, forKey: shuffledArticleIdsKey)
        
        // Save the shuffle date
        userDefaults.set(Date(), forKey: lastShuffleDateKey)
        userDefaults.synchronize()
        
        print("📊 Shuffled \(shuffledCardIds.count) cards and \(shuffledArticleIds.count) articles for today")
    }
    
    /// Get one card from each topic for diversity
    private func getDiverseCardsFromAllTopics() -> [CareCard] {
        let allCards = cachedCareCards ?? getFallbackCareCards()
        var cardsByTopic: [String: [CareCard]] = [:]
        
        // Group cards by topic
        for card in allCards {
            let topic = card.category.rawValue
            if cardsByTopic[topic] == nil {
                cardsByTopic[topic] = []
            }
            cardsByTopic[topic]?.append(card)
        }
        
        // Pick one random card from each topic
        var diverseCards: [CareCard] = []
        for (topic, cards) in cardsByTopic {
            if let randomCard = cards.randomElement() {
                diverseCards.append(randomCard)
                print("📌 Selected '\(randomCard.title)' from topic '\(topic)'")
            }
        }
        
        return diverseCards
    }
    
    /// Get one article from each category for diversity
    private func getDiverseArticlesFromAllCategories() -> [SuggestedArticle] {
        let allArticles = cachedSuggestedArticles ?? getFallbackSuggestedArticles()
        var articlesByCategory: [String: [SuggestedArticle]] = [:]
        
        // Group articles by category
        for article in allArticles {
            let category = article.category.rawValue
            if articlesByCategory[category] == nil {
                articlesByCategory[category] = []
            }
            articlesByCategory[category]?.append(article)
        }
        
        // Pick one random article from each category
        var diverseArticles: [SuggestedArticle] = []
        for (category, articles) in articlesByCategory {
            if let randomArticle = articles.randomElement() {
                diverseArticles.append(randomArticle)
                print("📰 Selected '\(randomArticle.title)' from category '\(category)'")
            }
        }
        
        return diverseArticles
    }
    
    /// Force refresh the shuffle (can be called manually)
    func forceRefreshShuffle() {
        reshuffleContent()
    }
    
    // MARK: - JSON Loading
    
    private func loadDataFromJSON() {
        cachedCareCards = loadCareCardsFromJSON()
        cachedSuggestedArticles = loadSuggestedArticlesFromJSON()
        print("📊 Loaded \(cachedCareCards?.count ?? 0) care cards and \(cachedSuggestedArticles?.count ?? 0) suggested articles from JSON")
    }
    
    private func loadCareCardsFromJSON() -> [CareCard] {
        guard let url = Bundle.main.url(forResource: "care_cards", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("⚠️ Could not find care_cards.json, using fallback data")
            return getFallbackCareCards()
        }
        
        do {
            let jsonCards = try JSONDecoder().decode([JSONCareCard].self, from: data)
            return jsonCards.compactMap { convertToCareCard($0) }
        } catch {
            print("❌ Error decoding care_cards.json: \(error)")
            return getFallbackCareCards()
        }
    }
    
    private func loadSuggestedArticlesFromJSON() -> [SuggestedArticle] {
        guard let url = Bundle.main.url(forResource: "suggested_articles", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("⚠️ Could not find suggested_articles.json, using fallback data")
            return getFallbackSuggestedArticles()
        }
        
        do {
            let jsonArticles = try JSONDecoder().decode([JSONSuggestedArticle].self, from: data)
            return jsonArticles.compactMap { convertToSuggestedArticle($0) }
        } catch {
            print("❌ Error decoding suggested_articles.json: \(error)")
            return getFallbackSuggestedArticles()
        }
    }
    
    // MARK: - JSON to Model Conversion
    
    private func convertToCareCard(_ json: JSONCareCard) -> CareCard? {
        // Create UUID from the hex string ID
        let uuid = UUID(uuidString: formatAsUUID(json.id)) ?? UUID()
        
        let category = mapTopicToCategory(json.topic_id)
        let ageGroups = json.age_groups.compactMap { mapAgeGroupString($0) }
        let gradientColors = getGradientColorsForTheme(json.color_theme)
        let imageName = getImageNameForTopic(json.topic_id)
        
        // Convert tips to ContentCards (now with rich 3-line content)
        let contentCards = json.tips.enumerated().map { index, tip in
            ContentCard(id: UUID(), text: tip, order: index + 1)
        }
        
        return CareCard(
            id: uuid,
            title: json.title,
            summary: json.subtitle,  // Use subtitle as the card summary
            category: category,
            ageGroups: ageGroups,
            tags: [json.topic_id, category.rawValue.lowercased()],
            personalizedScore: Double.random(in: 0.7...0.99),
            relevanceReason: nil,
            imageName: imageName,
            gradientColors: gradientColors,
            contentCards: contentCards,
            isTrending: true,
            isSaved: false,
            readingTimeMinutes: max(3, json.tips.count),  // Longer reading time for richer content
            createdAt: Date()
        )
    }
    
    /// Convert hex string ID to UUID format
    private func formatAsUUID(_ hexId: String) -> String {
        // Pad to 32 characters if needed
        let padded = hexId.padding(toLength: 32, withPad: "0", startingAt: 0)
        // Format as UUID: 8-4-4-4-12
        let chars = Array(padded)
        return "\(String(chars[0..<8]))-\(String(chars[8..<12]))-\(String(chars[12..<16]))-\(String(chars[16..<20]))-\(String(chars[20..<32]))"
    }
    
    private func convertToSuggestedArticle(_ json: JSONSuggestedArticle) -> SuggestedArticle? {
        // Create a stable UUID from the article's string ID
        let uuid = UUID(uuidString: json.id.padding(toLength: 36, withPad: "0", startingAt: 0).replacingOccurrences(of: "(.{8})(.{4})(.{4})(.{4})(.{12})", with: "$1-$2-$3-$4-$5", options: .regularExpression)) ?? UUID()
        
        let category = mapCategoryIdToCategory(json.category_id)
        let gradientColors = getGradientColorsForCategory(category)
        
        return SuggestedArticle(
            id: uuid,
            title: json.title,
            summary: json.summary,
            category: category,
            sourceURL: json.url,
            sourceName: json.domain.replacingOccurrences(of: "www.", with: "").components(separatedBy: ".").first?.capitalized ?? json.domain,
            emoji: json.emoji,
            gradientColors: gradientColors,
            isTrending: true,
            isSaved: false,
            readingTimeMinutes: json.reading_time_minutes,
            createdAt: Date()
        )
    }
    
    // MARK: - Mapping Helpers
    
    private func mapTopicToCategory(_ topicId: String) -> CareCardCategory {
        switch topicId.lowercased() {
        case "tantrums": return .tantrums
        case "sleep", "sleeping": return .sleep
        case "eating", "eating_habits", "nutrition": return .nutrition
        case "behavior", "behavior_management": return .behavior
        case "screen_time", "screentime": return .screenTime
        case "separation_anxiety", "separation": return .separationAnxiety
        case "social_skills", "social": return .social
        case "confidence", "confidence_building": return .confidence
        case "emotional", "emotional_regulation": return .emotional
        default: return .behavior
        }
    }
    
    private func mapCategoryIdToCategory(_ categoryId: String) -> CareCardCategory {
        switch categoryId.lowercased() {
        case "sleep": return .sleep
        case "tantrums": return .tantrums
        case "eating", "eating_habits": return .nutrition
        case "screen_time", "screentime": return .screenTime
        case "social_skills": return .social
        case "confidence": return .confidence
        case "separation_anxiety": return .separationAnxiety
        case "emotional", "emotional_regulation": return .emotional
        case "behavior": return .behavior
        default: return .behavior
        }
    }
    
    private func mapAgeGroupString(_ ageString: String) -> AgeGroup? {
        switch ageString {
        case "2-4": return .toddler
        case "4-6": return .preschool
        case "6-8", "8-10": return .schoolAge
        default: return nil
        }
    }
    
    private func getGradientColorsForTheme(_ theme: String) -> [String] {
        switch theme.lowercased() {
        case "calm_orange": return ["#FFE5E5", "#FFF5F5"]
        case "gentle_blue": return ["#E3F2FD", "#E8EAF6"]
        case "soft_green": return ["#E8F5E9", "#F1F8E9"]
        case "warm_purple": return ["#F3E5F5", "#EDE7F6"]
        case "sky_blue": return ["#E1F5FE", "#E3F2FD"]
        case "sunny_yellow": return ["#FFFDE7", "#FFF8E1"]
        case "peach": return ["#FFF3E0", "#FFF8E1"]
        case "lavender": return ["#EDE7F6", "#F3E5F5"]
        case "teal": return ["#E0F2F1", "#E0F7FA"]
        case "coral": return ["#FFEBEE", "#FCE4EC"]
        case "mint": return ["#E8F5E9", "#E0F2F1"]
        default: return ["#F5F5F5", "#FAFAFA"]
        }
    }
    
    private func getGradientColorsForCategory(_ category: CareCardCategory) -> [String] {
        switch category {
        case .tantrums: return ["#FFE5E5", "#FFF5F5"]
        case .sleep: return ["#E8EAF6", "#F3E5F5"]
        case .nutrition: return ["#E8F5E9", "#F1F8E9"]
        case .screenTime: return ["#E3F2FD", "#F3E5F5"]
        case .separationAnxiety: return ["#FFF3E0", "#FFF8E1"]
        case .social: return ["#E1F5FE", "#F1F8E9"]
        case .confidence: return ["#FFFDE7", "#FFF8E1"]
        case .emotional: return ["#FCE4EC", "#F3E5F5"]
        case .behavior: return ["#EDE7F6", "#E8EAF6"]
        }
    }
    
    private func getImageNameForTopic(_ topicId: String) -> String {
        switch topicId.lowercased() {
        case "tantrums": return "tantrum"
        case "sleep", "sleeping": return "sleepingHabits"
        case "eating", "eating_habits", "nutrition": return "eatingHabits"
        case "screen_time", "screentime": return "screenTime"
        case "separation_anxiety", "separation": return "seprationAnxiety"
        case "social_skills", "social": return "socialSkills"
        case "confidence", "confidence_building": return "confidence"
        case "behavior", "behavior_management": return "behaviour"
        default: return "behaviour"
        }
    }
    
    // MARK: - Get Recommended Cards (Diverse - one from each topic)
    
    func getRecommendedCards(for user: UserData?) -> [CareCard] {
        let allCards = getAllCareCards()
        
        // If no cards loaded, return empty (UI should handle this)
        if allCards.isEmpty {
            print("⚠️ No cards available")
            return []
        }
        
        // Get diverse cards - one from each topic
        let diverseCards = getDiverseCardsFromAllTopics()
        
        // Filter by user's age group if available
        var filteredCards = diverseCards
        if let user = user,
           let ageGroupString = user.screenerData?.childAgeGroup,
           let ageGroup = AgeGroup(rawValue: ageGroupString) {
            filteredCards = diverseCards.filter { $0.ageGroups.contains(ageGroup) }
        }
        
        // If filtering resulted in too few cards, use unfiltered
        if filteredCards.count < 3 {
            filteredCards = diverseCards
        }
        
        // Return up to 6 diverse cards
        print("📋 Returning \(min(6, filteredCards.count)) recommended cards")
        return Array(filteredCards.shuffled().prefix(6))
    }
    
    // MARK: - Get Suggested Articles (Diverse - one from each category)
    
    func getSuggestedArticles() -> [SuggestedArticle] {
        let allArticles = getAllSuggestedArticles()
        
        // If no articles loaded, return empty
        if allArticles.isEmpty {
            print("⚠️ No articles available")
            return []
        }
        
        // Get diverse articles - one from each category
        let diverseArticles = getDiverseArticlesFromAllCategories()
        
        // Return up to 8 diverse articles (one from each category)
        print("📰 Returning \(min(8, diverseArticles.count)) suggested articles")
        return Array(diverseArticles.shuffled().prefix(8))
    }
    
    // MARK: - Save/Unsave Cards
    
    func isCardSaved(_ cardId: UUID) -> Bool {
        let saved = getSavedCardIds().contains(cardId)
        print("🔍 Checking if card \(cardId) is saved: \(saved)")
        return saved
    }
    
    func saveCard(_ cardId: UUID) {
        var savedIds = getSavedCardIds()
        if !savedIds.contains(cardId) {
            savedIds.append(cardId)
            saveSavedCardIds(savedIds)
            print("✅ Saved card: \(cardId)")
            print("📊 All saved card IDs: \(savedIds)")
        }
    }
    
    func unsaveCard(_ cardId: UUID) {
        var savedIds = getSavedCardIds()
        savedIds.removeAll { $0 == cardId }
        saveSavedCardIds(savedIds)
        print("✅ Unsaved card: \(cardId)")
        print("📊 Remaining saved card IDs: \(savedIds)")
    }
    
    private func getSavedCardIds() -> [UUID] {
        if let data = userDefaults.data(forKey: savedCardsKey),
           let ids = try? JSONDecoder().decode([UUID].self, from: data) {
            print("📚 Loaded \(ids.count) saved card IDs: \(ids)")
            return ids
        }
        print("📚 No saved cards found")
        return []
    }
    
    private func saveSavedCardIds(_ ids: [UUID]) {
        if let encoded = try? JSONEncoder().encode(ids) {
            userDefaults.set(encoded, forKey: savedCardsKey)
            userDefaults.synchronize()
            print("💾 Saved \(ids.count) card IDs to UserDefaults")
        }
    }
    
    // MARK: - Save/Unsave Articles
    
    func isArticleSaved(_ articleId: UUID) -> Bool {
        let saved = getSavedArticleIds().contains(articleId)
        print("🔍 Checking if article \(articleId) is saved: \(saved)")
        return saved
    }
    
    func saveArticle(_ articleId: UUID) {
        var savedIds = getSavedArticleIds()
        if !savedIds.contains(articleId) {
            savedIds.append(articleId)
            saveSavedArticleIds(savedIds)
            print("✅ Saved article: \(articleId)")
            print("📊 All saved article IDs: \(savedIds)")
        }
    }
    
    func unsaveArticle(_ articleId: UUID) {
        var savedIds = getSavedArticleIds()
        savedIds.removeAll { $0 == articleId }
        saveSavedArticleIds(savedIds)
        print("✅ Unsaved article: \(articleId)")
        print("📊 Remaining saved article IDs: \(savedIds)")
    }
    
    private func getSavedArticleIds() -> [UUID] {
        if let data = userDefaults.data(forKey: savedArticlesKey),
           let ids = try? JSONDecoder().decode([UUID].self, from: data) {
            print("📰 Loaded \(ids.count) saved article IDs: \(ids)")
            return ids
        }
        print("📰 No saved articles found")
        return []
    }
    
    private func saveSavedArticleIds(_ ids: [UUID]) {
        if let encoded = try? JSONEncoder().encode(ids) {
            userDefaults.set(encoded, forKey: savedArticlesKey)
            userDefaults.synchronize()
            print("💾 Saved \(ids.count) article IDs to UserDefaults")
        }
    }
    
    // MARK: - Get Saved Items
    
    func getSavedCards() -> [CareCard] {
        let savedIds = getSavedCardIds()
        let allCards = getAllCareCards()
        
        print("\n🔍 DEBUGGING getSavedCards:")
        print("📋 Saved IDs: \(savedIds)")
        print("📋 All card IDs: \(allCards.map { $0.id })")
        
        let saved = allCards.filter { savedIds.contains($0.id) }
        print("🔍 Found \(saved.count) saved cards out of \(allCards.count) total")
        print("📌 Saved card titles: \(saved.map { $0.title })")
        
        return saved
    }
    
    func getSavedArticles() -> [SuggestedArticle] {
        let savedIds = getSavedArticleIds()
        let allArticles = getAllSuggestedArticles()
        
        print("\n🔍 DEBUGGING getSavedArticles:")
        print("📋 Saved IDs: \(savedIds)")
        print("📋 All article IDs: \(allArticles.map { $0.id })")
        
        let saved = allArticles.filter { savedIds.contains($0.id) }
        print("🔍 Found \(saved.count) saved articles out of \(allArticles.count) total")
        print("📰 Saved article titles: \(saved.map { $0.title })")
        
        return saved
    }
    
    func getSavedCardsCount() -> Int {
        return getSavedCardIds().count
    }
    
    func getSavedArticlesCount() -> Int {
        return getSavedArticleIds().count
    }
    
    func getTotalSavedCount() -> Int {
        return getSavedCardsCount() + getSavedArticlesCount()
    }
    
    // MARK: - Get All Data (from cached JSON)
    
    private func getAllCareCards() -> [CareCard] {
        return cachedCareCards ?? getFallbackCareCards()
    }
    
    private func getAllSuggestedArticles() -> [SuggestedArticle] {
        return cachedSuggestedArticles ?? getFallbackSuggestedArticles()
    }
    
    // MARK: - Fallback Data (used when JSON is not available)
    
    private func getFallbackCareCards() -> [CareCard] {
        return [
            CareCard(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                title: "Taming Tantrums",
                summary: "Learn effective strategies to handle emotional outbursts with compassion",
                category: .tantrums,
                ageGroups: [.toddler, .preschool],
                tags: ["tantrums", "behavior", "emotional regulation"],
                personalizedScore: 0.95,
                relevanceReason: "Based on your recent activity",
                imageName: "tantrum",
                gradientColors: ["#FFE5E5", "#FFF5F5"],
                contentCards: [
                    ContentCard(text: "Tantrums aren't about manipulation; they're a child's way of expressing overwhelm when they lack the words or emotional regulation skills.", order: 1),
                    ContentCard(text: "During a tantrum, a child's logical brain effectively shuts down. Trying to reason during the storm won't work—it's like trying to teach swimming in a hurricane.", order: 2),
                    ContentCard(text: "A child in emotional distress needs calm, non-judgmental presence, not lectures. By staying calm and providing comfort, you become the anchor that helps them ride out the storm.", order: 3),
                    ContentCard(text: "Every tantrum is an opportunity to teach emotional regulation. With time and consistent caring responses, you're building neural pathways that help children learn to self-soothe.", order: 4)
                ],
                readingTimeMinutes: 5
            ),
            
            CareCard(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                title: "Eating Habits",
                summary: "Develop healthy relationships with food without power struggles",
                category: .nutrition,
                ageGroups: [.toddler, .preschool, .schoolAge],
                tags: ["eating", "nutrition", "picky eater"],
                personalizedScore: 0.88,
                relevanceReason: "Matches your focus areas",
                imageName: "eatingHabits",
                gradientColors: ["#E8F5E9", "#F1F8E9"],
                contentCards: [
                    ContentCard(text: "Children have an innate ability to self-regulate their food intake. Trust their hunger cues rather than enforcing 'clean plate' rules.", order: 1),
                    ContentCard(text: "Make mealtimes pressure-free zones. The more you push, the more resistance you'll face. Your job is to offer nutritious options; their job is to decide what and how much to eat.", order: 2),
                    ContentCard(text: "It can take 10-15 exposures to a new food before a child accepts it. Keep offering without pressure, and celebrate small wins like touching or smelling new foods.", order: 3),
                    ContentCard(text: "Model healthy eating yourself. Children learn more from watching than from being told. Enjoy a variety of foods and they'll become curious too.", order: 4)
                ],
                readingTimeMinutes: 4
            ),
            
            CareCard(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                title: "Screen Time Balance",
                summary: "Navigate the digital world with healthy boundaries",
                category: .screenTime,
                ageGroups: [.toddler, .preschool, .schoolAge],
                tags: ["screen time", "technology", "digital wellness"],
                personalizedScore: 0.82,
                imageName: "screenTime",
                gradientColors: ["#E3F2FD", "#F3E5F5"],
                contentCards: [
                    ContentCard(text: "Screen time isn't inherently bad, but passive consumption differs from interactive, educational use. Choose quality over quantity.", order: 1),
                    ContentCard(text: "Set clear, consistent boundaries. Use visual timers so children can see time passing. This makes transitions easier and reduces power struggles.", order: 2),
                    ContentCard(text: "Create tech-free zones: bedrooms, dinner tables, and the hour before bed. These boundaries protect sleep, family connection, and healthy habits.", order: 3),
                    ContentCard(text: "Co-view when possible. Discuss what they're watching, ask questions, and connect screen content to real life. This transforms passive watching into active learning.", order: 4)
                ],
                readingTimeMinutes: 4
            ),
            
            CareCard(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
                title: "Separation Anxiety",
                summary: "Build confidence in goodbyes and reunions",
                category: .separationAnxiety,
                ageGroups: [.toddler, .preschool],
                tags: ["separation", "anxiety", "attachment"],
                personalizedScore: 0.78,
                imageName: "seprationAnxiety",
                gradientColors: ["#FFF3E0", "#FFF8E1"],
                contentCards: [
                    ContentCard(text: "Separation anxiety is developmentally normal and actually a sign of healthy attachment. It shows your child values your relationship.", order: 1),
                    ContentCard(text: "Create a consistent goodbye ritual: hug, kiss, wave, and go. Long, drawn-out goodbyes often increase distress rather than soothe it.", order: 2),
                    ContentCard(text: "Never sneak away. It may seem easier in the moment, but it erodes trust and can make future separations harder. Always say goodbye, even if briefly.", order: 3),
                    ContentCard(text: "Build trust by always returning when promised. Reliability teaches them that separations are temporary and that you'll always come back.", order: 4)
                ],
                readingTimeMinutes: 4
            ),
            
            CareCard(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
                title: "Sleep Routines",
                summary: "Create peaceful bedtimes with consistent routines",
                category: .sleep,
                ageGroups: [.toddler, .preschool, .schoolAge],
                tags: ["sleep", "bedtime", "routines"],
                personalizedScore: 0.90,
                imageName: "sleepingHabits",
                gradientColors: ["#E8EAF6", "#F3E5F5"],
                contentCards: [
                    ContentCard(text: "Consistent bedtime routines signal the brain that it's time to wind down. A predictable sequence reduces resistance and anxiety.", order: 1),
                    ContentCard(text: "Start your routine 30-60 minutes before desired sleep time. Include calming activities: bath, story, quiet play, dim lights.", order: 2),
                    ContentCard(text: "The bedroom should be cool, dark, and quiet. Consider blackout curtains and white noise if environmental factors disrupt sleep.", order: 3),
                    ContentCard(text: "Stay consistent, even on weekends. A regular sleep schedule helps regulate your child's internal clock and makes bedtime smoother.", order: 4)
                ],
                readingTimeMinutes: 5
            ),
            
            CareCard(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
                title: "Social Skills",
                summary: "Help your child build meaningful friendships",
                category: .social,
                ageGroups: [.preschool, .schoolAge],
                tags: ["social", "friendship", "play"],
                personalizedScore: 0.75,
                imageName: "socialSkills",
                gradientColors: ["#E1F5FE", "#F1F8E9"],
                contentCards: [
                    ContentCard(text: "Social skills are learned, not innate. Children need opportunities to practice sharing, taking turns, and resolving conflicts with guidance.", order: 1),
                    ContentCard(text: "Model the behavior you want to see. Demonstrate empathy, active listening, and respectful disagreement in your own interactions.", order: 2),
                    ContentCard(text: "Arrange playdates and provide gentle coaching. Help them read social cues and navigate tricky situations without taking over.", order: 3),
                    ContentCard(text: "Celebrate social wins, no matter how small. 'You invited Alex to play—that was brave and kind!' builds confidence and reinforces positive behavior.", order: 4)
                ],
                readingTimeMinutes: 4
            )
        ]
    }
    
    private func getFallbackSuggestedArticles() -> [SuggestedArticle] {
        return [
            SuggestedArticle(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
                title: "Why Your Toddler Has Big Feelings",
                summary: "Neuroscience shows that toddlers' brains are still developing emotional regulation. Their prefrontal cortex (responsible for rational thought) won't fully mature until their mid-20s. When they melt down, it's not manipulation—it's biology. Their amygdala (emotion center) is in overdrive while their 'thinking brain' is offline. Your calm presence helps co-regulate their nervous system, teaching them how to manage big emotions over time.",
                category: .emotional,
                sourceURL: "https://childmind.org/article/why-do-kids-have-tantrums-and-meltdowns/",
                sourceName: "Child Mind Institute",
                emoji: "🧠",
                gradientColors: ["#FFE5E5", "#FFF5F5"],
                readingTimeMinutes: 3
            ),
            
            SuggestedArticle(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
                title: "The Division of Responsibility in Feeding",
                summary: "Dietitian Ellyn Satter's research transformed pediatric nutrition. The parent decides what, when, and where food is offered. The child decides whether and how much to eat. This division eliminates food battles and teaches children to trust their internal hunger cues. Studies show children raised this way have healthier relationships with food, lower obesity rates, and better nutrition overall. Stop the 'clean plate' pressure—it backfires.",
                category: .nutrition,
                sourceURL: "https://www.ellynsatterinstitute.org/how-to-feed/the-division-of-responsibility-in-feeding/",
                sourceName: "Ellyn Satter Institute",
                emoji: "🍽️",
                gradientColors: ["#E8F5E9", "#F1F8E9"],
                readingTimeMinutes: 4
            ),
            
            SuggestedArticle(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
                title: "Screen Time: Quality Over Quantity",
                summary: "The American Academy of Pediatrics shifted from strict time limits to focusing on content quality and family context. Not all screen time is equal: passive consumption differs from interactive learning. Co-viewing transforms it into bonding time. The key concerns are: Does it displace sleep, physical activity, or face-to-face interaction? Set boundaries, choose high-quality content, and be present. Screen time itself isn't the enemy—how we use it matters.",
                category: .screenTime,
                sourceURL: "https://www.aap.org/en/patient-care/media-and-children/",
                sourceName: "American Academy of Pediatrics",
                emoji: "📺",
                gradientColors: ["#E3F2FD", "#F3E5F5"],
                readingTimeMinutes: 3
            ),
            
            SuggestedArticle(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000004")!,
                title: "Separation Anxiety: A Sign of Secure Attachment",
                summary: "Attachment research shows that separation anxiety peaks between 10-18 months and is actually a positive developmental milestone. It means your child recognizes you as their secure base—the person who keeps them safe. Children with secure attachments protest separations but can be comforted and recover. The solution isn't avoiding separation but handling it consistently: brief, warm goodbyes and reliable returns. This builds trust that you'll always come back.",
                category: .separationAnxiety,
                sourceURL: "https://www.zerotothree.org/resource/separation-anxiety/",
                sourceName: "Zero to Three",
                emoji: "💙",
                gradientColors: ["#FFF3E0", "#FFF8E1"],
                readingTimeMinutes: 4
            ),
            
            SuggestedArticle(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000005")!,
                title: "The Science of Sleep in Children",
                summary: "Sleep isn't just downtime—it's when the brain consolidates memories, processes emotions, and grows. Children aged 1-2 need 11-14 hours, 3-5 need 10-13 hours, and 6-12 need 9-12 hours per 24 hours. Consistent routines help regulate circadian rhythms. Blue light from screens suppresses melatonin, so avoid them an hour before bed. A dark, cool room optimizes sleep architecture. Better sleep means better behavior, learning, and emotional regulation.",
                category: .sleep,
                sourceURL: "https://www.sleepfoundation.org/children-and-sleep",
                sourceName: "Sleep Foundation",
                emoji: "🌙",
                gradientColors: ["#E8EAF6", "#F3E5F5"],
                readingTimeMinutes: 4
            )
        ]
    }
}
