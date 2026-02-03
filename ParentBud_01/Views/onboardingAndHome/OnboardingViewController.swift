//
//  OnboardingViewController.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 07/11/25.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - UI Elements
    private let logoLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Parent", attributes: [
            .foregroundColor: UIColor(red: 231/255, green: 112/255, blue: 118/255, alpha: 1.0),
            .font: UIFont(name: "SF-Pro-Display-Bold", size: 32) ?? .systemFont(ofSize: 32, weight: .bold)
        ])
        attributedText.append(NSAttributedString(string: "Bud", attributes: [
            .foregroundColor: UIColor(red: 65/255, green: 110/255, blue: 154/255, alpha: 1.0),
            .font: UIFont(name: "SF-Pro-Display-Bold", size: 32) ?? .systemFont(ofSize: 32, weight: .bold)
        ]))
        label.attributedText = attributedText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let illustrationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "family_illustration")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        if let customFont = UIFont(name: "SF-Pro-Display-Regular", size: 22) {
            label.font = customFont
        } else {
            label.font = .systemFont(ofSize: 22, weight: .regular)
        }
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let getStartedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Get Started", for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        if let customFont = UIFont(name: "SF-Pro-Display-Semibold", size: 18) {
            button.titleLabel?.font = customFont
        } else {
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        }
        button.layer.cornerRadius = 28
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 12
        button.layer.shadowOpacity = 0.5
        button.layer.masksToBounds = false
        
        return button
    }()
    
    private let loginContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // 🔥 FIX: Enable touch forwarding
        container.isUserInteractionEnabled = true
        
        return container
    }()
    
    private let haveAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "Have an account? "
        if let customFont = UIFont(name: "SF-Pro-Display-Regular", size: 16) {
            label.font = customFont
        } else {
            label.font = .systemFont(ofSize: 16)
        }
        label.textColor = ThemeManager.Colors.secondaryText
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        if let customFont = UIFont(name: "SF-Pro-Display-Semibold", size: 16) {
            button.titleLabel?.font = customFont
        } else {
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        }
        return button
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = ThemeManager.Colors.primaryPurple
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: - Properties
    private let messages = [
        "Because kids don't come\nwith manuals.",
        "Guiding Your Parenthood,\nMoment by Moment",
        "Adaptive Parenting: Clarity in\nEvery Chapter."
    ]
    private var currentMessageIndex = 0
    private var messageTimer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupUI()
        startMessageAnimation()
        setupActions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messageTimer?.invalidate()
        messageTimer = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ThemeManager.shared.updateGradientFrame(gradientLayer!, for: view)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTheme()
        }
    }
    
    // MARK: - Setup Gradient
    private func setupGradient() {
        gradientLayer = ThemeManager.shared.createBackgroundGradient(for: view, traitCollection: traitCollection)
        view.layer.insertSublayer(gradientLayer!, at: 0)
    }

    // MARK: - Update Theme
    private func updateTheme() {
        gradientLayer?.removeFromSuperlayer()
        setupGradient()
        
        messageLabel.textColor = ThemeManager.Colors.primaryText
        haveAccountLabel.textColor = ThemeManager.Colors.secondaryText
        loginButton.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        getStartedButton.backgroundColor = ThemeManager.Colors.primaryPurple
        pageControl.currentPageIndicatorTintColor = ThemeManager.Colors.primaryPurple
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(logoLabel)
        view.addSubview(illustrationImageView)
        view.addSubview(messageLabel)
        view.addSubview(getStartedButton)
        view.addSubview(pageControl)
        view.addSubview(loginContainer)
        
        let loginStack = UIStackView(arrangedSubviews: [haveAccountLabel, loginButton])
        loginStack.axis = .horizontal
        loginStack.spacing = 4
        loginStack.alignment = .center
        loginContainer.addSubview(loginStack)
        loginStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Logo
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Illustration
            illustrationImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            illustrationImageView.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 40),
            illustrationImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            illustrationImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            // Message
            messageLabel.topAnchor.constraint(equalTo: illustrationImageView.bottomAnchor, constant: 40),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // Page Control
            pageControl.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Get Started Button
            getStartedButton.bottomAnchor.constraint(equalTo: loginContainer.topAnchor, constant: -24),
            getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartedButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            getStartedButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Login Container
            loginContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            loginContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginContainer.heightAnchor.constraint(equalToConstant: 44),
            
            // Login Stack
            loginStack.centerXAnchor.constraint(equalTo: loginContainer.centerXAnchor),
            loginStack.centerYAnchor.constraint(equalTo: loginContainer.centerYAnchor),
        ])
        
        // 🔥 ADD THIS WIDTH FIX
        loginContainer.widthAnchor.constraint(greaterThanOrEqualTo: loginStack.widthAnchor).isActive = true
        
        messageLabel.text = messages[0]
    }
    
    private func setupActions() {
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }
    
    // MARK: - Animations
    private func startMessageAnimation() {
        messageTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.animateToNextMessage()
        }
    }
    
    private func animateToNextMessage() {
        UIView.transition(with: messageLabel, duration: 0.5, options: .transitionCrossDissolve) { [weak self] in
            guard let self = self else { return }
            self.currentMessageIndex = (self.currentMessageIndex + 1) % self.messages.count
            self.messageLabel.text = self.messages[self.currentMessageIndex]
            self.pageControl.currentPage = self.currentMessageIndex
        }
    }
    
    // MARK: - Actions
    @objc private func getStartedTapped() {
        print("Get Started tapped")
        let whatWeOfferVC = WhatWeOfferViewController()
        navigationController?.pushViewController(whatWeOfferVC, animated: true)
    }
    
    @objc private func loginTapped() {
        print("Login tapped from Onboarding")
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
}
