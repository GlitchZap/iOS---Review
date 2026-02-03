//
//  ScreenerQuestionViewController.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 2025-11-07
//  ✅ UPDATED: Fixed spacing issues and improved layout for better user experience
//

import UIKit

class ScreenerQuestionViewController: UIViewController {
    
    // MARK: - Properties
    
    private var gradientLayer: CAGradientLayer?
    private var questions: [ScreenerQuestion] = []
    private var currentQuestionIndex = 0
    private var selectedOptions: [String] = []
    private let dataManager = ScreenerDataManager.shared
    
    var isAddingChildFromSettings = false
    var isEditingChildFromSettings = false
    var startQuestionIndex = 0
    
    // MARK: - UI Components
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = ThemeManager.Colors.primaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.layer.cornerRadius = 2
        progress.clipsToBounds = true
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    // ✅ FIXED: Improved scroll view configuration
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .automatic
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .clear
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = ThemeManager.Colors.secondaryText
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping // ✅ FIXED: Better text wrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.inputBackground
        view.layer.borderWidth = 1
        view.layer.borderColor = ThemeManager.Colors.border.cgColor
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter name"
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textColor = ThemeManager.Colors.primaryText
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16 // ✅ INCREASED spacing between options for better breathability
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
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
        questions = ScreenerQuestionsData.questions
        
        if isAddingChildFromSettings {
            dataManager.clearAllData()
            dataManager.isAddingNewChild = true
            currentQuestionIndex = 3
            startQuestionIndex = 3
            print("🔄 Setting up screener for adding NEW child - cleared all responses")
            
        } else if isEditingChildFromSettings {
            currentQuestionIndex = 3
            startQuestionIndex = 3
            print("🔄 Setting up screener for editing existing child")
            
        } else {
            dataManager.clearAllData()
            currentQuestionIndex = 0
            startQuestionIndex = 0
            print("🔄 Setting up screener for initial onboarding - cleared all responses")
        }
        
        setupGradient()
        setupUI()
        setupConstraints()
        setupActions()
        updateProgressBarColors()
        loadQuestion()
        
        textField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ThemeManager.shared.updateGradientFrame(gradientLayer!, for: view)
        
        textFieldContainer.layer.cornerRadius = textFieldContainer.bounds.height / 2
        nextButton.layer.cornerRadius = nextButton.bounds.height / 2
        
        for view in optionsStackView.arrangedSubviews {
            if let button = view as? UIButton {
                button.layer.cornerRadius = button.bounds.height / 2
            }
        }
        
