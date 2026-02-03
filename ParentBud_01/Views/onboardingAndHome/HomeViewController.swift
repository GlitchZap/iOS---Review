//
//  HomeViewController.swift
//  ParentBud_01
//

import UIKit

class HomeViewController:  UIViewController {
    
    // MARK: - Properties
    private let userDataManager = UserDataManager.shared
    private var hasCompletedScreener:  Bool {
        return userDataManager.getCurrentUser()?.hasCompletedScreener ?? false
    }
    
    // MARK: - UI Components
    
    // Fixed Header View
    private let headerView:  UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.background
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = . label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ready for today's journey?"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.alpha = 0.9
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        button.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Scrollable Content
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = ThemeManager.Colors.background
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.background
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Journey Card
    private let journeyCard:  UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.08
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let journeyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let journeyDetailsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let completeProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Complete Child Profile", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 90/255, green: 170/255, blue: 240/255, alpha: 1.0)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor(red: 90/255, green: 170/255, blue:  240/255, alpha: 1.0).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height:  4)
        button.layer.shadowRadius = 12
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private let incompleteProfileMessage: UILabel = {
        let label = UILabel()
        label.text = "Complete your child's profile to unlock personalized insights and milestones!"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = . secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // ✅ UPDATED:  Tip Card with gradient support
    private let tipCard: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.08
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tipCardInner: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var tipGradientLayer: CAGradientLayer?
    
    private let tipIconLabel: UILabel = {
        let label = UILabel()
        label.text = "💡"
        label.font = UIFont.systemFont(ofSize: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tipTitleLabel:  UILabel = {
        let label = UILabel()
        label.text = "Today's Tip"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tipContentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Milestones Section
    private let milestonesLabel: UILabel = {
        let label = UILabel()
        label.text = "Milestones"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let milestonesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Milestones Locked Card
    private let milestonesLockedCard: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.08
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let milestonesLockedIconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 90/255, green: 170/255, blue: 240/255, alpha: 0.15)
        view.layer.cornerRadius = 40
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let milestonesLockedIcon: UILabel = {
        let label = UILabel()
        label.text = "🎯"
        label.font = UIFont.systemFont(ofSize: 40)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let milestonesLockedTitle: UILabel = {
        let label = UILabel()
        label.text = "Unlock Personalized Milestones"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let milestonesLockedMessage: UILabel = {
        let label = UILabel()
        label.text = "Complete your child's profile to track milestones, celebrate achievements, and get age-specific insights!"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let unlockMilestonesButton:  UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Complete Profile", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 90/255, green: 170/255, blue: 240/255, alpha: 1.0)
        button.layer.cornerRadius = 22
        button.layer.shadowColor = UIColor(red: 90/255, green: 170/255, blue: 240/255, alpha: 1.0).cgColor
        button.layer.shadowOffset = CGSize(width:  0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Community Cards Section
    private let communityCardsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.Colors.background
        setupUI()
        setupConstraints()
        setupActions()
        loadUserData()
        configureJourneyCard()
        configureMilestonesSection()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // ✅ Listen for child profile updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshHomeScreen),
            name: NSNotification.Name("RefreshHomeScreen"),
            object:  nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(childProfileUpdated),
            name: NSNotification.Name("ChildProfileUpdated"),
            object:  nil
        )
    }

    @objc private func refreshHomeScreen() {
        print("📢 HomeViewController: RefreshHomeScreen received")
        DispatchQueue.main.async { [weak self] in
            self?.loadUserData()
            self?.configureJourneyCard()
            self?.configureMilestonesSection()
        }
    }
    
    @objc private func childProfileUpdated() {
        print("📢 HomeViewController:  ChildProfileUpdated received")
        DispatchQueue.main.async { [weak self] in
            self?.loadUserData()
            self?.configureJourneyCard()
            self?.configureMilestonesSection()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
        
        // ✅ Refresh data every time view appears
        loadUserData()
        configureJourneyCard()
        configureMilestonesSection()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupTipGradient()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateShadowColors()
            setupTipGradient()
        }
    }
    
    // ✅ NEW: Setup Tip Card Gradient
    // ✅ UPDATED:  Setup Tip Card Gradient - Lighter tone
    private func setupTipGradient() {
        tipGradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.frame = tipCardInner.bounds
        
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        let topColor: CGColor
        let bottomColor: CGColor
        
        if isDarkMode {
            // Dark mode gradient:  darker purple to lighter purple
            topColor = UIColor(red: 0.25, green: 0.10, blue: 0.30, alpha: 0.4).cgColor
            bottomColor = UIColor(red: 0.30, green: 0.15, blue: 0.35, alpha: 0.2).cgColor
        } else {
            // ✅ Light mode gradient:  LIGHTER purple to almost white
            topColor = UIColor(red: 235/255, green: 225/255, blue: 245/255, alpha: 1.0).cgColor
            bottomColor = UIColor(red: 250/255, green: 248/255, blue: 252/255, alpha: 1.0).cgColor
        }
        
        gradient.colors = [topColor, bottomColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        tipCardInner.layer.insertSublayer(gradient, at: 0)
        tipGradientLayer = gradient
    }
    
    private func updateShadowColors() {
        let shadowOpacity:  Float = traitCollection.userInterfaceStyle == .dark ?  0.3 : 0.08
        
        journeyCard.layer.shadowOpacity = shadowOpacity
        tipCard.layer.shadowOpacity = shadowOpacity
        milestonesLockedCard.layer.shadowOpacity = shadowOpacity
    }
    
    // ✅ UPDATED: Load User Data - Get age group from active child
    private func loadUserData() {
        if let currentUser = userDataManager.getCurrentUser() {
            // Update greeting
            greetingLabel.text = "Hi \(currentUser.name)!"
            
            // ✅ Get age group from ACTIVE child
            let activeChild = currentUser.childData
            let ageGroup = activeChild?.ageGroup
            
            // Update subtitle based on child name
            if let childName = activeChild?.name {
                subtitleLabel.text = "Let's support \(childName) today"
            } else {
                subtitleLabel.text = "Ready for today's journey?"
            }
            
            // Update tip based on age group
            let todaysTip = TodaysTipManager.shared.getTodaysTip(for: ageGroup)
            updateTipCard(with: todaysTip)
            
            // Update milestones if profile complete
            if hasCompletedScreener {
                let featuredMilestones = MilestoneManager.shared.getFeaturedMilestones(for: ageGroup)
                updateMilestones(with: featuredMilestones)
            }
            
            print("✅ HomeViewController loaded user:  \(currentUser.name)")
            print("✅ Active child: \(activeChild?.name ?? "None")")
            print("✅ Age group: \(ageGroup ?? "Not set")")
            print("✅ Profile complete: \(hasCompletedScreener)")
            
        } else {
            greetingLabel.text = "Hi there!"
            subtitleLabel.text = "Ready for today's journey?"
            
            let defaultTip = TodaysTipManager.shared.getTodaysTip(for: nil)
            updateTipCard(with: defaultTip)
        }
    }
    
    // MARK: - Update Tip Card
    private func updateTipCard(with tip: TodaysTip) {
        tipTitleLabel.text = tip.title
        tipContentLabel.text = tip.content
    }
    
    // MARK: - Update Milestones
    private func updateMilestones(with milestones: [Milestone]) {
        milestonesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for milestone in milestones.prefix(2) {
            let card = createMilestoneCard(icon: milestone.icon, title: milestone.title)
            milestonesStack.addArrangedSubview(card)
        }
    }
    
    // ✅ UPDATED: Configure Journey Card - Shows active child's age group with full description
    private func configureJourneyCard() {
        journeyDetailsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let currentUser = userDataManager.getCurrentUser() else {
            journeyTitleLabel.text = "Child's Journey"
            completeProfileButton.isHidden = false
            incompleteProfileMessage.isHidden = false
            return
        }
        
        if !hasCompletedScreener {
            journeyTitleLabel.text = "Child's Journey"
            completeProfileButton.isHidden = false
            incompleteProfileMessage.isHidden = false
            return
        }
        
        completeProfileButton.isHidden = true
        incompleteProfileMessage.isHidden = true
        
        guard let activeChild = currentUser.childData else {
            journeyTitleLabel.text = "Child's Journey"
            return
        }
        
        journeyTitleLabel.text = "\(activeChild.name)'s Journey"
        
        var separators:  [UIView] = []
        
        // ✅ UPDATED: Display age group with full description
        if let childAgeGroup = activeChild.ageGroup {
            let ageDescription = getAgeGroupDescription(childAgeGroup)
            let ageView = createDetailRow(title: "Age Group", value: ageDescription)
            journeyDetailsStack.addArrangedSubview(ageView)
            separators.append(createSeparator())
            
            print("✅ Displaying active child's age group: \(childAgeGroup)")
        }
        
        // Temperament
        if let temperament = activeChild.temperament, !temperament.isEmpty {
            if !separators.isEmpty {
                journeyDetailsStack.addArrangedSubview(separators.removeFirst())
            }
            let tempValue = temperament.joined(separator: ", ")
            let tempView = createDetailRow(title: "Temperament", value: tempValue)
            journeyDetailsStack.addArrangedSubview(tempView)
            separators.append(createSeparator())
        }
        
        // Current Focus
        if let focus = activeChild.currentFocus, !focus.isEmpty {
            if !separators.isEmpty {
                journeyDetailsStack.addArrangedSubview(separators.removeFirst())
            }
            let focusValue = focus.joined(separator: ", ")
            let focusView = createDetailRow(title: "Current Focus", value: focusValue)
            journeyDetailsStack.addArrangedSubview(focusView)
        }
    }
    
    // ✅ NEW: Helper function to get age group description
    private func getAgeGroupDescription(_ ageGroup: String) -> String {
        switch ageGroup {
        case "0-1 years":
            return "0-1 years (infant years)"
        case "2-3 years":
            return "2-3 years"
        case "2-4 years":
            return "2-4 years (toddler & preschool years)"
        case "4-6 years":
            return "4-6 years (preschool & early elementary)"
        case "6-8 years":
            return "6-8 years (elementary years)"
        case "8-12 years":
            return "8-12 years (pre-teen years)"
        default:
            return ageGroup
        }
    }
    
    // MARK: - Configure Milestones Section
    private func configureMilestonesSection() {
        if hasCompletedScreener {
            milestonesLabel.isHidden = false
            milestonesStack.isHidden = false
            milestonesLockedCard.isHidden = true
        } else {
            milestonesLabel.isHidden = true
            milestonesStack.isHidden = true
            milestonesLockedCard.isHidden = false
        }
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor.separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    private func createDetailRow(title: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 15)
        valueLabel.textColor = .secondaryLabel
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Add header view (fixed at top)
        view.addSubview(headerView)
        headerView.addSubview(greetingLabel)
        headerView.addSubview(subtitleLabel)
        headerView.addSubview(settingsButton)
        
        // Add scroll view (scrollable content)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(journeyCard)
        journeyCard.addSubview(journeyTitleLabel)
        journeyCard.addSubview(journeyDetailsStack)
        journeyCard.addSubview(incompleteProfileMessage)
        journeyCard.addSubview(completeProfileButton)
        
        // ✅ UPDATED:  Tip Card with inner view for gradient
        contentView.addSubview(tipCard)
        tipCard.addSubview(tipCardInner)
        tipCardInner.addSubview(tipIconLabel)
        tipCardInner.addSubview(tipTitleLabel)
        tipCardInner.addSubview(tipContentLabel)
        
        contentView.addSubview(milestonesLabel)
        contentView.addSubview(milestonesStack)
        
        contentView.addSubview(milestonesLockedCard)
        setupMilestonesLockedCard()
        
        // Community Cards
        contentView.addSubview(communityCardsStack)
        setupCommunityCards()
    }
    
    // MARK: - Setup Milestones Locked Card
    private func setupMilestonesLockedCard() {
        milestonesLockedCard.addSubview(milestonesLockedIconContainer)
        milestonesLockedIconContainer.addSubview(milestonesLockedIcon)
        milestonesLockedCard.addSubview(milestonesLockedTitle)
        milestonesLockedCard.addSubview(milestonesLockedMessage)
        milestonesLockedCard.addSubview(unlockMilestonesButton)
        
        NSLayoutConstraint.activate([
            milestonesLockedIconContainer.topAnchor.constraint(equalTo: milestonesLockedCard.topAnchor, constant: 32),
            milestonesLockedIconContainer.centerXAnchor.constraint(equalTo: milestonesLockedCard.centerXAnchor),
            milestonesLockedIconContainer.widthAnchor.constraint(equalToConstant: 80),
            milestonesLockedIconContainer.heightAnchor.constraint(equalToConstant: 80),
            
            milestonesLockedIcon.centerXAnchor.constraint(equalTo: milestonesLockedIconContainer.centerXAnchor),
            milestonesLockedIcon.centerYAnchor.constraint(equalTo: milestonesLockedIconContainer.centerYAnchor),
            
            milestonesLockedTitle.topAnchor.constraint(equalTo: milestonesLockedIconContainer.bottomAnchor, constant: 20),
            milestonesLockedTitle.leadingAnchor.constraint(equalTo: milestonesLockedCard.leadingAnchor, constant: 24),
            milestonesLockedTitle.trailingAnchor.constraint(equalTo: milestonesLockedCard.trailingAnchor, constant: -24),
            
            milestonesLockedMessage.topAnchor.constraint(equalTo: milestonesLockedTitle.bottomAnchor, constant: 12),
            milestonesLockedMessage.leadingAnchor.constraint(equalTo: milestonesLockedCard.leadingAnchor, constant: 24),
            milestonesLockedMessage.trailingAnchor.constraint(equalTo: milestonesLockedCard.trailingAnchor, constant: -24),
            
            unlockMilestonesButton.topAnchor.constraint(equalTo: milestonesLockedMessage.bottomAnchor, constant: 24),
            unlockMilestonesButton.centerXAnchor.constraint(equalTo: milestonesLockedCard.centerXAnchor),
            unlockMilestonesButton.widthAnchor.constraint(equalToConstant: 180),
            unlockMilestonesButton.heightAnchor.constraint(equalToConstant: 44),
            unlockMilestonesButton.bottomAnchor.constraint(equalTo: milestonesLockedCard.bottomAnchor, constant: -32)
        ])
    }
    
    // ✅ NEW: Setup Community Cards
    private func setupCommunityCards() {
        let disciplineCard = createCommunityCard(icon: "👦", title: "Discipline Guide for kids")
        let sleepCard = createCommunityCard(icon: "😴", title: "Sleep Regression-Share Tips")
        
        communityCardsStack.addArrangedSubview(disciplineCard)
        communityCardsStack.addArrangedSubview(sleepCard)
    }
    
    private func createCommunityCard(icon: String, title: String) -> UIView {
        let card = UIView()
        card.backgroundColor = ThemeManager.Colors.cardBackground
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 12
        card.layer.shadowOpacity = 0.08
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 36)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(iconLabel)
        card.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 50),
            iconLabel.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            card.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        return card
    }
    
    // ✅ UPDATED:  Milestone cards with proper height and text visibility
    private func createMilestoneCard(icon:  String, title: String) -> UIView {
        let card = UIView()
        card.backgroundColor = ThemeManager.Colors.cardBackground
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 12
        card.layer.shadowOpacity = 0.08
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        iconImageView.image = UIImage(systemName: icon, withConfiguration: config)
        iconImageView.tintColor = . label
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(iconImageView)
        card.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            
            card.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        return card
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ✅ Fixed Header View (stays at top)
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            greetingLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            greetingLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            greetingLabel.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            
            settingsButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            settingsButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            settingsButton.widthAnchor.constraint(equalToConstant: 40),
            settingsButton.heightAnchor.constraint(equalToConstant: 40),
            
            // ✅ Scrollable Content (below header)
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            journeyCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            journeyCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            journeyCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            journeyTitleLabel.topAnchor.constraint(equalTo: journeyCard.topAnchor, constant: 24),
            journeyTitleLabel.leadingAnchor.constraint(equalTo: journeyCard.leadingAnchor, constant:  24),
            journeyTitleLabel.trailingAnchor.constraint(equalTo: journeyCard.trailingAnchor, constant: -24),
            
            journeyDetailsStack.topAnchor.constraint(equalTo: journeyTitleLabel.bottomAnchor, constant: 24),
            journeyDetailsStack.leadingAnchor.constraint(equalTo: journeyCard.leadingAnchor, constant: 24),
            journeyDetailsStack.trailingAnchor.constraint(equalTo: journeyCard.trailingAnchor, constant: -24),
            journeyDetailsStack.bottomAnchor.constraint(equalTo: journeyCard.bottomAnchor, constant: -24),
            
            incompleteProfileMessage.topAnchor.constraint(equalTo: journeyTitleLabel.bottomAnchor, constant: 16),
            incompleteProfileMessage.leadingAnchor.constraint(equalTo: journeyCard.leadingAnchor, constant:  24),
            incompleteProfileMessage.trailingAnchor.constraint(equalTo: journeyCard.trailingAnchor, constant: -24),
            
            completeProfileButton.topAnchor.constraint(equalTo: incompleteProfileMessage.bottomAnchor, constant: 20),
            completeProfileButton.leadingAnchor.constraint(equalTo: journeyCard.leadingAnchor, constant: 24),
            completeProfileButton.trailingAnchor.constraint(equalTo: journeyCard.trailingAnchor, constant: -24),
            completeProfileButton.bottomAnchor.constraint(equalTo: journeyCard.bottomAnchor, constant: -24),
            completeProfileButton.heightAnchor.constraint(equalToConstant: 50),
            
            // ✅ UPDATED: Tip Card Constraints
            tipCard.topAnchor.constraint(equalTo: journeyCard.bottomAnchor, constant: 24),
            tipCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            tipCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            tipCardInner.topAnchor.constraint(equalTo: tipCard.topAnchor),
            tipCardInner.leadingAnchor.constraint(equalTo: tipCard.leadingAnchor),
            tipCardInner.trailingAnchor.constraint(equalTo: tipCard.trailingAnchor),
            tipCardInner.bottomAnchor.constraint(equalTo: tipCard.bottomAnchor),
            
            tipIconLabel.topAnchor.constraint(equalTo: tipCardInner.topAnchor, constant: 20),
            tipIconLabel.leadingAnchor.constraint(equalTo: tipCardInner.leadingAnchor, constant:  20),
            
            tipTitleLabel.centerYAnchor.constraint(equalTo: tipIconLabel.centerYAnchor),
            tipTitleLabel.leadingAnchor.constraint(equalTo: tipIconLabel.trailingAnchor, constant: 10),
            
            tipContentLabel.topAnchor.constraint(equalTo: tipTitleLabel.bottomAnchor, constant: 12),
            tipContentLabel.leadingAnchor.constraint(equalTo: tipCardInner.leadingAnchor, constant: 20),
            tipContentLabel.trailingAnchor.constraint(equalTo: tipCardInner.trailingAnchor, constant: -20),
            tipContentLabel.bottomAnchor.constraint(equalTo: tipCardInner.bottomAnchor, constant: -20),
            
            milestonesLabel.topAnchor.constraint(equalTo: tipCard.bottomAnchor, constant: 36),
            milestonesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            milestonesStack.topAnchor.constraint(equalTo: milestonesLabel.bottomAnchor, constant: 20),
            milestonesStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            milestonesStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            milestonesLockedCard.topAnchor.constraint(equalTo: tipCard.bottomAnchor, constant: 36),
            milestonesLockedCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            milestonesLockedCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            communityCardsStack.topAnchor.constraint(equalTo: milestonesStack.bottomAnchor, constant: 36),
            communityCardsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            communityCardsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            communityCardsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100)
        ])
        
        let communityCardsAlternateConstraint = communityCardsStack.topAnchor.constraint(equalTo: milestonesLockedCard.bottomAnchor, constant: 36)
        communityCardsAlternateConstraint.priority = .defaultLow
        communityCardsAlternateConstraint.isActive = true
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        completeProfileButton.addTarget(self, action: #selector(completeProfileTapped), for: .touchUpInside)
        unlockMilestonesButton.addTarget(self, action: #selector(completeProfileTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func settingsTapped() {
        let settingsVC = SettingsViewController()
        settingsVC.modalPresentationStyle = .fullScreen
        present(settingsVC, animated: true)
    }
    
    @objc private func completeProfileTapped() {
        let screenerVC = ScreenerQuestionViewController()
        navigationController?.pushViewController(screenerVC, animated:  true)
    }
}
