//
//  FindYourFlowViewController.swift
//  ParentBud_01
//

import UIKit

class FindYourFlowViewController: UIViewController {
    
    private let flowDataManager = FlowDataManager.shared
    private let userDataManager = UserDataManager.shared
    private let activityFeedManager = ActivityFeedDataManager.shared
    
    private var commonStruggles: [CommonStruggle] = []
    private var filteredLogs: [LogEntry] = []
    private var currentFilter:  LogStatus?  = nil
    
    private let scrollView:  UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = . automatic
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let challengeCapsuleButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 32
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let plusIconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 28
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let plusIcon:  UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        imageView.image = UIImage(systemName: "plus", withConfiguration: config)
        imageView.tintColor = . white
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let challengeLabel: UILabel = {
        let label = UILabel()
        label.text = "What's Challenging today?"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let strugglesLabel: UILabel = {
        let label = UILabel()
        label.text = "Common Struggles"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bentoGridContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let activityFeedLabel: UILabel = {
        let label = UILabel()
        label.text = "Activity Feed"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Ongoing", "Resolved", "Unresolved"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: . zero, style: .plain)
        tableView.backgroundColor = . clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(EnhancedLogEntryCell.self, forCellReuseIdentifier: "EnhancedLogEntryCell")
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No entries yet.  Tap the button above to log your first struggle."
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private var tableViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupActions()
        loadData()
        registerForTraitChanges()
        updateThemeColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        updateTableHeight()
        updateThemeColors()
    }
    
    private func registerForTraitChanges() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self:  Self, previousTraitCollection: UITraitCollection) in
                DispatchQueue.main.async {
                    self.updateThemeColors()
                    self.refreshTabBarFromParent()
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            DispatchQueue.main.async { [weak self] in
                self?.updateThemeColors()
                self?.refreshTabBarFromParent()
            }
        }
    }
    
    private func refreshTabBarFromParent() {
        if let tabBarController = self.tabBarController as? MainTabBarController {
            tabBarController.refreshTabBarAppearance()
        }
    }
    
