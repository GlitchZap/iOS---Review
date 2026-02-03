//
//  ExpertCell.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 16/11/25.
//

import UIKit

// MARK: - Expert Cell

class ExpertCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.05
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.15)
        view.layer.cornerRadius = 28
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let initialsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = ThemeManager.Colors.primaryPurple
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let specializationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = ThemeManager.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let starIcon: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        imageView.image = UIImage(systemName: "star.fill", withConfiguration: config)
        imageView.tintColor = .systemYellow
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronIcon: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        imageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        imageView.tintColor = ThemeManager.Colors.tertiaryText
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(profileImageView)
        profileImageView.addSubview(initialsLabel)
        containerView.addSubview(contentStack)
        containerView.addSubview(chevronIcon)
        
        // Setup content stack
        contentStack.addArrangedSubview(nameLabel)
        contentStack.addArrangedSubview(specializationLabel)
        contentStack.addArrangedSubview(ratingStack)
        
        // Setup rating stack
        ratingStack.addArrangedSubview(starIcon)
        ratingStack.addArrangedSubview(ratingLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            profileImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 56),
            profileImageView.heightAnchor.constraint(equalToConstant: 56),
            
            initialsLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            contentStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            contentStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            contentStack.trailingAnchor.constraint(equalTo: chevronIcon.leadingAnchor, constant: -12),
            
            chevronIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronIcon.widthAnchor.constraint(equalToConstant: 12),
            chevronIcon.heightAnchor.constraint(equalToConstant: 12),
            
            starIcon.widthAnchor.constraint(equalToConstant: 14),
            starIcon.heightAnchor.constraint(equalToConstant: 14),
            
            containerView.heightAnchor.constraint(equalToConstant: 88)
        ])
    }
    
    func configure(with expert: Expert) {
        initialsLabel.text = expert.initials
        nameLabel.text = expert.name
        specializationLabel.text = expert.specialization
        ratingLabel.text = "\(String(format: "%.1f", expert.rating)) (\(expert.reviewCount))"
        
        updateTheme()
    }
    
    private func updateTheme() {
        containerView.backgroundColor = ThemeManager.Colors.cardBackground
        nameLabel.textColor = ThemeManager.Colors.primaryText
        specializationLabel.textColor = ThemeManager.Colors.secondaryText
        ratingLabel.textColor = ThemeManager.Colors.primaryText
        chevronIcon.tintColor = ThemeManager.Colors.tertiaryText
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.1) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.containerView.alpha = highlighted ? 0.8 : 1.0
        }
    }
}

// MARK: - ✅ Apple-Style Minimal Royal Scheduled Session Cell

class ScheduledSessionCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.04
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // ✅ Minimal Date Container - Apple Style
    private let dateContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = ThemeManager.Colors.primaryPurple
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // ✅ Clean Separator Line
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.15)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // ✅ Expert Info Stack
    private let expertInfoContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let specializationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = ThemeManager.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // ✅ Minimal Status Indicator
    private let statusContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusDot: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirmed"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        
        // Add components to container
        containerView.addSubview(dateContainer)
        dateContainer.addSubview(monthLabel)
        dateContainer.addSubview(dayLabel)
        dateContainer.addSubview(timeLabel)
        
        containerView.addSubview(separatorLine)
        
        containerView.addSubview(expertInfoContainer)
        expertInfoContainer.addSubview(nameLabel)
        expertInfoContainer.addSubview(specializationLabel)
        
        containerView.addSubview(statusContainer)
        statusContainer.addSubview(statusDot)
        statusContainer.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.heightAnchor.constraint(equalToConstant: 96),
            
            // Date Container
            dateContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            dateContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            dateContainer.widthAnchor.constraint(equalToConstant: 60),
            
            monthLabel.topAnchor.constraint(equalTo: dateContainer.topAnchor),
            monthLabel.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor),
            monthLabel.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor),
            
            dayLabel.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 2),
            dayLabel.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor),
            dayLabel.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor),
            
            timeLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 2),
            timeLabel.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: dateContainer.bottomAnchor),
            
            // Separator Line
            separatorLine.leadingAnchor.constraint(equalTo: dateContainer.trailingAnchor, constant: 16),
            separatorLine.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            separatorLine.widthAnchor.constraint(equalToConstant: 1),
            separatorLine.heightAnchor.constraint(equalToConstant: 44),
            
            // Expert Info
            expertInfoContainer.leadingAnchor.constraint(equalTo: separatorLine.trailingAnchor, constant: 16),
            expertInfoContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            expertInfoContainer.trailingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: -12),
            
            nameLabel.topAnchor.constraint(equalTo: expertInfoContainer.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: expertInfoContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: expertInfoContainer.trailingAnchor),
            
            specializationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            specializationLabel.leadingAnchor.constraint(equalTo: expertInfoContainer.leadingAnchor),
            specializationLabel.trailingAnchor.constraint(equalTo: expertInfoContainer.trailingAnchor),
            specializationLabel.bottomAnchor.constraint(equalTo: expertInfoContainer.bottomAnchor),
            
            // Status Container
            statusContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            statusContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            statusDot.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor),
            statusDot.centerYAnchor.constraint(equalTo: statusContainer.centerYAnchor),
            statusDot.widthAnchor.constraint(equalToConstant: 8),
            statusDot.heightAnchor.constraint(equalToConstant: 8),
            
            statusLabel.leadingAnchor.constraint(equalTo: statusDot.trailingAnchor, constant: 8),
            statusLabel.centerYAnchor.constraint(equalTo: statusContainer.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor),
            statusLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor)
        ])
    }
    
    func configure(with session: ExpertSession, expert: Expert) {
        nameLabel.text = expert.name
        specializationLabel.text = expert.specialization
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        monthLabel.text = dateFormatter.string(from: session.sessionDate).uppercased()
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        dayLabel.text = dayFormatter.string(from: session.sessionDate)
        
        timeLabel.text = session.timeSlot.startTime
        
        updateTheme()
    }
    
    private func updateTheme() {
        containerView.backgroundColor = ThemeManager.Colors.cardBackground
        monthLabel.textColor = ThemeManager.Colors.primaryPurple
        dayLabel.textColor = ThemeManager.Colors.primaryText
        timeLabel.textColor = ThemeManager.Colors.secondaryText
        separatorLine.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.15)
        nameLabel.textColor = ThemeManager.Colors.primaryText
        specializationLabel.textColor = ThemeManager.Colors.secondaryText
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.containerView.alpha = highlighted ? 0.8 : 1.0
        }
    }
}

