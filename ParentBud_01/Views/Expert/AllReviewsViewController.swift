//
//  AllReviewsViewController.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 16/11/25.
//

import UIKit

class AllReviewsViewController: UIViewController {
    
    // MARK: - Properties
    var expert: Expert!
    var reviews: [ExpertReview] = []
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = ThemeManager.Colors.background
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Colors.cardBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let overallRatingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = ThemeManager.Colors.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let totalReviewsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        loadData()
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
        tableView.backgroundColor = ThemeManager.Colors.background
        headerView.backgroundColor = ThemeManager.Colors.cardBackground
        overallRatingLabel.textColor = ThemeManager.Colors.primaryText
        totalReviewsLabel.textColor = ThemeManager.Colors.secondaryText
        
        tableView.reloadData()
    }
    
    // MARK: - Setup Navigation Bar
    
    private func setupNavigationBar() {
        title = "All Reviews"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        backButton.tintColor = ThemeManager.Colors.primaryPurple
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.Colors.background
        
        view.addSubview(headerView)
        headerView.addSubview(overallRatingLabel)
        headerView.addSubview(starsStackView)
        headerView.addSubview(totalReviewsLabel)
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ReviewTableCell.self, forCellReuseIdentifier: "ReviewTableCell")
        
        // Create star images
        for _ in 0..<5 {
            let starImageView = UIImageView()
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
            starImageView.image = UIImage(systemName: "star.fill", withConfiguration: config)
            starImageView.tintColor = .systemYellow
            starImageView.contentMode = .scaleAspectFit
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            starsStackView.addArrangedSubview(starImageView)
        }
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 160),
            
            overallRatingLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            overallRatingLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            starsStackView.topAnchor.constraint(equalTo: overallRatingLabel.bottomAnchor, constant: 12),
            starsStackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            totalReviewsLabel.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 8),
            totalReviewsLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Load Data
    
    private func loadData() {
        overallRatingLabel.text = String(format: "%.1f", expert.rating)
        totalReviewsLabel.text = "Based on \(reviews.count) reviews"
        
        updateStars(rating: expert.rating)
        tableView.reloadData()
    }
    
    private func updateStars(rating: Double) {
        let fullStars = Int(rating)
        let hasHalfStar = rating - Double(fullStars) >= 0.5
        
        for (index, view) in starsStackView.arrangedSubviews.enumerated() {
            guard let starImageView = view as? UIImageView else { continue }
            
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
            
            if index < fullStars {
                starImageView.image = UIImage(systemName: "star.fill", withConfiguration: config)
                starImageView.tintColor = .systemYellow
            } else if index == fullStars && hasHalfStar {
                starImageView.image = UIImage(systemName: "star.leadinghalf.filled", withConfiguration: config)
                starImageView.tintColor = .systemYellow
            } else {
                starImageView.image = UIImage(systemName: "star", withConfiguration: config)
                starImageView.tintColor = .systemYellow.withAlphaComponent(0.3)
            }
        }
    }
}

// MARK: - UITableView DataSource & Delegate

extension AllReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableCell", for: indexPath) as! ReviewTableCell
        let review = reviews[indexPath.row]
        cell.configure(with: review)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

// MARK: - Review Table Cell

class ReviewTableCell: UITableViewCell {
    
    private let reviewCardView = ExpertReviewCardView()
    
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
        
        contentView.addSubview(reviewCardView)
        reviewCardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            reviewCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            reviewCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            reviewCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            reviewCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with review: ExpertReview) {
        reviewCardView.configure(with: review, showHelpfulButton: true)
    }
}
