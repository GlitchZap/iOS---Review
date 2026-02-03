//
//  CareCardDetailViewController.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-15
//

import UIKit

class CareCardDetailViewController: UIViewController {
    
    // MARK: - Properties
    var careCard: CareCard!
    private let dataManager = CareCardsDataManager.shared
    
    private var currentCardIndex = 0
    private var currentCardView: UIView?
    private var cardStartCenter: CGPoint = .zero
    
    // MARK: - UI Components
    
    private let mainContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Card background container for the image - SMALLER SIZE
    private let imageCardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = ThemeManager.Colors.shadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 16
        view.layer.shadowOpacity = 0.12
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Card image with background card
    private let cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share", for: .normal)
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
        loadCard()
        displayCurrentCard()
        updateBookmarkButton()
        registerForThemeChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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
        bookmarkButton.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        bookmarkButton.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.1)
        shareButton.backgroundColor = ThemeManager.Colors.primaryPurple
        
        // Update card background
        imageCardContainer.backgroundColor = ThemeManager.Colors.cardBackground
        if traitCollection.userInterfaceStyle == .dark {
            imageCardContainer.layer.shadowOpacity = 0.3
        } else {
            imageCardContainer.layer.shadowOpacity = 0.12
        }
        
        displayCurrentCard()
    }
    
    // MARK: - Setup Navigation Bar
    
    private func setupNavigationBar() {
        title = careCard?.title ?? "Care Card"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        backButton.tintColor = ThemeManager.Colors.primaryPurple
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(mainContentView)
        
        // Add the card container with the image
        mainContentView.addSubview(imageCardContainer)
        imageCardContainer.addSubview(cardImageView)
        
        mainContentView.addSubview(cardContainerView)
        
        actionButtonsStack.addArrangedSubview(bookmarkButton)
        actionButtonsStack.addArrangedSubview(shareButton)
        view.addSubview(actionButtonsStack)
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Main content view fills the available space
            mainContentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainContentView.bottomAnchor.constraint(equalTo: actionButtonsStack.topAnchor, constant: -16),
            
            // Image card container at the top - smaller size
            imageCardContainer.topAnchor.constraint(equalTo: mainContentView.topAnchor, constant: 20),
            imageCardContainer.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 30),
            imageCardContainer.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor, constant: -30),
            imageCardContainer.heightAnchor.constraint(equalToConstant: 200),
            
            // Image inside the card container
            cardImageView.topAnchor.constraint(equalTo: imageCardContainer.topAnchor, constant: 15),
            cardImageView.leadingAnchor.constraint(equalTo: imageCardContainer.leadingAnchor, constant: 15),
            cardImageView.trailingAnchor.constraint(equalTo: imageCardContainer.trailingAnchor, constant: -15),
            cardImageView.bottomAnchor.constraint(equalTo: imageCardContainer.bottomAnchor, constant: -15),
            
            // Content card fills remaining space (no bottom hint label anymore)
            cardContainerView.topAnchor.constraint(equalTo: imageCardContainer.bottomAnchor, constant: 24),
            cardContainerView.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 20),
            cardContainerView.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor, constant: -20),
            cardContainerView.bottomAnchor.constraint(equalTo: mainContentView.bottomAnchor, constant: -20),
            
            // Action buttons at the bottom
            actionButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButtonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            actionButtonsStack.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
    }
    
    // MARK: - Load Card
    
    private func loadCard() {
        title = careCard.title
        
        if let image = UIImage(named: careCard.imageName) {
            cardImageView.image = image
        } else {
            cardImageView.image = UIImage(systemName: "heart.fill")
        }
    }
    
    // MARK: - Display Current Card
    
    private func displayCurrentCard() {
        currentCardView?.removeFromSuperview()
        
        guard currentCardIndex < careCard.contentCards.count else { return }
        
        let contentCard = careCard.contentCards.sorted { $0.order < $1.order }[currentCardIndex]
        let card = createStackedCard(text: contentCard.text, cardIndex: currentCardIndex, totalCards: careCard.contentCards.count)
        
        cardContainerView.addSubview(card)
        currentCardView = card
        
        // Make the card fill the entire container
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            card.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor)
        ])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        card.addGestureRecognizer(panGesture)
        
        animateCardEntrance()
    }
    
    // MARK: - Create Stacked Card with Updated Chevron Positions
    
    private func createStackedCard(text: String, cardIndex: Int, totalCards: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = ThemeManager.Colors.cardBackground
        card.layer.cornerRadius = 28
        card.layer.shadowColor = ThemeManager.Colors.shadowColor.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 10)
        card.layer.shadowRadius = 24
        card.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.12
        card.clipsToBounds = false
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Main content label - centered in the card
        let contentLabel = UILabel()
        contentLabel.text = text
        contentLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        contentLabel.textColor = ThemeManager.Colors.primaryText
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .center
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Set optimal line height for better readability
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .medium),
                .foregroundColor: ThemeManager.Colors.primaryText,
                .paragraphStyle: paragraphStyle
            ]
        )
        contentLabel.attributedText = attributedString
        
        // Progress badge - positioned at bottom with proper spacing
        let badgeContainer = UIView()
        badgeContainer.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.12)
        badgeContainer.layer.cornerRadius = 14
        badgeContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let badgeLabel = UILabel()
        badgeLabel.text = "\(cardIndex + 1)/\(totalCards)"
        badgeLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        badgeLabel.textColor = ThemeManager.Colors.primaryPurple
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        badgeContainer.addSubview(badgeLabel)
        
        // Updated chevron logic - ONLY CHEVRON POSITIONS CHANGED
        let isFirstCard = cardIndex == 0
        let isLastCard = cardIndex >= totalCards - 1
        let hasMultipleCards = totalCards > 1
        
        var leftChevron: UIImageView?
        var rightChevron: UIImageView?
        
        if hasMultipleCards {
            if isFirstCard {
                // First card: show RIGHT chevron (changed from left to right)
                rightChevron = UIImageView(image: UIImage(systemName: "chevron.right"))
                rightChevron?.tintColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.6)
                rightChevron?.translatesAutoresizingMaskIntoConstraints = false
            } else if isLastCard {
                // Last card: show LEFT chevron (changed from right to left)
                leftChevron = UIImageView(image: UIImage(systemName: "chevron.left"))
                leftChevron?.tintColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.6)
                leftChevron?.translatesAutoresizingMaskIntoConstraints = false
            } else {
                // Middle cards: show both chevrons (unchanged)
                leftChevron = UIImageView(image: UIImage(systemName: "chevron.left"))
                leftChevron?.tintColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.6)
                leftChevron?.translatesAutoresizingMaskIntoConstraints = false
                
                rightChevron = UIImageView(image: UIImage(systemName: "chevron.right"))
                rightChevron?.tintColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.6)
                rightChevron?.translatesAutoresizingMaskIntoConstraints = false
            }
        }
        
        // Add all components to card
        card.addSubview(contentLabel)
        card.addSubview(badgeContainer)
        
        if let leftChev = leftChevron {
            card.addSubview(leftChev)
        }
        if let rightChev = rightChevron {
            card.addSubview(rightChev)
        }
        
        // Setup constraints
        var constraints: [NSLayoutConstraint] = [
            // Badge positioned at bottom-center with proper margin
            badgeContainer.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            badgeContainer.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            badgeContainer.heightAnchor.constraint(equalToConstant: 28),
            
            badgeLabel.centerXAnchor.constraint(equalTo: badgeContainer.centerXAnchor),
            badgeLabel.centerYAnchor.constraint(equalTo: badgeContainer.centerYAnchor),
            badgeLabel.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor, constant: 12),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: -12),
            
            // Content label centered vertically in available space above badge
            contentLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: -14), // Slight offset to account for bottom badge
            contentLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 48), // More padding to avoid chevrons
            contentLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -48),
            
            // Ensure content doesn't overlap with badge
            contentLabel.topAnchor.constraint(greaterThanOrEqualTo: card.topAnchor, constant: 32),
            contentLabel.bottomAnchor.constraint(lessThanOrEqualTo: badgeContainer.topAnchor, constant: -24)
        ]
        
        // Add chevron constraints
        if let leftChev = leftChevron {
            constraints.append(contentsOf: [
                leftChev.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
                leftChev.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                leftChev.widthAnchor.constraint(equalToConstant: 16),
                leftChev.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        
        if let rightChev = rightChevron {
            constraints.append(contentsOf: [
                rightChev.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
                rightChev.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                rightChev.widthAnchor.constraint(equalToConstant: 16),
                rightChev.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
        
        return card
    }
    
    // MARK: - Pan Gesture (UNCHANGED - Original swipe behavior maintained)
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let card = gesture.view else { return }
        
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .began:
            cardStartCenter = card.center
            
        case .changed:
            card.center = CGPoint(x: cardStartCenter.x + translation.x, y: cardStartCenter.y)
            let rotation = translation.x / view.bounds.width * 0.15
            card.transform = CGAffineTransform(rotationAngle: rotation)
            let dragPercentage = abs(translation.x) / (view.bounds.width / 2)
            card.alpha = max(1.0 - dragPercentage * 0.3, 0.7)
            
        case .ended:
            let threshold: CGFloat = 80
            
            if translation.x < -threshold || velocity.x < -500 {
                // Swiping left (next card) - UNCHANGED
                if currentCardIndex < careCard.contentCards.count - 1 {
                    animateCardOffScreen(card: card, direction: .left) {
                        self.goToNextCard()
                    }
                } else {
                    // At last card, show feedback and bounce back
                    showLastCardFeedback()
                    bounceCardBack(card: card)
                }
            } else if translation.x > threshold || velocity.x > 500 {
                // Swiping right (previous card) - UNCHANGED
                if currentCardIndex > 0 {
                    animateCardOffScreen(card: card, direction: .right) {
                        self.goToPreviousCard()
                    }
                } else {
                    // At first card, show feedback and bounce back
                    showFirstCardFeedback()
                    bounceCardBack(card: card)
                }
            } else {
                // Not enough movement, bounce back
                bounceCardBack(card: card)
            }
            
        default:
            break
        }
    }
    
    private func bounceCardBack(card: UIView) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            card.center = self.cardStartCenter
            card.transform = .identity
            card.alpha = 1.0
        }
    }
    
    private func showLastCardFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        showToast(message: "You've reached the last card! ✓")
    }
    
    private func showFirstCardFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        showToast(message: "This is the first card!")
    }
    
    private func animateCardOffScreen(card: UIView, direction: Direction, completion: @escaping () -> Void) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let offScreenX: CGFloat = direction == .left ? -view.bounds.width : view.bounds.width
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            card.center = CGPoint(x: offScreenX, y: card.center.y)
            card.alpha = 0
            card.transform = CGAffineTransform(rotationAngle: direction == .left ? -0.2 : 0.2)
        }) { _ in
            completion()
        }
    }
    
    private func goToNextCard() {
        currentCardIndex += 1
        displayCurrentCard()
    }
    
    private func goToPreviousCard() {
        currentCardIndex -= 1
        displayCurrentCard()
    }
    
    private func animateCardEntrance() {
        currentCardView?.alpha = 0
        currentCardView?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.currentCardView?.alpha = 1
            self.currentCardView?.transform = .identity
        }
    }
    
    // MARK: - Actions
    
    @objc private func bookmarkTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        print("\n🔖 Bookmark button tapped for card: \(careCard.title)")
        print("📋 Card ID: \(careCard.id)")
        
        if dataManager.isCardSaved(careCard.id) {
            print("➖ Removing from bookmarks...")
            dataManager.unsaveCard(careCard.id)
            bookmarkButton.setTitle("Bookmark", for: .normal)
            showToast(message: "Removed from bookmarks")
        } else {
            print("➕ Adding to bookmarks...")
            dataManager.saveCard(careCard.id)
            bookmarkButton.setTitle("Bookmarked ✓", for: .normal)
            showToast(message: "Added to bookmarks")
        }
        
        // Verify it was saved
        let isSaved = dataManager.isCardSaved(careCard.id)
        print("✅ Verification: Card is \(isSaved ? "SAVED" : "NOT SAVED")")
        print("📊 Total saved cards: \(dataManager.getSavedCardsCount())")
    }
    
    @objc private func shareTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let textToShare = "\(careCard.title)\n\n\(careCard.summary)\n\nShared from ParentBud"
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = shareButton
        present(activityVC, animated: true)
    }
    
    private func updateBookmarkButton() {
        if dataManager.isCardSaved(careCard.id) {
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
            toast.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
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
    
    enum Direction {
        case left, right
    }
}
