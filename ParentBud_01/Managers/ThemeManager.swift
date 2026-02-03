//
//  ThemeManager.swift
//  ParentBud_01
//
//  Created by GlitchZap on 10/11/25.
//

import UIKit

class ThemeManager {
    static let shared = ThemeManager()
    
    private init() {}
    
    // MARK: - Current Theme (Based on System)
    var currentTheme: UIUserInterfaceStyle {
        return UIScreen.main.traitCollection.userInterfaceStyle
    }
    
    // MARK: - Light Theme Colors (Original)
    struct LightColors {
        // Background Colors - UPDATED
        static let background = UIColor.white
        static let cardBackground = UIColor.white
        static let inputBackground = UIColor.white
        
        // Primary Colors
        static let primaryPurple = UIColor(red: 0.46, green: 0.36, blue: 0.98, alpha: 1.0) // #635BFF
        static let accentPurple = UIColor(red: 0.60, green: 0.50, blue: 1.0, alpha: 1.0) // Lighter purple
        
        // Text Colors
        static let primaryText = UIColor.black
        static let secondaryText = UIColor.systemGray
        static let tertiaryText = UIColor.systemGray2
        
        // Border Colors
        static let border = UIColor(white: 0.9, alpha: 1.0)
        static let activeBorder = primaryPurple
        
        // Shadow
        static let shadowColor = UIColor.black
    }
    
    // MARK: - Dark Theme Colors
    struct DarkColors {
        // Background Colors
        static let background = UIColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1.0) // Midnight
        static let cardBackground = UIColor(red: 0.12, green: 0.12, blue: 0.20, alpha: 1.0)
        static let inputBackground = UIColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0)
        
        // Primary Colors
        static let primaryPurple = UIColor(red: 0.46, green: 0.36, blue: 0.98, alpha: 1.0) // #635BFF
        static let accentPurple = UIColor(red: 0.60, green: 0.50, blue: 1.0, alpha: 1.0) // Lighter purple
        
        // Text Colors
        static let primaryText = UIColor.white
        static let secondaryText = UIColor(white: 0.7, alpha: 1.0)
        static let tertiaryText = UIColor(white: 0.5, alpha: 1.0)
        
        // Border Colors
        static let border = UIColor(white: 0.3, alpha: 1.0)
        static let activeBorder = primaryPurple
        
        // Shadow
        static let shadowColor = UIColor.black
    }
    
    // MARK: - Dynamic Colors (Returns current theme colors based on system)
    struct Colors {
        static var background: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    DarkColors.background : LightColors.background
            }
        }
        
        static var cardBackground: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    DarkColors.cardBackground : LightColors.cardBackground
            }
        }
        
        static var inputBackground: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    DarkColors.inputBackground : LightColors.inputBackground
            }
        }
        
        static var primaryPurple: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    DarkColors.primaryPurple : LightColors.primaryPurple
            }
        }

        static var progressTrack: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    UIColor(white: 0.3, alpha: 1.0) :  // Dark mode: gray
                    UIColor(white: 0.85, alpha: 1.0)   // Light mode: light gray
            }
        }
        
        static var accentPurple: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    DarkColors.accentPurple : LightColors.accentPurple
            }
        }
        
        static var primaryText: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    DarkColors.primaryText : LightColors.primaryText
            }
        }
        
        static var secondaryText: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    DarkColors.secondaryText : LightColors.secondaryText
            }
        }
        
        static var tertiaryText: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    DarkColors.tertiaryText : LightColors.tertiaryText
            }
        }
        
        static var border: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    DarkColors.border : LightColors.border
            }
        }
        
        static var activeBorder: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    DarkColors.activeBorder : LightColors.activeBorder
            }
        }
        
        static var shadowColor: UIColor {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    DarkColors.shadowColor : LightColors.shadowColor
            }
        }
        
        // ✅ NEW — Navigation Bar Color (ONLY CHANGE YOU REQUESTED)
        static var navigationBarBackground: UIColor {
            return UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    // Deep Purple (top gradient color)
                    return UIColor(red: 0.25, green: 0.10, blue: 0.30, alpha: 1.0)
                } else {
                    return UIColor.white
                }
            }
        }
    }
    
    // MARK: - Gradient Setup (ONLY for Onboarding & WhatWeOffer - Simple Background Color)
    func createBackgroundGradient(for view: UIView, traitCollection: UITraitCollection) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        
        if traitCollection.userInterfaceStyle == .dark {
            // Dark theme gradient
            let deepPurple = UIColor(red: 0.25, green: 0.10, blue: 0.30, alpha: 1.0)
            let darkBlue = UIColor(red: 0.08, green: 0.12, blue: 0.25, alpha: 1.0)
            let midnight = UIColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1.0)
            
            gradient.colors = [deepPurple.cgColor, darkBlue.cgColor, midnight.cgColor]
            gradient.locations = [0.0, 0.5, 1.0]
        } else {
            // Light theme - SOLID COLOR #E7EDF3
            let lightBackground = UIColor(red: 0.906, green: 0.929, blue: 0.953, alpha: 1.0) // #E7EDF3
            gradient.colors = [lightBackground.cgColor, lightBackground.cgColor]
            gradient.locations = [0.0, 1.0]
        }
        
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        return gradient
    }
    
    // MARK: - Gradient for Other Screens (Login, SignUp, etc.)
    func createAuthBackgroundGradient(for view: UIView, traitCollection: UITraitCollection) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        
        if traitCollection.userInterfaceStyle == .dark {
            // Dark theme gradient
            let deepPurple = UIColor(red: 0.25, green: 0.10, blue: 0.30, alpha: 1.0)
            let darkBlue = UIColor(red: 0.08, green: 0.12, blue: 0.25, alpha: 1.0)
            let midnight = UIColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1.0)
            
            gradient.colors = [deepPurple.cgColor, darkBlue.cgColor, midnight.cgColor]
            gradient.locations = [0.0, 0.5, 1.0]
        } else {
            // Light theme gradient (original for auth screens)
            gradient.colors = [
                UIColor(red: 0.93, green: 0.87, blue: 0.94, alpha: 1.0).cgColor,
                UIColor(red: 0.95, green: 0.77, blue: 0.94, alpha: 1.0).cgColor,
                UIColor(red: 0.82, green: 0.81, blue: 0.94, alpha: 1.0).cgColor,
                UIColor(red: 0.75, green: 0.86, blue: 0.90, alpha: 1.0).cgColor
            ]
            gradient.locations = [0.0, 0.3, 0.47, 1.0]
        }
        
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        return gradient
    }
    
    // MARK: - Update Gradient Frame
    func updateGradientFrame(_ gradient: CAGradientLayer, for view: UIView) {
        gradient.frame = view.bounds
    }
}
