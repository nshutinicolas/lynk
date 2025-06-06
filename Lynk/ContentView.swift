//
//  ContentView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import LocalAuthentication
import SwiftUI

struct ContentView: View {
	private var authService = AuthService.shared
	@State private var isAuthenticated: Bool = false
	@Flag(.appLockEnabled) private var appLockEnabled
	
    var body: some View {
		Group {
			if appLockEnabled == false || isAuthenticated {
				AppView()
			} else {
				AuthView(action: authenticate)
			}
		}
    }
	
	private func authenticate() {
		Task {
			do {
				let authState = try await authService.authenticateUser()
				isAuthenticated = authState
			} catch {
				print("Auth Error: \(error.localizedDescription)")
				isAuthenticated = false
			}
		}
	}
}

struct AuthView: View {
	let action: () -> Void
	
	init(action: @escaping() -> Void) {
		self.action = action
	}
	
	var body: some View {
		VStack {
			Text("Welcome to Lynk")
				.font(.largeTitle)
				.padding()
			Image(systemName: "faceid")
				.resizable()
				.frame(width: 80, height: 80)
				.padding()
			Button {
				action()
			} label: {
				Text("Authenticate")
					.foregroundStyle(.white)
					.padding(.vertical, 12)
					.padding(.horizontal, 32)
			}
			.background(Color.blue)
			.clipShape(.rect(cornerRadius: 8))
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

#Preview {
    ContentView()
		.environmentObject(AppCoordinator())
}

#Preview {
	AuthView(action: { })
}
