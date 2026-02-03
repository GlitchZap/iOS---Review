//
//  SignupRequiredModal.swift
//  ParentBud_01
//
//  Created by GitHub Copilot on 2026-01-15
//

import UIKit

class SignupRequiredModal: UIViewController {
    
    // MARK: - Properties
    var message: String = "Sign up to unlock this feature"
    var featureName: String = ""
    
    // MARK: - UI Components
    
    private let containerView:  UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width:  0, height: 8)
        view.layer.shadowRadius = 20
        view.layer.shadowOpacity = 0.3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .light)
        imageView.image = UIImage(systemName: "lock.circle. fill", withConfiguration: config)
        imageView.tintColor = ThemeManager.Colors.primaryPurple
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign Up Required"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(. white, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.layer.cornerRadius = 28
        button.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 12
        button.layer.shadowOpacity = 0.4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Already have an account?  Log In", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(ThemeManager.Colors.primaryPurple, for: . normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for:  .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(ThemeManager.Colors.secondaryText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        messageLabel.text = message
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTheme()
        }
    }
    
    private func updateTheme() {
        containerView.backgroundColor = ThemeManager.Colors.cardBackground
        titleLabel.textColor = ThemeManager.Colors.primaryText
        messageLabel.textColor = ThemeManager.Colors.secondaryText
        iconImageView.tintColor = ThemeManager.Colors.primaryPurple
        signUpButton.backgroundColor = ThemeManager.Colors.primaryPurple
        loginButton.setTitleColor(ThemeManager.Colors.primaryPurple, for: . normal)
        cancelButton.setTitleColor(ThemeManager.Colors.secondaryText, for:  .normal)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(signUpButton)
        containerView.addSubview(loginButton)
        containerView.addSubview(cancelButton)
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant:  32),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant:  -24),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant:  12),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant:  -24),
            
            signUpButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 32),
            signUpButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            signUpButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            signUpButton.heightAnchor.constraint(equalToConstant: 56),
            
            loginButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 16),
            loginButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant:  16),
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func signUpTapped() {
        let generator = UIImpactFeedbackGenerator(style:  .medium)
        generator.impactOccurred()
        
        dismiss(animated: true) {
            self.navigateToSignUp()
        }
    }
    
    @objc private func loginTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        dismiss(animated: true) {
            self.navigateToLogin()
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Navigation
    
    private func navigateToSignUp() {
        let signUpVC = SignUpViewController()
        let navController = UINavigationController(rootViewController: signUpVC)
        navController.modalPresentationStyle = .fullScreen
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(navController, animated:  true)
        }
    }
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(navController, animated: true)
        }
    }
    
    // MARK: - Present Modal Helper
    
    static func present(from viewController: UIViewController, message: String?  = nil, featureName: String = "") {
        let modal = SignupRequiredModal()
        modal.modalPresentationStyle = . overFullScreen
        modal.modalTransitionStyle = .crossDissolve
        
        if let customMessage = message {
            modal.message = customMessage
        }
        modal.featureName = featureName
        
        viewController.present(modal, animated: true)
    }
}

// MARK: - ✅ Extension:  Reusable Show Function

extension UIViewController {
    func showSignupRequiredModal(message: String = "Sign up to unlock this feature", featureName:  String = "") {
        SignupRequiredModal.present(from: self, message: message, featureName: featureName)
    }
}
