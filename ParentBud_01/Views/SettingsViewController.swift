//
//  SettingsViewController.swift
//  ParentBud_01
//
//  Created by Lovansh1245 on 2025-11-17
//  ✅ UPDATED: Fixed text overlapping and spacing issues in child profile cells
//

import UIKit

// MARK: - Main Settings Menu
class SettingsViewController: UIViewController {
    
    private let sections: [(title: String, items: [SettingsItem])] = [
        ("Account", [
            SettingsItem(icon: "person.fill", title: "My Profile", action: .profile),
            SettingsItem(icon: "lock.fill", title: "Password", action: .password)
        ]),
        ("Child Management", [
            SettingsItem(icon: "person.badge.plus.fill", title: "Add Child Profile", action: .addChild),
            SettingsItem(icon: "person.2.fill", title: "Manage Child Profiles", action: .manageChildren)
        ]),
        ("Support", [
            SettingsItem(icon: "envelope.fill", title: "Contact Support", action: .contactSupport),
            SettingsItem(icon: "questionmark.circle.fill", title: "Help & FAQ", action: .helpFAQ),
            SettingsItem(icon: "hand.raised.fill", title: "Privacy Settings", action: .privacy)
        ])
    ]
    
    // MARK: - UI Components
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.backgroundColor = UIColor.systemGray6
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Menu"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .systemGroupedBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(signOutButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: signOutButton.topAnchor, constant: -16),
            
            signOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signOutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            signOutButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func signOutTapped() {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            self?.performSignOut()
        })
        present(alert, animated: true)
    }
    
    private func performSignOut() {
        UserDataManager.shared.logout()
        
        let onboardingVC = OnboardingViewController()
        let navController = UINavigationController(rootViewController: onboardingVC)
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.isHidden = true
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = navController
                window.makeKeyAndVisible()
            }
        }
    }
}

