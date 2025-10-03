//
//  AppReviewRequest.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 14/05/2025.
//

import UIKit

enum AppReviewRequest {
	static func requestAppReviewEligible() -> Bool {
		let currentAppVersion = Bundle.main.appVersion
		@Cached<String>(.lastPromptedVersion) var lastPromptedVersion
		@Cached<Int>(.appVisits) var appVisitsCount
		
		// If app version is the same and visits ain't divisible by 3, then exit
		guard currentAppVersion != lastPromptedVersion,
			  let appVisitsCount,
			  appVisitsCount.isMultiple(of: 3)
		else {
			return false
		}
		
		return true
	}
	
	static func requestReviewManually() {
		guard let url = URL(string: AppConstants.appStoreReviewUrl) else { return }
		UIApplication.shared.open(url)
	}
	
	static func updateReviewValues() {
		@Cached<String>(.lastPromptedVersion) var lastPromptedVersion
		lastPromptedVersion = Bundle.main.appVersion
		// Update last date reviewed
	}
}
