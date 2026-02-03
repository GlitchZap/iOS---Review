//
//  CareCardsViewController.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-15
//

import UIKit

class CareCardsViewController: UIViewController {
    
    // MARK: - Properties
    private let dataManager = CareCardsDataManager.shared
    private let userDataManager = UserDataManager.shared
    
    private var recommendedCards: [CareCard] = []
    private var suggestedArticles: [SuggestedArticle] = []
    
    // MARK: - UI Components
    
    private let scrollView:  UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = ThemeManager.Colors.background
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.background
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Recommended Section
    private let recommendedSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Recommended for you"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var recommendedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right:  20)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = ThemeManager.Colors.background
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RecommendedCardCell.self, forCellWithReuseIdentifier: "RecommendedCardCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isUserInteractionEnabled = true
        collectionView.delaysContentTouches = false
        
        return collectionView
    }()
    
    // Suggested Section
    private let suggestedSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Suggested for you"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trendingLabel: UILabel = {
        let label = UILabel()
        label.text = "Trending now"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: . plain)
        tableView.backgroundColor = ThemeManager.Colors.background
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var tableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK:  - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        loadData()
        registerForThemeChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // ✅ Refresh bookmark button
        updateBookmarkButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recommendedCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func registerForThemeChanges() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self:  Self, previousTraitCollection: UITraitCollection) in
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
        let backgroundColor:  UIColor = traitCollection.userInterfaceStyle == .dark ?
        ThemeManager.Colors.background :  . white
        
        view.backgroundColor = backgroundColor
        scrollView.backgroundColor = backgroundColor
        contentView.backgroundColor = ThemeManager.Colors.background
        recommendedCollectionView.backgroundColor = backgroundColor
        tableView.backgroundColor = backgroundColor
        
        recommendedSectionLabel.textColor = ThemeManager.Colors.primaryText
        suggestedSectionLabel.textColor = ThemeManager.Colors.primaryText
        trendingLabel.textColor = ThemeManager.Colors.secondaryText
        
        recommendedCollectionView.reloadData()
        tableView.reloadData()
    }
    
    // MARK: - Setup Navigation Bar
    
    private func setupNavigationBar() {
        title = "Care Cards"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .inline
        
        // ✅ Add Bookmark Button
        updateBookmarkButton()
        
        // Style the navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = ThemeManager.Colors.background
        appearance.titleTextAttributes = [
            . foregroundColor: ThemeManager.Colors.primaryText,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: ThemeManager.Colors.primaryText,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func updateBookmarkButton() {
        let count = dataManager.getTotalSavedCount()
        
        let bookmarkButton = UIBarButtonItem(
            image: UIImage(systemName: count > 0 ? "bookmark.fill" : "bookmark"),
            style: .plain,
            target: self,
            action: #selector(bookmarkButtonTapped)
        )
        bookmarkButton.tintColor = ThemeManager.Colors.primaryPurple
        navigationItem.rightBarButtonItem = bookmarkButton
    }
    
    @objc private func bookmarkButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let bookmarksVC = BookmarksViewController()
        bookmarksVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(bookmarksVC, animated: true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        let backgroundColor: UIColor = traitCollection.userInterfaceStyle == .dark ?
            ThemeManager.Colors.background :  .white
        
        view.backgroundColor = backgroundColor
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(recommendedSectionLabel)
        contentView.addSubview(recommendedCollectionView)
        contentView.addSubview(suggestedSectionLabel)
        contentView.addSubview(trendingLabel)
        contentView.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SuggestedArticleCell.self, forCellReuseIdentifier: "SuggestedArticleCell")
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            recommendedSectionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            recommendedSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  20),
            recommendedSectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            recommendedCollectionView.topAnchor.constraint(equalTo: recommendedSectionLabel.bottomAnchor, constant: 16),
            recommendedCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recommendedCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recommendedCollectionView.heightAnchor.constraint(equalToConstant: 300),
            
            suggestedSectionLabel.topAnchor.constraint(equalTo: recommendedCollectionView.bottomAnchor, constant: 32),
            suggestedSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  20),
            suggestedSectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            trendingLabel.topAnchor.constraint(equalTo: suggestedSectionLabel.bottomAnchor, constant: 4),
            trendingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            trendingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -20),
            
            tableView.topAnchor.constraint(equalTo: trendingLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tableViewHeightConstraint,
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Load Data
    
    private func loadData() {
        let currentUser = userDataManager.getCurrentUser()
        recommendedCards = dataManager.getRecommendedCards(for: currentUser)
        suggestedArticles = dataManager.getSuggestedArticles()
        
        recommendedCollectionView.reloadData()
        tableView.reloadData()
        
        DispatchQueue.main.async {
            self.updateTableHeight()
        }
    }
    
    private func updateTableHeight() {
        tableView.layoutIfNeeded()
        let height = tableView.contentSize.height
        tableViewHeightConstraint.constant = height
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension CareCardsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView:  UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:  IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedCardCell", for: indexPath) as! RecommendedCardCell
        let card = recommendedCards[indexPath.item]
        cell.configure(with: card)
        
        let tapGesture = UITapGestureRecognizer(target:  self, action: #selector(handleCardTap(_:)))
        cell.addGestureRecognizer(tapGesture)
        cell.tag = indexPath.item
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 220, height: 290)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = recommendedCards[indexPath.item]
        openCardDetail(for: card)
    }
    
    @objc private func handleCardTap(_ gesture: UITapGestureRecognizer) {
        guard let cell = gesture.view as?  RecommendedCardCell else { return }
        let index = cell.tag
        guard index < recommendedCards.count else { return }
        
        let card = recommendedCards[index]
        openCardDetail(for: card)
    }
    
    private func openCardDetail(for card: CareCard) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let detailVC = CareCardDetailViewController()
        detailVC.careCard = card
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UITableView DataSource & Delegate

extension CareCardsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestedArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestedArticleCell", for: indexPath) as! SuggestedArticleCell
        let article = suggestedArticles[indexPath.row]
        cell.configure(with: article)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView:  UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = suggestedArticles[indexPath.row]
        openArticleDetail(for: article)
    }
    
    private func openArticleDetail(for article: SuggestedArticle) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let detailVC = SuggestedArticleDetailViewController()
        detailVC.article = article
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Premium Recommended Card Cell - WITHOUT GRADIENT

