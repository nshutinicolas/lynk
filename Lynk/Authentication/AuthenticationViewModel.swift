//
//  AuthenticationViewModel.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 13/05/2025.
//

import LocalAuthentication
import Foundation
import SwiftUI

class AuthenticationViewModel: ObservableObject {
	// TODO: Instead of just using a boolean, use an enum that will help when handling success and error in the contentview
	@Published var isAuthenticated = false // For now
	@AppStorage("biometricAuth") var biometricAuthEnabled: Bool = false
	
	init() { }
	
	func checkAuthenticationStatus() {
		guard biometricAuthEnabled else {
			return
		}
		// Now the user enabled the biometrics
		authenticateUser()
	}
	
	private func authenticateUser() {
		let context = LAContext()
		var error: NSError?
		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			let reason = "We need to unlock your data."
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
				if success {
					
				} else {
					
				}
			}
		} else {
			// No Biometrics
		}
	}
}
