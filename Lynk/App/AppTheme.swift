//
//  AppTheme.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 13/05/2025.
//

import Foundation
import SwiftUI

class AppTheme: ObservableObject {
	@Cached<String>(.colorScheme) private var storedColorScheme
	var colorScheme: ColorScheme? = .none {
		didSet {
			updateColorScheme()
		}
	}
	
	init() { }
	
	private func updateColorScheme() {
		storedColorScheme = colorScheme?.rawValue
		keyWindow?.overrideUserInterfaceStyle = UIUserInterfaceStyle(colorScheme)
	}
	
	func updateFromLocalStorage() {
		let scheme = storedColorScheme?.colorScheme
		keyWindow?.overrideUserInterfaceStyle = UIUserInterfaceStyle(scheme)
	}
	
	private var keyWindow: UIWindow? {
		guard let scene = UIApplication.shared.connectedScenes.first,
			  let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
			  let window = windowSceneDelegate.window else {
			return nil
		}
		return window
	}
}

extension String {
	var colorScheme: ColorScheme? {
		switch self {
		case "dark": return .dark
		case "light": return .light
		default: return .none
		}
	}
}

extension ColorScheme {
	func transformed(_ scheme: String) -> ColorScheme? {
		switch scheme {
		case "dark": return .dark
		case "light": return .light
		default: return .none
		}
	}
	
	var rawValue: String {
		switch self {
		case .dark: return "dark"
		case .light: return "light"
		default: return "none"
		}
	}
}
