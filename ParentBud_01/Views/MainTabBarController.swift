//
//  MainTabBarController. swift
//  ParentBud_01
//
//  Created by GlitchZap on 12/11/25.
//  Cleaned Without Changing Theme or Content
//

import UIKit

class MainTabBarController:   UITabBarController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()

        // Register theme change
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self:   Self, _) in
                self.refreshAppearanceAsync()
            }
        }
        
        // Check and present community guidelines after tab bar setup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.checkAndPresentCommunityGuidelines()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }

        refreshAppearanceAsync()
        propagateStatusBarUpdates()
    }

    // MARK:   - Helpers
    private func refreshAppearanceAsync() {
        DispatchQueue.main.async { [weak self] in
            self?.setupTabBarAppearance()
        }
    }

    private func propagateStatusBarUpdates() {
        viewControllers?.forEach { vc in
            if let nav = vc as?   UINavigationController {
                nav.viewControllers.forEach { $0.setNeedsStatusBarAppearanceUpdate() }
            } else {
                vc.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    // MARK:  - Public Refresh Method
    func refreshTabBarAppearance() {
        refreshAppearanceAsync()
    }

    // MARK: - Setup View Controllers
    private func setupViewControllers() {

        let homeNav = UINavigationController(rootViewController: HomeViewController())
        homeNav.tabBarItem = UITabBarItem(
            title:  "Home",
            image:   UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let flowNav = UINavigationController(rootViewController: FindYourFlowViewController())
        flowNav.tabBarItem = UITabBarItem(
            title: "Flow",
            image:  UIImage(systemName: "brain.head.profile"),
            selectedImage:   UIImage(systemName:  "brain.head.profile.fill")
        )

        let careCardsNav = UINavigationController(rootViewController: CareCardsViewController())
        careCardsNav.tabBarItem = UITabBarItem(
            title:   "Care Cards",
            image: UIImage(systemName: "newspaper"),
            selectedImage: UIImage(systemName: "newspaper.fill")
        )

        // ✅ NEW: Replace placeholder with actual Community feature
        let communityNav = createCommunityViewController()

        let expertsNav = UINavigationController(rootViewController:  ExpertsViewController())
        expertsNav.tabBarItem = UITabBarItem(
            title:  "Experts",
            image:  UIImage(systemName: "star.bubble"),
            selectedImage: UIImage(systemName: "star.bubble.fill")
        )

        viewControllers = [homeNav, flowNav, careCardsNav, communityNav, expertsNav]
    }

    // ✅ NEW:   Create Community View Controller with proper navigation
    private func createCommunityViewController() -> UINavigationController {
        let feedVC = CommunityFeedViewController()
        let navController = UINavigationController(rootViewController: feedVC)
        navController.tabBarItem = UITabBarItem(
            title:   "Parent Pods",
            image:  UIImage(systemName: "figure.2.and.child.holdinghands"),
            selectedImage: UIImage(systemName: "figure.2.and.child.holdinghands")
        )
        
        return navController
    }
    
    // ✅ NEW: Check and present community guidelines only when user taps Community tab
    private func checkAndPresentCommunityGuidelines() {
        // Only check guidelines when user hasn't accepted them yet
        // This creates a seamless experience without interrupting the normal app flow
        
        // We'll handle guidelines presentation in the CommunityFeedViewController
        // when the user actually navigates to the Community tab for the first time
        
        print("✅ Community feature integrated - guidelines will be presented when Community tab is accessed")
    }

    // MARK:  - Tab Bar Appearance
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        let isDark = traitCollection.userInterfaceStyle == . dark

        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = isDark
            ?   ThemeManager.Colors.background
            :  .systemBackground

        // Normal (unselected) state - gray
        appearance.stackedLayoutAppearance.normal.iconColor = . systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            . foregroundColor: UIColor.systemGray
        ]

        // Selected state - ALWAYS PURPLE (both light and dark mode)
        appearance.stackedLayoutAppearance.selected.iconColor = ThemeManager.Colors.primaryPurple
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: ThemeManager.Colors.primaryPurple
        ]

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width:  0, height:  -1)
        tabBar.layer.shadowRadius = 4
        tabBar.layer.shadowOpacity = isDark ? 0.3 :   0.1

        UIView.transition(with: tabBar, duration: 0.2, options: .transitionCrossDissolve) {
            self.tabBar.setNeedsLayout()
            self.tabBar.layoutIfNeeded()
        }
    }
}
