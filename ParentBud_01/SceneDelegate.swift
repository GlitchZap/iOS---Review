//
//  SceneDelegate.swift
//  ParentBud_01
//
//  Created by Aayush on 2025-11-13
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = createOnboardingFlow() // placeholder until auth is resolved
        window?.makeKeyAndVisible()

        Task {
            await bootstrapInitialFlow()
        }
    }
    
    // ✅ Determine which screen to show based on Supabase session & profile
    @MainActor
    private func determineInitialViewController(currentUser: UserData?) -> UIViewController {
        guard let currentUser else {
            return createOnboardingFlow()
        }

        // If user exists and is logged in, go to main app
        // Screener is only for new signups, not returning users
        return createMainApp()
    }

    private func bootstrapInitialFlow() async {
        // First, check for local user data (faster startup for existing users)
        if let localUser = UserDataManager.shared.getCurrentUser() {
            print("ℹ️ Found local user: \(localUser.name) (\(localUser.email))")
            await MainActor.run {
                self.window?.rootViewController = self.determineInitialViewController(currentUser: localUser)
            }
            
            // Try to refresh from remote in background (don't block UI)
            Task {
                do {
                    let remoteUser = try await UserDataManager.shared.refreshCurrentUserFromRemote()
                    print("✅ Successfully refreshed user data from Supabase: \(remoteUser.name)")
                } catch {
                    print("⚠️ Failed to refresh from remote, using local data: \(error)")
                }
            }
            return
        }
        
        // No local user, try to get from Supabase session
        do {
            let remoteUser = try await UserDataManager.shared.refreshCurrentUserFromRemote()
            print("✅ Found remote user session: \(remoteUser.name)")
            await MainActor.run {
                self.window?.rootViewController = self.determineInitialViewController(currentUser: remoteUser)
            }
        } catch {
            print("ℹ️ No remote session/profile found, showing onboarding: \(error)")
            await MainActor.run {
                self.window?.rootViewController = self.createOnboardingFlow()
            }
        }
    }
    
    private func createOnboardingFlow() -> UIViewController {
        let onboardingVC = OnboardingViewController()
        let navController = UINavigationController(rootViewController: onboardingVC)
        navController.navigationBar.prefersLargeTitles = true
        navController.navigationBar.isHidden = true
        return navController
    }
    
    private func createMainApp() -> UIViewController {
        let tabBarController = MainTabBarController()
        return tabBarController
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

extension SceneDelegate {
    func switchToMainApp() {
        print("✅ Switching to main app after onboarding")
        
        UIView.transition(with: window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = self.createMainApp()
        }, completion: nil)
    }
}
