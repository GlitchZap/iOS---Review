//
//  SessionScheduledViewController.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-16
//

import UIKit

class SessionScheduledViewController: UIViewController {
    
    // MARK: - Properties
    var session: ExpertSession!
    var expert: Expert!
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let successImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .bold)
        imageView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Session Scheduled!"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your session has been confirmed. You'll receive a reminder before it starts."
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sessionDetailsCard: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let expertNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sessionDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = ThemeManager.Colors.primaryPurple
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sessionTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.layer.cornerRadius = 28
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let startChatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Chat", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
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
        loadSessionData()
        registerForThemeChanges()
    }
    
    private func registerForThemeChanges() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                self.updateTheme()
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTheme()
        }
    }
    
    private func updateTheme() {
        view.backgroundColor = ThemeManager.Colors.background
        titleLabel.textColor = ThemeManager.Colors.primaryText
        subtitleLabel.textColor = ThemeManager.Colors.secondaryText
        sessionDetailsCard.backgroundColor = ThemeManager.Colors.cardBackground
        expertNameLabel.textColor = ThemeManager.Colors.primaryText
        sessionDateLabel.textColor = ThemeManager.Colors.primaryPurple
        sessionTimeLabel.textColor = ThemeManager.Colors.secondaryText
        doneButton.backgroundColor = ThemeManager.Colors.primaryPurple
        startChatButton.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        startChatButton.layer.borderColor = ThemeManager.Colors.primaryPurple.cgColor
    }
    
    // MARK: - Setup Navigation Bar
    
    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(successImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(sessionDetailsCard)
        
        sessionDetailsCard.addSubview(expertNameLabel)
        sessionDetailsCard.addSubview(sessionDateLabel)
        sessionDetailsCard.addSubview(sessionTimeLabel)
        
        view.addSubview(startChatButton)
        view.addSubview(doneButton)
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: startChatButton.topAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            successImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            successImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            successImageView.widthAnchor.constraint(equalToConstant: 100),
            successImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: successImageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            sessionDetailsCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            sessionDetailsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            sessionDetailsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            sessionDetailsCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            expertNameLabel.topAnchor.constraint(equalTo: sessionDetailsCard.topAnchor, constant: 24),
            expertNameLabel.leadingAnchor.constraint(equalTo: sessionDetailsCard.leadingAnchor, constant: 20),
            expertNameLabel.trailingAnchor.constraint(equalTo: sessionDetailsCard.trailingAnchor, constant: -20),
            
            sessionDateLabel.topAnchor.constraint(equalTo: expertNameLabel.bottomAnchor, constant: 16),
            sessionDateLabel.leadingAnchor.constraint(equalTo: sessionDetailsCard.leadingAnchor, constant: 20),
            sessionDateLabel.trailingAnchor.constraint(equalTo: sessionDetailsCard.trailingAnchor, constant: -20),
            
            sessionTimeLabel.topAnchor.constraint(equalTo: sessionDateLabel.bottomAnchor, constant: 8),
            sessionTimeLabel.leadingAnchor.constraint(equalTo: sessionDetailsCard.leadingAnchor, constant: 20),
            sessionTimeLabel.trailingAnchor.constraint(equalTo: sessionDetailsCard.trailingAnchor, constant: -20),
            sessionTimeLabel.bottomAnchor.constraint(equalTo: sessionDetailsCard.bottomAnchor, constant: -24),
            
            startChatButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startChatButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startChatButton.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -12),
            startChatButton.heightAnchor.constraint(equalToConstant: 56),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        startChatButton.addTarget(self, action: #selector(startChatButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Load Session Data
    
    private func loadSessionData() {
        expertNameLabel.text = expert.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        sessionDateLabel.text = dateFormatter.string(from: session.sessionDate)
        
        sessionTimeLabel.text = session.timeSlot.displayTime
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func startChatButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let chatVC = ExpertChatViewController()
        chatVC.session = session
        chatVC.expert = expert
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
