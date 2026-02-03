//
//  ExpertsViewController.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 16/11/25.
//

import UIKit

class ExpertsViewController: UIViewController {
    
    // MARK: - Properties
    private let dataManager = ExpertsDataManager.shared
    private let userDataManager = UserDataManager.shared
    
    private var allExperts: [Expert] = []
    private var scheduledSessions: [ExpertSession] = []
    private var chatThreads: [ChatThread] = []
    
    private enum Tab: Int {
        case all = 0
        case scheduled = 1
        case inbox = 2
    }
    
    private var currentTab: Tab = .all
    
    // MARK: - UI Components
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search experts..."
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["All", "Scheduled", "Inbox"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = ThemeManager.Colors.primaryPurple
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ], for: .selected)
        control.setTitleTextAttributes([
            .foregroundColor: ThemeManager.Colors.primaryText,
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ], for: .normal)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = ThemeManager.Colors.background
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // ✅ Clean Empty State View
    private let emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyStateStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let emptyStateIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.3)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateSubLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupActions()
        setupNotificationObservers()
        loadData()
        registerForThemeChanges()
        
        // Refresh data from Supabase
        dataManager.refreshAllData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        loadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(expertsDidUpdate),
            name: .expertsDidUpdate,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionsDidUpdate),
            name: .sessionsDidUpdate,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(chatThreadsDidUpdate),
            name: .chatThreadsDidUpdate,
            object: nil
        )
    }
    
    @objc private func expertsDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.loadData()
        }
    }
    
    @objc private func sessionsDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.loadData()
        }
    }
    
    @objc private func chatThreadsDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.loadData()
        }
    }
    
    private func registerForThemeChanges() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                self.updateTheme()
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTheme()
        }
    }
    
    private func updateTheme() {
        view.backgroundColor = ThemeManager.Colors.background
        tableView.backgroundColor = ThemeManager.Colors.background
        emptyStateLabel.textColor = ThemeManager.Colors.primaryText
        emptyStateSubLabel.textColor = ThemeManager.Colors.secondaryText
        emptyStateIconView.tintColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.3)
        
        segmentedControl.selectedSegmentTintColor = ThemeManager.Colors.primaryPurple
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: ThemeManager.Colors.primaryText
        ], for: .normal)
        
        tableView.reloadData()
    }
    
    // MARK: - Setup Navigation Bar
    
    private func setupNavigationBar() {
        navigationItem.title = "Talk to an Expert"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .inline
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(searchBar)
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        // Setup empty state stack
        emptyStateView.addSubview(emptyStateStackView)
        emptyStateStackView.addArrangedSubview(emptyStateIconView)
        emptyStateStackView.addArrangedSubview(emptyStateLabel)
        emptyStateStackView.addArrangedSubview(emptyStateSubLabel)
        emptyStateStackView.addArrangedSubview(emptyStateButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.register(ExpertCell.self, forCellReuseIdentifier: "ExpertCell")
        tableView.register(ScheduledSessionCell.self, forCellReuseIdentifier: "ScheduledSessionCell")
        tableView.register(ChatThreadCell.self, forCellReuseIdentifier: "ChatThreadCell")
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            segmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateStackView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor, constant: -40),
            emptyStateStackView.leadingAnchor.constraint(greaterThanOrEqualTo: emptyStateView.leadingAnchor, constant: 40),
            emptyStateStackView.trailingAnchor.constraint(lessThanOrEqualTo: emptyStateView.trailingAnchor, constant: -40),
            
            emptyStateIconView.widthAnchor.constraint(equalToConstant: 64),
            emptyStateIconView.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        emptyStateButton.addTarget(self, action: #selector(emptyStateButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Load Data
    
    private func loadData() {
        allExperts = dataManager.getAllExperts()
        
        let currentUser = userDataManager.getCurrentUser()
        let userId = currentUser?.userId ?? "user_001"
        
        print("🔍 Loading data for user: \(userId)")
        
        // ✅ Get properly filtered data
        scheduledSessions = dataManager.getScheduledSessions(for: userId)
            .filter { $0.status == .scheduled } // Only confirmed scheduled sessions
        
        chatThreads = dataManager.getChatThreads(for: userId)
            .filter { thread in
                // ✅ Only show threads with actual messages and expert data
                guard !thread.messages.isEmpty,
                      thread.lastMessage != nil,
                      let _ = dataManager.getExpert(byId: thread.expertId) else {
                    return false
                }
                return true
            }
        
        print("📊 Filtered Data - Experts: \(allExperts.count), Sessions: \(scheduledSessions.count), Chats: \(chatThreads.count)")
        
        updateEmptyState()
        tableView.reloadData()
    }
    
    @objc private func segmentChanged() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        currentTab = Tab(rawValue: segmentedControl.selectedSegmentIndex) ?? .all
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        updateEmptyState()
        tableView.reloadData()
    }
    
    @objc private func emptyStateButtonTapped() {
        if currentTab == .scheduled {
            segmentedControl.selectedSegmentIndex = 0
            segmentChanged()
        }
    }
    
    // ✅ Professional Empty State Messages
    private func updateEmptyState() {
        let isEmpty: Bool
        let iconName: String
        let title: String
        let subtitle: String
        let showButton: Bool
        
        switch currentTab {
        case .all:
            isEmpty = allExperts.isEmpty
            iconName = "person.3.sequence"
            title = "No Experts Available"
            subtitle = "We're bringing together the best parenting experts for you.\nPlease check back soon!"
            showButton = false
            
        case .scheduled:
            isEmpty = scheduledSessions.isEmpty
            iconName = "calendar.badge.plus"
            title = "No Scheduled Sessions"
            subtitle = "You haven't scheduled any sessions yet.\nBrowse our expert directory to book your first consultation."
            showButton = true
            emptyStateButton.setTitle("Browse Experts", for: .normal)
            
        case .inbox:
            isEmpty = chatThreads.isEmpty
            iconName = "message.badge"
            title = "Inbox Empty"
            subtitle = "Your conversations with experts will appear here.\nSchedule a session to start chatting with an expert."
            showButton = false
        }
        
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        
        if isEmpty {
            let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
            emptyStateIconView.image = UIImage(systemName: iconName, withConfiguration: config)
            emptyStateLabel.text = title
            emptyStateSubLabel.text = subtitle
            emptyStateButton.isHidden = !showButton
        }
        
        print("📌 Tab: \(currentTab), Empty: \(isEmpty)")
    }
}