// MARK: - UITableViewDelegate & DataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        let item = sections[indexPath.section].items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].items[indexPath.row]
        navigateTo(action: item.action)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    private func navigateTo(action: SettingsAction) {
        let vc: UIViewController
        
        switch action {
        case .profile:
            vc = MyProfileViewController()
        case .password:
            vc = ChangePasswordViewController()
        case .addChild:
            let screenerVC = ScreenerQuestionViewController()
            screenerVC.isAddingChildFromSettings = true
            screenerVC.startQuestionIndex = 4
            let navController = UINavigationController(rootViewController: screenerVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
            return
        case .manageChildren:
            vc = ManageChildProfilesViewController()
        case .contactSupport:
            vc = ContactSupportViewController()
        case .helpFAQ:
            showComingSoon(title: "Help & FAQ")
            return
        case .privacy:
            showComingSoon(title: "Privacy Settings")
            return
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func showComingSoon(title: String) {
        let alert = UIAlertController(title: title, message: "Coming Soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Settings Cell
class SettingsCell: UITableViewCell {
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ThemeManager.Colors.primaryPurple
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .tertiaryLabel
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .secondarySystemGroupedBackground
        
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(chevronView)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            chevronView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 12),
            chevronView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    func configure(with item: SettingsItem) {
        iconView.image = UIImage(systemName: item.icon)
        titleLabel.text = item.title
    }
}

// MARK: - Supporting Models
struct SettingsItem {
    let icon: String
    let title: String
    let action: SettingsAction
}

enum SettingsAction {
    case profile, password, addChild, manageChildren, contactSupport, helpFAQ, privacy
}

// MARK: - My Profile Screen
class MyProfileViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.2)
        view.layer.cornerRadius = 50
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryPurple
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameField = Self.createTextField(placeholder: "Username", icon: "person.fill")
    private lazy var emailField = Self.createTextField(placeholder: "Email Id", icon: "envelope.fill", keyboardType: .emailAddress)
    private lazy var phoneField = Self.createTextField(placeholder: "Phone Number", icon: "phone.fill", keyboardType: .phonePad)
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "My Profile"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem?.tintColor = ThemeManager.Colors.primaryPurple
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        avatarView.addSubview(avatarLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(roleLabel)
        contentView.addSubview(nameField)
        contentView.addSubview(emailField)
        contentView.addSubview(phoneField)
        contentView.addSubview(saveButton)
        
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
            
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            avatarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            avatarView.heightAnchor.constraint(equalToConstant: 100),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            roleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameField.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 40),
            nameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameField.heightAnchor.constraint(equalToConstant: 56),
            
            emailField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 16),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailField.heightAnchor.constraint(equalToConstant: 56),
            
            phoneField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            phoneField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            phoneField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            phoneField.heightAnchor.constraint(equalToConstant: 56),
            
            saveButton.topAnchor.constraint(equalTo: phoneField.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 56),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func loadUserData() {
        guard let user = UserDataManager.shared.getCurrentUser() else {
            print("⚠️ No user found")
            return
        }
        
        nameLabel.text = user.name
        avatarLabel.text = String(user.name.prefix(1)).uppercased()
        
        if let parentRole = user.screenerData?.parentRole {
            roleLabel.text = parentRole
        } else {
            roleLabel.text = "Parent"
        }
        
        if let textField = nameField.subviews.compactMap({ $0 as? UITextField }).first {
            textField.text = user.name
        }
        
        if let textField = emailField.subviews.compactMap({ $0 as? UITextField }).first {
            textField.text = user.email
        }
        
        if let textField = phoneField.subviews.compactMap({ $0 as? UITextField }).first {
            textField.text = user.phoneNumber ?? ""
        }
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard var user = UserDataManager.shared.getCurrentUser() else { return }
        
        if let textField = nameField.subviews.compactMap({ $0 as? UITextField }).first,
           let name = textField.text, !name.isEmpty {
            user.name = name
        }
        
        if let textField = phoneField.subviews.compactMap({ $0 as? UITextField }).first,
           let phone = textField.text {
            user.phoneNumber = phone.isEmpty ? nil : phone
        }
        
        UserDataManager.shared.updateUser(user)
        
        let alert = UIAlertController(title: "Success", message: "Profile updated successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private static func createTextField(placeholder: String, icon: String, keyboardType: UIKeyboardType = .default) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.separator.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = ThemeManager.Colors.primaryPurple
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .label
        textField.keyboardType = keyboardType
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconView)
        container.addSubview(textField)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            textField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
}

// MARK: - Change Password Screen
class ChangePasswordViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose a strong password and don't reuse it for other accounts."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "You maybe signed out of your accounts on some devices."
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .systemOrange
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var newPasswordField = Self.createPasswordField(placeholder: "New Password", tag: 100)
    
    private let strengthLabel: UILabel = {
        let label = UILabel()
        label.text = "Password strength: Weak"
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let requirementsLabel: UILabel = {
        let label = UILabel()
        label.text = "Use at least 8 characters. Don't use a password from another site or something too obvious like your pet's name."
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmPasswordField = Self.createPasswordField(placeholder: "Confirm new password", tag: 101)
    
    private let changeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPasswordObserver()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Password"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem?.tintColor = ThemeManager.Colors.primaryPurple
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerLabel)
        contentView.addSubview(warningLabel)
        contentView.addSubview(newPasswordField)
        contentView.addSubview(strengthLabel)
        contentView.addSubview(requirementsLabel)
        contentView.addSubview(confirmPasswordField)
        contentView.addSubview(changeButton)
        
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
            
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            warningLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
            warningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            warningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            newPasswordField.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 32),
            newPasswordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            newPasswordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            newPasswordField.heightAnchor.constraint(equalToConstant: 56),
            
            strengthLabel.topAnchor.constraint(equalTo: newPasswordField.bottomAnchor, constant: 8),
            strengthLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            requirementsLabel.topAnchor.constraint(equalTo: strengthLabel.bottomAnchor, constant: 4),
            requirementsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            requirementsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            confirmPasswordField.topAnchor.constraint(equalTo: requirementsLabel.bottomAnchor, constant: 24),
            confirmPasswordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmPasswordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 56),
            
            changeButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 32),
            changeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            changeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            changeButton.heightAnchor.constraint(equalToConstant: 56),
            changeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        
        changeButton.addTarget(self, action: #selector(changePasswordTapped), for: .touchUpInside)
    }
    
    private func setupPasswordObserver() {
        if let textField = newPasswordField.subviews.compactMap({ $0 as? UITextField }).first {
            textField.addTarget(self, action: #selector(passwordChanged(_:)), for: .editingChanged)
        }
    }
    
    @objc private func passwordChanged(_ textField: UITextField) {
        guard let password = textField.text else { return }
        
        let strength = evaluatePasswordStrength(password)
        
        switch strength {
        case .weak:
            strengthLabel.text = "Password strength: Weak"
            strengthLabel.textColor = .systemRed
        case .good:
            strengthLabel.text = "Password strength: Good"
            strengthLabel.textColor = .systemOrange
        case .strong:
            strengthLabel.text = "Password strength: Strong"
            strengthLabel.textColor = .systemGreen
        }
    }
    
    private func evaluatePasswordStrength(_ password: String) -> PasswordStrength {
        if password.count < 6 {
            return .weak
        }
        
        var score = 0
        
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:',.<>?")) != nil { score += 1 }
        
        if score <= 2 {
            return .weak
        } else if score <= 4 {
            return .good
        } else {
            return .strong
        }
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
    }
    
    @objc private func changePasswordTapped() {
        guard let newPasswordTextField = newPasswordField.subviews.compactMap({ $0 as? UITextField }).first,
              let confirmPasswordTextField = confirmPasswordField.subviews.compactMap({ $0 as? UITextField }).first else { return }
        
        guard let newPassword = newPasswordTextField.text, !newPassword.isEmpty else {
            showAlert(title: "Error", message: "Please enter a new password")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please confirm your password")
            return
        }
        
        guard newPassword == confirmPassword else {
            showAlert(title: "Error", message: "Passwords do not match")
            return
        }
        
        guard newPassword.count >= 8 else {
            showAlert(title: "Error", message: "Password must be at least 8 characters")
            return
        }
        
        let alert = UIAlertController(title: "Success", message: "Password changed successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private static func createPasswordField(placeholder: String, tag: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.separator.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .label
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.tag = tag
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let toggleButton = UIButton(type: .system)
        toggleButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        toggleButton.tintColor = .secondaryLabel
        toggleButton.tag = tag + 1000
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.addTarget(nil, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        
        container.addSubview(textField)
        container.addSubview(toggleButton)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: toggleButton.leadingAnchor, constant: -8),
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            toggleButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            toggleButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            toggleButton.widthAnchor.constraint(equalToConstant: 32),
            toggleButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return container
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        let textFieldTag = sender.tag - 1000
        
        if let textField = view.viewWithTag(textFieldTag) as? UITextField {
            textField.isSecureTextEntry.toggle()
            let imageName = textField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
            sender.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
}

enum PasswordStrength {
    case weak, good, strong
}

// MARK: - ✅ FIXED Manage Child Profiles Screen - Text Overlapping Issues
class ManageChildProfilesViewController: UIViewController {
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .systemGroupedBackground
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let noChildrenView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No child profiles found.\nAdd a child profile from the main settings menu."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var childProfiles: [ChildData] = []
    private var activeChildId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadChildProfiles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadChildProfiles()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Manage Child Profiles"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem?.tintColor = ThemeManager.Colors.primaryPurple
        
        view.addSubview(tableView)
        view.addSubview(noChildrenView)
        noChildrenView.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            noChildrenView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            noChildrenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noChildrenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noChildrenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: noChildrenView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: noChildrenView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: noChildrenView.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: noChildrenView.trailingAnchor, constant: -40)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChildProfileCell.self, forCellReuseIdentifier: "ChildProfileCell")
    }
    
    private func loadChildProfiles() {
        guard let user = UserDataManager.shared.getCurrentUser() else {
            print("⚠️ No user found")
            childProfiles = []
            activeChildId = nil
            updateUI()
            return
        }
        
        childProfiles = user.childProfiles
        activeChildId = user.activeChildId
        updateUI()
        print("✅ Loaded \(childProfiles.count) child profiles")
    }
    
    private func updateUI() {
        if !childProfiles.isEmpty {
            tableView.isHidden = false
            noChildrenView.isHidden = true
            tableView.reloadData()
        } else {
            tableView.isHidden = true
            noChildrenView.isHidden = false
        }
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
    }
    
    private func showProfileOptions(for child: ChildData) {
        let alert = UIAlertController(title: child.name, message: "Choose an action", preferredStyle: .actionSheet)
        
        if child.id != activeChildId {
            alert.addAction(UIAlertAction(title: "Switch to this Profile", style: .default) { [weak self] _ in
                self?.switchToProfile(child)
            })
        } else {
            alert.addAction(UIAlertAction(title: "Currently Active Profile", style: .default, handler: nil))
        }
        
        alert.addAction(UIAlertAction(title: "Edit Profile", style: .default) { [weak self] _ in
            self?.editProfile(child)
        })
        
        alert.addAction(UIAlertAction(title: "View Details", style: .default) { [weak self] _ in
            self?.showChildDetails(child)
        })
        
        if childProfiles.count > 1 {
            alert.addAction(UIAlertAction(title: "Delete Profile", style: .destructive) { [weak self] _ in
                self?.confirmDeleteProfile(child)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = tableView.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func switchToProfile(_ child: ChildData) {
        UserDataManager.shared.setActiveChild(childId: child.id)
        
        loadChildProfiles()
        
        let alert = UIAlertController(
            title: "Profile Switched",
            message: "Successfully switched to \(child.name)'s profile.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func confirmDeleteProfile(_ child: ChildData) {
        let alert = UIAlertController(
            title: "Delete Profile",
            message: "Are you sure you want to delete \(child.name)'s profile? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteProfile(child)
        })
        
        present(alert, animated: true)
    }
    
    private func deleteProfile(_ child: ChildData) {
        UserDataManager.shared.removeChildProfile(withId: child.id)
        loadChildProfiles()
        
        let alert = UIAlertController(
            title: "Profile Deleted",
            message: "\(child.name)'s profile has been deleted.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func editProfile(_ child: ChildData) {
        ScreenerDataManager.shared.isAddingNewChild = false
        ScreenerDataManager.shared.editingChildId = child.id
        ScreenerDataManager.shared.loadExistingChildData(childId: child.id)
        
        let screenerVC = ScreenerQuestionViewController()
        screenerVC.isEditingChildFromSettings = true
        screenerVC.startQuestionIndex = 4
        
        let navController = UINavigationController(rootViewController: screenerVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func showChildDetails(_ child: ChildData) {
        var details = "Name: \(child.name)\n"
        
        if let user = UserDataManager.shared.getCurrentUser(),
           let ageGroup = user.screenerData?.childAgeGroup {
            details += "Age Group: \(ageGroup)\n"
        } else if let age = child.age {
            details += "Age: \(age) years\n"
        } else {
            details += "Age: Not specified\n"
        }
        
        if let temperament = child.temperament, !temperament.isEmpty {
            details += "Temperament: \(temperament.joined(separator: ", "))\n"
        }
        
        if let focus = child.currentFocus, !focus.isEmpty {
            details += "Current Focus Areas: \(focus.joined(separator: ", "))"
        }
        
        let alert = UIAlertController(title: "Child Profile Details", message: details, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Table View Extensions
extension ManageChildProfilesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childProfiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChildProfileCell", for: indexPath) as! ChildProfileCell
        let child = childProfiles[indexPath.row]
        let isActive = child.id == activeChildId
        cell.configure(with: child, isActive: isActive)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let child = childProfiles[indexPath.row]
        showProfileOptions(for: child)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85 // ✅ INCREASED height to prevent text overlapping
    }
}

// ✅ FIXED ChildProfileCell - Proper spacing and no text overlapping
class ChildProfileCell: UITableViewCell {
    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.2)
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryPurple
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1 // ✅ FIXED: Ensure single line
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2 // ✅ FIXED: Allow 2 lines with proper spacing
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activeStatusView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let activeLabel: UILabel = {
        let label = UILabel()
        label.text = "Active"
        label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .tertiaryLabel
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .secondarySystemGroupedBackground
        
        avatarView.addSubview(avatarLabel)
        activeStatusView.addSubview(activeLabel)
        
        contentView.addSubview(avatarView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(activeStatusView)
        contentView.addSubview(chevronView)
        
        NSLayoutConstraint.activate([
            // Avatar positioning
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            // ✅ FIXED: Name label positioning with proper spacing
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: activeStatusView.leadingAnchor, constant: -8),
            
            // ✅ FIXED: Detail label positioning with proper spacing
            detailLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            detailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            detailLabel.trailingAnchor.constraint(lessThanOrEqualTo: activeStatusView.leadingAnchor, constant: -8),
            detailLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            
            // ✅ FIXED: Active status positioning
            activeStatusView.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -12),
            activeStatusView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activeStatusView.widthAnchor.constraint(equalToConstant: 55),
            activeStatusView.heightAnchor.constraint(equalToConstant: 20),
            
            activeLabel.centerXAnchor.constraint(equalTo: activeStatusView.centerXAnchor),
            activeLabel.centerYAnchor.constraint(equalTo: activeStatusView.centerYAnchor),
            
            // Chevron positioning
            chevronView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 12),
            chevronView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    // ✅ FIXED: Configure method with proper text handling
    func configure(with child: ChildData, isActive: Bool = false) {
        avatarLabel.text = String(child.name.prefix(1)).uppercased()
        nameLabel.text = child.name
        
        // Show active status
        activeStatusView.isHidden = !isActive
        
        // ✅ FIXED: Improved detail text formatting with proper line breaks
        var detailText = ""
        
        if let childAgeGroup = child.ageGroup {
            detailText = childAgeGroup
        } else if let age = child.age {
            detailText = "\(age) years old"
        } else {
            detailText = "Age not specified"
        }
        
        // Add temperament on new line if available and if there's space
        if let temperament = child.temperament, !temperament.isEmpty {
            let temperamentText = temperament.joined(separator: ", ")
            detailText += "\n\(temperamentText)"
        }
        
        detailLabel.text = detailText
        
        print("✅ Configured cell for \(child.name) with age group: \(child.ageGroup ?? "N/A")")
    }
}

// MARK: - Contact Support Screen
class ContactSupportViewController: UIViewController {
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Have a question or need assistance?\n\nSend us a message below:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let helpLabel: UILabel = {
        let label = UILabel()
        label.text = "What do you need help with?"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Message"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = .label
        tv.backgroundColor = .secondarySystemGroupedBackground
        tv.layer.cornerRadius = 12
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.separator.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Contact Support"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem?.tintColor = ThemeManager.Colors.primaryPurple
        
        view.addSubview(headerLabel)
        view.addSubview(helpLabel)
        view.addSubview(messageLabel)
        view.addSubview(textView)
        view.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            helpLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 32),
            helpLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            messageLabel.topAnchor.constraint(equalTo: helpLabel.bottomAnchor, constant: 24),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            textView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 200),
            
            submitButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 32),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
    }
    
    @objc private func submitTapped() {
        let alert = UIAlertController(title: "Message Sent", message: "Thank you! We'll get back to you soon.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}
