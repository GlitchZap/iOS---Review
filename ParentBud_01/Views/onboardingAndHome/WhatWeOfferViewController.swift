//
//  WhatWeOfferViewController.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 07/11/25.
//

import UIKit

class WhatWeOfferViewController: UIViewController {
    
    // MARK: - Properties
    private var gradientLayer: CAGradientLayer?
    private var currentIndex = 0
    private let features = [
        FeatureData(title: "Find Your Flow",
                   subtitle: "Instant coaching for today's challenges with step-by-step plans",
                   imageName: "flow_icon"),
        FeatureData(title: "Care Cards",
                   subtitle: "Get Guided insights in bite-sized Articles",
                   imageName: "care_cards_icon"),
        FeatureData(title: "Community",
                   subtitle: "Join a supportive community of parents sharing experiences",
                   imageName: "community_icon"),
        FeatureData(title: "Expert Access",
                   subtitle: "Connect with certified experts for personalized guidance",
                   imageName: "expert_icon")
        
    ]
    
    // MARK: - UI Elements
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "What We Offer"
        if let customFont = UIFont(name: "SF-Pro-Display-Bold", size: 38) {
            label.font = customFont
        } else {
            label.font = .systemFont(ofSize: 38, weight: .bold)
        }
        label.textColor = ThemeManager.Colors.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Four Pillars of support for your\nparenting journey"
        label.numberOfLines = 0
        label.textAlignment = .center
        if let customFont = UIFont(name: "SF-Pro-Display-Regular", size: 16) {
            label.font = customFont
        } else {
            label.font = .systemFont(ofSize: 16)
        }
        label.textColor = ThemeManager.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        if let customFont = UIFont(name: "SF-Pro-Display-Regular", size: 16) {
            button.titleLabel?.font = customFont
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        collection.isPagingEnabled = false
        collection.showsHorizontalScrollIndicator = false
        collection.decelerationRate = .fast
        collection.contentInsetAdjustmentBehavior = .never
        collection.register(FeatureCardCell.self, forCellWithReuseIdentifier: "FeatureCardCell")
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 4
        control.currentPage = 0
        control.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        control.currentPageIndicatorTintColor = ThemeManager.Colors.primaryPurple
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupUI()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ThemeManager.shared.updateGradientFrame(gradientLayer!, for: view)
        updateCollectionViewLayout()
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
        headerLabel.textColor = ThemeManager.Colors.primaryText
        subtitleLabel.textColor = ThemeManager.Colors.secondaryText
        skipButton.setTitleColor(ThemeManager.Colors.primaryPurple, for: .normal)
        pageControl.currentPageIndicatorTintColor = ThemeManager.Colors.primaryPurple
        
        // Reload collection view
        collectionView.reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(skipButton)
        view.addSubview(headerLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
    }
    
    private func updateCollectionViewLayout() {
        let cardWidth = view.bounds.width - 80
        let cardHeight = cardWidth * 1.3
        
        collectionViewLayout.itemSize = CGSize(width: cardWidth, height: cardHeight)
        let horizontalInset = (view.bounds.width - cardWidth) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
    
    // MARK: - Actions
    @objc private func skipButtonTapped() {
        print("✅ Skip button tapped")
        navigateToLogin()
    }
    
    private func navigateToLogin() {
        print("✅ Navigating to Login from WhatWeOffer")
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension WhatWeOfferViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeatureCardCell", for: indexPath) as! FeatureCardCell
        let isLastCard = indexPath.item == features.count - 1
        cell.configure(with: features[indexPath.item], isLastCard: isLastCard)
        cell.delegate = self
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension WhatWeOfferViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let cardWidth = view.bounds.width - 80
        let spacing: CGFloat = 20
        let offsetX = scrollView.contentOffset.x + scrollView.contentInset.left
        let page = round(offsetX / (cardWidth + spacing))
        pageControl.currentPage = max(0, min(Int(page), features.count - 1))
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cardWidth = view.bounds.width - 80
        let spacing: CGFloat = 20
        let pageWidth = cardWidth + spacing
        
        let offsetX = targetContentOffset.pointee.x + scrollView.contentInset.left
        let page = round(offsetX / pageWidth)
        let finalOffset = (page * pageWidth) - scrollView.contentInset.left
        
        let maxOffset = pageWidth * CGFloat(features.count - 1) - scrollView.contentInset.left
        targetContentOffset.pointee.x = min(finalOffset, maxOffset)
    }
}

// MARK: - Feature Card Cell Delegate
protocol FeatureCardCellDelegate: AnyObject {
    func didTapNextButton(in cell: FeatureCardCell)
}

extension WhatWeOfferViewController: FeatureCardCellDelegate {
    func didTapNextButton(in cell: FeatureCardCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            print("❌ Could not find indexPath for cell")
            return
        }
        
        print("✅ Next button tapped on card \(indexPath.item + 1)")
        
        if indexPath.item == features.count - 1 {
            print("✅ Last card detected - Navigating to Login")
            navigateToLogin()
        } else {
            print("✅ Scrolling to next card")
            let nextIndexPath = IndexPath(item: indexPath.item + 1, section: 0)
            collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

// MARK: - Feature Card Cell
class FeatureCardCell: UICollectionViewCell {
    weak var delegate: FeatureCardCellDelegate?
    private var isLastCard = false
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        if let customFont = UIFont(name: "SF-Pro-Display-Bold", size: 28) {
            label.font = customFont
        } else {
            label.font = .systemFont(ofSize: 28, weight: .bold)
        }
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        if let customFont = UIFont(name: "SF-Pro-Display-Regular", size: 17) {
            label.font = customFont
        } else {
            label.font = .systemFont(ofSize: 17)
        }
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("NEXT", for: .normal)
        button.backgroundColor = ThemeManager.Colors.primaryPurple
        button.layer.cornerRadius = 28
        button.layer.shadowColor = ThemeManager.Colors.primaryPurple.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 12
        button.layer.shadowOpacity = 0.5
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            containerView.backgroundColor = ThemeManager.Colors.cardBackground
            titleLabel.textColor = ThemeManager.Colors.primaryText
            subtitleLabel.textColor = ThemeManager.Colors.secondaryText
            nextButton.backgroundColor = ThemeManager.Colors.primaryPurple
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(imageView)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(nextButton)
        
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 140),
            imageView.heightAnchor.constraint(equalToConstant: 140),
            
            subtitleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            nextButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            nextButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            nextButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.9),
            nextButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    func configure(with feature: FeatureData, isLastCard: Bool) {
        self.isLastCard = isLastCard
        titleLabel.text = feature.title
        subtitleLabel.text = feature.subtitle
        imageView.image = UIImage(named: feature.imageName)
        
        // Update colors for current theme
        containerView.backgroundColor = ThemeManager.Colors.cardBackground
        titleLabel.textColor = ThemeManager.Colors.primaryText
        subtitleLabel.textColor = ThemeManager.Colors.secondaryText
        nextButton.backgroundColor = ThemeManager.Colors.primaryPurple
        nextButton.setTitle("NEXT", for: .normal)
    }
    
    @objc private func nextButtonTapped() {
        print("✅ Cell next button tapped, isLastCard: \(isLastCard)")
        delegate?.didTapNextButton(in: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        isLastCard = false
    }
}

// MARK: - Feature Data
struct FeatureData {
    let title: String
    let subtitle: String
    let imageName: String
}
