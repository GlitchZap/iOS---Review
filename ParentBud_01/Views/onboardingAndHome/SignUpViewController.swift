//
//  SignUpViewController.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 07/11/25.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Helper function for resizing image
    private static func resizedImage(named name: String, targetSize: CGSize) -> UIImage? {
        guard let image = UIImage(named: name) else { return nil }
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    // MARK: - UI Components
    private let backButton:  UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName:  "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = ThemeManager.Colors.primaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign up"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Name Container
    private let nameContainerView: UIView = {
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
    
    private let nameIcon: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize:  20, weight: .medium)
        imageView.image = UIImage(systemName: "person.fill", withConfiguration: config)
        imageView.tintColor = ThemeManager.Colors.primaryPurple
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = ThemeManager.Colors.primaryText
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // MARK: - Email Container
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
    
    // MARK: - Password Container
    private let passwordContainerView: UIView = {
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
    
    private let passwordIcon: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        imageView.image = UIImage(systemName: "lock.fill", withConfiguration: config)
        imageView.tintColor = ThemeManager.Colors.primaryPurple
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = ThemeManager.Colors.primaryText
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let showPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "eye.slash. fill", withConfiguration: config), for: .normal)
        button.tintColor = . systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Confirm Password Container
    private let confirmPasswordContainerView: UIView = {
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
    
    private let confirmPasswordIcon:  UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        imageView.image = UIImage(systemName: "lock.fill", withConfiguration: config)
        imageView.tintColor = ThemeManager.Colors.primaryPurple
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = ThemeManager.Colors.primaryText
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let showConfirmPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "eye.slash. fill", withConfiguration: config), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Buttons
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(. white, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.layer.cornerRadius = 30
        button.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height:  8)
        button.layer.shadowRadius = 16
        button.layer.shadowOpacity = 0.4
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let dividerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let leftLine = UIView()
        leftLine.backgroundColor = . systemGray4
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        let rightLine = UIView()
        rightLine.backgroundColor = .systemGray4
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = "or"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = . systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(leftLine)
        container.addSubview(rightLine)
        container.addSubview(label)
        NSLayoutConstraint.activate([
            leftLine.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            leftLine.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            leftLine.heightAnchor.constraint(equalToConstant: 1),
            leftLine.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -12),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            rightLine.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12),
            rightLine.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            rightLine.heightAnchor.constraint(equalToConstant: 1),
            rightLine.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        return container
    }()
    
    private let appleButton: UIButton = {
        let button = UIButton(type: . system)
        var config = UIButton.Configuration.filled()
        config.title = "Continue with Apple"
        config.image = UIImage(systemName: "apple.logo")
        config.imagePadding = 8
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        button.configuration = config
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.2
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let googleButton: UIButton = {
        let button = UIButton(type:  .system)
        var config = UIButton.Configuration.filled()
        config.title = "Continue with Google"
        config.image = SignUpViewController.resizedImage(named: "GoogleLogo", targetSize: CGSize(width: 28, height: 28))
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseBackgroundColor = . white
        config.baseForegroundColor = .black
        config.cornerStyle = .capsule
        button.configuration = config
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.1
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Skip Button
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip for now", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.systemGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    // MARK:  - Setup Gradient
    private func setupGradient() {
        gradientLayer = ThemeManager.shared.createAuthBackgroundGradient(for: view, traitCollection: traitCollection)
        view.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    // MARK:  - Update Theme
    private func updateTheme() {
        // Update gradient
        gradientLayer?.removeFromSuperlayer()
        setupGradient()
        
        // Update colors
        backButton.tintColor = ThemeManager.Colors.primaryText
        titleLabel.textColor = ThemeManager.Colors.primaryText
        
        nameContainerView.backgroundColor = ThemeManager.Colors.inputBackground
        nameTextField.textColor = ThemeManager.Colors.primaryText
        
        emailContainerView.backgroundColor = ThemeManager.Colors.inputBackground
        emailTextField.textColor = ThemeManager.Colors.primaryText
        
        passwordContainerView.backgroundColor = ThemeManager.Colors.inputBackground
        passwordTextField.textColor = ThemeManager.Colors.primaryText
        
        confirmPasswordContainerView.backgroundColor = ThemeManager.Colors.inputBackground
        confirmPasswordTextField.textColor = ThemeManager.Colors.primaryText
        
        signUpButton.backgroundColor = ThemeManager.Colors.primaryPurple
        
        updatePlaceholders()
    }
    
    // MARK: - Update Placeholders
    private func updatePlaceholders() {
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Name",
            attributes: [. foregroundColor: ThemeManager.Colors.tertiaryText]
        )
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes:  [.foregroundColor: ThemeManager.Colors.tertiaryText]
        )
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string:  "Password",
            attributes: [.foregroundColor: ThemeManager.Colors.tertiaryText]
        )
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(
            string:  "Confirm Password",
            attributes: [.foregroundColor: ThemeManager.Colors.tertiaryText]
        )
    }
    
    // MARK:  - Setup UI
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        nameContainerView.addSubview(nameIcon)
        nameContainerView.addSubview(nameTextField)
        contentView.addSubview(nameContainerView)
        emailContainerView.addSubview(emailIcon)
        emailContainerView.addSubview(emailTextField)
        contentView.addSubview(emailContainerView)
        passwordContainerView.addSubview(passwordIcon)
        passwordContainerView.addSubview(passwordTextField)
        passwordContainerView.addSubview(showPasswordButton)
        contentView.addSubview(passwordContainerView)
        confirmPasswordContainerView.addSubview(confirmPasswordIcon)
        confirmPasswordContainerView.addSubview(confirmPasswordTextField)
        confirmPasswordContainerView.addSubview(showConfirmPasswordButton)
        contentView.addSubview(confirmPasswordContainerView)
        contentView.addSubview(signUpButton)
        contentView.addSubview(dividerView)
        contentView.addSubview(appleButton)
        contentView.addSubview(googleButton)
        contentView.addSubview(skipButton)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            backButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            nameContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -24),
            nameContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            nameIcon.leadingAnchor.constraint(equalTo: nameContainerView.leadingAnchor, constant: 20),
            nameIcon.centerYAnchor.constraint(equalTo: nameContainerView.centerYAnchor),
            nameIcon.widthAnchor.constraint(equalToConstant: 24),
            nameIcon.heightAnchor.constraint(equalToConstant: 24),
            
            nameTextField.leadingAnchor.constraint(equalTo: nameIcon.trailingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: nameContainerView.trailingAnchor, constant: -20),
            nameTextField.centerYAnchor.constraint(equalTo: nameContainerView.centerYAnchor),
            
            emailContainerView.topAnchor.constraint(equalTo: nameContainerView.bottomAnchor, constant: 16),
            emailContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -24),
            emailContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            emailIcon.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor, constant:  20),
            emailIcon.centerYAnchor.constraint(equalTo: emailContainerView.centerYAnchor),
            emailIcon.widthAnchor.constraint(equalToConstant: 24),
            emailIcon.heightAnchor.constraint(equalToConstant: 24),
            
            emailTextField.leadingAnchor.constraint(equalTo: emailIcon.trailingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor, constant: -20),
            emailTextField.centerYAnchor.constraint(equalTo: emailContainerView.centerYAnchor),
            
            passwordContainerView.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 16),
            passwordContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            passwordContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            passwordContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            passwordIcon.leadingAnchor.constraint(equalTo: passwordContainerView.leadingAnchor, constant: 20),
            passwordIcon.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            passwordIcon.widthAnchor.constraint(equalToConstant: 24),
            passwordIcon.heightAnchor.constraint(equalToConstant: 24),
            
            passwordTextField.leadingAnchor.constraint(equalTo: passwordIcon.trailingAnchor, constant: 16),
            passwordTextField.trailingAnchor.constraint(equalTo: showPasswordButton.leadingAnchor, constant: -8),
            passwordTextField.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            
            showPasswordButton.trailingAnchor.constraint(equalTo: passwordContainerView.trailingAnchor, constant: -20),
            showPasswordButton.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            showPasswordButton.widthAnchor.constraint(equalToConstant: 32),
            showPasswordButton.heightAnchor.constraint(equalToConstant: 32),
            
            confirmPasswordContainerView.topAnchor.constraint(equalTo: passwordContainerView.bottomAnchor, constant: 16),
            confirmPasswordContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            confirmPasswordContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            confirmPasswordContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            confirmPasswordIcon.leadingAnchor.constraint(equalTo: confirmPasswordContainerView.leadingAnchor, constant:  20),
            confirmPasswordIcon.centerYAnchor.constraint(equalTo: confirmPasswordContainerView.centerYAnchor),
            confirmPasswordIcon.widthAnchor.constraint(equalToConstant: 24),
            confirmPasswordIcon.heightAnchor.constraint(equalToConstant: 24),
            
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: confirmPasswordIcon.trailingAnchor, constant: 16),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: showConfirmPasswordButton.leadingAnchor, constant: -8),
            confirmPasswordTextField.centerYAnchor.constraint(equalTo: confirmPasswordContainerView.centerYAnchor),
            
            showConfirmPasswordButton.trailingAnchor.constraint(equalTo: confirmPasswordContainerView.trailingAnchor, constant: -20),
            showConfirmPasswordButton.centerYAnchor.constraint(equalTo: confirmPasswordContainerView.centerYAnchor),
            showConfirmPasswordButton.widthAnchor.constraint(equalToConstant: 32),
            showConfirmPasswordButton.heightAnchor.constraint(equalToConstant: 32),
            
            signUpButton.topAnchor.constraint(equalTo: confirmPasswordContainerView.bottomAnchor, constant: 24),
            signUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            signUpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            signUpButton.heightAnchor.constraint(equalToConstant: 60),
            
            dividerView.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 24),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            dividerView.heightAnchor.constraint(equalToConstant: 20),
            
            appleButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 24),
            appleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            appleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            appleButton.heightAnchor.constraint(equalToConstant: 60),
            
            googleButton.topAnchor.constraint(equalTo: appleButton.bottomAnchor, constant: 12),
            googleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            googleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            googleButton.heightAnchor.constraint(equalToConstant: 60),
            
            skipButton.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 20),
            skipButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    // MARK: - Setup Actions
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        showConfirmPasswordButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleSignUpTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleSignUpTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
    }

    // MARK: - Keyboard Dismissal
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK:  - Button Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func signUpTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in:  .whitespaces), !name.isEmpty else {
            showAlert(message: "Please enter your name")
            return
        }
        guard let email = emailTextField.text?.trimmingCharacters(in:  .whitespaces), !email.isEmpty else {
            showAlert(message:  "Please enter your email")
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter a password")
            return
        }
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please confirm your password")
            return
        }
        guard password == confirmPassword else {
            showAlert(message: "Passwords do not match")
            return
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await UserDataManager.shared.signUp(email: email, password: password, name: name)
                await MainActor.run {
                    let screenerVC = ScreenerQuestionViewController()
                    self.navigationController?.pushViewController(screenerVC, animated: true)
                }
            } catch {
                await MainActor.run {
                    self.showAlert(message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash. fill" : "eye.fill"
        showPasswordButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }

    @objc private func toggleConfirmPasswordVisibility() {
        confirmPasswordTextField.isSecureTextEntry.toggle()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: . medium)
        let imageName = confirmPasswordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        showConfirmPasswordButton.setImage(UIImage(systemName:  imageName, withConfiguration: config), for: .normal)
    }

    @objc private func appleSignUpTapped() {
        print("Apple sign up tapped")
    }

    @objc private func googleSignUpTapped() {
        print("Google sign up tapped")
    }
    
    @objc private func skipTapped() {
        // Navigate to HomeViewController without authentication
        navigateToHome()
    }
    
    // MARK: - Navigation
    private func navigateToHome() {
        // Create the main tab bar controller
        let tabBarController = UITabBarController()
        
        // Create Home tab
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName:  "house"),
            selectedImage: UIImage(systemName:  "house.fill")
        )
        
        // Create placeholder tabs for other sections
        let milestonesVC = UIViewController()
        milestonesVC.view.backgroundColor = .systemBackground
        milestonesVC.title = "Milestones"
        let milestonesNav = UINavigationController(rootViewController: milestonesVC)
        milestonesNav.tabBarItem = UITabBarItem(
            title: "Milestones",
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill")
        )
        
        let resourcesVC = UIViewController()
        resourcesVC.view.backgroundColor = .systemBackground
        resourcesVC.title = "Resources"
        let resourcesNav = UINavigationController(rootViewController: resourcesVC)
        resourcesNav.tabBarItem = UITabBarItem(
            title: "Resources",
            image: UIImage(systemName: "book"),
            selectedImage: UIImage(systemName: "book.fill")
        )
        
        let communityVC = UIViewController()
        communityVC.view.backgroundColor = . systemBackground
        communityVC.title = "Community"
        let communityNav = UINavigationController(rootViewController: communityVC)
        communityNav.tabBarItem = UITabBarItem(
            title: "Community",
            image: UIImage(systemName:  "person.2"),
            selectedImage: UIImage(systemName: "person.2.fill")
        )
        
        // Add all tabs to tab bar controller
        tabBarController.viewControllers = [homeNav, milestonesNav, resourcesNav, communityNav]
        tabBarController.modalPresentationStyle = .fullScreen
        
        // Present the tab bar controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = tabBarController
            UIView.transition(with: window, duration: 0.3, options: . transitionCrossDissolve, animations: nil)
        }
    }

    // MARK: - Alerts
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
