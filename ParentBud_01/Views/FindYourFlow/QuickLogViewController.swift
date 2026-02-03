//
//  QuickLogViewController.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-13
//

import UIKit

class QuickLogViewController: UIViewController {
    
    // MARK: - Properties
    var prefilledStruggle: CommonStruggle?
    private let flowDataManager = FlowDataManager.shared
    private let userDataManager = UserDataManager.shared
    private let activityFeedManager = ActivityFeedDataManager.shared // ✅ ADDED
    
    private var selectedTags: [String] = []
    private var availableStruggles: [String] = []
    
    // App's brand color (Theme Consistent)
    private let brandColor = ThemeManager.Colors.primaryPurple
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .automatic
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let mainHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Quick Struggle Log"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Tell us what's challenging with your little one right now, and we'll suggest a gentle approach."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = ThemeManager.Colors.secondaryText
        label.numberOfLines = 0
        return label
    }()
    
    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "What type of struggle?"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        return label
    }()
    
    private let pillsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        return stack
    }()
    
    private let quickNoteTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Quick note"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        return label
    }()
    
    private let textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.inputBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let noteTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "What happened? Any specific details..."
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textColor = ThemeManager.Colors.primaryText
        textField.borderStyle = .none
        return textField
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.35
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupActions()
        loadStruggles()
        setupKeyboardHandling()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        navigationItem.title = "What's Happening?"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = true
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        [mainHeaderLabel, descriptionLabel, sectionTitleLabel,
         pillsStackView, quickNoteTitleLabel, textFieldContainer, continueButton]
            .forEach { contentView.addSubview($0) }
        
        textFieldContainer.addSubview(noteTextField)
        
        [mainHeaderLabel, descriptionLabel, sectionTitleLabel, pillsStackView,
         quickNoteTitleLabel, textFieldContainer, noteTextField, continueButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    // MARK: - Constraints
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
            
            mainHeaderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: mainHeaderLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: mainHeaderLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: mainHeaderLabel.trailingAnchor),
            
            sectionTitleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 28),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: mainHeaderLabel.leadingAnchor),
            sectionTitleLabel.trailingAnchor.constraint(equalTo: mainHeaderLabel.trailingAnchor),
            
            pillsStackView.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 16),
            pillsStackView.leadingAnchor.constraint(equalTo: mainHeaderLabel.leadingAnchor),
            pillsStackView.trailingAnchor.constraint(equalTo: mainHeaderLabel.trailingAnchor),
            
            quickNoteTitleLabel.topAnchor.constraint(equalTo: pillsStackView.bottomAnchor, constant: 32),
            quickNoteTitleLabel.leadingAnchor.constraint(equalTo: mainHeaderLabel.leadingAnchor),
            quickNoteTitleLabel.trailingAnchor.constraint(equalTo: mainHeaderLabel.trailingAnchor),
            
            textFieldContainer.topAnchor.constraint(equalTo: quickNoteTitleLabel.bottomAnchor, constant: 16),
            textFieldContainer.leadingAnchor.constraint(equalTo: mainHeaderLabel.leadingAnchor),
            textFieldContainer.trailingAnchor.constraint(equalTo: mainHeaderLabel.trailingAnchor),
            textFieldContainer.heightAnchor.constraint(equalToConstant: 56),
            
            noteTextField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 16),
            noteTextField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -16),
            noteTextField.centerYAnchor.constraint(equalTo: textFieldContainer.centerYAnchor),
            
            continueButton.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 40),
            continueButton.leadingAnchor.constraint(equalTo: mainHeaderLabel.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: mainHeaderLabel.trailingAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 56),
            continueButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Actions
    private func setupActions() {
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Keyboard
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = frame.height - view.safeAreaInsets.bottom + 20
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Pills & Logic
    private func loadStruggles() {
        availableStruggles = [
            "Behaviour Management", "Eating Habits", "Potty Training", "Screen Time",
            "Separation Anxiety", "Sleep Routines", "Social Skills", "Tantrums"
        ]
        createPills()
    }
    
    private func createPills() {
        pillsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        var currentRow: UIStackView?
        for (index, struggle) in availableStruggles.enumerated() {
            if index % 2 == 0 {
                currentRow = UIStackView()
                currentRow?.axis = .horizontal
                currentRow?.spacing = 16
                currentRow?.distribution = .fillEqually
                pillsStackView.addArrangedSubview(currentRow!)
            }
            let pill = createPill(title: struggle)
            currentRow?.addArrangedSubview(pill)
        }
    }
    
    private func createPill(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(ThemeManager.Colors.primaryText, for: .normal)
        button.backgroundColor = ThemeManager.Colors.inputBackground
        button.layer.cornerRadius = 28
        button.layer.borderWidth = 1.5
        button.layer.borderColor = brandColor.withAlphaComponent(0.3).cgColor
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.addTarget(self, action: #selector(pillTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func pillTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        guard let title = sender.title(for: .normal) else { return }
        if selectedTags.contains(title) {
            selectedTags.removeAll { $0 == title }
        } else {
            selectedTags.append(title)
        }
        updatePillStates()
    }
    
    private func updatePillStates() {
        for case let row as UIStackView in pillsStackView.arrangedSubviews {
            for case let button as UIButton in row.arrangedSubviews {
                guard let title = button.title(for: .normal) else { continue }
                let isSelected = selectedTags.contains(title)
                UIView.animate(withDuration: 0.25) {
                    button.backgroundColor = isSelected ? self.brandColor.withAlphaComponent(0.15) : ThemeManager.Colors.inputBackground
                    button.layer.borderColor = isSelected ? self.brandColor.cgColor : self.brandColor.withAlphaComponent(0.3).cgColor
                    button.setTitleColor(isSelected ? self.brandColor : ThemeManager.Colors.primaryText, for: .normal)
                }
            }
        }
    }
    
    // ✅ UPDATED: Continue Button with ActivityFeed Integration
    @objc private func continueButtonTapped() {
        guard !selectedTags.isEmpty else {
            let alert = UIAlertController(title: "Select a Struggle", message: "Please select at least one type of struggle.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Get user ID
        let userId: UUID
        if let currentUser = userDataManager.getCurrentUser(),
           let existingUserId = UUID(uuidString: currentUser.userId) {
            userId = existingUserId
        } else {
            userId = UUID()
        }
        
        // ✅ Generate attractive flowTitle from selected struggle
        let primaryStruggle = selectedTags.first ?? "General"
        let flowTitle = StruggleTitles.getTitle(for: primaryStruggle)
        
        // ✅ Create log entry with flowTitle
        let logEntry = LogEntry(
            userId: userId,
            tags: selectedTags,
            customNote: noteTextField.text,
            flowTitle: flowTitle, // ✅ This will show in navigation bar
            totalSteps: 5,
            completedSteps: 0,
            status: .ongoing
        )
        
        // ✅ Save to both managers
        flowDataManager.addLog(logEntry)
        activityFeedManager.saveActivityLog(logEntry)
        
        print("✅ Created log from QuickLog: \(logEntry.id) with flowTitle: \(flowTitle)")
        
        // Navigate to StepByStep
        let stepVC = StepByStepGuidanceViewController()
        stepVC.logEntry = logEntry
        stepVC.struggleName = primaryStruggle
        stepVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(stepVC, animated: true)
        
        print("✅ Navigated to StepByStep from QuickLog")
    }
}
