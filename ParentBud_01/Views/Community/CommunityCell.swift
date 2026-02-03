//
//  CommunityCell.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-16
//

import UIKit

class CommunityCell: UITableViewCell {

    var onJoinToggle: (() -> Void)?
    private var community: Community?

    // MARK: - UI Components

    private let cardView: UIView = {
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

    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.12)
        view.layer.cornerRadius = 28
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        imageView.preferredSymbolConfiguration = config
        imageView.tintColor = ThemeManager.Colors.primaryPurple
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = ThemeManager.Colors.primaryText
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = ThemeManager.Colors.secondaryText
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let memberCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = ThemeManager.Colors.tertiaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        imageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        imageView.tintColor = ThemeManager.Colors.tertiaryText
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTheme()
        }
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(cardView)
        cardView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        cardView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.addArrangedSubview(memberCountLabel)
        cardView.addSubview(joinButton)
        cardView.addSubview(chevronImageView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            iconContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 56),
            iconContainer.heightAnchor.constraint(equalToConstant: 56),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),

            contentStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 14),
            contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: joinButton.leadingAnchor, constant: -12),
            contentStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            joinButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            joinButton.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -12),
            joinButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 75),
            joinButton.heightAnchor.constraint(equalToConstant: 36),

            chevronImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }

    private func setupActions() {
        joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
    }

    private func updateTheme() {
        cardView.backgroundColor = ThemeManager.Colors.cardBackground
        cardView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.3 : 0.08
        iconContainer.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.12)
        iconImageView.tintColor = ThemeManager.Colors.primaryPurple
        nameLabel.textColor = ThemeManager.Colors.primaryText
        descriptionLabel.textColor = ThemeManager.Colors.secondaryText
        memberCountLabel.textColor = ThemeManager.Colors.tertiaryText
        chevronImageView.tintColor = ThemeManager.Colors.tertiaryText
        updateJoinButtonAppearance()
    }

    // MARK: - Configuration

    func configure(with community: Community) {
        self.community = community

        nameLabel.text = community.name
        descriptionLabel.text = community.description
        memberCountLabel.text = "👥 \(formatMemberCount(community.memberCount))"
        iconImageView.image = UIImage(systemName: community.icon)

        updateJoinButtonAppearance()
    }

    private func updateJoinButtonAppearance() {
        guard let community = community else { return }

        if community.isJoined {
            joinButton.setTitle("Joined", for: .normal)
            joinButton.backgroundColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.12)
            joinButton.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
            joinButton.layer.borderWidth = 0
        } else {
            joinButton.setTitle("Join", for: .normal)
            joinButton.backgroundColor = ThemeManager.Colors.primaryPurple
            joinButton.setTitleColor(.white, for: .normal)
            joinButton.layer.borderWidth = 0
        }
    }

    private func formatMemberCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk+ members", Double(count) / 1000.0)
        } else {
            return "\(count)+ members"
        }
    }

    // MARK: - Actions

    @objc private func joinButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        UIView.animate(withDuration: 0.1, animations: {
            self.joinButton.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.8
            ) {
                self.joinButton.transform = .identity
            }
        }

        onJoinToggle?()
    }
}
