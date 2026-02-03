//
//  ExpertBioViewController.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-16
//

import UIKit

class ExpertBioViewController: UIViewController {
    
    // MARK: - Properties
    var expert: Expert!
    private let dataManager = ExpertsDataManager.shared
    private var reviews: [ExpertReview] = []
    private let maxVisibleReviews = 2
    
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
    
    private let profileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.15)
        view.layer.cornerRadius = 60
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let initialsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryPurple
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let reviewCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = ThemeManager.Colors.tertiaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let aboutSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "About the Expert"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = ThemeManager.Colors.primaryText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let certificationsSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Certifications:"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let certificationsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let reviewsHeaderContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let reviewsSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Parent Reviews"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See All", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let reviewsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let noReviewsLabel: UILabel = {
        let label = UILabel()
        label.text = "No reviews yet. Be the first to review!"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Schedule a Session", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.layer.cornerRadius = 28
        button.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        button.layer.shadowRadius = 16
        button.layer.shadowOpacity = 0.4
        button.layer.masksToBounds = false
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
        loadData()
        registerForThemeChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        // Reload reviews in case they were updated
        loadReviews()
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
        nameLabel.textColor = ThemeManager.Colors.primaryText
        titleLabel.textColor = ThemeManager.Colors.secondaryText
        ratingLabel.textColor = ThemeManager.Colors.primaryText
        reviewCountLabel.textColor = ThemeManager.Colors.tertiaryText
        aboutSectionLabel.textColor = ThemeManager.Colors.primaryText
        bioLabel.textColor = ThemeManager.Colors.primaryText
        certificationsSectionLabel.textColor = ThemeManager.Colors.primaryText
        reviewsSectionLabel.textColor = ThemeManager.Colors.primaryText
        seeAllButton.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        noReviewsLabel.textColor = ThemeManager.Colors.secondaryText
        scheduleButton.backgroundColor = ThemeManager.Colors.primaryPurple
    }
    
    // MARK: - Setup Navigation Bar
    
    private func setupNavigationBar() {
        title = "Expert Profile"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        backButton.tintColor = ThemeManager.Colors.primaryPurple
        navigationItem.leftBarButtonItem = backButton
        
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareTapped))
        shareButton.tintColor = ThemeManager.Colors.primaryPurple
        navigationItem.rightBarButtonItem = shareButton
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func shareTapped() {
        let shareText = "Check out \(expert.name) - \(expert.title) on ParentBud"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(activityVC, animated: true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileImageView)
        profileImageView.addSubview(initialsLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingContainer)
        ratingContainer.addSubview(ratingLabel)
        ratingContainer.addSubview(starsStackView)
        ratingContainer.addSubview(reviewCountLabel)
        
        contentView.addSubview(aboutSectionLabel)
        contentView.addSubview(bioLabel)
        contentView.addSubview(certificationsSectionLabel)
        contentView.addSubview(certificationsStack)
        
        contentView.addSubview(reviewsHeaderContainer)
        reviewsHeaderContainer.addSubview(reviewsSectionLabel)
        reviewsHeaderContainer.addSubview(seeAllButton)
        
        contentView.addSubview(reviewsStack)
        contentView.addSubview(noReviewsLabel)
        
        view.addSubview(scheduleButton)
        
        // Create star images
        for _ in 0..<5 {
            let starImageView = UIImageView()
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
            starImageView.image = UIImage(systemName: "star.fill", withConfiguration: config)
            starImageView.tintColor = .systemYellow
            starImageView.contentMode = .scaleAspectFit
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
            starsStackView.addArrangedSubview(starImageView)
        }
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: scheduleButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            initialsLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            titleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            ratingContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            ratingContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            ratingLabel.leadingAnchor.constraint(equalTo: ratingContainer.leadingAnchor),
            ratingLabel.centerYAnchor.constraint(equalTo: ratingContainer.centerYAnchor),
            
            starsStackView.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 8),
            starsStackView.centerYAnchor.constraint(equalTo: ratingContainer.centerYAnchor),
            
            reviewCountLabel.leadingAnchor.constraint(equalTo: starsStackView.trailingAnchor, constant: 8),
            reviewCountLabel.centerYAnchor.constraint(equalTo: ratingContainer.centerYAnchor),
            reviewCountLabel.trailingAnchor.constraint(equalTo: ratingContainer.trailingAnchor),
            reviewCountLabel.topAnchor.constraint(equalTo: ratingContainer.topAnchor),
            reviewCountLabel.bottomAnchor.constraint(equalTo: ratingContainer.bottomAnchor),
            
            aboutSectionLabel.topAnchor.constraint(equalTo: ratingContainer.bottomAnchor, constant: 32),
            aboutSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            aboutSectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            bioLabel.topAnchor.constraint(equalTo: aboutSectionLabel.bottomAnchor, constant: 12),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            certificationsSectionLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 28),
            certificationsSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            certificationsSectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            certificationsStack.topAnchor.constraint(equalTo: certificationsSectionLabel.bottomAnchor, constant: 12),
            certificationsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            certificationsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            reviewsHeaderContainer.topAnchor.constraint(equalTo: certificationsStack.bottomAnchor, constant: 28),
            reviewsHeaderContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            reviewsHeaderContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            reviewsHeaderContainer.heightAnchor.constraint(equalToConstant: 32),
            
            reviewsSectionLabel.leadingAnchor.constraint(equalTo: reviewsHeaderContainer.leadingAnchor),
            reviewsSectionLabel.centerYAnchor.constraint(equalTo: reviewsHeaderContainer.centerYAnchor),
            
            seeAllButton.trailingAnchor.constraint(equalTo: reviewsHeaderContainer.trailingAnchor),
            seeAllButton.centerYAnchor.constraint(equalTo: reviewsHeaderContainer.centerYAnchor),
            seeAllButton.leadingAnchor.constraint(greaterThanOrEqualTo: reviewsSectionLabel.trailingAnchor, constant: 8),
            
            reviewsStack.topAnchor.constraint(equalTo: reviewsHeaderContainer.bottomAnchor, constant: 16),
            reviewsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            reviewsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            reviewsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            noReviewsLabel.topAnchor.constraint(equalTo: reviewsHeaderContainer.bottomAnchor, constant: 24),
            noReviewsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            noReviewsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            noReviewsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            scheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scheduleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            scheduleButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        seeAllButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
    }
    
    // MARK: - Load Data
    
    private func loadData() {
        initialsLabel.text = expert.initials
        nameLabel.text = expert.name
        titleLabel.text = expert.title
        ratingLabel.text = String(format: "%.1f", expert.rating)
        
        bioLabel.text = expert.bio
        
        // Update stars based on rating
        updateStars(rating: expert.rating)
        
        // Load certifications
        for certification in expert.certifications {
            let certView = createCertificationView(text: certification)
            certificationsStack.addArrangedSubview(certView)
        }
        
        // Load reviews
        loadReviews()
    }
    
    private func loadReviews() {
        reviews = dataManager.getReviews(for: expert.id)
        
        print("\n🔍 LOADING REVIEWS IN BIO")
        print("📊 Expert: \(expert.name)")
        print("📊 Reviews found: \(reviews.count)")
        
        // ✅ FIX: Update the expert's review count from actual reviews
        let actualReviewCount = reviews.count
        reviewCountLabel.text = "(\(actualReviewCount) reviews)"
        
        // Clear existing reviews
        reviewsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if reviews.isEmpty {
            print("⚠️ No reviews found, showing empty state")
            noReviewsLabel.isHidden = false
            reviewsStack.isHidden = true
            seeAllButton.isHidden = true
        } else {
            print("✅ Showing \(min(maxVisibleReviews, reviews.count)) of \(reviews.count) reviews")
            noReviewsLabel.isHidden = true
            reviewsStack.isHidden = false
            
            // ✅ FIX: Show "See All" button if there are more than maxVisibleReviews
            let shouldShowSeeAll = reviews.count > maxVisibleReviews
            seeAllButton.isHidden = !shouldShowSeeAll
            
            print("📌 See All button visibility: \(shouldShowSeeAll ? "VISIBLE ✓" : "HIDDEN ✗")")
            
            // Show limited reviews (only first maxVisibleReviews)
            let reviewsToShow = Array(reviews.prefix(maxVisibleReviews))
            
            for (index, review) in reviewsToShow.enumerated() {
                print("   Review \(index + 1): \(review.parentName) - \(review.rating) stars")
                let reviewView = createReviewView(review: review)
                reviewsStack.addArrangedSubview(reviewView)
            }
        }
        
        // Force layout update
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func updateStars(rating: Double) {
        let fullStars = Int(rating)
        let hasHalfStar = rating - Double(fullStars) >= 0.5
        
        for (index, view) in starsStackView.arrangedSubviews.enumerated() {
            guard let starImageView = view as? UIImageView else { continue }
            
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
            
            if index < fullStars {
                starImageView.image = UIImage(systemName: "star.fill", withConfiguration: config)
                starImageView.tintColor = .systemYellow
            } else if index == fullStars && hasHalfStar {
                starImageView.image = UIImage(systemName: "star.leadinghalf.filled", withConfiguration: config)
                starImageView.tintColor = .systemYellow
            } else {
                starImageView.image = UIImage(systemName: "star", withConfiguration: config)
                starImageView.tintColor = .systemYellow.withAlphaComponent(0.3)
            }
        }
    }
    
    private func createCertificationView(text: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let bulletLabel = UILabel()
        bulletLabel.text = "•"
        bulletLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        bulletLabel.textColor = ThemeManager.Colors.primaryPurple
        bulletLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textLabel.textColor = ThemeManager.Colors.primaryText
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(bulletLabel)
        container.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            bulletLabel.topAnchor.constraint(equalTo: container.topAnchor),
            bulletLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bulletLabel.widthAnchor.constraint(equalToConstant: 20),
            
            textLabel.topAnchor.constraint(equalTo: container.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: bulletLabel.trailingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func createReviewView(review: ExpertReview) -> UIView {
        let reviewView = ExpertReviewCardView()
        reviewView.configure(with: review, showHelpfulButton: true)
        return reviewView
    }
    
    // MARK: - Actions
    
    @objc private func scheduleButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let scheduleVC = ScheduleSessionViewController()
        scheduleVC.expert = expert
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc private func seeAllTapped() {
        print("🎯 See All button tapped - navigating to AllReviewsViewController")
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let allReviewsVC = AllReviewsViewController()
        allReviewsVC.expert = expert
        allReviewsVC.reviews = reviews
        navigationController?.pushViewController(allReviewsVC, animated: true)
    }
}