// MARK: - UITableView DataSource & Delegate

extension ExpertsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentTab {
        case .all:
            return allExperts.count
        case .scheduled:
            return scheduledSessions.count
        case .inbox:
            return chatThreads.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentTab {
        case .all:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpertCell", for: indexPath) as! ExpertCell
            let expert = allExperts[indexPath.row]
            cell.configure(with: expert)
            return cell
            
        case .scheduled:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduledSessionCell", for: indexPath) as! ScheduledSessionCell
            let session = scheduledSessions[indexPath.row]
            
            // ✅ Ensure expert data is available
            if let expert = dataManager.getExpert(byId: session.expertId) {
                cell.configure(with: session, expert: expert)
            } else {
                print("⚠️ Expert not found for session: \(session.id)")
            }
            return cell
            
        case .inbox:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatThreadCell", for: indexPath) as! ChatThreadCell
            let thread = chatThreads[indexPath.row]
            
            // ✅ Ensure expert data is available
            if let expert = dataManager.getExpert(byId: thread.expertId) {
                cell.configure(with: thread, expert: expert)
            } else {
                print("⚠️ Expert not found for thread: \(thread.id)")
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        switch currentTab {
        case .all:
            let expert = allExperts[indexPath.row]
            openExpertBio(expert: expert)
            
        case .scheduled:
            let session = scheduledSessions[indexPath.row]
            if let expert = dataManager.getExpert(byId: session.expertId) {
                openExpertChat(session: session, expert: expert)
            }
            
        case .inbox:
            let thread = chatThreads[indexPath.row]
            if let session = dataManager.getSession(byId: thread.sessionId),
               let expert = dataManager.getExpert(byId: thread.expertId) {
                openExpertChat(session: session, expert: expert)
                
                // Mark messages as read
                dataManager.markMessagesAsRead(sessionId: thread.sessionId)
            }
        }
    }
    
    private func openExpertBio(expert: Expert) {
        let bioVC = ExpertBioViewController()
        bioVC.expert = expert
        bioVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(bioVC, animated: true)
    }
    
    private func openExpertChat(session: ExpertSession, expert: Expert) {
        let chatVC = ExpertChatViewController()
        chatVC.session = session
        chatVC.expert = expert
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension ExpertsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if currentTab == .all {
            if searchText.isEmpty {
                allExperts = dataManager.getAllExperts()
            } else {
                allExperts = dataManager.searchExperts(query: searchText)
            }
            updateEmptyState()
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