class RecommendedCardCell: UICollectionViewCell {
    
    private let containerView:  UIView = {
        let view = UIView()
        view.backgroundColor = . white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.08
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = ThemeManager.Colors.secondaryText
        label.numberOfLines = 2
        label.textAlignment = . center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let readTimeBadge: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.1)
        view.layer.cornerRadius = 14
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let readTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = ThemeManager.Colors.primaryPurple
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
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
        if traitCollection.userInterfaceStyle == .dark {
            containerView.backgroundColor = ThemeManager.Colors.cardBackground
            containerView.layer.shadowOpacity = 0.3
        } else {
            containerView.backgroundColor = . white
            containerView.layer.shadowOpacity = 0.08
        }
    }
    
    private func setupUI() {
        backgroundColor = . clear
        contentView.backgroundColor = . clear
        
        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        
        contentView.addSubview(containerView)
        containerView.addSubview(imageContainer)
        imageContainer.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(summaryLabel)
        containerView.addSubview(readTimeBadge)
        readTimeBadge.addSubview(readTimeLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            imageContainer.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageContainer.heightAnchor.constraint(equalToConstant: 120),
            
            iconImageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            summaryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            summaryLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            readTimeBadge.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 16),
            readTimeBadge.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            readTimeBadge.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -20),
            
            readTimeLabel.topAnchor.constraint(equalTo: readTimeBadge.topAnchor, constant: 6),
            readTimeLabel.leadingAnchor.constraint(equalTo: readTimeBadge.leadingAnchor, constant: 12),
            readTimeLabel.trailingAnchor.constraint(equalTo: readTimeBadge.trailingAnchor, constant: -12),
            readTimeLabel.bottomAnchor.constraint(equalTo: readTimeBadge.bottomAnchor, constant: -6)
        ])
    }
    
    func configure(with card: CareCard) {
        if let image = UIImage(named: card.imageName) {
            iconImageView.image = image
        } else {
            iconImageView.image = UIImage(systemName:  "heart.fill")
        }
        
        titleLabel.text = card.title
        summaryLabel.text = card.summary
        readTimeLabel.text = "\(card.readingTimeMinutes) min"
        
        updateForTheme()
    }
}

// MARK: - Premium Suggested Article Cell

class SuggestedArticleCell: UITableViewCell {
    
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
    
    private let emojiContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 28
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var emojiGradientLayer: CAGradientLayer?
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    private let sourceLabel: UILabel = {
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
        imageView.image = UIImage(systemName:  "chevron.right", withConfiguration: config)
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
        emojiGradientLayer?.frame = emojiContainer.bounds
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
            containerView.backgroundColor = . white
            containerView.layer.shadowOpacity = 0.06
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(emojiContainer)
        emojiContainer.addSubview(emojiLabel)
        containerView.addSubview(contentStack)
        containerView.addSubview(chevronImageView)
        
        contentStack.addArrangedSubview(titleLabel)
        
        metaStack.addArrangedSubview(sourceLabel)
        metaStack.addArrangedSubview(separatorDot)
        metaStack.addArrangedSubview(readTimeLabel)
        contentStack.addArrangedSubview(metaStack)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            emojiContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            emojiContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            emojiContainer.widthAnchor.constraint(equalToConstant: 56),
            emojiContainer.heightAnchor.constraint(equalToConstant: 56),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor),
            
            contentStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            contentStack.leadingAnchor.constraint(equalTo: emojiContainer.trailingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -18),
            
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with article: SuggestedArticle) {
        emojiLabel.text = article.emoji
        titleLabel.text = article.title
        sourceLabel.text = article.sourceName
        readTimeLabel.text = "\(article.readingTimeMinutes) min"
        
        if article.gradientColors.count >= 2 {
            emojiGradientLayer?.removeFromSuperlayer()
            let gradient = CAGradientLayer()
            gradient.frame = emojiContainer.bounds
            gradient.cornerRadius = 28
            let startColor = hexToUIColor(article.gradientColors[0])
            let endColor = hexToUIColor(article.gradientColors[1])
            gradient.colors = [startColor.cgColor, endColor.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y:  1)
            emojiContainer.layer.insertSublayer(gradient, at: 0)
            emojiGradientLayer = gradient
        }
        
        updateForTheme()
    }
    
    private func hexToUIColor(_ hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.remove(at: cString.startIndex) }
        
        var rgbValue: UInt64 = 0
        Scanner(string:  cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
