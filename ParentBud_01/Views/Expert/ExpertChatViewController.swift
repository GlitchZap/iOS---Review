//
//  ExpertChatViewController.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 16/11/25.
//

import UIKit

class ExpertChatViewController: UIViewController {
    
    // MARK: - Properties
    var session: ExpertSession!
    var expert: Expert!
    
    private let dataManager = ExpertsDataManager.shared
    private let userDataManager = UserDataManager.shared
    
    private var chatThread: ChatThread?
    private var messages: [ChatMessage] = []
    
    private var typingTimer: Timer?
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = ThemeManager.Colors.background
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let typingIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 20
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let typingLabel: UILabel = {
        let label = UILabel()
        label.text = "Expert is typing..."
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textColor = ThemeManager.Colors.primaryText
        textView.backgroundColor = ThemeManager.Colors.background
        textView.layer.cornerRadius = 20
        textView.layer.borderWidth = 1.5
        textView.layer.borderColor = ThemeManager.Colors.secondaryText.withAlphaComponent(0.3).cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 48)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Type your message..."
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = ThemeManager.Colors.tertiaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        button.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = ThemeManager.Colors.primaryPurple
        button.alpha = 0.5
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    private var messageTextViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupActions()
        setupKeyboardObservers()
        loadChatData()
        simulateExpertMessages()
        registerForThemeChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        markMessagesAsRead()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        tableView.backgroundColor = ThemeManager.Colors.background
        typingIndicatorView.backgroundColor = ThemeManager.Colors.cardBackground
        typingLabel.textColor = ThemeManager.Colors.secondaryText
        inputContainerView.backgroundColor = ThemeManager.Colors.cardBackground
        messageTextView.textColor = ThemeManager.Colors.primaryText
        messageTextView.backgroundColor = ThemeManager.Colors.background
        messageTextView.layer.borderColor = ThemeManager.Colors.secondaryText.withAlphaComponent(0.3).cgColor
        placeholderLabel.textColor = ThemeManager.Colors.tertiaryText
        sendButton.tintColor = ThemeManager.Colors.primaryPurple
        
