//
//  ForgotPasswordViewController.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 07/11/25.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    // MARK: - Properties
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - UI Components
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = ThemeManager.Colors.primaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
        imageView.image = UIImage(systemName: "lock.rotation", withConfiguration: config)
        imageView.tintColor = ThemeManager.Colors.primaryPurple
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Forgot Password?"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your email address and we'll send you instructions to reset your password"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.inputBackground
        view.layer.cornerRadius = 30
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.25
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emailIcon: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        imageView.image = UIImage(systemName: "envelope.fill", withConfiguration: config)
        imageView.tintColor = ThemeManager.Colors.primaryPurple
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = ThemeManager.Colors.primaryText
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Reset Link", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.layer.cornerRadius = 30
        button.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        button.layer.shadowRadius = 16
        button.layer.shadowOpacity = 0.4
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backToLoginLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupUI()
        setupConstraints()
        setupActions()
        setupKeyboardDismissal()
        updatePlaceholders()
        updateBackToLoginLabel()
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
        // Update gradient
        gradientLayer?.removeFromSuperlayer()
        setupGradient()
        
        // Update colors
        backButton.tintColor = ThemeManager.Colors.primaryText
        iconImageView.tintColor = ThemeManager.Colors.primaryPurple
        titleLabel.textColor = ThemeManager.Colors.primaryText
        subtitleLabel.textColor = ThemeManager.Colors.secondaryText
        
        emailContainerView.backgroundColor = ThemeManager.Colors.inputBackground
        emailTextField.textColor = ThemeManager.Colors.primaryText
        
        sendButton.backgroundColor = ThemeManager.Colors.primaryPurple
        
        updatePlaceholders()
        updateBackToLoginLabel()
    }
    
    // MARK: - Update Placeholders
    private func updatePlaceholders() {
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [.foregroundColor: ThemeManager.Colors.tertiaryText]
        )
    }
    
    // MARK: - Update Back To Login Label
    private func updateBackToLoginLabel() {
        let fullText = "Remember your password?  Back to Login"
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: ThemeManager.Colors.secondaryText, range: NSRange(location: 0, length: fullText.count))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: fullText.count))
        
        if let range = fullText.range(of: "Back to Login") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: ThemeManager.Colors.primaryPurple, range: nsRange)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .semibold), range: nsRange)
        }
        
        backToLoginLabel.attributedText = attributedString
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        emailContainerView.addSubview(emailIcon)
        emailContainerView.addSubview(emailTextField)
        view.addSubview(emailContainerView)
        
        view.addSubview(sendButton)
        view.addSubview(backToLoginLabel)
        
        backToLoginLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backToLoginTapped))
        backToLoginLabel.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            iconImageView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 40),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 100),
            iconImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            emailContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            emailContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emailContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            emailIcon.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor, constant: 20),
            emailIcon.centerYAnchor.constraint(equalTo: emailContainerView.centerYAnchor),
            emailIcon.widthAnchor.constraint(equalToConstant: 24),
            emailIcon.heightAnchor.constraint(equalToConstant: 24),
            
            emailTextField.leadingAnchor.constraint(equalTo: emailIcon.trailingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor, constant: -20),
            emailTextField.centerYAnchor.constraint(equalTo: emailContainerView.centerYAnchor),
            
            sendButton.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 32),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            sendButton.heightAnchor.constraint(equalToConstant: 60),
            
            backToLoginLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backToLoginLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }
    
    // MARK: - Keyboard Dismissal
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sendTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email address", style: .alert)
            return
        }
        
        guard isValidEmail(email) else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address", style: .alert)
            return
        }
        
        print("Send reset link to: \(email)")
        
        showAlert(title: "Success", message: "Password reset instructions have been sent to your email", style: .alert) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func backToLoginTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func showAlert(title: String, message: String, style: UIAlertController.Style = .alert, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
