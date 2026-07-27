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
				Text("How To!")
					.font(.title3)
					.fontWeight(.medium)
				Text("Works from Safari or any app")
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
					title: "Tap the share action",
					description: "Every app has an option to share content",
					additionalView: {
						VStack(alignment: .leading) {
							Image(.onboardingSharesheetLaunchSafari)
								.resizable()
								.scaledToFit()
								.roundedBorder(lineWidth: 2)
							Text("Ref: Safari")
								.font(.caption)
								.foregroundStyle(.secondary)
						}
						.padding(.vertical)
					}
				)
				StepRow(
					number: 2,
					title: "After tapping Lynk",
					description: "You are presented with a bookmark sheet that lets you save the link to Lynk",
					additionalView: {
						VStack(alignment: .leading) {
							Image(.onboardingLynkEditTitle)
								.resizable()
								.scaledToFit()
								.roundedBorder(lineWidth: 2)
							Text("On this flow, you are able to edit the link's title and set a reminder.")
								.font(.caption)
								.foregroundStyle(.secondary)
							// Wheck if user has notification enabled and show them the
							if notificationEnabled == false {
								VStack(alignment: .leading) {
									Text("To set a reminder, you need to enable notifications")
										.fontWeight(.semibold)
									PrimaryButton("Enable notifications") {
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
					title: "Can't find Lynk in the share sheet?",
					description: "When you can't find lynk in the enabled apps list, you can add it from here.",
					additionalView: {
						VStack(alignment: .leading) {
							VStack(alignment: .leading, spacing: 2) {
								Text("Tap More button")
									.font(.subheadline.weight(.medium))
								Image(.onboardingSharesheetApps)
									.resizable()
									.scaledToFit()
									.roundedBorder(lineWidth: 2)
							}
							VStack(alignment: .leading, spacing: 2) {
								Text("Tap Edit")
									.font(.subheadline.weight(.medium))
								Image(.onboardingEditSelection)
									.resizable()
									.scaledToFit()
									.roundedBorder(lineWidth: 2)
							}
							VStack(alignment: .leading, spacing: 2) {
								Text("Enable Lynk")
									.font(.subheadline.weight(.medium))
								Image(.onboardingEnableApp)
									.resizable()
									.scaledToFit()
									.roundedBorder(lineWidth: 2)
							}
							
							Label("Now you good to Go", systemImage: "hand.thumbsup")
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
