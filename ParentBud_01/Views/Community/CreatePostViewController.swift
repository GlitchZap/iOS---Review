//
//  CreatePostViewController.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-16
//

import UIKit

class CreatePostViewController: UIViewController {
    
    private let dataManager = CommunityDataManager.shared
    var currentCommunity: Community?
    var onPostCreated: (() -> Void)?
    
    private var selectedCommunity: Community?
    private var selectedImage: UIImage?
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        imageView.backgroundColor = UIColor.systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.textColor = ThemeManager.Colors.primaryText
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Share your thoughts..."
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = ThemeManager.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let communitySelectionCard: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1.5
        view.layer.borderColor = ThemeManager.Colors.primaryPurple.withAlphaComponent(0.3).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let communityButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let communityChevron: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        imageView.image = UIImage(systemName: "chevron.down", withConfiguration: config)
        imageView.tintColor = ThemeManager.Colors.primaryPurple
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let imagePreviewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let imagePreview: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let removeImageButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let toolbarView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let photoButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        button.setImage(UIImage(systemName: "photo", withConfiguration: config), for: .normal)
        button.tintColor = ThemeManager.Colors.primaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        button.setImage(UIImage(systemName: "camera", withConfiguration: config), for: .normal)
        button.tintColor = ThemeManager.Colors.primaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var imagePreviewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupKeyboardObservers()
        configureNavigationBar()
        
        if let community = currentCommunity {
            selectedCommunity = community
            updateCommunityButton()
        }
        
        setupUserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTheme()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(avatarImageView)
        headerView.addSubview(usernameLabel)
        
        contentView.addSubview(textView)
        contentView.addSubview(placeholderLabel)
        contentView.addSubview(communitySelectionCard)
        communitySelectionCard.addSubview(communityButton)
        communitySelectionCard.addSubview(communityChevron)
        contentView.addSubview(imagePreviewContainer)
        imagePreviewContainer.addSubview(imagePreview)
        imagePreviewContainer.addSubview(removeImageButton)
        
        view.addSubview(toolbarView)
        toolbarView.addSubview(photoButton)
        toolbarView.addSubview(cameraButton)
        
        textView.delegate = self
    }
    
    private func setupConstraints() {
        imagePreviewHeightConstraint = imagePreviewContainer.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            avatarImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            avatarImageView.heightAnchor.constraint(equalToConstant: 48),
            avatarImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            usernameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 14),
            usernameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            
            textView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            
            communitySelectionCard.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            communitySelectionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            communitySelectionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            communitySelectionCard.heightAnchor.constraint(equalToConstant: 52),
            
            communityButton.leadingAnchor.constraint(equalTo: communitySelectionCard.leadingAnchor, constant: 16),
            communityButton.centerYAnchor.constraint(equalTo: communitySelectionCard.centerYAnchor),
            communityButton.trailingAnchor.constraint(equalTo: communityChevron.leadingAnchor, constant: -8),
            
            communityChevron.trailingAnchor.constraint(equalTo: communitySelectionCard.trailingAnchor, constant: -16),
            communityChevron.centerYAnchor.constraint(equalTo: communitySelectionCard.centerYAnchor),
            communityChevron.widthAnchor.constraint(equalToConstant: 16),
            communityChevron.heightAnchor.constraint(equalToConstant: 16),
            
            imagePreviewContainer.topAnchor.constraint(equalTo: communitySelectionCard.bottomAnchor, constant: 20),
            imagePreviewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imagePreviewContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imagePreviewHeightConstraint,
            imagePreviewContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            imagePreview.topAnchor.constraint(equalTo: imagePreviewContainer.topAnchor),
            imagePreview.leadingAnchor.constraint(equalTo: imagePreviewContainer.leadingAnchor),
            imagePreview.trailingAnchor.constraint(equalTo: imagePreviewContainer.trailingAnchor),
            imagePreview.bottomAnchor.constraint(equalTo: imagePreviewContainer.bottomAnchor),
            
            removeImageButton.topAnchor.constraint(equalTo: imagePreviewContainer.topAnchor, constant: 12),
            removeImageButton.trailingAnchor.constraint(equalTo: imagePreviewContainer.trailingAnchor, constant: -12),
            removeImageButton.widthAnchor.constraint(equalToConstant: 32),
            removeImageButton.heightAnchor.constraint(equalToConstant: 32),
            
            toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbarView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 64),
            
            photoButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 20),
            photoButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            photoButton.widthAnchor.constraint(equalToConstant: 44),
            photoButton.heightAnchor.constraint(equalToConstant: 44),
            
            cameraButton.leadingAnchor.constraint(equalTo: photoButton.trailingAnchor, constant: 16),
            cameraButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 44),
            cameraButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Actions / Helpers
    
    private func setupActions() {
        communityButton.addTarget(self, action: #selector(selectCommunityTapped), for: .touchUpInside)
        photoButton.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        removeImageButton.addTarget(self, action: #selector(removeImageTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCommunityTapped))
        communitySelectionCard.addGestureRecognizer(tapGesture)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureNavigationBar() {
        title = "Create Post"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .done,
            target: self,
            action: #selector(postButtonTapped)
        )
    }
    
    private func setupUserInfo() {
        if let user = UserDataManager.shared.getCurrentUser() {
            usernameLabel.text = user.name
            avatarImageView.image = createAvatarPlaceholder(with: String(user.name.prefix(1)))
        }
    }
    
    private func createAvatarPlaceholder(with initials: String) -> UIImage {
        let size = CGSize(width: 48, height: 48)
        return UIGraphicsImageRenderer(size: size).image { context in
            ThemeManager.Colors.primaryPurple.withAlphaComponent(0.2).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                .foregroundColor: ThemeManager.Colors.primaryPurple
            ]
            
            let textSize = initials.size(withAttributes: attrs)
            let rect = CGRect(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2, width: textSize.width, height: textSize.height)
            initials.draw(in: rect, withAttributes: attrs)
        }
    }
    
    private func updateTheme() {}
    
    private func updateCommunityButton() {
        communityButton.setTitle(selectedCommunity != nil ? "📍 \(selectedCommunity!.name)" : "Select a community", for: .normal)
    }
    
    // MARK: - User Actions
    
    @objc private func closeButtonTapped() { dismiss(animated: true) }
    
    @objc private func postButtonTapped() {
        guard let community = selectedCommunity,
              !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let user = UserDataManager.shared.getCurrentUser()
        let post = CommunityPost(
            authorName: user?.name ?? "Anonymous",
            communityId: community.id,
            communityName: community.name,
            content: textView.text.trimmingCharacters(in: .whitespacesAndNewlines),
            imageURL: selectedImage != nil ? "user_post_image" : nil
        )
        
        dataManager.addPost(post)
        onPostCreated?()
        dismiss(animated: true)
    }
    
    @objc private func selectCommunityTapped() {
        let pickerVC = CommunityPickerViewController()
        pickerVC.onCommunitySelected = { [weak self] community in
            self?.selectedCommunity = community
            self?.updateCommunityButton()
        }
        present(pickerVC, animated: true)
    }
    
    @objc private func photoButtonTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc private func cameraButtonTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc private func removeImageTapped() {
        selectedImage = nil
        imagePreview.image = nil
        imagePreviewHeightConstraint.constant = 0
        imagePreviewContainer.isHidden = true
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = frame.height
        scrollView.scrollIndicatorInsets.bottom = frame.height
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}

// MARK: - Delegates

extension CreatePostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            selectedImage = image
            imagePreview.image = image
            imagePreviewContainer.isHidden = false
            imagePreviewHeightConstraint.constant = 240
        }
    }
}