    private func updateThemeColors() {
        view.backgroundColor = ThemeManager.Colors.background
        contentView.backgroundColor = ThemeManager.Colors.background
        scrollView.backgroundColor = ThemeManager.Colors.background
        
        strugglesLabel.textColor = ThemeManager.Colors.primaryText
        activityFeedLabel.textColor = ThemeManager.Colors.primaryText
        emptyStateLabel.textColor = ThemeManager.Colors.secondaryText
        
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        segmentedControl.selectedSegmentTintColor = ThemeManager.Colors.primaryPurple
        segmentedControl.backgroundColor = isDarkMode ? ThemeManager.Colors.cardBackground : UIColor.systemGray6
        
        segmentedControl.setTitleTextAttributes([
            . foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: ThemeManager.Colors.primaryText,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        
        challengeCapsuleButton.backgroundColor = isDarkMode ? ThemeManager.Colors.cardBackground : ThemeManager.Colors.primaryPurple.withAlphaComponent(0.12)
        challengeLabel.textColor = ThemeManager.Colors.primaryText
        plusIconContainer.backgroundColor = ThemeManager.Colors.primaryPurple
        plusIcon.tintColor = . white
        
        setupBentoGrid()
        
        tableView.reloadData()
        
        print("✅ FindYourFlow theme updated for \(isDarkMode ? "dark" : "light") mode")
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Find Your Flow"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .inline
        navigationController?.navigationBar.isTranslucent = true
    }
    
    private func loadData() {
        guard let currentUser = userDataManager.getCurrentUser() else {
            commonStruggles = []
            filteredLogs = []
            setupBentoGrid()
            tableView.reloadData()
            updateEmptyState()
            return
        }
        
        let ageGroup: AgeGroup?
        if let ageGroupString = currentUser.screenerData?.childAgeGroup {
            ageGroup = AgeGroup(rawValue: ageGroupString)
        } else {
            ageGroup = nil
        }
        
        commonStruggles = flowDataManager.getCommonStruggles(for: ageGroup)
        
        setupBentoGrid()
        updateFilteredLogs()
        
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateFilteredLogs() {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        
        let status:  LogStatus
        switch selectedIndex {
        case 0:  status = .ongoing
        case 1: status = .resolved
        case 2: status = .unresolved
        default: status = .ongoing
        }
        
        currentFilter = status
        filteredLogs = activityFeedManager.getLogs(byStatus: status)
        
        print("✅ Loaded \(filteredLogs.count) logs for status:  \(status.rawValue)")
    }
    
    private func updateEmptyState() {
        if filteredLogs.isEmpty {
            emptyStateLabel.isHidden = false
            tableView.isHidden = true
        } else {
            emptyStateLabel.isHidden = true
            tableView.isHidden = false
        }
    }
    
    private func setupBentoGrid() {
        bentoGridContainer.subviews.forEach { $0.removeFromSuperview() }
        
        guard commonStruggles.count >= 4 else { return }
        
        let topLeft = createBentoCard(struggle: commonStruggles[0])
        let topRight = createBentoCard(struggle: commonStruggles[1])
        let bottomLeft = createBentoCard(struggle: commonStruggles[2])
        let bottomRight = createBentoCard(struggle: commonStruggles[3])
        
        bentoGridContainer.addSubview(topLeft)
        bentoGridContainer.addSubview(topRight)
        bentoGridContainer.addSubview(bottomLeft)
        bentoGridContainer.addSubview(bottomRight)
        
        let spacing: CGFloat = 12
        
        NSLayoutConstraint.activate([
            topLeft.topAnchor.constraint(equalTo: bentoGridContainer.topAnchor),
            topLeft.leadingAnchor.constraint(equalTo: bentoGridContainer.leadingAnchor),
            topLeft.widthAnchor.constraint(equalTo: bentoGridContainer.widthAnchor, multiplier: 0.5, constant: -spacing/2),
            topLeft.heightAnchor.constraint(equalToConstant: 120),
            
            topRight.topAnchor.constraint(equalTo: bentoGridContainer.topAnchor),
            topRight.trailingAnchor.constraint(equalTo: bentoGridContainer.trailingAnchor),
            topRight.widthAnchor.constraint(equalTo: bentoGridContainer.widthAnchor, multiplier: 0.5, constant: -spacing/2),
            topRight.heightAnchor.constraint(equalToConstant: 120),
            
            bottomLeft.topAnchor.constraint(equalTo: topLeft.bottomAnchor, constant: spacing),
            bottomLeft.leadingAnchor.constraint(equalTo: bentoGridContainer.leadingAnchor),
            bottomLeft.widthAnchor.constraint(equalTo: bentoGridContainer.widthAnchor, multiplier: 0.5, constant: -spacing/2),
            bottomLeft.heightAnchor.constraint(equalToConstant: 120),
            bottomLeft.bottomAnchor.constraint(equalTo: bentoGridContainer.bottomAnchor),
            
            bottomRight.topAnchor.constraint(equalTo: topRight.bottomAnchor, constant: spacing),
            bottomRight.trailingAnchor.constraint(equalTo: bentoGridContainer.trailingAnchor),
            bottomRight.widthAnchor.constraint(equalTo: bentoGridContainer.widthAnchor, multiplier: 0.5, constant: -spacing/2),
            bottomRight.heightAnchor.constraint(equalToConstant: 120),
            bottomRight.bottomAnchor.constraint(equalTo: bentoGridContainer.bottomAnchor)
        ])
    }
    
    // MARK: - Create Bento Card
    private func createBentoCard(struggle: CommonStruggle) -> UIView {
        let card = UIView()
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        // ✅ FIXED: Theme-consistent colors
        if isDarkMode {
            card.backgroundColor = ThemeManager.Colors.cardBackground
        } else {
            card.backgroundColor = hexStringToUIColor(hex: struggle.color).withAlphaComponent(0.35)
        }
        
        card.layer.cornerRadius = 24
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .semibold)
        iconView.image = UIImage(systemName: struggle.icon, withConfiguration: config)
        
        // ✅ FIXED: Dynamic icon color
        if isDarkMode {
            iconView.tintColor = ThemeManager.Colors.primaryPurple
        } else {
            iconView.tintColor = UIColor(red: 0/255, green: 97/255, blue: 153/255, alpha: 1.0)
        }
        
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = struggle.title
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = ThemeManager.Colors.primaryText
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(iconView)
        card.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bentoCardTapped(_:)))
        card.addGestureRecognizer(tapGesture)
        card.isUserInteractionEnabled = true
        card.tag = commonStruggles.firstIndex(where: { $0.id == struggle.id }) ?? 0
        
        // ✅ FIXED: Proper shadow
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.layer.shadowOpacity = isDarkMode ? 0.4 : 0.06
        
        return card
    }
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(challengeCapsuleButton)
        challengeCapsuleButton.addSubview(plusIconContainer)
        plusIconContainer.addSubview(plusIcon)
        challengeCapsuleButton.addSubview(challengeLabel)
        
