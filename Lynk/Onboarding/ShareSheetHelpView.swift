//
//  ShareSheetHelpView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 24/07/2026.
//

import SwiftUI

struct ShareSheetHelpView: View {
	let dismiss: () -> Void
	
	init(dismiss: @escaping () -> Void) {
		self.dismiss = dismiss
	}
	
	var body: some View {
		VStack(spacing: .zero) {
			VStack(spacing: 4) {
				Text(L10n.ShareSheetHelpView.title)
					.font(.title3)
					.fontWeight(.medium)
				Text(L10n.ShareSheetHelpView.message)
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity)
			.overlay(alignment: .trailing) {
				Button {
					dismiss()
				} label: {
					Image(systemName: "xmark")
						.resizable()
						.scaledToFit()
						.frame(width: 16, height: 16)
						.padding(12)
						.background()
						.roundedBorder(for: .circle)
				}
				.buttonStyle(.plain)
			}
			.padding()
			
			AppUsageExplainer()
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

private struct StepRow<Additional: View>: View {
	let number: Int
	let title: String
	let description: String
	var additionalView: (() -> Additional)?
	
	init(number: Int, title: String, description: String, additionalView: @escaping () -> Additional) {
		self.number = number
		self.title = title
		self.description = description
		self.additionalView = additionalView
	}
	
	init(number: Int, title: String, description: String) where Additional == EmptyView {
		self.number = number
		self.title = title
		self.description = description
		self.additionalView = nil
	}
	
	var body: some View {
		HStack(alignment: .top, spacing: 10) {
			Text("\(number)")
				.font(.caption.weight(.semibold))
				.foregroundStyle(Color(uiColor: .systemBackground))
				.frame(width: 22, height: 22)
				.background(Circle().fill(Color.primary))
			
			VStack(alignment: .leading, spacing: 2) {
				Text(title)
					.font(.subheadline.weight(.medium))
				Text(description)
					.font(.footnote)
					.foregroundStyle(.secondary)
					.fixedSize(horizontal: false, vertical: true)
				additionalView?()
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.padding()
		.frame(maxWidth: .infinity)
		.roundedBorder()
	}
}

#Preview {
	ShareSheetHelpView {
		
	}
}

private struct AppUsageExplainer: View {
	private let notification = NotificationManager.shared
	@State private var notificationEnabled = false
	@Environment(\.openURL) var openURL
	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				StepRow(
					number: 1,
					title: String(localized: L10n.ShareSheetHelpView.Explainer.Step1.title),
					description: String(localized: L10n.ShareSheetHelpView.Explainer.Step1.description),
					additionalView: {
						VStack(alignment: .leading) {
							Image(.onboardingSharesheetLaunchSafari)
								.resizable()
								.scaledToFit()
								.roundedBorder(lineWidth: 2)
							Text(L10n.ShareSheetHelpView.Explainer.Step1.safariRef)
								.font(.caption)
								.foregroundStyle(.secondary)
						}
						.padding(.vertical)
					}
				)
				StepRow(
					number: 2,
					title: String(localized: L10n.ShareSheetHelpView.Explainer.Step2.title),
					description: String(localized: L10n.ShareSheetHelpView.Explainer.Step2.description),
					additionalView: {
						VStack(alignment: .leading) {
							Image(.onboardingLynkEditTitle)
								.resizable()
								.scaledToFit()
								.roundedBorder(lineWidth: 2)
							Text(L10n.ShareSheetHelpView.Explainer.Step2.expectation)
								.font(.caption)
								.foregroundStyle(.secondary)
							// Wheck if user has notification enabled and show them the
							if notificationEnabled == false {
								VStack(alignment: .leading) {
									Text(L10n.ShareSheetHelpView.Explainer.Step2.setReminderText)
										.fontWeight(.semibold)
									PrimaryButton(String(localized:  L10n.ShareSheetHelpView.Explainer.Step2.enableNotificationButton)) {
										Task {
											// When user has disabled system notification,
											// prompt them to open the system settings
											// otherwise open system notification prompt
											let status = await notification.notificationPermissionStatus()
											switch status {
											case .denied:
												guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
												openURL(settingsUrl)
											case .authorized:
												// Not needed in this case
												break
											default:
												_ = try? await notification.requestNotificationPermission()
											}
										}
									}
								}
								.frame(maxWidth: .infinity, alignment: .leading)
								.padding(.top)
							}
						}
						.padding(.vertical)
					}
				)
				StepRow(
					number: 3,
					title: String(localized: L10n.ShareSheetHelpView.Explainer.Step3.title),
					description: String(localized: L10n.ShareSheetHelpView.Explainer.Step3.description),
					additionalView: {
						VStack(alignment: .leading) {
							VStack(alignment: .leading, spacing: 2) {
								Text(L10n.ShareSheetHelpView.Explainer.Step3.tapMoreText)
									.font(.subheadline.weight(.medium))
								Image(.onboardingSharesheetApps)
									.resizable()
									.scaledToFit()
									.roundedBorder(lineWidth: 2)
							}
							VStack(alignment: .leading, spacing: 2) {
								Text(L10n.ShareSheetHelpView.Explainer.Step3.tapEditText)
									.font(.subheadline.weight(.medium))
								Image(.onboardingEditSelection)
									.resizable()
									.scaledToFit()
									.roundedBorder(lineWidth: 2)
							}
							VStack(alignment: .leading, spacing: 2) {
								Text(L10n.ShareSheetHelpView.Explainer.Step3.enableLynkText)
									.font(.subheadline.weight(.medium))
								Image(.onboardingEnableApp)
									.resizable()
									.scaledToFit()
									.roundedBorder(lineWidth: 2)
							}
							
							Label(L10n.ShareSheetHelpView.Explainer.Step3.goodToGoText, systemImage: "hand.thumbsup")
								.font(.title3)
								.fontWeight(.medium)
								.foregroundStyle(.blue)
								.padding(.top, 24)
						}
						.padding(.vertical)
						.frame(maxWidth: .infinity, alignment: .leading)
					}
				)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.padding()
		}
		.task {
			let status = await notification.notificationPermissionStatus()
			notificationEnabled = status == .authorized
		}
	}
}

#Preview("Explainer") {
	AppUsageExplainer()
}
