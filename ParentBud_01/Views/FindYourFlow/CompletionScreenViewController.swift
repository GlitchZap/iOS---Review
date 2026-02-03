//
//  CompletionScreenViewController.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-14
//

import UIKit

class CompletionScreenViewController: UIViewController {
    
    // MARK: - Properties
    var logEntry: LogEntry!
    var struggleName: String = ""
    var flowTitle: String = ""
    var currentApproach: String = "CBT+PCIT"
    
    private let activityFeedManager = ActivityFeedDataManager.shared
    private let purpleColor = ThemeManager.Colors.primaryPurple
    private var selectedFeedback: String?
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let celebrationCard: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 16
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let sparkleIcon: UILabel = {
        let label = UILabel()
        label.text = "✨"
        label.font = UIFont.systemFont(ofSize: 48)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let greatWorkLabel: UILabel = {
        let label = UILabel()
        label.text = "Great Work!"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completionMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = ThemeManager.Colors.secondaryText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let techniquesLabel: UILabel = {
        let label = UILabel()
        label.text = "Techniques Used : CBT + PCIT"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = ThemeManager.Colors.tertiaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "info.circle", withConfiguration: config), for: .normal)
        button.tintColor = ThemeManager.Colors.tertiaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let feedbackTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "How did this approach work?"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let feedbackStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let markAsDoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✓ Mark as Done!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.layer.cornerRadius = 28
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false // Initially disabled
        return button
    }()
    
