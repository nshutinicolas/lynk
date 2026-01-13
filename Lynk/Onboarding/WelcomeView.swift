//
//  WelcomeView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 29/08/2025.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
	private var notificationManager = NotificationManager.shared
	@Flag(.isFirstLaunch) private var isFirstLaunch
	
	@State private var onboardingStage: Stage = .intro
	
    var body: some View {
		ZStack {
			switch onboardingStage {
			case .intro:
				VStack {
					Image(systemName: "folder")
						.resizable()
						.scaledToFit()
						.frame(width: 80, height: 80)
					Text("👋🏼 Welcome to Lynk")
						.font(.title)
						.fontWeight(.bold)
						.padding(.vertical)
					Text("Save and organize the links that matter to you - articles, videos or anything you want to comeback to later.")
						.multilineTextAlignment(.center)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.transition(.opacity)
			case .notification:
				VStack {
					Image(systemName: "bell.badge")
						.resizable()
						.scaledToFit()
						.frame(width: 80, height: 80)
					Text("⏰ Gentle reminders")
						.font(.title)
						.fontWeight(.bold)
						.padding(.vertical)
					Text("With reminders, **Lynk** can send you a gentle nudge when it’s time to revisit something you saved.")
						.multilineTextAlignment(.center)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background()
				.transition(.asymmetric(
					insertion: .move(edge: .trailing).combined(with: .opacity),
					removal: .move(edge: .leading).combined(with: .opacity))
				)
			}
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.safeAreaInset(edge: .bottom) {
			ZStack {
				switch onboardingStage {
				case .intro:
					primaryButton(title: "Get Started") {
						onboardingStage = .notification
					}
					.transition(.opacity)
				case .notification:
					VStack(spacing: 12) {
						Text("We’ll only notify you when you set a reminder, nothing more.")
							.font(.footnote)
							.foregroundStyle(.secondary)
							.multilineTextAlignment(.center)
						
						primaryButton(title: "Enable Notifications") {
							Task {
								_ = try await notificationManager.requestNotificationPermission()
								completeOnboarding()
							}
						}
						
						secondaryButton(title: "skip for now") {
							completeOnboarding()
						}
					}
					.transition(
						.asymmetric(
							insertion: .move(edge: .trailing).combined(with: .opacity),
							removal: .move(edge: .leading).combined(with: .opacity)
						)
					)
				}
			}
			.padding()
		}
		.animation(.easeInOut, value: onboardingStage)
		.background()
    }
	
	@ViewBuilder
	private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
		Button {
			action()
		} label: {
			Text(title)
				.fontWeight(.medium)
				.foregroundStyle(.white)
				.frame(maxWidth: .infinity)
				.contentShape(.rect)
		}
		.buttonStyle(.plain)
		.padding()
		.background(Color.blue)
		.roundedBorder(12, color: .clear)
	}
	
	@ViewBuilder
	private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
		Button {
			action()
		} label: {
			Text(title)
				.fontWeight(.medium)
				.frame(maxWidth: .infinity)
				.contentShape(.rect)
		}
		.buttonStyle(.plain)
	}
	
	private var _onboardingComplete: (Bool) -> Void = { _ in }
}

extension WelcomeView {
	func onboardingComplete(_ update: @escaping (Bool) -> Void) -> Self {
		var modified = self
		modified._onboardingComplete = update
		return modified
	}
	
	private func completeOnboarding() {
		isFirstLaunch = false
		_onboardingComplete(true)
	}
}

extension WelcomeView {
	enum Stage {
		case intro
		case notification
	}
}

#Preview {
    WelcomeView()
}
