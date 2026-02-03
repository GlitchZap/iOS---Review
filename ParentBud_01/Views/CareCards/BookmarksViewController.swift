//
//  BookmarksViewController.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-16
//

import UIKit

class BookmarksViewController: UIViewController {
    
    // MARK: - Properties
    private let dataManager = CareCardsDataManager.shared
    
    private var savedCards: [CareCard] = []
    private var savedArticles: [SuggestedArticle] = []
    
    private enum SegmentType: Int {
        case cards = 0
        case articles = 1
    }
    
    private var currentSegment: SegmentType = .cards
    
    // MARK: - UI Components
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Care Cards", "Articles"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = ThemeManager.Colors.primaryPurple
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ], for: .selected)
        control.setTitleTextAttributes([
            .foregroundColor: ThemeManager.Colors.primaryPurple,
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ], for: .normal)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // ✅ CHANGED: Use single table view for both cards and articles
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = ThemeManager.Colors.background
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "📌\n\nNo bookmarks yet!\nStart saving your favorite content."
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = ThemeManager.Colors.primaryPurple
        return control
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupActions()
        loadBookmarks()
        registerForThemeChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        print("\n🔄 BookmarksViewController appearing - reloading bookmarks...")
        loadBookmarks()
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
        emptyStateLabel.textColor = ThemeManager.Colors.secondaryText
        
        tableView.reloadData()
    }
    
    // MARK: - Setup Navigation Bar
    
    private func setupNavigationBar() {
        title = "Bookmarks"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        backButton.tintColor = ThemeManager.Colors.primaryPurple
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // ✅ Register both cell types
        tableView.register(BookmarkedCareCardCell.self, forCellReuseIdentifier: "BookmarkedCareCardCell")
        tableView.register(SuggestedArticleCell.self, forCellReuseIdentifier: "SuggestedArticleCell")
        
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: emptyStateView.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: emptyStateView.trailingAnchor, constant: -40)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    @objc private func segmentChanged() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        currentSegment = SegmentType(rawValue: segmentedControl.selectedSegmentIndex) ?? .cards
        updateViewForSegment()
    }
    
    @objc private func handleRefresh() {
        loadBookmarks()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Load Bookmarks
    
    private func loadBookmarks() {
        print("\n📊 Loading bookmarks...")
        
        savedCards = dataManager.getSavedCards()
        savedArticles = dataManager.getSavedArticles()
        
        print("✅ Loaded \(savedCards.count) cards and \(savedArticles.count) articles")
        
        if savedCards.isEmpty && savedArticles.isEmpty {
            print("⚠️ No bookmarks found")
        } else {
            print("📌 Cards: \(savedCards.map { $0.title })")
            print("📰 Articles: \(savedArticles.map { $0.title })")
        }
        
        updateViewForSegment()
    }
    
    private func updateViewForSegment() {
        print("\n🎯 Updating view for segment: \(currentSegment == .cards ? "Cards" : "Articles")")
        
        switch currentSegment {
        case .cards:
            emptyStateView.isHidden = !savedCards.isEmpty
            emptyStateLabel.text = "📌\n\nNo bookmarked cards yet!\nSave your favorite Care Cards here."
            tableView.isHidden = savedCards.isEmpty
            print("📱 Showing \(savedCards.count) cards in table view")
            
        case .articles:
            emptyStateView.isHidden = !savedArticles.isEmpty
            emptyStateLabel.text = "📌\n\nNo bookmarked articles yet!\nSave interesting articles to read later."
            tableView.isHidden = savedArticles.isEmpty
            print("📱 Showing \(savedArticles.count) articles in table view")
        }
        
        tableView.reloadData()
    }
}

// MARK: - UITableView DataSource & Delegate

extension BookmarksViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSegment == .cards ? savedCards.count : savedArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentSegment == .cards {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkedCareCardCell", for: indexPath) as! BookmarkedCareCardCell
            let card = savedCards[indexPath.row]
            cell.configure(with: card)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestedArticleCell", for: indexPath) as! SuggestedArticleCell
            let article = savedArticles[indexPath.row]
            cell.configure(with: article)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if currentSegment == .cards {
            let card = savedCards[indexPath.row]
            openCardDetail(for: card)
        } else {
            let article = savedArticles[indexPath.row]
            openArticleDetail(for: article)
        }
    }
    
    private func openCardDetail(for card: CareCard) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let detailVC = CareCardDetailViewController()
        detailVC.careCard = card
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func openArticleDetail(for article: SuggestedArticle) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let detailVC = SuggestedArticleDetailViewController()
        detailVC.article = article
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - ✅ NEW: Bookmarked Care Card Cell (Same Style as Article Cell)

class BookmarkedCareCardCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.06
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 28
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var iconGradientLayer: CAGradientLayer?
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let metaStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorDot: UILabel = {
        let label = UILabel()
        label.text = "•"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = ThemeManager.Colors.tertiaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let readTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = ThemeManager.Colors.primaryPurple
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        imageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        imageView.tintColor = ThemeManager.Colors.primaryPurple
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconGradientLayer?.frame = iconContainer.bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateForTheme()
        }
    }
    
    private func updateForTheme() {
        if traitCollection.userInterfaceStyle == .dark {
            containerView.backgroundColor = ThemeManager.Colors.cardBackground
            containerView.layer.shadowOpacity = 0.3
        } else {
            containerView.backgroundColor = .white
            containerView.layer.shadowOpacity = 0.06
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        containerView.addSubview(contentStack)
        containerView.addSubview(chevronImageView)
        
        contentStack.addArrangedSubview(titleLabel)
        
        metaStack.addArrangedSubview(categoryLabel)
        metaStack.addArrangedSubview(separatorDot)
        metaStack.addArrangedSubview(readTimeLabel)
        contentStack.addArrangedSubview(metaStack)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 56),
            iconContainer.heightAnchor.constraint(equalToConstant: 56),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            contentStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            contentStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -18),
            
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with card: CareCard) {
        if let image = UIImage(named: card.imageName) {
            iconImageView.image = image
        } else {
            iconImageView.image = UIImage(systemName: "heart.fill")
        }
        titleLabel.text = card.title
        categoryLabel.text = card.category.rawValue
        readTimeLabel.text = "\(card.readingTimeMinutes) min"
        
        if card.gradientColors.count >= 2 {
            iconGradientLayer?.removeFromSuperlayer()
            let gradient = CAGradientLayer()
            gradient.frame = iconContainer.bounds
            gradient.cornerRadius = 28
            let startColor = hexToUIColor(card.gradientColors[0])
            let endColor = hexToUIColor(card.gradientColors[1])
            gradient.colors = [startColor.cgColor, endColor.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            iconContainer.layer.insertSublayer(gradient, at: 0)
            iconGradientLayer = gradient
        }
        
        updateForTheme()
    }
    
    private func hexToUIColor(_ hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.remove(at: cString.startIndex) }
        
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