// MARK: - ✅ Premium Chat Thread Cell

class ChatThreadCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.05
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.15)
        view.layer.cornerRadius = 28
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let initialsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = ThemeManager.Colors.primaryPurple
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let onlineStatusView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let topRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = ThemeManager.Colors.primaryText
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = ThemeManager.Colors.tertiaryText
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = ThemeManager.Colors.secondaryText
        label.numberOfLines = 2
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let unreadBadge: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.primaryPurple
        view.layer.cornerRadius = 10
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let unreadLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(profileContainer)
        
        profileContainer.addSubview(profileImageView)
        profileImageView.addSubview(initialsLabel)
        profileContainer.addSubview(onlineStatusView)
        
        containerView.addSubview(contentStack)
        
        // Setup stacks
        topRow.addArrangedSubview(nameLabel)
        topRow.addArrangedSubview(UIView()) // Spacer
        topRow.addArrangedSubview(timeLabel)
        
        messageContainer.addArrangedSubview(lastMessageLabel)
        messageContainer.addArrangedSubview(unreadBadge)
        
        contentStack.addArrangedSubview(topRow)
        contentStack.addArrangedSubview(messageContainer)
        
        unreadBadge.addSubview(unreadLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.heightAnchor.constraint(equalToConstant: 88),
            
            profileContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            profileContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            profileContainer.widthAnchor.constraint(equalToConstant: 56),
            profileContainer.heightAnchor.constraint(equalToConstant: 56),
            
            profileImageView.topAnchor.constraint(equalTo: profileContainer.topAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: profileContainer.leadingAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 56),
            profileImageView.heightAnchor.constraint(equalToConstant: 56),
            
            initialsLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            onlineStatusView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2),
            onlineStatusView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 2),
            onlineStatusView.widthAnchor.constraint(equalToConstant: 12),
            onlineStatusView.heightAnchor.constraint(equalToConstant: 12),
            
            contentStack.leadingAnchor.constraint(equalTo: profileContainer.trailingAnchor, constant: 16),
            contentStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            topRow.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            topRow.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            
            messageContainer.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            messageContainer.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            
            unreadBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
            unreadBadge.heightAnchor.constraint(equalToConstant: 20),
            
            unreadLabel.centerXAnchor.constraint(equalTo: unreadBadge.centerXAnchor),
            unreadLabel.centerYAnchor.constraint(equalTo: unreadBadge.centerYAnchor),
            unreadLabel.leadingAnchor.constraint(greaterThanOrEqualTo: unreadBadge.leadingAnchor, constant: 6),
            unreadLabel.trailingAnchor.constraint(lessThanOrEqualTo: unreadBadge.trailingAnchor, constant: -6)
        ])
        
        // Add pulse animation to online status
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 2.0
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.2
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        onlineStatusView.layer.add(pulseAnimation, forKey: "pulse")
    }
    
    func configure(with thread: ChatThread, expert: Expert) {
        initialsLabel.text = expert.initials
        nameLabel.text = expert.name
        
        if let lastMessage = thread.lastMessage {
            lastMessageLabel.text = lastMessage.message
            
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            timeLabel.text = formatter.localizedString(for: lastMessage.timestamp, relativeTo: Date())
        } else {
            lastMessageLabel.text = "No messages yet"
            timeLabel.text = ""
        }
        
        // Configure unread badge
        if thread.unreadCount > 0 {
            unreadBadge.isHidden = false
            unreadLabel.text = "\(thread.unreadCount)"
            
            // Bold text for unread messages
            nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            lastMessageLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            lastMessageLabel.textColor = ThemeManager.Colors.primaryText
        } else {
            unreadBadge.isHidden = true
            
            // Regular text for read messages
            nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            lastMessageLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            lastMessageLabel.textColor = ThemeManager.Colors.secondaryText
        }
        
        updateTheme()
    }
    
    private func updateTheme() {
        containerView.backgroundColor = ThemeManager.Colors.cardBackground
        nameLabel.textColor = ThemeManager.Colors.primaryText
        timeLabel.textColor = ThemeManager.Colors.tertiaryText
        onlineStatusView.layer.borderColor = ThemeManager.Colors.cardBackground.cgColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.1) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.containerView.alpha = highlighted ? 0.8 : 1.0
        }
    }
}
