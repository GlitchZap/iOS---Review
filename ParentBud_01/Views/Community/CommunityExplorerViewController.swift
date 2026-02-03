//
//  CommunityExplorerViewController.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-16
//

import UIKit

class CommunityExplorerViewController: UIViewController {

    private let dataManager = CommunityDataManager.shared
    private var communities: [Community] = []
    private var filteredCommunities: [Community] = []

    var onCommunitySelected: ((Community) -> Void)?

    // MARK: - UI Components

    private let segmentedControl: UISegmentedControl = {
        let items = ["Local", "Global", "Joined"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .normal)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search communities..."
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CommunityCell.self, forCellReuseIdentifier: "CommunityCell")
        return tableView
    }()

    private let emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .light)
        imageView.image = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        imageView.tintColor = ThemeManager.Colors.secondaryText.withAlphaComponent(0.5)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No Communities Found"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = ThemeManager.Colors.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emptyStateSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Try searching with different keywords"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = ThemeManager.Colors.tertiaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadCommunities()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        loadCommunities()
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

        view.addSubview(segmentedControl)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateSubtitle)

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self

        updateSegmentedControlStyle()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36),

            searchBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 90),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 90),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 24),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),

            emptyStateSubtitle.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            emptyStateSubtitle.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateSubtitle.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateSubtitle.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }

    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    private func configureNavigationBar() {
        title = "Explore Communities"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
    }

    private func updateSegmentedControlStyle() {
        let isDark = traitCollection.userInterfaceStyle == .dark

        if isDark {
            segmentedControl.selectedSegmentTintColor = ThemeManager.Colors.primaryPurple
            segmentedControl.backgroundColor = ThemeManager.Colors.cardBackground
        } else {
            segmentedControl.selectedSegmentTintColor = ThemeManager.Colors.primaryPurple
            segmentedControl.backgroundColor = UIColor.systemGray6
        }

        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)

        segmentedControl.setTitleTextAttributes([
            .foregroundColor: ThemeManager.Colors.secondaryText,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
    }

    private func updateTheme() {
        view.backgroundColor = ThemeManager.Colors.background
        emptyStateLabel.textColor = ThemeManager.Colors.secondaryText
        emptyStateSubtitle.textColor = ThemeManager.Colors.tertiaryText
        emptyStateImageView.tintColor = ThemeManager.Colors.secondaryText.withAlphaComponent(0.5)
        updateSegmentedControlStyle()
        tableView.reloadData()
    }

    private func loadCommunities() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            communities = dataManager.getCommunities(type: .local)
        case 1:
            communities = dataManager.getCommunities(type: .global)
        case 2:
            communities = dataManager.getJoinedCommunities()
        default:
            communities = dataManager.getAllCommunities()
        }

        filteredCommunities = communities
        updateEmptyState()
        tableView.reloadData()
    }

    private func filterCommunities(with searchText: String) {
        if searchText.isEmpty {
            filteredCommunities = communities
        } else {
            filteredCommunities = communities.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
            }
        }

        updateEmptyState()
        tableView.reloadData()
    }

    private func updateEmptyState() {
        let isEmpty = filteredCommunities.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty

        if segmentedControl.selectedSegmentIndex == 2 {
            emptyStateLabel.text = "No Communities Joined"
            emptyStateSubtitle.text = "Browse Local or Global tabs to discover and join communities"
            emptyStateImageView.image = UIImage(
                systemName: "figure.2.and.child.holdinghands",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 70, weight: .light)
            )
        } else {
            emptyStateLabel.text = "No Communities Found"
            emptyStateSubtitle.text = "Try searching with different keywords"
            emptyStateImageView.image = UIImage(
                systemName: "magnifyingglass",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 70, weight: .light)
            )
        }
    }

    // MARK: - Actions

    @objc private func segmentChanged() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadCommunities()
    }
}

// MARK: - UITableViewDelegate & DataSource

extension CommunityExplorerViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredCommunities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityCell", for: indexPath) as! CommunityCell
        let community = filteredCommunities[indexPath.row]

        cell.configure(with: community)
        cell.onJoinToggle = { [weak self] in
            self?.handleJoinToggle(community: community)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        let community = filteredCommunities[indexPath.row]
        onCommunitySelected?(community)
        navigationController?.popViewController(animated: true)
    }

    private func handleJoinToggle(community: Community) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        if community.isJoined {
            dataManager.leaveCommunity(community.id)
        } else {
            dataManager.joinCommunity(community.id)
        }

        loadCommunities()
    }
}

// MARK: - UISearchBarDelegate

extension CommunityExplorerViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterCommunities(with: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterCommunities(with: "")
    }
}
