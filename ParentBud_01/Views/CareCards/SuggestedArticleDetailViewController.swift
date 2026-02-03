//
//  SuggestedArticleDetailViewController.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-15
//

import UIKit
import SafariServices

class SuggestedArticleDetailViewController: UIViewController {
    
    // MARK: - Properties
    var article: SuggestedArticle!
    private let dataManager = CareCardsDataManager.shared
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var headerGradientLayer: CAGradientLayer?
    
    private let emojiContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 60
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var emojiGradientLayer: CAGradientLayer?
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 72)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let metadataContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let sourceButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separatorDot: UILabel = {
        let label = UILabel()
        label.text = "•"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = ThemeManager.Colors.tertiaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let readTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let summaryCard: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 24
        view.layer.shadowColor = ThemeManager.Colors.shadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 16
        view.layer.shadowOpacity = 0.08
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let summaryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Summary"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = ThemeManager.Colors.primaryText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Bookmark", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.1)
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let readMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Read Full Article", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.layer.cornerRadius = 24
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
        loadArticle()
        updateBookmarkButton()
        registerForThemeChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if headerGradientLayer == nil {
            setupHeaderGradient()
        }
        if emojiGradientLayer == nil {
            setupEmojiGradient()
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
        titleLabel.textColor = ThemeManager.Colors.primaryText
        sourceButton.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        readTimeLabel.textColor = ThemeManager.Colors.secondaryText
        separatorDot.textColor = ThemeManager.Colors.tertiaryText
        summaryCard.backgroundColor = ThemeManager.Colors.cardBackground
        summaryCard.layer.shadowColor = ThemeManager.Colors.shadowColor.cgColor
        summaryCard.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.08
        summaryTitleLabel.textColor = ThemeManager.Colors.primaryText
        summaryLabel.textColor = ThemeManager.Colors.primaryText
        bookmarkButton.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        bookmarkButton.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.1)
        readMoreButton.backgroundColor = ThemeManager.Colors.primaryPurple
        
        setupHeaderGradient()
        setupEmojiGradient()
    }
    
    // MARK: - Setup Navigation Bar
    
    private func setupNavigationBar() {
        title = "Article"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        backButton.tintColor = ThemeManager.Colors.primaryPurple
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup Gradients
    
    private func setupHeaderGradient() {
        headerGradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.frame = headerContainer.bounds
        
        if article.gradientColors.count >= 2 {
            let startColor = hexToUIColor(article.gradientColors[0])
            let endColor = hexToUIColor(article.gradientColors[1])
            gradient.colors = [startColor.withAlphaComponent(0.15).cgColor, endColor.withAlphaComponent(0.1).cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
        }
        
        headerContainer.layer.insertSublayer(gradient, at: 0)
        headerGradientLayer = gradient
    }
    
    private func setupEmojiGradient() {
        emojiGradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.frame = emojiContainer.bounds
        gradient.cornerRadius = 60
        
        if article.gradientColors.count >= 2 {
            let startColor = hexToUIColor(article.gradientColors[0])
            let endColor = hexToUIColor(article.gradientColors[1])
            gradient.colors = [startColor.cgColor, endColor.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
        }
        
        emojiContainer.layer.insertSublayer(gradient, at: 0)
        emojiGradientLayer = gradient
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerContainer)
        headerContainer.addSubview(emojiContainer)
        emojiContainer.addSubview(emojiLabel)
        headerContainer.addSubview(titleLabel)
        
        contentView.addSubview(metadataContainer)
        metadataContainer.addSubview(sourceButton)
        metadataContainer.addSubview(separatorDot)
        metadataContainer.addSubview(readTimeLabel)
        
        contentView.addSubview(summaryCard)
        summaryCard.addSubview(summaryTitleLabel)
        summaryCard.addSubview(summaryLabel)
        
        actionButtonsStack.addArrangedSubview(bookmarkButton)
        actionButtonsStack.addArrangedSubview(readMoreButton)
        view.addSubview(actionButtonsStack)
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: actionButtonsStack.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            emojiContainer.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 32),
            emojiContainer.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            emojiContainer.widthAnchor.constraint(equalToConstant: 120),
            emojiContainer.heightAnchor.constraint(equalToConstant: 120),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: emojiContainer.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -24),
            titleLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -32),
            
            metadataContainer.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 20),
            metadataContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            sourceButton.topAnchor.constraint(equalTo: metadataContainer.topAnchor),
            sourceButton.leadingAnchor.constraint(equalTo: metadataContainer.leadingAnchor),
            sourceButton.bottomAnchor.constraint(equalTo: metadataContainer.bottomAnchor),
            
            separatorDot.centerYAnchor.constraint(equalTo: sourceButton.centerYAnchor),
            separatorDot.leadingAnchor.constraint(equalTo: sourceButton.trailingAnchor, constant: 8),
            
            readTimeLabel.centerYAnchor.constraint(equalTo: sourceButton.centerYAnchor),
            readTimeLabel.leadingAnchor.constraint(equalTo: separatorDot.trailingAnchor, constant: 8),
            readTimeLabel.trailingAnchor.constraint(equalTo: metadataContainer.trailingAnchor),
            
            summaryCard.topAnchor.constraint(equalTo: metadataContainer.bottomAnchor, constant: 24),
            summaryCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summaryCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            summaryCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            summaryTitleLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 24),
            summaryTitleLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 24),
            summaryTitleLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -24),
            
            summaryLabel.topAnchor.constraint(equalTo: summaryTitleLabel.bottomAnchor, constant: 16),
            summaryLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 24),
            summaryLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -24),
            summaryLabel.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -24),
            
            actionButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButtonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            actionButtonsStack.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        sourceButton.addTarget(self, action: #selector(sourceTapped), for: .touchUpInside)
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        readMoreButton.addTarget(self, action: #selector(readMoreTapped), for: .touchUpInside)
    }
    
    // MARK: - Load Article
    
    private func loadArticle() {
        emojiLabel.text = article.emoji
        titleLabel.text = article.title
        summaryLabel.text = article.summary
        sourceButton.setTitle(article.sourceName, for: .normal)
        readTimeLabel.text = "\(article.readingTimeMinutes) min read"
    }
    
    // MARK: - Actions
    
    @objc private func sourceTapped() {
        openURL()
    }
    
    @objc private func bookmarkTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        print("\n🔖 Bookmark button tapped for article: \(article.title)")
        print("📋 Article ID: \(article.id)")
        
        if dataManager.isArticleSaved(article.id) {
            print("➖ Removing from bookmarks...")
            dataManager.unsaveArticle(article.id)
            bookmarkButton.setTitle("Bookmark", for: .normal)
            showToast(message: "Removed from bookmarks")
        } else {
            print("➕ Adding to bookmarks...")
            dataManager.saveArticle(article.id)
            bookmarkButton.setTitle("Bookmarked ✓", for: .normal)
            showToast(message: "Added to bookmarks")
        }
        
        // Verify it was saved
        let isSaved = dataManager.isArticleSaved(article.id)
        print("✅ Verification: Article is \(isSaved ? "SAVED" : "NOT SAVED")")
        print("📊 Total saved articles: \(dataManager.getSavedArticlesCount())")
    }
    
    @objc private func readMoreTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        openURL()
    }
    
    private func openURL() {
        guard let url = URL(string: article.sourceURL) else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = ThemeManager.Colors.primaryPurple
        present(safariVC, animated: true)
    }
    
    private func updateBookmarkButton() {
        if dataManager.isArticleSaved(article.id) {
            bookmarkButton.setTitle("Bookmarked ✓", for: .normal)
        } else {
            bookmarkButton.setTitle("Bookmark", for: .normal)
        }
    }
    
    private func showToast(message: String) {
        let toast = UILabel()
        toast.backgroundColor = UIColor.label.withAlphaComponent(0.9)
        toast.textColor = ThemeManager.Colors.background
        toast.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        toast.textAlignment = .center
        toast.text = message
        toast.alpha = 0
        toast.layer.cornerRadius = 12
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toast)
        
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: actionButtonsStack.topAnchor, constant: -16),
            toast.widthAnchor.constraint(lessThanOrEqualToConstant: 220),
            toast.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.8, animations: {
                toast.alpha = 0
            }) { _ in
                toast.removeFromSuperview()
            }
        }
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
