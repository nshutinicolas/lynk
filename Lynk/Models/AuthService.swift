//
//  AuthService.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 06/06/2025.
//

import Foundation
import LocalAuthentication

final class AuthService {
	static let shared = AuthService()
	private init() { }
	
	// Check if user has biometrics
	func hasBiometrics() -> Bool {
		let context = LAContext()
		var error: NSError?
		return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
	}
	
	func authenticateUser() async throws -> Bool {
		let context = LAContext()
		let reason = "Lynk requires your permission to only allow you to view content stored on this this App"
		return try await context.evaluatePolicy(
			.deviceOwnerAuthenticationWithBiometrics,
			localizedReason: reason
		)
	}
}
