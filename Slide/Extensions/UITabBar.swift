//  UITabBar.swift
//  Slide
//  Created by Ethan Harianto on 8/2/23.

import UIKit

extension UITabBar {
    static func customizeAppearance() {
        /* When called, this code changes the tab bar so that unselected items are white and the bar is opaque. */
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().backgroundColor = .black
    }
}
