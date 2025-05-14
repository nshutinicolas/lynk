//
//  AppReviewRequest.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 14/05/2025.
//

import Foundation
import UIKit

enum AppReviewRequest {
	#warning("Implement the logic for requesting app review")
	static func requestAppReview() -> Bool {
//		let currentAppVersion = Bundle.main.appVersion
//		let lastPromptedVersion: String? = LocalAppStorage.shared.getValue(for: .lastPromptedVersion)
//		let appVisitCount: Int? = LocalAppStorage.shared.getValue(for: .appVisits)
		
		// Logic
//		if let appVisitCount, appVisitCount % 4 == 0 && currentAppVersion != lastPromptedVersion {
//			LocalAppStorage.shared.set(currentAppVersion, for: .lastPromptedVersion)
//			return true
//		}
		return false
	}
	
	static func requestReviewManually() {
		guard let url = URL(string: AppConstants.appStoreReviewUrl) else { return }
		UIApplication.shared.open(url)
	}
}