        contentView.addSubview(strugglesLabel)
        contentView.addSubview(bentoGridContainer)
        
        contentView.addSubview(activityFeedLabel)
        contentView.addSubview(segmentedControl)
        contentView.addSubview(tableView)
        contentView.addSubview(emptyStateLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupConstraints() {
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            challengeCapsuleButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            challengeCapsuleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            challengeCapsuleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            challengeCapsuleButton.heightAnchor.constraint(equalToConstant: 64),
            
            plusIconContainer.leadingAnchor.constraint(equalTo: challengeCapsuleButton.leadingAnchor, constant:  8),
            plusIconContainer.centerYAnchor.constraint(equalTo: challengeCapsuleButton.centerYAnchor),
            plusIconContainer.widthAnchor.constraint(equalToConstant: 56),
            plusIconContainer.heightAnchor.constraint(equalToConstant: 56),
            
            plusIcon.centerXAnchor.constraint(equalTo: plusIconContainer.centerXAnchor),
            plusIcon.centerYAnchor.constraint(equalTo: plusIconContainer.centerYAnchor),
            plusIcon.widthAnchor.constraint(equalToConstant: 28),
            plusIcon.heightAnchor.constraint(equalToConstant: 28),
            
            challengeLabel.leadingAnchor.constraint(equalTo: plusIconContainer.trailingAnchor, constant:  16),
            challengeLabel.centerYAnchor.constraint(equalTo: challengeCapsuleButton.centerYAnchor),
            challengeLabel.trailingAnchor.constraint(equalTo: challengeCapsuleButton.trailingAnchor, constant: -16),
            
            strugglesLabel.topAnchor.constraint(equalTo: challengeCapsuleButton.bottomAnchor, constant: 32),
            strugglesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            bentoGridContainer.topAnchor.constraint(equalTo: strugglesLabel.bottomAnchor, constant: 16),
            bentoGridContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bentoGridContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            activityFeedLabel.topAnchor.constraint(equalTo: bentoGridContainer.bottomAnchor, constant: 32),
            activityFeedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            segmentedControl.topAnchor.constraint(equalTo: activityFeedLabel.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tableViewHeightConstraint,
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
            
            emptyStateLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 40),
            emptyStateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -40)
        ])
    }
    
    private func updateTableHeight() {
        tableView.layoutIfNeeded()
        let height = tableView.contentSize.height
        tableViewHeightConstraint.constant = height
    }
    
    private func setupActions() {
        challengeCapsuleButton.addTarget(self, action: #selector(challengeButtonTapped), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    @objc private func challengeButtonTapped() {
        openQuickLog(prefilledStruggle: nil)
    }
    
    @objc private func bentoCardTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let index = view.tag
        guard index < commonStruggles.count else { return }
        
        let struggle = commonStruggles[index]
        
        print("🔵 Tapped struggle: \(struggle.title)")
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let userId:  UUID
        if let currentUser = userDataManager.getCurrentUser(),
           let existingUserId = UUID(uuidString: currentUser.userId) {
            userId = existingUserId
        } else {
            userId = UUID()
            print("⚠️ No user logged in, using temporary UUID")
        }
        
        let flowTitle = StruggleTitles.getTitle(for: struggle.title)
        let logEntry = LogEntry(
            userId:  userId,
            tags: [struggle.title],
            customNote: "Started from common struggles",
            flowTitle: flowTitle,
            totalSteps: 5,
            completedSteps: 0,
            status: .ongoing
        )
        
        activityFeedManager.saveActivityLog(logEntry)
        print("✅ Created and saved log entry:  \(logEntry.id) with title: \(flowTitle)")
        
        let stepByStepVC = StepByStepGuidanceViewController()
        stepByStepVC.logEntry = logEntry
        stepByStepVC.struggleName = struggle.title
        
        navigationController?.pushViewController(stepByStepVC, animated: true)
        print("✅ Navigated to StepByStep for: \(struggle.title)")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle:  .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func segmentChanged() {
        updateFilteredLogs()
        tableView.reloadData()
        updateEmptyState()
        updateTableHeight()
    }
    
    private func openQuickLog(prefilledStruggle: CommonStruggle?) {
        print("🔵 Opening QuickLog")
        print("🔵 Navigation controller exists: \(navigationController != nil)")
        
        let quickLogVC = QuickLogViewController()
        quickLogVC.prefilledStruggle = prefilledStruggle
        
        navigationController?.pushViewController(quickLogVC, animated: true)
        
        print("🔵 QuickLog pushed to navigation stack")
    }
    
    private func hexStringToUIColor(hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            return UIColor.gray
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

extension FindYourFlowViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView:  UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EnhancedLogEntryCell", for: indexPath) as! EnhancedLogEntryCell
        let log = filteredLogs[indexPath.row]
        cell.configure(with: log)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:  IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let log = filteredLogs[indexPath.row]
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let stepByStepVC = StepByStepGuidanceViewController()
        stepByStepVC.logEntry = log
        stepByStepVC.struggleName = log.tags.first ?? "General"
        navigationController?.pushViewController(stepByStepVC, animated: true)
        
        print("✅ Resumed log:  \(log.id)")
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let log = filteredLogs[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.handleDeleteLog(log)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            self?.handleEditLog(log)
            completion(true)
        }
        editAction.backgroundColor = UIColor.systemBlue
        editAction.image = UIImage(systemName: "pencil")
        
        return UISwipeActionsConfiguration(actions:  [deleteAction, editAction])
    }
    
    private func handleDeleteLog(_ log: LogEntry) {
        let alert = UIAlertController(
            title: "Delete Entry",
            message: "Are you sure you want to delete this log entry?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.activityFeedManager.deleteLog(log)
            self?.loadData()
            self?.updateTableHeight()
        })
        
        present(alert, animated: true)
    }
    
    private func handleEditLog(_ log:  LogEntry) {
        print("Edit log:  \(log.id)")
    }
}

