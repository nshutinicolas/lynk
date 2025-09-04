//
//  AppFlag.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 16/05/2025.
//

import Foundation

@propertyWrapper
struct Flag {
	private let userDefault = UserDefaults(suiteName: "group.com.ernest.lynkapp")
	let key: Key
	let defaultValue: Bool
	
	init(_ key: Key) {
		self.key = key
		self.defaultValue = key.defaultValue
	}
	
	var wrappedValue: Bool {
		get {
			getValue(for: key) ?? defaultValue
		} nonmutating set {
			set(newValue, for: key)
		}
	}
}

extension Flag {
	func getValue<T>(for key: Key) -> T? {
		userDefault?.object(forKey: key.rawValue) as? T
	}
	
	func set(_ value: Any?, for key: Key) {
		userDefault?.set(value, forKey: key.rawValue)
	}
}

extension Flag {
	enum Key: String {
		case showSavePreview = "extension.show_save_preview"
		case appLockEnabled = "settings.app_lock_enabled"
		case enableReminders = "settings.enable_reminders"
		case isFirstLaunch = "app.is_first_launch"
		
		var defaultValue: Bool {
			switch self {
			case .showSavePreview: return true
			case .appLockEnabled: return false
			case .enableReminders: return true
			case .isFirstLaunch: return true
			}
		}
	}
}
