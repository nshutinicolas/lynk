//
//  ContentView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import LocalAuthentication
import SwiftUI

struct ContentView: View {
	@Environment(\.openURL) var openURL
	@EnvironmentObject private var notificationContainer: NotificationContainer
	private var authService = AuthService.shared
	@State private var isAuthenticated: Bool = false
	@Flag(.appLockEnabled) private var appLockEnabled
	@Flag(.isFirstLaunch) private var isFirstLaunch
	@State private var isOnboardingFlowCompleted: Bool = false
	
	// Auth Error
	@State private var biometricAuthError: NSError? {
		didSet {
			showBiometricAuthErrorAlert = true
		}
	}
	@State private var showBiometricAuthErrorAlert: Bool = false
	
    var body: some View {
		Group {
			if isFirstLaunch && isOnboardingFlowCompleted == false {
				WelcomeView()
					.onboardingComplete { status in
						isOnboardingFlowCompleted = status
					}
			} else if appLockEnabled == false || isAuthenticated {
				AppView()
			} else {
				AuthView(action: authenticate)
			}
		}
		.alert(
			biometricAuthError?.userInfo["NSLocalizedDescription"] as? String ?? "Biometric Authentication Failed",
			isPresented: $showBiometricAuthErrorAlert,
			presenting: biometricAuthError
		) { _ in
			Button("Settings") {
				guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
				openURL(settingsUrl)
			}
			Button("Cancel") { }
		} message: { error in
			Text(error?.userInfo["NSDebugDescription"] as? String ?? "Failed to validate biometric authentication on this device. Please check your device settings and try again.")
		}
    }
	
	private func authenticate() {
		Task {
			do {
				let authState = try await authService.authenticateUser()
				isAuthenticated = authState
			} catch {
				print("Auth Error: \(error.localizedDescription)")
				biometricAuthError = error as NSError
				isAuthenticated = false
			}
		}
	}
}

#Preview {
    ContentView()
		.environmentObject(AppCoordinator())
		.environmentObject(NotificationContainer())
}
