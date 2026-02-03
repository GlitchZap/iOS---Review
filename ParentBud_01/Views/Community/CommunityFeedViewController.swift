//
//  CommunityFeedViewController.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-16
//

import UIKit

enum FeedFilter: Int {
    case recent = 0
    case yourPosts = 1
    case saved = 2
}

class CommunityFeedViewController: UIViewController {

    private let dataManager = CommunityDataManager.shared
    private var currentCommunity: Community?
    private var currentFilter: FeedFilter = .recent
    private var posts: [CommunityPost] = []

    // MARK: - UI Components

    private let segmentedControl: UISegmentedControl = {
        let items = ["Recent", "Your Posts", "Saved"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .normal)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 100, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CommunityPostCell.self, forCellReuseIdentifier: "CommunityPostCell")
        return tableView
    }()

    private let postButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)
        button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.layer.cornerRadius = 30
        button.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 16
        button.layer.shadowOpacity = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .light)
        imageView.image = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: config)
        imageView.tintColor = ThemeManager.Colors.secondaryText.withAlphaComponent(0.5)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emptyStateSubtitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = ThemeManager.Colors.tertiaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let refreshControl: UIRefreshControl = {
        UIRefreshControl()
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadPosts()
        updateNavigationTitle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        loadPosts()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTheme()
        }
    }

    // MARK: - Public Methods

    func setCommunity(_ community: Community?) {
        currentCommunity = community
        updateNavigationTitle()
        loadPosts()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background

        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(postButton)
        view.addSubview(emptyStateView)

        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateSubtitle)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl

        updateSegmentedControlStyle()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36),

            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            postButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            postButton.widthAnchor.constraint(equalToConstant: 60),
            postButton.heightAnchor.constraint(equalToConstant: 60),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 90),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 90),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 24),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),

            emptyStateSubtitle.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            emptyStateSubtitle.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateSubtitle.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateSubtitle.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }

    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        let globeButton = UIBarButtonItem(
            image: UIImage(systemName: "globe"),
            style: .plain,
            target: self,
            action: #selector(globeButtonTapped)
        )
        globeButton.tintColor = ThemeManager.Colors.primaryPurple
        navigationItem.rightBarButtonItem = globeButton
    }

    private func updateNavigationTitle() {
        title = currentCommunity?.name ?? "Community"
    }

    private func updateSegmentedControlStyle() {
        let isDark = traitCollection.userInterfaceStyle == .dark

        segmentedControl.selectedSegmentTintColor = ThemeManager.Colors.primaryPurple
        segmentedControl.backgroundColor = isDark ? ThemeManager.Colors.cardBackground : UIColor.systemGray6

        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)

        segmentedControl.setTitleTextAttributes([
            .foregroundColor: ThemeManager.Colors.secondaryText,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
    }

    private func updateTheme() {
        view.backgroundColor = ThemeManager.Colors.background
        emptyStateLabel.textColor = ThemeManager.Colors.secondaryText
        emptyStateSubtitle.textColor = ThemeManager.Colors.tertiaryText
        emptyStateImageView.tintColor = ThemeManager.Colors.secondaryText.withAlphaComponent(0.5)
        postButton.backgroundColor = ThemeManager.Colors.primaryPurple
        postButton.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        updateSegmentedControlStyle()
        tableView.reloadData()
    }

    private func loadPosts() {
        switch currentFilter {
        case .recent:
            posts = currentCommunity != nil
                ? dataManager.getPosts(for: currentCommunity!.id)
                : dataManager.getAllPosts()
        case .yourPosts:
            let username = UserDataManager.shared.getCurrentUser()?.name ?? "Unknown"
            posts = dataManager.getUserPosts(username: username)
        case .saved:
            posts = dataManager.getSavedPosts()
        }

        updateEmptyState()
        tableView.reloadData()
    }

    private func updateEmptyState() {
        let isEmpty = posts.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty

        switch currentFilter {
        case .recent:
            emptyStateLabel.text = "No Posts Yet"
            emptyStateSubtitle.text = "Be the first to share something!\nTap the + button to create a post"
            emptyStateImageView.image = UIImage(systemName: "bubble.left.and.bubble.right")
        case .yourPosts:
            emptyStateLabel.text = "You Haven't Posted Yet"
            emptyStateSubtitle.text = "Share your parenting journey with the community"
            emptyStateImageView.image = UIImage(systemName: "square.and.pencil")
        case .saved:
            emptyStateLabel.text = "No Saved Posts"
            emptyStateSubtitle.text = "Bookmark posts you want to revisit later"
            emptyStateImageView.image = UIImage(systemName: "bookmark")
        }
    }

    // MARK: - Actions

    @objc private func segmentChanged() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        currentFilter = FeedFilter(rawValue: segmentedControl.selectedSegmentIndex) ?? .recent
        loadPosts()
    }

    @objc private func postButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        UIView.animate(withDuration: 0.1) {
            self.postButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.postButton.transform = .identity
            }
        }

        let createPostVC = CreatePostViewController()
        createPostVC.currentCommunity = currentCommunity
        createPostVC.onPostCreated = { [weak self] in
            self?.loadPosts()
        }

        let navController = UINavigationController(rootViewController: createPostVC)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        present(navController, animated: true)
    }

    @objc private func globeButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        let explorerVC = CommunityExplorerViewController()
        explorerVC.onCommunitySelected = { [weak self] community in
            self?.setCommunity(community)
        }
        navigationController?.pushViewController(explorerVC, animated: true)
    }

    @objc private func refreshPosts() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadPosts()
            self?.refreshControl.endRefreshing()
        }
    }
}

// MARK: - UITableViewDelegate & DataSource

extension CommunityFeedViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityPostCell", for: indexPath) as! CommunityPostCell
        let post = posts[indexPath.row]

        cell.configure(with: post, showCommunityName: currentCommunity == nil)
        cell.onLike = { [weak self] in self?.handleLike(postId: post.id) }
        cell.onSave = { [weak self] in self?.handleSave(postId: post.id) }
        cell.onJoinCommunity = { [weak self] in self?.handleJoinCommunity(communityId: post.communityId) }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func handleLike(postId: UUID) {
        dataManager.toggleLike(postId: postId)
        loadPosts()
    }

    private func handleSave(postId: UUID) {
        dataManager.toggleSave(postId: postId)
        loadPosts()
    }

    private func handleJoinCommunity(communityId: UUID) {
        dataManager.joinCommunity(communityId)
        loadPosts()
    }
}
