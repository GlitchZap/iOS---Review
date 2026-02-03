//
//  LoginViewController.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 07/11/25.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    private var gradientLayer: CAGradientLayer?
    
    private static func resizedImage(named name: String, targetSize: CGSize) -> UIImage? {
        guard let image = UIImage(named: name) else { return nil }
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    // MARK: - UI Components
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = ThemeManager.Colors.primaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
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
        textField.text = "testuser@gmail.com"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
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
        textField.text = "User12345"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let showPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "eye.slash.fill", withConfiguration: config), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
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
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot your Password?", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let dividerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let leftLine = UIView()
        leftLine.backgroundColor = .systemGray4
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        
        let rightLine = UIView()
        rightLine.backgroundColor = .systemGray4
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "or"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
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
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Continue with Apple"
        config.image = UIImage(systemName: "apple.logo")
        config.imagePadding = 8
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        button.configuration = config
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.2
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let googleButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Continue with Google"
        config.image = LoginViewController.resizedImage(named: "GoogleLogo", targetSize: CGSize(width: 28, height: 28))
        config.imagePadding = 8
        config.baseBackgroundColor = .white
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
    
    private let signUpPromptLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
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
    
    // MARK: - Setup Gradient
    private func setupGradient() {
        gradientLayer = ThemeManager.shared.createAuthBackgroundGradient(for: view, traitCollection: traitCollection)
        view.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    // MARK: - Update Theme
    private func updateTheme() {
        gradientLayer?.removeFromSuperlayer()
        setupGradient()
        
        backButton.tintColor = ThemeManager.Colors.primaryText
        titleLabel.textColor = ThemeManager.Colors.primaryText
        
        emailContainerView.backgroundColor = ThemeManager.Colors.inputBackground
        emailTextField.textColor = ThemeManager.Colors.primaryText
        
        passwordContainerView.backgroundColor = ThemeManager.Colors.inputBackground
        passwordTextField.textColor = ThemeManager.Colors.primaryText
        
        loginButton.backgroundColor = ThemeManager.Colors.primaryPurple
        forgotPasswordButton.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        
        updatePlaceholders()
        updateSignUpPrompt()
    }
    
    // MARK: - Update Placeholders
    private func updatePlaceholders() {
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [.foregroundColor: ThemeManager.Colors.tertiaryText]
        )
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [.foregroundColor: ThemeManager.Colors.tertiaryText]
        )
    }
    
    // MARK: - Update Sign Up Prompt
    private func updateSignUpPrompt() {
        let fullText = "Don't have an account?  Sign up"
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: ThemeManager.Colors.secondaryText, range: NSRange(location: 0, length: fullText.count))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: fullText.count))
        
        if let range = fullText.range(of: "Sign up") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: ThemeManager.Colors.primaryPurple, range: nsRange)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .semibold), range: nsRange)
        }
        signUpPromptLabel.attributedText = attributedString
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        
        emailContainerView.addSubview(emailIcon)
        emailContainerView.addSubview(emailTextField)
        view.addSubview(emailContainerView)
        
        passwordContainerView.addSubview(passwordIcon)
        passwordContainerView.addSubview(passwordTextField)
        passwordContainerView.addSubview(showPasswordButton)
        view.addSubview(passwordContainerView)
        
        view.addSubview(loginButton)
        loginButton.addSubview(activityIndicator)
        view.addSubview(forgotPasswordButton)
        view.addSubview(dividerView)
        view.addSubview(appleButton)
        view.addSubview(googleButton)
        view.addSubview(signUpPromptLabel)
        
        updateSignUpPrompt()
        signUpPromptLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(signUpTapped))
        signUpPromptLabel.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
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
            
            passwordContainerView.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 16),
            passwordContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
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
            
            loginButton.topAnchor.constraint(equalTo: passwordContainerView.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 60),
            
            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            dividerView.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 32),
            dividerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            dividerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            dividerView.heightAnchor.constraint(equalToConstant: 20),
            
            appleButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 24),
            appleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            appleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            appleButton.heightAnchor.constraint(equalToConstant: 60),
            
            googleButton.topAnchor.constraint(equalTo: appleButton.bottomAnchor, constant: 12),
            googleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            googleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            googleButton.heightAnchor.constraint(equalToConstant: 60),
            
            signUpPromptLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            signUpPromptLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleLoginTapped), for: .touchUpInside)
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
    
    @objc private func loginTapped() {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespaces), !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email")
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter your password")
            return
        }
        
        loginButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        loginButton.isEnabled = false
        
        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await UserDataManager.shared.signIn(email: email, password: password)
                await MainActor.run {
                    self.loginSuccess()
                }
            } catch {
                // Enhanced error logging for debugging
                print("❌ Login error: \(error)")
                print("❌ Error type: \(type(of: error))")
                print("❌ Localized: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("❌ NSError domain: \(nsError.domain)")
                    print("❌ NSError code: \(nsError.code)")
                    print("❌ NSError userInfo: \(nsError.userInfo)")
                    if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                        print("❌ Underlying error: \(underlying)")
                    }
                }
                
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.loginButton.setTitle("Login", for: .normal)
                    self.loginButton.isEnabled = true
                    self.showAlert(title: "Login Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Login Success
    private func loginSuccess() {
        activityIndicator.stopAnimating()
        loginButton.setTitle("Login", for: .normal)
        loginButton.isEnabled = true
        
        guard let currentUser = UserDataManager.shared.getCurrentUser() else { return }
        
        print("✅ Login successful: \(currentUser.name)")
        UserDataManager.shared.printAllUsers()
        
        // For login, always navigate to main app - screener is only for new signups
        let mainTabBar = MainTabBarController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = mainTabBar
                window.makeKeyAndVisible()
            }
        }
    }
    
    @objc private func forgotPasswordTapped() {
        let forgotPasswordVC = ForgotPasswordViewController()
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        showPasswordButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
    
    @objc private func appleLoginTapped() {
        showAlert(title: "Apple Login", message: "Apple Sign-In will be implemented soon!")
    }
    
    @objc private func googleLoginTapped() {
        showAlert(title: "Google Login", message: "Google Sign-In will be implemented soon!")
    }
    
    @objc private func signUpTapped() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    // MARK: - Show Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
