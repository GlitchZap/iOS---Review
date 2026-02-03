//
//  CommunityPostCell.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-16
//

import UIKit

class CommunityPostCell: UITableViewCell {
    
    var onLike: (() -> Void)?
    var onSave: (() -> Void)?
    var onJoinCommunity: (() -> Void)?
    var onComment: (() -> Void)?
    
    private var post: CommunityPost?
    
    // MARK: - UI Components
    
    private let cardView:  UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.08
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 22
        imageView.backgroundColor = UIColor.systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: . semibold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = ThemeManager.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let communityBadge: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        button.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.12)
        button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right:  12)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let joinButton: UIButton = {
        let button = UIButton(type:  .system)
        button.setTitle("Join", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        button.setTitleColor(. white, for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right:  14)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = ThemeManager.Colors.primaryText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = UIColor.systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let actionsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = . clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton(type:  .custom)
        button.backgroundColor = . clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let commentCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type:  .custom)
        button.backgroundColor = . clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var postImageHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder:  NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTheme()
        }
    }
    
    // MARK:  - Setup
    
    private func setupUI() {
        backgroundColor = . clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(headerContainer)
        headerContainer.addSubview(avatarImageView)
        headerContainer.addSubview(authorLabel)
        headerContainer.addSubview(timeLabel)
        headerContainer.addSubview(communityBadge)
        headerContainer.addSubview(joinButton)
        cardView.addSubview(contentLabel)
        cardView.addSubview(postImageView)
        cardView.addSubview(actionsContainer)
        
        actionsContainer.addSubview(likeButton)
        actionsContainer.addSubview(likeCountLabel)
        actionsContainer.addSubview(commentButton)
        actionsContainer.addSubview(commentCountLabel)
        actionsContainer.addSubview(saveButton)
        
        configureActionButtons()
    }
    
    private func configureActionButtons() {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        
        // Like button - gray outline when not liked, purple filled when liked
        let likeImageNormal = UIImage(systemName:  "hand.thumbsup", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        let likeImageSelected = UIImage(systemName: "hand.thumbsup.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        likeButton.setImage(likeImageNormal, for: .normal)
        likeButton.setImage(likeImageSelected, for: .selected)
        
        // Comment button - always gray outline
        let commentImage = UIImage(systemName: "bubble.right", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        commentButton.setImage(commentImage, for:  .normal)
        commentButton.tintColor = ThemeManager.Colors.primaryText
        
        // Save button - gray outline when not saved, purple filled when saved
        let saveImageNormal = UIImage(systemName: "bookmark", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        let saveImageSelected = UIImage(systemName: "bookmark.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        saveButton.setImage(saveImageNormal, for: .normal)
        saveButton.setImage(saveImageSelected, for: .selected)
        
        updateButtonColors()
    }
    
    private func updateButtonColors() {
        // Update like button color based on state
        if likeButton.isSelected {
            likeButton.tintColor = ThemeManager.Colors.primaryPurple
        } else {
            likeButton.tintColor = ThemeManager.Colors.primaryText
        }
        
        // Update save button color based on state
        if saveButton.isSelected {
            saveButton.tintColor = ThemeManager.Colors.primaryPurple
        } else {
            saveButton.tintColor = ThemeManager.Colors.primaryText
        }
    }
    
    private func setupConstraints() {
        postImageHeightConstraint = postImageView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            headerContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            headerContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            headerContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            avatarImageView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44),
            
            authorLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 2),
            authorLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            
            timeLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            
            communityBadge.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 12),
            communityBadge.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            communityBadge.heightAnchor.constraint(equalToConstant: 28),
            
            joinButton.centerYAnchor.constraint(equalTo: communityBadge.centerYAnchor),
            joinButton.leadingAnchor.constraint(equalTo: communityBadge.trailingAnchor, constant:  10),
            joinButton.heightAnchor.constraint(equalToConstant: 28),
            
            contentLabel.topAnchor.constraint(equalTo: communityBadge.bottomAnchor, constant: 12),
            contentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            postImageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 12),
            postImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            postImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            postImageHeightConstraint,
            
            actionsContainer.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 16),
            actionsContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            actionsContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            actionsContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            actionsContainer.heightAnchor.constraint(equalToConstant: 32),
            
            likeButton.leadingAnchor.constraint(equalTo: actionsContainer.leadingAnchor),
            likeButton.centerYAnchor.constraint(equalTo: actionsContainer.centerYAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 32),
            likeButton.heightAnchor.constraint(equalToConstant: 32),
            
            likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 6),
            likeCountLabel.centerYAnchor.constraint(equalTo: actionsContainer.centerYAnchor),
            
            commentButton.leadingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: 20),
            commentButton.centerYAnchor.constraint(equalTo: actionsContainer.centerYAnchor),
            commentButton.widthAnchor.constraint(equalToConstant: 32),
            commentButton.heightAnchor.constraint(equalToConstant: 32),
            
            commentCountLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 6),
            commentCountLabel.centerYAnchor.constraint(equalTo: actionsContainer.centerYAnchor),
            
            saveButton.trailingAnchor.constraint(equalTo: actionsContainer.trailingAnchor),
            saveButton.centerYAnchor.constraint(equalTo: actionsContainer.centerYAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 32),
            saveButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupActions() {
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
    }
    
    private func updateTheme() {
        cardView.backgroundColor = ThemeManager.Colors.cardBackground
        cardView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ?  0.3 : 0.08
        authorLabel.textColor = ThemeManager.Colors.primaryText
        timeLabel.textColor = ThemeManager.Colors.secondaryText
        contentLabel.textColor = ThemeManager.Colors.primaryText
        likeCountLabel.textColor = ThemeManager.Colors.secondaryText
        commentCountLabel.textColor = ThemeManager.Colors.secondaryText
        communityBadge.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        communityBadge.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.12)
        joinButton.backgroundColor = ThemeManager.Colors.primaryPurple
        commentButton.tintColor = ThemeManager.Colors.primaryText
        updateButtonColors()
    }
    
    // MARK: - Configuration
    
    func configure(with post: CommunityPost, showCommunityName: Bool = false) {
        self.post = post
        
        authorLabel.text = post.authorName
        timeLabel.text = post.timeAgoDisplay
        contentLabel.text = post.content
        
        likeButton.isSelected = post.isLiked
        saveButton.isSelected = post.isSaved
        
        updateButtonColors()
        
        likeCountLabel.text = formatCount(post.likeCount)
        commentCountLabel.text = formatCount(post.commentCount)
        
        communityBadge.isHidden = !showCommunityName
        if showCommunityName {
            communityBadge.setTitle("📍 \(post.communityName)", for: .normal)
            
            let community = CommunityDataManager.shared.getCommunity(byId: post.communityId)
            joinButton.isHidden = community?.isJoined ??  false
        }
        
        if let _ = post.imageURL {
            postImageView.isHidden = false
            postImageHeightConstraint.constant = 240
            postImageView.image = UIImage(named: post.imageURL ?? "")
        } else {
            postImageView.isHidden = true
            postImageHeightConstraint.constant = 0
        }
        
        let initials = String(post.authorName.prefix(1))
        avatarImageView.image = createAvatarPlaceholder(with: initials)
    }
    
    private func formatCount(_ count: Int) -> String {
        if count == 0 {
            return ""
        } else if count < 1000 {
            return "\(count)"
        } else {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
    }
    
    private func createAvatarPlaceholder(with initials: String) -> UIImage {
        let size = CGSize(width: 44, height: 44)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            ThemeManager.Colors.primaryPurple.withAlphaComponent(0.2).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: ThemeManager.Colors.primaryPurple,
                .paragraphStyle: paragraphStyle
            ]
            
            let textSize = initials.size(withAttributes: attrs)
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            initials.draw(in: rect, withAttributes: attrs)
        }
    }
    
    // MARK: - Actions
    
    @objc private func likeButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8) {
                self.likeButton.transform = .identity
            }
        }
        
        onLike?()
    }
    
    @objc private func saveButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.saveButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8) {
                self.saveButton.transform = .identity
            }
        }
        
        onSave?()
    }
    
    @objc private func joinButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.2) {
            self.joinButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.joinButton.transform = .identity
            }
        }
        
        onJoinCommunity?()
    }
    
    @objc private func commentButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style:  .light)
        generator.impactOccurred()
        
        onComment?()
    }
}
