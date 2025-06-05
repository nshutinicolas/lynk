//
//  Cached.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 04/06/2025.
//

import Foundation

@propertyWrapper
struct Cached<Value> {
	private let userDefault = UserDefaults(suiteName: "group.com.ernest.lynkapp")
	let key: Key
	
	init(_ key: Key) {
		self.key = key
	}
	
	var wrappedValue: Value? {
		get {
			getValue(for: key)
		} nonmutating set {
			set(newValue, for: key)
		}
	}
}

extension Cached {
	func getValue<T>(for key: Key) -> T? {
		userDefault?.object(forKey: key.rawValue) as? T
	}
	
	func set(_ value: Any?, for key: Key) {
		userDefault?.set(value, forKey: key.rawValue)
	}
}

extension Cached {
	enum Key: String {
		case layout
	}
}
