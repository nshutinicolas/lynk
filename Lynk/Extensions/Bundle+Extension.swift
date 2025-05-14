//
//  Bundle+Extension.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 13/05/2025.
//

import Foundation

extension Bundle {
	var appBuild: String? {
		object(forInfoDictionaryKey: "CFBundleVersion") as? String
	}
	
	var appVersion: String? {
		object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
	}
}