    private let tryAnotherApproachButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Try Another Approach?", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 28
        button.layer.borderWidth = 2
        button.layer.borderColor = ThemeManager.Colors.primaryPurple.cgColor
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
        createFeedbackOptions()
        updateCompletionMessage()
        updateButtonStates() // Set initial button states
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTheme()
        }
    }
    
    private func updateTheme() {
        view.backgroundColor = ThemeManager.Colors.background
        celebrationCard.backgroundColor = ThemeManager.Colors.cardBackground
        greatWorkLabel.textColor = ThemeManager.Colors.primaryText
        completionMessageLabel.textColor = ThemeManager.Colors.secondaryText
        techniquesLabel.textColor = ThemeManager.Colors.tertiaryText
        infoButton.tintColor = ThemeManager.Colors.tertiaryText
        feedbackTitleLabel.textColor = ThemeManager.Colors.primaryText
        markAsDoneButton.backgroundColor = ThemeManager.Colors.primaryPurple
        tryAnotherApproachButton.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        tryAnotherApproachButton.layer.borderColor = ThemeManager.Colors.primaryPurple.cgColor
    }
    
    private func setupNavigationBar() {
        title = "How did it Go?"
        navigationItem.hidesBackButton = false
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // FIXED: Custom back button that navigates to FindYourFlowViewController
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backToFindYourFlow))
        backButton.tintColor = ThemeManager.Colors.primaryPurple
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backToFindYourFlow() {
        // Navigate back to FindYourFlowViewController
        if let navController = navigationController {
            for viewController in navController.viewControllers.reversed() {
                if viewController is FindYourFlowViewController {
                    navController.popToViewController(viewController, animated: true)
                    return
                }
            }
            // Fallback if FindYourFlowViewController is not in the stack
            navController.popToRootViewController(animated: true)
        }
    }
    
    private func updateCompletionMessage() {
        let attributedText = NSMutableAttributedString(string: "You completed the ", attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: ThemeManager.Colors.secondaryText
        ])
        
        attributedText.append(NSAttributedString(string: flowTitle, attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: ThemeManager.Colors.primaryPurple
        ]))
        
        attributedText.append(NSAttributedString(string: " flow", attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: ThemeManager.Colors.secondaryText
        ]))
        
        completionMessageLabel.attributedText = attributedText
    }
    
    private func createFeedbackOptions() {
        let options: [(emoji: String, title: String)] = [
            ("😊", "Worked Well!"),
            ("😐", "Somewhat!"),
            ("😔", "Not Yet!")
        ]
        
        for option in options {
            let feedbackCard = createFeedbackCard(emoji: option.emoji, title: option.title)
            feedbackStack.addArrangedSubview(feedbackCard)
        }
    }
    
    private func createFeedbackCard(emoji: String, title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = ThemeManager.Colors.cardBackground
        container.layer.cornerRadius = 20
        container.layer.borderWidth = 2
        container.layer.borderColor = UIColor.clear.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 52)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = ThemeManager.Colors.primaryText
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(emojiLabel)
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            emojiLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            
            container.heightAnchor.constraint(equalToConstant: 140)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(feedbackTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        container.tag = feedbackStack.arrangedSubviews.count
        
        return container
    }
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        celebrationCard.addSubview(sparkleIcon)
        celebrationCard.addSubview(greatWorkLabel)
        celebrationCard.addSubview(completionMessageLabel)
        celebrationCard.addSubview(techniquesLabel)
        celebrationCard.addSubview(infoButton)
        
        contentView.addSubview(celebrationCard)
        contentView.addSubview(feedbackTitleLabel)
        contentView.addSubview(feedbackStack)
        contentView.addSubview(markAsDoneButton)
        contentView.addSubview(tryAnotherApproachButton)
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
            
            celebrationCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            celebrationCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            celebrationCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            sparkleIcon.topAnchor.constraint(equalTo: celebrationCard.topAnchor, constant: 28),
            sparkleIcon.leadingAnchor.constraint(equalTo: celebrationCard.leadingAnchor, constant: 24),
            
            greatWorkLabel.centerYAnchor.constraint(equalTo: sparkleIcon.centerYAnchor),
            greatWorkLabel.leadingAnchor.constraint(equalTo: sparkleIcon.trailingAnchor, constant: 16),
            
            completionMessageLabel.topAnchor.constraint(equalTo: greatWorkLabel.bottomAnchor, constant: 16),
            completionMessageLabel.leadingAnchor.constraint(equalTo: celebrationCard.leadingAnchor, constant: 24),
            completionMessageLabel.trailingAnchor.constraint(equalTo: celebrationCard.trailingAnchor, constant: -24),
            
            techniquesLabel.topAnchor.constraint(equalTo: completionMessageLabel.bottomAnchor, constant: 20),
            techniquesLabel.leadingAnchor.constraint(equalTo: celebrationCard.leadingAnchor, constant: 24),
            techniquesLabel.bottomAnchor.constraint(equalTo: celebrationCard.bottomAnchor, constant: -24),
            
            infoButton.centerYAnchor.constraint(equalTo: techniquesLabel.centerYAnchor),
            infoButton.trailingAnchor.constraint(equalTo: celebrationCard.trailingAnchor, constant: -24),
            infoButton.widthAnchor.constraint(equalToConstant: 32),
            infoButton.heightAnchor.constraint(equalToConstant: 32),
            
            feedbackTitleLabel.topAnchor.constraint(equalTo: celebrationCard.bottomAnchor, constant: 48),
            feedbackTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            feedbackTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            feedbackStack.topAnchor.constraint(equalTo: feedbackTitleLabel.bottomAnchor, constant: 24),
            feedbackStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            feedbackStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            markAsDoneButton.topAnchor.constraint(equalTo: feedbackStack.bottomAnchor, constant: 48),
            markAsDoneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            markAsDoneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            markAsDoneButton.heightAnchor.constraint(equalToConstant: 56),
            
            tryAnotherApproachButton.topAnchor.constraint(equalTo: markAsDoneButton.bottomAnchor, constant: 16),
            tryAnotherApproachButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tryAnotherApproachButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tryAnotherApproachButton.heightAnchor.constraint(equalToConstant: 56),
            tryAnotherApproachButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupActions() {
        markAsDoneButton.addTarget(self, action: #selector(markAsDoneTapped), for: .touchUpInside)
        tryAnotherApproachButton.addTarget(self, action: #selector(tryAnotherApproachTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    }
    
    // NEW: Update button states based on feedback selection
    private func updateButtonStates() {
        guard let feedback = selectedFeedback else {
            markAsDoneButton.isEnabled = false
            markAsDoneButton.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.3)
            return
        }
        
        if feedback == "Worked Well!" || feedback == "Somewhat!" {
            markAsDoneButton.isEnabled = true
            markAsDoneButton.backgroundColor = ThemeManager.Colors.primaryPurple
        } else {
            // "Not Yet!" - keep disabled
            markAsDoneButton.isEnabled = false
            markAsDoneButton.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.3)
        }
    }
    
    @objc private func feedbackTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        for view in feedbackStack.arrangedSubviews {
            view.backgroundColor = ThemeManager.Colors.cardBackground
            view.layer.borderColor = UIColor.clear.cgColor
        }
        
        tappedView.backgroundColor = purpleColor.withAlphaComponent(0.1)
        tappedView.layer.borderColor = purpleColor.cgColor
        
        let feedbackOptions = ["Worked Well!", "Somewhat!", "Not Yet!"]
        selectedFeedback = feedbackOptions[tappedView.tag]
        
        // Update button states based on selection
        updateButtonStates()
    }
    
    @objc private func markAsDoneTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        var updatedLog = logEntry!
        updatedLog.status = .resolved
        updatedLog.updatedAt = Date()
        updatedLog.completedSteps = updatedLog.totalSteps
        
        if let feedback = selectedFeedback {
            updatedLog.finalNotes = feedback
        }
        
        activityFeedManager.saveActivityLog(updatedLog)
        
        let alert = UIAlertController(
            title: "Success! 🎉",
            message: "Your struggle has been marked as resolved.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.backToFindYourFlow()
        })
        present(alert, animated: true)
    }
    
    @objc private func tryAnotherApproachTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // FIXED: Handle "Not Yet!" case - mark as unresolved and go to unresolved section
        if selectedFeedback == "Not Yet!" {
            var updatedLog = logEntry!
            updatedLog.status = .unresolved
            updatedLog.updatedAt = Date()
            updatedLog.finalNotes = selectedFeedback
            activityFeedManager.saveActivityLog(updatedLog)
            
            let alert = UIAlertController(
                title: "Marked as Unresolved",
                message: "This has been moved to your unresolved section. You can try different approaches later.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.backToFindYourFlow()
            })
            present(alert, animated: true)
        } else {
            // Regular try another approach flow
            let stepByStepVC = StepByStepGuidanceViewController()
            stepByStepVC.logEntry = logEntry
            stepByStepVC.struggleName = struggleName
            
            if let navController = navigationController {
                var viewControllers = navController.viewControllers
                viewControllers.removeLast()
                viewControllers.append(stepByStepVC)
                navController.setViewControllers(viewControllers, animated: true)
            }
        }
    }
    
    @objc private func infoButtonTapped() {
        print("🔵 Info button tapped")
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let infoText = """
📚 About CBT + PCIT

🧠 CBT (Cognitive Behavioral Therapy)
Helps children understand and manage their thoughts, feelings, and behaviors through structured problem-solving.

👨‍👩‍👧 PCIT (Parent-Child Interaction Therapy)
Focuses on strengthening parent-child relationships through positive reinforcement, clear communication, and consistent responses.

Both approaches emphasize:
• Connection before correction
• Positive reinforcement
• Consistent responses
• Teaching new skills
• Building emotional regulation
"""
        
        let alert = UIAlertController(
            title: "Techniques Used",
            message: infoText,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Got It", style: .default, handler: nil))
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
            print("✅ Alert presented")
        }
    }
}
