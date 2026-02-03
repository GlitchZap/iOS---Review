//
//  StepByStepGuidanceViewController.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 2025-11-14
//

import UIKit

class StepByStepGuidanceViewController: UIViewController {
    
    // MARK: - Properties
    var logEntry: LogEntry!
    var struggleName: String = ""
    
    private var currentSteps: [StepDetail] = []
    private var currentCardIndex = 0
    private var currentApproach: String = "CBT+PCIT"
    
    private let activityFeedManager = ActivityFeedDataManager.shared
    private let purpleColor = ThemeManager.Colors.primaryPurple
    private let pinkColor = UIColor(red: 255/255, green: 105/255, blue: 180/255, alpha: 1.0)
    
    private var cardView: UIView?
    private var cardStartCenter: CGPoint = .zero
    private var hasNavigatedToCompletion = false
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = ThemeManager.Colors.progressTrack
        progress.progressTintColor = ThemeManager.Colors.primaryPurple
        progress.layer.cornerRadius = 6
        progress.clipsToBounds = true
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = ThemeManager.Colors.primaryPurple
        control.pageIndicatorTintColor = UIColor.systemGray4
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tryAnotherApproachButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Try Another Approach?", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 28
        button.layer.borderWidth = 2.5
        button.layer.borderColor = ThemeManager.Colors.primaryPurple.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        loadSteps()
        loadExistingProgress()
        setupConstraints()
        displayCurrentCard()
        updateProgress()
        animateEntrance()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTheme()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !hasNavigatedToCompletion {
            saveProgressToActivityFeed()
        }
    }
    
    private func updateTheme() {
        view.backgroundColor = ThemeManager.Colors.background
        progressBar.trackTintColor = ThemeManager.Colors.progressTrack
        progressBar.progressTintColor = ThemeManager.Colors.primaryPurple
        progressLabel.textColor = ThemeManager.Colors.secondaryText
        pageControl.currentPageIndicatorTintColor = ThemeManager.Colors.primaryPurple
        tryAnotherApproachButton.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        tryAnotherApproachButton.layer.borderColor = ThemeManager.Colors.primaryPurple.cgColor
    }
    
    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        let flowTitle: String
        
        // ✅ Use flowTitle from logEntry if available
        if let existingFlowTitle = logEntry.flowTitle, !existingFlowTitle.isEmpty {
            flowTitle = existingFlowTitle
        } else {
            // For custom user input, just capitalize properly
            let words = struggleName.split(separator: " ").map { $0.capitalized }
            flowTitle = words.joined(separator: " ")
        }
        
        title = flowTitle
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        print("✅ Navigation title set to: \(flowTitle)")
    }
    
    private func loadSteps() {
        let struggle = logEntry.tags.first ?? "General"
        currentSteps = GuidanceStepsRepository.shared.getSteps(for: struggle, approach: currentApproach)
        pageControl.numberOfPages = currentSteps.count
        pageControl.currentPage = 0
        print("✅ Loaded \(currentSteps.count) steps for \(struggle)")
    }
    
    private func loadExistingProgress() {
        if let existingLog = activityFeedManager.getLog(byId: logEntry.id) {
            print("✅ Found existing log, loading progress...")
            
            for (index, step) in existingLog.stepsTried.enumerated() {
                if index < currentSteps.count {
                    currentSteps[index].isCompleted = step.isCompleted
                }
            }
            
            logEntry = existingLog
        } else {
            print("✅ New log entry, starting fresh")
        }
    }
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(progressLabel)
        contentView.addSubview(progressBar)
        contentView.addSubview(pageControl)
        contentView.addSubview(cardContainerView)
        contentView.addSubview(tryAnotherApproachButton)
        
        tryAnotherApproachButton.addTarget(self, action: #selector(tryAnotherApproachTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
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
            
            progressLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            progressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            progressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            progressBar.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 12),
            progressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            progressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            progressBar.heightAnchor.constraint(equalToConstant: 12),
            
            pageControl.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Reduced card height to fit on screen without scrolling
            cardContainerView.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 24),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardContainerView.heightAnchor.constraint(equalToConstant: 320), // Reduced from 400 to 320
            
            tryAnotherApproachButton.topAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: 32),
            tryAnotherApproachButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tryAnotherApproachButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tryAnotherApproachButton.heightAnchor.constraint(equalToConstant: 56),
            tryAnotherApproachButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func displayCurrentCard() {
        cardView?.removeFromSuperview()
        
        guard currentCardIndex < currentSteps.count else {
            checkAndNavigateToCompletion()
            return
        }
        
        let step = currentSteps[currentCardIndex]
        let card = createPremiumCard(step: step)
        cardContainerView.addSubview(card)
        cardView = card
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            card.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor)
        ])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        card.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        card.addGestureRecognizer(tapGesture)
        
        pageControl.currentPage = currentCardIndex
    }
    
    private func createPremiumCard(step: StepDetail) -> UIView {
        let card = UIView()
        card.backgroundColor = ThemeManager.Colors.cardBackground
        card.layer.cornerRadius = 28
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 12)
        card.layer.shadowRadius = 24
        card.layer.shadowOpacity = 0.15
        card.clipsToBounds = false
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let stepBadge = createStepBadge(stepNumber: step.stepNumber, totalSteps: currentSteps.count)
        card.addSubview(stepBadge)
        
        let iconContainer = UIView()
        iconContainer.layer.cornerRadius = 35
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        if step.isCompleted {
            iconContainer.backgroundColor = purpleColor
            let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
            iconImageView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
            addPulseAnimation(to: iconContainer)
        } else {
            iconContainer.backgroundColor = pinkColor
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
            iconImageView.image = UIImage(systemName: "hand.tap.fill", withConfiguration: config)
        }
        
        iconContainer.addSubview(iconImageView)
        card.addSubview(iconContainer)
        
        let titleLabel = UILabel()
        titleLabel.text = step.title
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        titleLabel.textColor = ThemeManager.Colors.primaryText
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = step.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = ThemeManager.Colors.secondaryText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(titleLabel)
        card.addSubview(descriptionLabel)
        
        // Add subtle swipe indicator at the bottom
        let swipeIndicator = createSwipeIndicator()
        card.addSubview(swipeIndicator)
        
        NSLayoutConstraint.activate([
            stepBadge.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stepBadge.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            
            iconContainer.topAnchor.constraint(equalTo: stepBadge.bottomAnchor, constant: 24),
            iconContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            iconContainer.widthAnchor.constraint(equalToConstant: 70),
            iconContainer.heightAnchor.constraint(equalToConstant: 70),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            
            // Swipe indicator at bottom
            swipeIndicator.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
            swipeIndicator.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            swipeIndicator.heightAnchor.constraint(equalToConstant: 4),
            swipeIndicator.widthAnchor.constraint(equalToConstant: 40),
            
            // Ensure description doesn't overlap with swipe indicator
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: swipeIndicator.topAnchor, constant: -16)
        ])
        
        return card
    }
    
    private func createSwipeIndicator() -> UIView {
        let indicator = UIView()
        indicator.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.3)
        indicator.layer.cornerRadius = 2
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subtle animation to indicate swipeable
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.3
        fadeAnimation.toValue = 0.7
        fadeAnimation.duration = 1.5
        fadeAnimation.autoreverses = true
        fadeAnimation.repeatCount = .infinity
        indicator.layer.add(fadeAnimation, forKey: "swipeHint")
        
        return indicator
    }
    
    private func createStepBadge(stepNumber: Int, totalSteps: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = purpleColor.withAlphaComponent(0.15)
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "\(stepNumber) of \(totalSteps)"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = purpleColor
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            container.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        return container
    }
    
    private func addPulseAnimation(to view: UIView) {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.0
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.05
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        view.layer.add(pulseAnimation, forKey: "pulse")
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let card = gesture.view else { return }
        
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .began:
            cardStartCenter = card.center
            
        case .changed:
            card.center = CGPoint(x: cardStartCenter.x + translation.x, y: cardStartCenter.y)
            let rotation = translation.x / view.bounds.width * 0.4
            card.transform = CGAffineTransform(rotationAngle: rotation)
            let dragPercentage = abs(translation.x) / (view.bounds.width / 2)
            card.alpha = max(1.0 - dragPercentage * 0.5, 0.5)
            
        case .ended:
            let threshold: CGFloat = 80
            
            if translation.x < -threshold || velocity.x < -500 {
                // Swiping left - auto mark as done and go to next
                animateCardOffScreen(card: card, direction: .left) {
                    self.markCurrentStepAsDone()
                    self.goToNextCard()
                }
            } else if translation.x > threshold || velocity.x > 500 {
                animateCardOffScreen(card: card, direction: .right) {
                    self.goToPreviousCard()
                }
            } else {
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
                    card.center = self.cardStartCenter
                    card.transform = .identity
                    card.alpha = 1.0
                }
            }
            
        default:
            break
        }
    }
    
    // NEW: Auto-mark step as done when swiping
    private func markCurrentStepAsDone() {
        if currentCardIndex < currentSteps.count && !currentSteps[currentCardIndex].isCompleted {
            currentSteps[currentCardIndex].isCompleted = true
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            updateProgress()
            saveProgressToActivityFeed()
        }
    }
    
    private func animateCardOffScreen(card: UIView, direction: Direction, completion: @escaping () -> Void) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let offScreenX: CGFloat = direction == .left ? -view.bounds.width : view.bounds.width
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            card.center = CGPoint(x: offScreenX, y: card.center.y)
            card.alpha = 0
            card.transform = CGAffineTransform(rotationAngle: direction == .left ? -0.3 : 0.3)
        }) { _ in
            completion()
        }
    }
    
    private func goToNextCard() {
        guard currentCardIndex < currentSteps.count - 1 else {
            if currentSteps.allSatisfy({ $0.isCompleted }) {
                checkAndNavigateToCompletion()
            } else {
                displayCurrentCard()
            }
            return
        }
        
        currentCardIndex += 1
        displayCurrentCard()
        updateProgress()
    }
    
    private func goToPreviousCard() {
        guard currentCardIndex > 0 else {
            displayCurrentCard()
            return
        }
        
        currentCardIndex -= 1
        displayCurrentCard()
        updateProgress()
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        currentSteps[currentCardIndex].isCompleted.toggle()
        
        if currentSteps[currentCardIndex].isCompleted {
            celebrateCompletion()
        }
        
        displayCurrentCard()
        updateProgress()
        saveProgressToActivityFeed()
    }
    
    private func celebrateCompletion() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        guard let card = cardView else { return }
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8) {
            card.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
                card.transform = .identity
            }
        }
        
        addConfettiEffect()
    }
    
    private func addConfettiEffect() {
        let colors: [UIColor] = [purpleColor, pinkColor, .systemYellow, .systemGreen, .systemOrange]
        
        for _ in 0..<20 {
            let confetti = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
            confetti.backgroundColor = colors.randomElement()
            confetti.layer.cornerRadius = 4
            confetti.center = CGPoint(x: view.bounds.width / 2, y: cardContainerView.frame.midY)
            view.addSubview(confetti)
            
            let randomX = CGFloat.random(in: -200...200)
            let randomY = CGFloat.random(in: -200...200)
            
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
                confetti.center = CGPoint(x: confetti.center.x + randomX, y: confetti.center.y + randomY)
                confetti.alpha = 0
                confetti.transform = CGAffineTransform(rotationAngle: .pi * 2)
            }) { _ in
                confetti.removeFromSuperview()
            }
        }
    }
    
    private func updateProgress() {
        let completedCount = currentSteps.filter { $0.isCompleted }.count
        let totalCount = currentSteps.count
        let progress = Float(completedCount) / Float(totalCount)
        
        progressBar.setProgress(progress, animated: true)
        progressLabel.text = "\(completedCount) of \(totalCount) steps completed"
    }
    
    private func saveProgressToActivityFeed() {
        let completedCount = currentSteps.filter { $0.isCompleted }.count
        let totalCount = currentSteps.count
        
        var updatedLog = logEntry!
        updatedLog.totalSteps = totalCount
        updatedLog.completedSteps = completedCount
        
        // Preserve the existing flowTitle or generate from struggleName
        if updatedLog.flowTitle == nil || updatedLog.flowTitle?.isEmpty == true {
            let words = struggleName.split(separator: " ").map { $0.capitalized }
            updatedLog.flowTitle = words.joined(separator: " ")
        }
        
        updatedLog.updatedAt = Date()
        
        updatedLog.stepsTried = currentSteps.map { step in
            StepTried(
                stepDescription: step.title,
                isCompleted: step.isCompleted,
                completedAt: step.isCompleted ? Date() : nil
            )
        }
        
        if completedCount == totalCount {
            updatedLog.status = .ongoing
        } else if updatedLog.currentApproachIndex > 0 {
            updatedLog.status = .unresolved
        } else {
            updatedLog.status = .ongoing
        }
        
        activityFeedManager.saveActivityLog(updatedLog)
        logEntry = updatedLog
        
        print("✅ Saved progress to Activity Feed: \(completedCount)/\(totalCount)")
    }
    
    private func animateEntrance() {
        cardView?.alpha = 0
        cardView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.cardView?.alpha = 1
            self.cardView?.transform = .identity
        }
    }
    
    private func checkAndNavigateToCompletion() {
        if hasNavigatedToCompletion {
            print("⚠️ Already navigated to completion, skipping")
            return
        }
        
        if navigationController?.topViewController is CompletionScreenViewController {
            print("⚠️ Already on completion screen, skipping navigation")
            return
        }
        
        if currentSteps.allSatisfy({ $0.isCompleted }) {
            hasNavigatedToCompletion = true
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            let completionVC = CompletionScreenViewController()
            completionVC.logEntry = logEntry
            completionVC.struggleName = struggleName
            
            // Use existing flowTitle or generate from struggleName
            if let existingFlowTitle = logEntry.flowTitle, !existingFlowTitle.isEmpty {
                completionVC.flowTitle = existingFlowTitle
            } else {
                let words = struggleName.split(separator: " ").map { $0.capitalized }
                completionVC.flowTitle = words.joined(separator: " ")
            }
            
            completionVC.currentApproach = currentApproach
            
            navigationController?.pushViewController(completionVC, animated: true)
            print("✅ Navigated to completion screen")
        }
    }
    
    @objc private func tryAnotherApproachTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let alert = UIAlertController(
            title: "Switch Approach?",
            message: "This will show different strategies for the same struggle.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Switch", style: .default) { [weak self] _ in
            self?.switchApproach()
        })
        
        present(alert, animated: true)
    }
    
    private func switchApproach() {
        currentApproach = currentApproach == "CBT+PCIT" ? "Alternative" : "CBT+PCIT"
        currentCardIndex = 0
        
        var updatedLog = logEntry!
        updatedLog.currentApproachIndex += 1
        updatedLog.status = .unresolved
        activityFeedManager.saveActivityLog(updatedLog)
        logEntry = updatedLog
        
        loadSteps()
        displayCurrentCard()
        updateProgress()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        showToast(message: "Switched to \(currentApproach) Approach")
    }
    
    private func showToast(message: String) {
        let toast = UILabel()
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        toast.textColor = .white
        toast.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        toast.textAlignment = .center
        toast.text = message
        toast.alpha = 0
        toast.layer.cornerRadius = 14
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toast)
        
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: tryAnotherApproachButton.topAnchor, constant: -20),
            toast.widthAnchor.constraint(lessThanOrEqualToConstant: 280),
            toast.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, animations: {
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