        tableView.reloadData()
    }
    
    // MARK: - Setup Navigation Bar
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Custom title view with expert info
        let titleContainer = UIView()
        titleContainer.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        
        let imageView = UIView()
        imageView.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.15)
        imageView.layer.cornerRadius = 18
        imageView.frame = CGRect(x: 0, y: 2, width: 36, height: 36)
        
        let initialsLabel = UILabel()
        initialsLabel.text = expert.initials
        initialsLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        initialsLabel.textColor = ThemeManager.Colors.primaryPurple
        initialsLabel.textAlignment = .center
        initialsLabel.frame = imageView.bounds
        imageView.addSubview(initialsLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = expert.name
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = ThemeManager.Colors.primaryText
        nameLabel.frame = CGRect(x: 44, y: 4, width: 150, height: 18)
        
        let statusLabel = UILabel()
        statusLabel.text = "Online"
        statusLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        statusLabel.textColor = .systemGreen
        statusLabel.frame = CGRect(x: 44, y: 22, width: 150, height: 16)
        
        titleContainer.addSubview(imageView)
        titleContainer.addSubview(nameLabel)
        titleContainer.addSubview(statusLabel)
        
        navigationItem.titleView = titleContainer
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        backButton.tintColor = ThemeManager.Colors.primaryPurple
        navigationItem.leftBarButtonItem = backButton
        
        let infoButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(infoTapped))
        infoButton.tintColor = ThemeManager.Colors.primaryPurple
        navigationItem.rightBarButtonItem = infoButton
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func infoTapped() {
        let bioVC = ExpertBioViewController()
        bioVC.expert = expert
        navigationController?.pushViewController(bioVC, animated: true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(tableView)
        view.addSubview(typingIndicatorView)
        typingIndicatorView.addSubview(typingLabel)
        view.addSubview(inputContainerView)
        inputContainerView.addSubview(messageTextView)
        messageTextView.addSubview(placeholderLabel)
        inputContainerView.addSubview(sendButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        messageTextView.delegate = self
        
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        inputContainerBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        messageTextViewHeightConstraint = messageTextView.heightAnchor.constraint(equalToConstant: 44)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            
            typingIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typingIndicatorView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -8),
            typingIndicatorView.heightAnchor.constraint(equalToConstant: 40),
            
            typingLabel.topAnchor.constraint(equalTo: typingIndicatorView.topAnchor, constant: 10),
            typingLabel.leadingAnchor.constraint(equalTo: typingIndicatorView.leadingAnchor, constant: 16),
            typingLabel.trailingAnchor.constraint(equalTo: typingIndicatorView.trailingAnchor, constant: -16),
            typingLabel.bottomAnchor.constraint(equalTo: typingIndicatorView.bottomAnchor, constant: -10),
            
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerBottomConstraint,
            
            messageTextView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 12),
            messageTextView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
            messageTextView.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16),
            messageTextView.bottomAnchor.constraint(equalTo: inputContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            messageTextViewHeightConstraint,
            
            placeholderLabel.topAnchor.constraint(equalTo: messageTextView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: messageTextView.leadingAnchor, constant: 17),
            
            sendButton.trailingAnchor.constraint(equalTo: messageTextView.trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: -8),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Keyboard Observers
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        inputContainerBottomConstraint.constant = -keyboardHeight
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        
        scrollToBottom(animated: true)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        inputContainerBottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Load Data
    
    private func loadChatData() {
        chatThread = dataManager.getChatThread(for: session.id)
        messages = chatThread?.messages ?? []
        
        tableView.reloadData()
        scrollToBottom(animated: false)
    }
    
    private func markMessagesAsRead() {
        dataManager.markMessagesAsRead(sessionId: session.id)
        chatThread = dataManager.getChatThread(for: session.id)
    }
    
    // MARK: - Send Message
    
    @objc private func sendButtonTapped() {
        guard let messageText = messageTextView.text, !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let currentUser = userDataManager.getCurrentUser() else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Send message
        dataManager.sendMessage(
            sessionId: session.id,
            senderId: currentUser.userId,
            senderType: .user,
            message: messageText
        )
        
        // Clear text view
        messageTextView.text = ""
        placeholderLabel.isHidden = false
        updateSendButton()
        adjustTextViewHeight()
        
        // Reload data
        loadChatData()
        
        // Simulate expert typing and response
        simulateExpertTyping()
    }
    
    private func updateSendButton() {
        let hasText = !(messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        
        UIView.animate(withDuration: 0.2) {
            self.sendButton.alpha = hasText ? 1.0 : 0.5
            self.sendButton.isEnabled = hasText
        }
    }
    
    private func adjustTextViewHeight() {
        let size = messageTextView.sizeThatFits(CGSize(width: messageTextView.frame.width, height: .infinity))
        let newHeight = min(max(size.height, 44), 120)
        
        messageTextViewHeightConstraint.constant = newHeight
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func scrollToBottom(animated: Bool) {
        guard messages.count > 0 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let lastIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
        }
    }
    
    // MARK: - Simulate Expert Messages
    
    private func simulateExpertMessages() {
        // Add some initial messages if the chat is new
        if messages.isEmpty {
            let welcomeMessages = [
                "Hello! I'm \(expert.name). Thank you for scheduling this session with me.",
                "I'm here to help you with any concerns or questions you have about your child's development.",
                "Feel free to share what's on your mind, and we'll work through it together. 😊"
            ]
            
            for (index, message) in welcomeMessages.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 2.0) {
                    self.dataManager.sendMessage(
                        sessionId: self.session.id,
                        senderId: self.expert.id.uuidString,
                        senderType: .expert,
                        message: message
                    )
                    self.loadChatData()
                }
            }
        }
    }
    
    private func simulateExpertTyping() {
        // Show typing indicator
        showTypingIndicator()
        
        // Simulate response after 3-5 seconds
        let responseDelay = Double.random(in: 3.0...5.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + responseDelay) {
            self.hideTypingIndicator()
            
            let responses = [
                "That's a great question! Let me help you with that.",
                "I understand your concern. Here's what I suggest...",
                "Thank you for sharing that. Based on what you've told me, I recommend...",
                "That's completely normal at this age. Here's some advice...",
                "I'm glad you brought this up. Let's explore this together.",
                "That sounds like a positive step forward! Keep up the great work.",
                "I appreciate you being so open. Let's work on this together."
            ]
            
            let randomResponse = responses.randomElement() ?? responses[0]
            
            self.dataManager.sendMessage(
                sessionId: self.session.id,
                senderId: self.expert.id.uuidString,
                senderType: .expert,
                message: randomResponse
            )
            
            self.loadChatData()
        }
    }
    
    private func showTypingIndicator() {
        UIView.animate(withDuration: 0.3) {
            self.typingIndicatorView.alpha = 1.0
        }
        scrollToBottom(animated: true)
    }
    
    private func hideTypingIndicator() {
        UIView.animate(withDuration: 0.3) {
            self.typingIndicatorView.alpha = 0.0
        }
    }
}

