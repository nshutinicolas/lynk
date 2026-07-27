//
//  OnboardingView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 29/08/2025.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
	private var notificationManager = NotificationManager.shared
	@Flag(.isFirstLaunch) private var isFirstLaunch
	
	@State private var onboardingStage: Step = .intro
	
    var body: some View {
		VStack {
			Group {
				switch onboardingStage {
				case .intro:
					WelcomeView {
						next()
					}
					.tag(Step.intro)
				case .saveLinksWays:
					TwoWaysToSaveView {
						next()
					}
					.tag(Step.saveLinksWays)
				case .notification:
					NotificationRequestView {
						Task {
							_ = try await notificationManager.requestNotificationPermission()
							next()
						}
					} secondaryAction: {
						next()
					}
					.tag(Step.notification)
				case .complete:
					CompleteOnboardingView {
						completeOnboarding()
					}
					.tag(Step.complete)
				}
			}
			.frame(maxWidth: .infinity)
			.transition(transition)
			.id(onboardingStage)
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background()
    }
	
	private var _onboardingComplete: (Bool) -> Void = { _ in }
}

extension OnboardingView {
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

extension OnboardingView {
	enum Step: Int {
		case intro = 1
		case saveLinksWays
		case notification
		case complete
		
		mutating func next() {
			guard let nextValue = Self(rawValue: self.rawValue + 1) else { return }
			self = nextValue
		}
	}
	@MainActor
	func next() {
		withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
			onboardingStage.next()
		}
	}
	var transition: AnyTransition {
		.asymmetric(
			insertion: .move(edge: .trailing).combined(with: .opacity),
			removal: .move(edge: .leading).combined(with: .opacity)
		)
	}
}

#Preview {
    OnboardingView()
}

// MARK: - Onboarding screens
// Home
private struct WelcomeView: View {
	let action: () -> Void
	
	init(_ action: @escaping () -> Void) {
		self.action = action
	}
	
	var body: some View {
		VStack {
			Image(systemName: "folder")
				.resizable()
				.scaledToFit()
				.padding()
				.frame(width: 80, height: 80)
				.background(Color(uiColor: .secondarySystemBackground))
				.roundedBorder(lineWidth: 0)
			
			Text(L10n.Welcome.Onboarding.Intro.title)
				.font(.title)
				.fontWeight(.bold)
				.padding(.vertical)
			Text(L10n.Welcome.Onboarding.Intro.description)
				.multilineTextAlignment(.center)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.safeAreaInset(edge: .bottom) {
			PrimaryButton(String(localized: L10n.Button.continueButton)) {
				action()
			}
		}
		.background()
	}
}

// Ways to save
private struct TwoWaysToSaveView: View {
	let action: () -> Void
	
	init(_ action: @escaping () -> Void) {
		self.action = action
	}
	
	var body: some View {
		VStack(spacing: 0) {
			
			VStack(spacing: 4) {
				Text(L10n.Welcome.Onboarding.TwoWaysToSave.title)
					.font(.title2.weight(.semibold))
				Text(L10n.Welcome.Onboarding.TwoWaysToSave.description)
					.foregroundStyle(.secondary)
			}
			.multilineTextAlignment(.center)
			.padding(.top, 24)
			.padding(.bottom, 28)
			
			VStack(spacing: 12) {
				saveMethodCard(
					title: String(localized: L10n.Welcome.Onboarding.TwoWaysToSave.SaveMethod.shareSheetTitle),
					description: String(localized: L10n.Welcome.Onboarding.TwoWaysToSave.SaveMethod.shareSheetDecription),
					icon: "square.and.arrow.up"
				)
				saveMethodCard(
					title: String(localized: L10n.Welcome.Onboarding.TwoWaysToSave.SaveMethod.manualTitle),
					description: String(localized: L10n.Welcome.Onboarding.TwoWaysToSave.SaveMethod.manualDescription),
					icon: "plus.square.on.square"
				)
			}
			
			HStack(spacing: 6) {
				Image(systemName: "icloud")
					.font(.caption)
				Text(L10n.Welcome.Onboarding.TwoWaysToSave.icloudSync)
					.font(.caption)
			}
			.foregroundStyle(.secondary)
			.padding(.top, 16)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.safeAreaInset(edge: .bottom) {
			PrimaryButton(String(localized: L10n.Button.continueButton)) {
				action()
			}
		}
		.background()
	}
	
	@ViewBuilder
	private func saveMethodCard(title: String, description: String, icon: String) -> some View {
		VStack(alignment: .leading, spacing: 12) {
			Image(systemName: icon)
				.font(.system(size: 28, weight: .medium))
			
			VStack(alignment: .leading, spacing: 4) {
				Text(title)
					.font(.subheadline.weight(.semibold))
				Text(description)
					.font(.footnote)
					.foregroundStyle(.secondary)
					.fixedSize(horizontal: false, vertical: true)
			}
		}
		.padding()
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color(uiColor: .secondarySystemBackground))
		.roundedBorder(lineWidth: 0)
	}
}

// Notification
private struct NotificationRequestView: View {
	let primaryAction: () -> Void
	let secondaryAction: () -> Void
	
	init(primaryAction: @escaping () -> Void, secondaryAction: @escaping () -> Void) {
		self.primaryAction = primaryAction
		self.secondaryAction = secondaryAction
	}
	var body: some View {
		VStack {
			Image(systemName: "bell.badge")
				.resizable()
				.scaledToFit()
				.padding()
				.frame(width: 80, height: 80)
				.background(Color(uiColor: .secondarySystemBackground))
				.roundedBorder(lineWidth: 0)
			Text(L10n.Welcome.Onboarding.Notification.title)
				.font(.title)
				.fontWeight(.bold)
				.padding(.vertical)
			Text(L10n.Welcome.Onboarding.Notification.description)
				.multilineTextAlignment(.center)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.safeAreaInset(edge: .bottom) {
			VStack {
				PrimaryButton(String(localized: L10n.Welcome.Onboarding.Notification.Button.enableTitle)) {
					primaryAction()
				}
				SecondaryButton(String(localized: L10n.Welcome.Onboarding.Notification.Button.skipTitle)) {
					secondaryAction()
				}
			}
		}
		.background()
	}
}

// Complete onboarding
struct CompleteOnboardingView: View {
	let action: () -> Void
	
	init(_ action: @escaping () -> Void) {
		self.action = action
	}
	
	var body: some View {
		VStack {
			Image(systemName: "checkmark")
				.resizable()
				.scaledToFit()
				.padding()
				.frame(width: 80, height: 80)
				.foregroundStyle(Color(uiColor: .systemGreen))
				.background(Color(uiColor: .secondarySystemBackground))
				.roundedBorder(lineWidth: 0)
			Text(L10n.Welcome.Onboarding.CompleteOnboarding.title)
				.font(.title)
				.fontWeight(.bold)
				.padding(.vertical)
			Text(L10n.Welcome.Onboarding.CompleteOnboarding.description)
				.multilineTextAlignment(.center)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.safeAreaInset(edge: .bottom) {
			VStack {
				PrimaryButton(String(localized: L10n.Welcome.Onboarding.Intro.Button.title)) {
					action()
				}
			}
		}
		.background()
	}
}