class EnhancedLogEntryCell: UITableViewCell {
    
    private let cardView:  UIView = {
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
    
    private let initialLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 28
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = ThemeManager.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        imageView.image = UIImage(systemName:  "chevron.right", withConfiguration: config)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        updateForTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateForTheme()
        }
    }
    
    private func updateForTheme() {
        cardView.backgroundColor = ThemeManager.Colors.cardBackground
        cardView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.08
        titleLabel.textColor = ThemeManager.Colors.primaryText
        subtitleLabel.textColor = ThemeManager.Colors.secondaryText
        
        initialLabel.textColor = ThemeManager.Colors.primaryPurple
        initialLabel.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.15)
        arrowImageView.tintColor = ThemeManager.Colors.primaryPurple
    }
    
    private func setupUI() {
        backgroundColor = . clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(initialLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            initialLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            initialLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            initialLabel.widthAnchor.constraint(equalToConstant: 56),
            initialLabel.heightAnchor.constraint(equalToConstant: 56),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: initialLabel.trailingAnchor, constant:  16),
            titleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -12),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: initialLabel.trailingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -12),
            subtitleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            arrowImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalToConstant: 16),
            arrowImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with log: LogEntry) {
        let displayTitle = log.flowTitle ?? log.tags.joined(separator: ", ")
        let initial = displayTitle.prefix(1).uppercased()
        
        initialLabel.text = String(initial)
        titleLabel.text = displayTitle
        subtitleLabel.text = log.progressText
        
        updateForTheme()
    }
}