        updateScrollViewContentSize()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTheme()
        }
    }
    
    private func setupGradient() {
        gradientLayer = ThemeManager.shared.createAuthBackgroundGradient(for: view, traitCollection: traitCollection)
        view.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    private func updateProgressBarColors() {
        if traitCollection.userInterfaceStyle == .dark {
            progressBar.progressTintColor = ThemeManager.Colors.primaryPurple
            progressBar.trackTintColor = UIColor(white: 0.3, alpha: 1.0)
        } else {
            progressBar.progressTintColor = ThemeManager.Colors.primaryPurple
            progressBar.trackTintColor = UIColor(white: 0.85, alpha: 1.0)
        }
    }
    
    private func updateTheme() {
        gradientLayer?.removeFromSuperlayer()
        setupGradient()
        
        backButton.tintColor = ThemeManager.Colors.primaryText
        skipButton.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        
        updateProgressBarColors()
        
        titleLabel.textColor = ThemeManager.Colors.primaryText
        subtitleLabel.textColor = ThemeManager.Colors.secondaryText
        
        contentView.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        
        textFieldContainer.backgroundColor = ThemeManager.Colors.inputBackground
        textFieldContainer.layer.borderColor = ThemeManager.Colors.border.cgColor
        textField.textColor = ThemeManager.Colors.primaryText
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter name",
            attributes: [.foregroundColor: ThemeManager.Colors.tertiaryText]
        )
        
        nextButton.backgroundColor = ThemeManager.Colors.primaryPurple
        nextButton.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        
        for view in optionsStackView.arrangedSubviews {
            if let button = view as? UIButton {
                updateOptionButtonTheme(button)
            }
        }
    }
    
    private func updateOptionButtonTheme(_ button: UIButton) {
        let isSelected = selectedOptions.contains(button.attributedTitle(for: .normal)?.string ?? "")
        
        if isSelected {
            button.backgroundColor = ThemeManager.Colors.accentPurple
            button.layer.borderColor = ThemeManager.Colors.accentPurple.cgColor
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            if let title = button.attributedTitle(for: .normal)?.string {
                button.setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)
            }
        } else {
            button.backgroundColor = ThemeManager.Colors.inputBackground
            button.layer.borderColor = ThemeManager.Colors.border.cgColor
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: ThemeManager.Colors.primaryText,
                .paragraphStyle: paragraphStyle
            ]
            if let title = button.attributedTitle(for: .normal)?.string {
                button.setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(skipButton)
        view.addSubview(progressBar)
        view.addSubview(scrollView)
        view.addSubview(nextButton)
        
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(textFieldContainer)
        textFieldContainer.addSubview(textField)
        contentView.addSubview(optionsStackView)
    }
    
    // ✅ FIXED: Improved constraints with better spacing
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Top navigation
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            skipButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Progress bar
            progressBar.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressBar.heightAnchor.constraint(equalToConstant: 4),
            
            // ✅ IMPROVED: Scroll view with better spacing
            scrollView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 24), // Increased spacing
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -24), // Increased spacing
            
            // Content view constraints for proper scrolling
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // ✅ IMPROVED: Content elements with better spacing
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20), // Increased top spacing
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12), // Increased spacing
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Text field
            textFieldContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40), // Increased spacing
            textFieldContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            textFieldContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            textFieldContainer.heightAnchor.constraint(equalToConstant: 56),
            
            textField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -24),
            textField.centerYAnchor.constraint(equalTo: textFieldContainer.centerYAnchor),
            
            // ✅ IMPROVED: Options stack view with better spacing
            optionsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40), // Increased top spacing
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            optionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50), // Increased bottom spacing
            
            // Next button
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20), // Increased bottom spacing
            nextButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // ✅ IMPROVED: Better content size calculation
    private func updateScrollViewContentSize() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.contentView.layoutIfNeeded()
            
            let contentHeight: CGFloat
            if self.textFieldContainer.isHidden {
                // For options view, include stack view height plus extra padding
                let stackViewBottom = self.optionsStackView.frame.maxY
                contentHeight = max(stackViewBottom + 60, self.scrollView.bounds.height + 1) // Increased padding
            } else {
                // For text field view
                let textFieldBottom = self.textFieldContainer.frame.maxY
                contentHeight = max(textFieldBottom + 60, self.scrollView.bounds.height + 1) // Increased padding
            }
            
            let newContentSize = CGSize(width: self.scrollView.bounds.width, height: contentHeight)
            if self.scrollView.contentSize != newContentSize {
                self.scrollView.contentSize = newContentSize
            }
            
            print("📏 Updated scroll content size: \(newContentSize), scrollView frame: \(self.scrollView.frame)")
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .primaryActionTriggered)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.nextButton.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight + self.view.safeAreaInsets.bottom + 16)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.nextButton.transform = .identity
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // ✅ IMPROVED: Load Question with better UI updates
    private func loadQuestion() {
        guard currentQuestionIndex < questions.count else {
            completeScreener()
            return
        }
        
        let question = questions[currentQuestionIndex]
        titleLabel.text = question.questionTitle
        subtitleLabel.text = question.questionSubtitle
        
        let totalQuestions = Float(questions.count)
        let progress = Float(currentQuestionIndex) / totalQuestions
        progressBar.setProgress(progress, animated: true)
        
        selectedOptions.removeAll()
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        textField.text = ""
        
        var savedResponse: UserResponse? = nil
        if isEditingChildFromSettings {
            savedResponse = dataManager.getResponse(for: question.id)
            print("📝 Loading saved response for editing: \(savedResponse?.selectedOptions ?? []) - \(savedResponse?.textInput ?? "")")
        } else {
            print("🆕 Fresh start - no saved responses loaded")
        }
        
        if let savedResponse = savedResponse {
            if question.questionType == .textInput {
                textField.text = savedResponse.textInput
            } else {
                selectedOptions = savedResponse.selectedOptions
            }
        }
        
        switch question.questionType {
        case .textInput:
            textFieldContainer.isHidden = false
            optionsStackView.isHidden = true
            nextButton.isHidden = false
            
        case .singleChoice:
            textFieldContainer.isHidden = true
            optionsStackView.isHidden = false
            nextButton.isHidden = true
            
            for option in question.options {
                let optionButton = createOptionButton(title: option, isMultiSelect: false)
                optionsStackView.addArrangedSubview(optionButton)
                
                if isEditingChildFromSettings, let savedResponse = savedResponse, savedResponse.selectedOptions.contains(option) {
                    selectButton(optionButton)
                    print("🔄 Pre-selected option for editing: \(option)")
                }
            }
            
        case .multipleChoice:
            textFieldContainer.isHidden = true
            optionsStackView.isHidden = false
            nextButton.isHidden = false
            
            for option in question.options {
                let optionButton = createOptionButton(title: option, isMultiSelect: true)
                optionsStackView.addArrangedSubview(optionButton)
                
                if isEditingChildFromSettings, let savedResponse = savedResponse, savedResponse.selectedOptions.contains(option) {
                    selectButton(optionButton)
                    print("🔄 Pre-selected option for editing: \(option)")
                }
            }
        }
        
        if currentQuestionIndex == questions.count - 1 {
            nextButton.setTitle("Complete", for: .normal)
        } else {
            nextButton.setTitle("Next", for: .normal)
        }
        
        // ✅ IMPROVED: Better layout and animation
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Animate the content change
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                // Update button corners after layout
                for view in self.optionsStackView.arrangedSubviews {
                    if let button = view as? UIButton {
                        button.layer.cornerRadius = button.bounds.height / 2
                        button.clipsToBounds = true
                    }
                }
                
                self.updateScrollViewContentSize()
                self.scrollView.setContentOffset(.zero, animated: true)
            }
        }
    }
    
    // ✅ IMPROVED: Better option button creation with improved spacing
    private func createOptionButton(title: String, isMultiSelect: Bool) -> UIButton {
        let button = UIButton(type: .custom)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: ThemeManager.Colors.primaryText,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.backgroundColor = ThemeManager.Colors.inputBackground
        button.layer.borderWidth = 1.5
        button.layer.borderColor = ThemeManager.Colors.border.cgColor
        
        button.clipsToBounds = true
        button.isUserInteractionEnabled = true
        button.adjustsImageWhenHighlighted = true
        
        // ✅ IMPROVED: Better padding for options
        button.contentEdgeInsets = UIEdgeInsets(top: 18, left: 24, bottom: 18, right: 24) // Increased padding
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.lineBreakMode = .byWordWrapping
        
        let heightConstraint = button.heightAnchor.constraint(greaterThanOrEqualToConstant: 56) // Increased minimum height
        heightConstraint.priority = .required
        heightConstraint.isActive = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
    
    private func selectButton(_ button: UIButton) {
        guard let currentTitle = button.attributedTitle(for: .normal)?.string else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]
        
        let selectedTitle = NSAttributedString(string: currentTitle, attributes: selectedAttributes)
        button.setAttributedTitle(selectedTitle, for: .normal)
        
        UIView.animate(withDuration: 0.2) {
            button.backgroundColor = ThemeManager.Colors.accentPurple
            button.layer.borderColor = ThemeManager.Colors.accentPurple.cgColor
            button.layer.borderWidth = 2
        }
    }
    
    private func deselectButton(_ button: UIButton) {
        guard let currentTitle = button.attributedTitle(for: .normal)?.string else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let deselectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: ThemeManager.Colors.primaryText,
            .paragraphStyle: paragraphStyle
        ]
        
        let deselectedTitle = NSAttributedString(string: currentTitle, attributes: deselectedAttributes)
        button.setAttributedTitle(deselectedTitle, for: .normal)
        
        UIView.animate(withDuration: 0.2) {
            button.backgroundColor = ThemeManager.Colors.inputBackground
            button.layer.borderColor = ThemeManager.Colors.border.cgColor
            button.layer.borderWidth = 1.5
        }
    }
    
    @objc private func backTapped() {
        print("Back button tapped")
        
        if isAddingChildFromSettings || isEditingChildFromSettings {
            if currentQuestionIndex <= startQuestionIndex {
                dismiss(animated: true)
                return
            }
        }
        
        if currentQuestionIndex > startQuestionIndex {
            let currentQuestion = questions[currentQuestionIndex]
            dataManager.clearResponse(for: currentQuestion.id)
            
            currentQuestionIndex -= 1
            loadQuestion()
            
            print("Moved back to question \(currentQuestionIndex + 1)")
        } else {
            print("Going back to previous screen")
            if isAddingChildFromSettings || isEditingChildFromSettings {
                dismiss(animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func skipTapped() {
        print("Skip button tapped")
        if isAddingChildFromSettings || isEditingChildFromSettings {
            dismiss(animated: true)
        } else {
            navigateToHome()
        }
    }
    
    @objc private func optionTapped(_ sender: UIButton) {
        guard let title = sender.attributedTitle(for: .normal)?.string else { return }
        let question = questions[currentQuestionIndex]
        
        print("Button tapped: \(title)")
        
        if question.questionType == .singleChoice {
            for view in optionsStackView.arrangedSubviews {
                if let button = view as? UIButton {
                    deselectButton(button)
                }
            }
            selectedOptions.removeAll()
            selectedOptions.append(title)
            selectButton(sender)
            
            dataManager.saveResponse(for: question.id, selectedOptions: selectedOptions)
            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.autoAdvanceToNext()
            }
            
        } else {
            if selectedOptions.contains(title) {
                selectedOptions.removeAll { $0 == title }
                deselectButton(sender)
            } else {
                selectedOptions.append(title)
                selectButton(sender)
            }
            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    @objc private func nextTapped() {
        let question = questions[currentQuestionIndex]
        
        if question.questionType == .textInput {
            guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else {
                showAlert(message: "Please enter required information")
                return
            }
            dataManager.saveResponse(for: question.id, textInput: text)
        } else if question.questionType == .multipleChoice {
            guard !selectedOptions.isEmpty else {
                showAlert(message: "Please select at least one option")
                return
            }
            dataManager.saveResponse(for: question.id, selectedOptions: selectedOptions)
        }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        currentQuestionIndex += 1
        loadQuestion()
    }
    
    private func autoAdvanceToNext() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        currentQuestionIndex += 1
        loadQuestion()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func completeScreener() {
        dataManager.buildUserProfile()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let title: String
        let message: String
        
        if isAddingChildFromSettings {
            title = "Success!"
            message = "Child profile added successfully!"
        } else if isEditingChildFromSettings {
            title = "Success!"
            message = "Child profile updated successfully!"
        } else {
            title = "Welcome!"
            message = "Your profile is complete!"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            if self?.isAddingChildFromSettings == true || self?.isEditingChildFromSettings == true {
                self?.dismiss(animated: true) {
                    NotificationCenter.default.post(name: NSNotification.Name("ChildProfileUpdated"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshHomeScreen"), object: nil)
                }
            } else {
                self?.navigateToMainApp()
            }
        })
        
        present(alert, animated: true)
    }
    
    private func navigateToHome() {
        let homeVC = HomeViewController()
        
        if let navigationController = navigationController {
            var viewControllers = navigationController.viewControllers
            if viewControllers.count > 1 {
                viewControllers = [viewControllers[0], homeVC]
                navigationController.setViewControllers(viewControllers, animated: true)
            } else {
                navigationController.pushViewController(homeVC, animated: true)
            }
        }
        
        print("Navigated to Home Page")
    }
    
    private func navigateToMainApp() {
        let mainTabBar = MainTabBarController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = mainTabBar
                window.makeKeyAndVisible()
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Required", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

extension ScreenerQuestionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        nextTapped()
        return true
    }
}
