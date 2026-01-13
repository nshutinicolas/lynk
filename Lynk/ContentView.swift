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
		.sheet(isPresented: $showBiometricAuthErrorAlert) {
			VStack(alignment: .leading, spacing: 16) {
				Text(biometricAuthError?.userInfo["NSLocalizedDescription"] as? String ?? "Biometric Authentication Failed")
					.font(.title2)
					.fontWeight(.semibold)
					.lineLimit(2)
				Text(biometricAuthError?.userInfo["NSDebugDescription"] as? String ?? "Failed to validate biometric authentication on this device. Please check your device settings and try again.")
				VStack {
					Button(L10n.Button.settings) {
						guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
						openURL(settingsUrl)
						showBiometricAuthErrorAlert = false
					}
					.buttonStyle(.plain)
					.padding()
					.frame(maxWidth: .infinity)
					.background(Color.blue)
					.roundedBorder(for: .capsule)
					.foregroundStyle(Color.white)
					
					Button(L10n.Button.cancel) {
						showBiometricAuthErrorAlert = false
					}
					.buttonStyle(.plain)
					.padding()
					.frame(maxWidth: .infinity)
					.background()
					.roundedBorder(for: .capsule, color: .gray)
					.foregroundStyle(Color.secondary)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding()
			.background()
			.presentationDetents([.fraction(0.4)])
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
