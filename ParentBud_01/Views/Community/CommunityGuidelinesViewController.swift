//
//  CommunityGuidelinesViewController.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-16
//

import UIKit

class CommunityGuidelinesViewController: UIViewController {
    
    private let dataManager = CommunityDataManager.shared
    var onAccept: (() -> Void)?
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .light)
        imageView.image = UIImage(systemName: "figure.2.and.child.holdinghands", withConfiguration: config)
        imageView.tintColor = ThemeManager.Colors.primaryPurple
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to\nParent Pods"
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "A supportive community where parents connect, share experiences, and grow together"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let guidelinesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Community Guidelines"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let guidelinesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let agreementCard: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 16
        view.layer.shadowOpacity = 0.08
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        button.setImage(UIImage(systemName: "circle", withConfiguration: config), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: config), for: .selected)
        button.tintColor = ThemeManager.Colors.primaryPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let agreementLabel: UILabel = {
        let label = UILabel()
        label.text = "I have read and agree to the community guidelines"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = ThemeManager.Colors.primaryText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Started", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.layer.cornerRadius = 16
        button.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        button.layer.shadowRadius = 20
        button.layer.shadowOpacity = 0.4
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        populateGuidelines()
        updateContinueButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateEntrance()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTheme()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(iconImageView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        contentView.addSubview(guidelinesTitleLabel)
        contentView.addSubview(guidelinesStackView)
        contentView.addSubview(agreementCard)
        contentView.addSubview(continueButton)
        
        agreementCard.addSubview(checkboxButton)
        agreementCard.addSubview(agreementLabel)
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
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            iconImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 90),
            iconImageView.heightAnchor.constraint(equalToConstant: 90),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            guidelinesTitleLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 48),
            guidelinesTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            guidelinesTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            guidelinesStackView.topAnchor.constraint(equalTo: guidelinesTitleLabel.bottomAnchor, constant: 24),
            guidelinesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            guidelinesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            agreementCard.topAnchor.constraint(equalTo: guidelinesStackView.bottomAnchor, constant: 40),
            agreementCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            agreementCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            checkboxButton.leadingAnchor.constraint(equalTo: agreementCard.leadingAnchor, constant: 20),
            checkboxButton.topAnchor.constraint(equalTo: agreementCard.topAnchor, constant: 20),
            checkboxButton.widthAnchor.constraint(equalToConstant: 36),
            checkboxButton.heightAnchor.constraint(equalToConstant: 36),
            
            agreementLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 16),
            agreementLabel.trailingAnchor.constraint(equalTo: agreementCard.trailingAnchor, constant: -20),
            agreementLabel.centerYAnchor.constraint(equalTo: checkboxButton.centerYAnchor),
            agreementLabel.bottomAnchor.constraint(equalTo: agreementCard.bottomAnchor, constant: -20),
            
            continueButton.topAnchor.constraint(equalTo: agreementCard.bottomAnchor, constant: 32),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 56),
            continueButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupActions() {
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        agreementCard.addGestureRecognizer(tapGesture)
    }
    
    private func populateGuidelines() {
        let guidelines = [
            ("heart.circle.fill", "Be Kind & Respectful", "Treat every parent with empathy and understanding. We're all doing our best."),
            ("shield.checkered", "Keep It Safe", "No personal information, child photos, or identifying details should be shared."),
            ("stethoscope", "Share Experiences, Not Medical Advice", "Support each other with personal stories, not medical recommendations."),
            ("hand.raised.fill", "Report Concerns", "If you see inappropriate content, please report it immediately."),
            ("bubble.left.and.bubble.right.fill", "Stay On Topic", "Keep discussions relevant to parenting and family life."),
            ("checkmark.seal.fill", "No Spam or Promotions", "This is a community space, not a marketplace.")
        ]
        
        for (icon, title, description) in guidelines {
            let view = createEnhancedGuidelineCard(icon: icon, title: title, description: description)
            guidelinesStackView.addArrangedSubview(view)
        }
    }
    
    private func createEnhancedGuidelineCard(icon: String, title: String, description: String) -> UIView {
        let container = UIView()
        container.backgroundColor = ThemeManager.Colors.cardBackground
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.06
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.12)
        iconContainer.layer.cornerRadius = 24
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        iconView.image = UIImage(systemName: icon, withConfiguration: config)
        iconView.tintColor = ThemeManager.Colors.primaryPurple
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = ThemeManager.Colors.primaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descLabel.textColor = ThemeManager.Colors.secondaryText
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(iconView)
        container.addSubview(iconContainer)
        container.addSubview(titleLabel)
        container.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconContainer.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func updateTheme() {
        view.backgroundColor = ThemeManager.Colors.background
        titleLabel.textColor = ThemeManager.Colors.primaryText
        subtitleLabel.textColor = ThemeManager.Colors.secondaryText
        guidelinesTitleLabel.textColor = ThemeManager.Colors.primaryText
        agreementCard.backgroundColor = ThemeManager.Colors.cardBackground
        agreementLabel.textColor = ThemeManager.Colors.primaryText
        iconImageView.tintColor = ThemeManager.Colors.primaryPurple
        checkboxButton.tintColor = ThemeManager.Colors.primaryPurple
        continueButton.backgroundColor = ThemeManager.Colors.primaryPurple
        continueButton.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
    }
    
    private func updateContinueButtonState() {
        let isEnabled = checkboxButton.isSelected
        continueButton.isEnabled = isEnabled
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.continueButton.alpha = isEnabled ? 1.0 : 0.5
            self.continueButton.transform = isEnabled ? .identity : CGAffineTransform(scaleX: 0.98, y: 0.98)
            self.continueButton.layer.shadowOpacity = isEnabled ? 0.4 : 0.1
        }
    }
    
    private func animateEntrance() {
        headerView.alpha = 0
        headerView.transform = CGAffineTransform(translationX: 0, y: -30)
        
        guidelinesStackView.alpha = 0
        guidelinesStackView.transform = CGAffineTransform(translationX: 0, y: 20)
        
        agreementCard.alpha = 0
        agreementCard.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        continueButton.alpha = 0
        continueButton.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.headerView.alpha = 1
            self.headerView.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.guidelinesStackView.alpha = 1
            self.guidelinesStackView.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.agreementCard.alpha = 1
            self.agreementCard.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.7, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.continueButton.alpha = 0.5
            self.continueButton.transform = .identity
        }
    }
    
    // MARK: - Actions
    
    @objc private func checkboxTapped() {
        checkboxButton.isSelected.toggle()
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            self.checkboxButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.checkboxButton.transform = .identity
            }
        }
        
        updateContinueButtonState()
    }
    
    @objc private func cardTapped() {
        checkboxTapped()
    }
    
    @objc private func continueTapped() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dataManager.acceptGuidelines()
        
        UIView.animate(withDuration: 0.2) {
            self.continueButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.continueButton.transform = .identity
            } completion: { _ in
                self.onAccept?()
                self.dismiss(animated: true)
            }
        }
    }
}