// MARK: - UITableView DataSource & Delegate

extension ExpertChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        cell.configure(with: message, expertInitials: expert.initials)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - UITextViewDelegate

extension ExpertChatViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        updateSendButton()
        adjustTextViewHeight()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Limit to 1000 characters
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 1000
    }
}

// MARK: - Chat Message Cell

class ChatMessageCell: UITableViewCell {
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = ThemeManager.Colors.tertiaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expertImageView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.15)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let expertInitialsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryPurple
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var bubbleLeadingConstraint: NSLayoutConstraint!
    private var bubbleTrailingConstraint: NSLayoutConstraint!
    private var expertImageLeadingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Colors will be updated when configure is called again
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(expertImageView)
        expertImageView.addSubview(expertInitialsLabel)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(timestampLabel)
        
        bubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        bubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        expertImageLeadingConstraint = expertImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            expertImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            expertImageLeadingConstraint,
            expertImageView.widthAnchor.constraint(equalToConstant: 32),
            expertImageView.heightAnchor.constraint(equalToConstant: 32),
            
            expertInitialsLabel.centerXAnchor.constraint(equalTo: expertImageView.centerXAnchor),
            expertInitialsLabel.centerYAnchor.constraint(equalTo: expertImageView.centerYAnchor),
            
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 280),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
            
            timestampLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 4),
            timestampLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 4),
            timestampLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -4),
            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with message: ChatMessage, expertInitials: String) {
        messageLabel.text = message.message
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timestampLabel.text = formatter.string(from: message.timestamp)
        
        // Deactivate previous constraints
        bubbleLeadingConstraint.isActive = false
        bubbleTrailingConstraint.isActive = false
        
        if message.senderType == .user {
            // User message (right side)
            bubbleView.backgroundColor = ThemeManager.Colors.primaryPurple
            messageLabel.textColor = .white
            timestampLabel.textAlignment = .right
            expertImageView.isHidden = true
            
            bubbleTrailingConstraint.constant = -16
            bubbleTrailingConstraint.isActive = true
            
        } else {
            // Expert message (left side)
            bubbleView.backgroundColor = ThemeManager.Colors.cardBackground
            messageLabel.textColor = ThemeManager.Colors.primaryText
            timestampLabel.textAlignment = .left
            expertImageView.isHidden = false
            expertInitialsLabel.text = expertInitials
            
            bubbleLeadingConstraint.constant = 56
            bubbleLeadingConstraint.isActive = true
        }
    }
}
