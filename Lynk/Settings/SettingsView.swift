//
//  SettingsView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 01/05/2025.
//

import MessageUI
import SwiftUI

struct SettingsView: View {
	@Environment(\.openURL) private var openURL
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var appTheme: AppTheme
	@EnvironmentObject private var storage: BookmarkStorage
	
	// Flag
	@Flag(.showSavePreview) private var showSavePreview
	@State private var showSavePreviewLocalValue: Bool = false
	@Flag(.appLockEnabled) private var appLockEnabled
	@State private var appLockEnabledLocalValue = false
	@Flag(.enableReminders) private var enableReminders
	@State private var enableRemindersLocalValue: Bool = false
	
	// State properties
	@State private var presentEmailView = false
	@State private var showAbout = false
	@State private var emailCompose: MailComposeModel?
	@State private var presentDeleteAllAlert = false
	@State private var showPushNotificationsAlert: Bool = false
	
	private var authService = AuthService.shared
	private var notificationManager = NotificationManager.shared
	
    var body: some View {
		VStack {
			HStack {
				Text("Settings")
					.font(.title2)
					.fontWeight(.semibold)
					.fontDesign(.serif)
			}
			.frame(maxWidth: .infinity)
			.overlay(alignment: .trailing) {
				Button {
					dismiss()
				} label: {
					Image(systemName: "xmark")
						.font(.title3)
						.padding(10)
						.roundedBorder(color: .gray.opacity(0.8), lineWidth: 1)
				}
				.buttonStyle(.plain)
				.shadow(color: Color.gray.opacity(0.2), radius: 2)
			}
			.padding(.top, 12)
			.padding(.horizontal)
			ScrollView {
				VStack(spacing: 16) {
					// Appearance
					container(title: "APPEARANCE") {
						HStack {
							HStack {
								Image(systemName: "moonphase.last.quarter.inverse")
									.font(.title)
								Text("Display\nMode")
							}
							.frame(maxWidth: .infinity, alignment: .leading)
							HStack {
								Button {
									appTheme.colorScheme = .none
								} label: {
									Image(systemName: "iphone.gen2")
										.font(.title2)
										.padding(12)
										.roundedBorder(color: Color.gray, lineWidth: appTheme.colorScheme == .none ? 3 : 1)
								}
								.buttonStyle(.plain)
								Button {
									appTheme.colorScheme = .light
								} label: {
									Image(systemName: "sun.max.fill")
										.font(.title2)
										.padding(12)
										.roundedBorder(color: Color.gray, lineWidth: appTheme.colorScheme == .light ? 3 : 1)
								}
								.buttonStyle(.plain)
								Button {
									appTheme.colorScheme = .dark
								} label: {
									Image(systemName: "moon.fill")
										.font(.title2)
										.padding(12)
										.roundedBorder(color: Color.gray, lineWidth: appTheme.colorScheme == .dark ? 3 : 1)
								}
								.buttonStyle(.plain)
							}
						}
					}
					// Data
					container(title: "DATA") {
						HStack {
							HStack(alignment: .top) {
								Image(systemName: "icloud")
									.padding(8)
									.roundedBorder(color: .gray.opacity(0.3))
								VStack(alignment: .leading, spacing: 4) {
									Text("iCloud Sync")
									Text("Sync with your icloud to access your data across devices.")
										.font(.caption)
										.foregroundStyle(.secondary)
										.multilineTextAlignment(.leading)
								}
								.frame(maxWidth: .infinity, alignment: .leading)
							}
							.frame(maxWidth: .infinity, alignment: .leading)
							Toggle(isOn: .constant(true)) { }
								.labelsHidden()
								.disabled(true)
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.background()
						.padding(.vertical, 4)
						separator()
						if authService.hasBiometrics() {
							HStack {
								HStack(alignment: .top) {
									Image(systemName: "faceid")
										.padding(8)
										.roundedBorder(color: .gray.opacity(0.3))
									VStack(alignment: .leading, spacing: 4) {
										Text("Biometric Authentication")
										Text("Protect your data on this app")
											.font(.caption)
											.foregroundStyle(.secondary)
											.multilineTextAlignment(.leading)
									}
									.frame(maxWidth: .infinity, alignment: .leading)
								}
								.frame(maxWidth: .infinity, alignment: .leading)
								Toggle(isOn: $appLockEnabledLocalValue) { }
									.labelsHidden()
							}
							.frame(maxWidth: .infinity, alignment: .leading)
							.background()
							.padding(.vertical, 4)
							separator()
						}
						// TODO: Refactor row to allow passing custom components ie support this
						HStack {
							HStack(alignment: .top) {
								Image(systemName: "trash")
									.foregroundStyle(.white)
									.padding(8)
									.background(Color.red)
									.roundedBorder(color: .gray.opacity(0.3))
								VStack(alignment: .leading, spacing: 4) {
									Text("Delete all your saved data")
									Text("This action will delete all the data shared or saved by this App")
										.font(.caption)
										.foregroundStyle(.secondary)
										.multilineTextAlignment(.leading)
								}
							}
							.frame(maxWidth: .infinity, alignment: .leading)
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.background()
						.padding(.vertical, 4)
						.onTapGesture {
							presentDeleteAllAlert = true
						}
					}
					// App
					container(title: "APP") {
						HStack {
							HStack(alignment: .top) {
								Image(systemName: "bell")
									.padding(8)
									.roundedBorder(color: .gray.opacity(0.3))
								VStack(alignment: .leading, spacing: 4) {
									Text("Reminder Notifications")
									Text("Enable this option if you would like to get reminders for your bookmarks")
										.font(.caption)
										.foregroundStyle(.secondary)
										.multilineTextAlignment(.leading)
								}
								.frame(maxWidth: .infinity, alignment: .leading)
							}
							.frame(maxWidth: .infinity, alignment: .leading)
							Toggle(isOn: $enableRemindersLocalValue) { }
								.labelsHidden()
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.background()
						.padding(.vertical, 4)
						.accessibilityAddTraits(.isButton)
						separator()
						HStack {
							HStack(alignment: .top) {
								Image(systemName: "square.split.1x2")
									.padding(8)
									.roundedBorder(color: .gray.opacity(0.3))
								VStack(alignment: .leading, spacing: 4) {
									Text("Show save preview")
									Text("This will let you see a preview of the data you are about to save in the app")
										.font(.caption)
										.foregroundStyle(.secondary)
										.multilineTextAlignment(.leading)
								}
								.frame(maxWidth: .infinity, alignment: .leading)
							}
							.frame(maxWidth: .infinity, alignment: .leading)
							Toggle(isOn: $showSavePreviewLocalValue) { }
								.labelsHidden()
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.background()
						.padding(.vertical, 4)
						.accessibilityAddTraits(.isButton)
						separator()
						row(icon: "star", title: "Rate the app", description: "Are you enjoying the app? Share your experience with others", disclosure: false) {
							AppReviewRequest.requestReviewManually()
						}
						separator()
						ShareApp()
						separator()
						row(icon: "captions.bubble", title: "Leave a feedback", description: "Do you have something to let us know about this app?", disclosure: false) {
							emailCompose = .feedback
						}
					}
					
					// Legal
					container(title: "LEGAL") {
						row(icon: "person.badge.key", title: "Privacy Policy", disclosure: false) {
							guard let url = URL(string: AppConstants.privacyPolicy) else { return }
							openURL(url)
						}
						separator()
						row(icon: "doc", title: "Terms And Conditions", disclosure: false) {
							guard let url = URL(string: AppConstants.termsAndConditions) else { return }
							openURL(url)
						}
					}
					
					// Help & Support
					container(title: "HELP & ABOUT") {
						row(icon: "info.circle", title: "About", description: "Know more about Lynk") {
							showAbout = true
						}
						separator()
						row(icon: "envelope", title: "Contact Support", description: "Reach out to our support team for any assistance") {
							emailCompose = .support
						}
						separator()
						row(icon: "airplayvideo", title: "How to use the app", description: "Finding it difficult to get started, here are some tips") {
							guard let url = URL(string: AppConstants.howtoDoc) else { return }
							openURL(url)
						}
					}
					if let appVersion = Bundle.main.appVersion, let appBuild = Bundle.main.appBuild {
						Text("Version \(appVersion)(\(appBuild))")
							.font(.callout)
							.foregroundStyle(.secondary)
					}
				}
				.padding()
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
			}
		}
		.sheet(isPresented: $presentEmailView) {
			MailComposeView(emailCompose ?? .support) { result in
				switch result {
				case .success(let response):
					print(response)
//					presentEmailView = false
				case .failure(let error):
					print("Email Error: \(error.localizedDescription)")
				}
			}
		}
		.sheet(isPresented: $showAbout) {
			VStack(spacing: 16) {
				Text("Lynk")
					.font(.title)
					.fontDesign(.serif)
					.fontWeight(.semibold)
				Text("""
				Lynk is a minimal, privacy-focused app that makes it easy to save and share text and URLs. Whether you're collecting notes, saving important links, or quickly sharing something with a friend, we keep everything in your iCloud
				""")
				.multilineTextAlignment(.leading)
				.fixedSize(horizontal: false, vertical: true)
				Spacer()
				Button {
					guard let url = URL(string: AppConstants.githubUrl) else { return }
					showAbout = false
					openURL(url)
				} label: {
					Text("View Project on Github")
						.fontWeight(.medium)
				}
				.foregroundStyle(Color(uiColor: .systemBackground))
				.padding(12)
				.frame(maxWidth: .infinity)
				.background(Color.primary)
				.roundedBorder()
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
			.padding(.vertical, 24)
			.padding(.horizontal)
			.presentationDetents([.fraction(0.4)])
			.presentationDragIndicator(.visible)
		}
		.onChange(of: emailCompose) { value in
			guard value != nil else { return }
			openSupportEmail()
		}
		.alert("Delete All Data", isPresented: $presentDeleteAllAlert) {
			Button("Delete", role: .destructive) {
				storage.deleteAllStoredBookmarks()
				presentDeleteAllAlert = false
			}
		} message: {
			Text("Are you sure you want to delete all the stored data?\nThis action cannot be undone.")
		}
		// Migrate this to the view model
		.onAppear {
			showSavePreviewLocalValue = showSavePreview
			appLockEnabledLocalValue = appLockEnabled
		}
		.onChange(of: showSavePreviewLocalValue) { value in
			guard value != showSavePreview else { return } // Prevent overwriting when it is the same value
			showSavePreview = value
		}
		.onChange(of: appLockEnabledLocalValue) { value in
			// When the new value is false, just flip the switch
			// Otherwise, request biometric permission
			guard value else {
				appLockEnabled = false
				return
			}
			Task {
				do {
					guard value != appLockEnabled else { return }
					let isTurnedOn = try await authService.authenticateUser()
					appLockEnabled = isTurnedOn
					appLockEnabledLocalValue = isTurnedOn
				} catch {
					appLockEnabled = false
					appLockEnabledLocalValue = false
				}
			}
		}
		.onChange(of: enableRemindersLocalValue) { value in
			enableReminders = value
			// Ideally, disabling this should disable it in system settings
			// For my implementation, I only disable it for the app and I won't be sending notifications from this app
			guard value else { return }
			Task {
				let state = try await notificationManager.requestNotificationPermission()
				guard state == false  else { return }
				let status = await notificationManager.notificationPermissionStatus()
				switch status {
				case .authorized:
					// We good to go
					break
				default:
					showPushNotificationsAlert = true
				}
			}
		}
		.task {
			let status = await notificationManager.notificationPermissionStatus()
			enableRemindersLocalValue = status == .authorized && enableReminders
		}
		.alert("Notification Permission Error", isPresented: $showPushNotificationsAlert) {
			Button("Settings") {
				enableRemindersLocalValue = false
				guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
				openURL(settingsUrl)
			}
			Button("Cancel") { enableRemindersLocalValue = false }
		} message: {
			Text("Open the settings app to enable the notifications.")
		}
    }
	
	// TODO: Figure out how to do the variadic input instead for reusability
	@ViewBuilder
	private func container<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(title)
				.foregroundStyle(.secondary)
			VStack {
				content()
			}
				.padding()
				.frame(maxWidth: .infinity, alignment: .leading)
				.roundedBorder(color: .gray)
		}
	}
	
	// TODO: Pass in the foreground color for icon and text
	@ViewBuilder
	private func row(
		icon: String,
		title: String,
		description: String? = nil,
		disclosure: Bool = true,
		action: (() -> Void)? = nil
	) -> some View {
		Button {
			action?()
		} label: {
			HStack {
				HStack(alignment: description == nil ? .center : .top) {
					Image(systemName: icon)
						.padding(8)
						.roundedBorder(color: .gray.opacity(0.3))
					VStack(alignment: .leading, spacing: 4) {
						Text(title)
						if let description {
							Text(description)
								.font(.caption)
								.foregroundStyle(.secondary)
								.multilineTextAlignment(.leading)
						}
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
				if disclosure {
					Image(systemName: "chevron.right")
						.fontWeight(.semibold)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.background()
			.padding(.vertical, 4)
		}
		.buttonStyle(.plain)
	}
	
	@ViewBuilder
	private func separator() -> some View {
		Rectangle()
			.fill(Color.gray.opacity(0.5))
			.frame(height: 0.5)
	}
	
	private func openSupportEmail() {
		if MailComposeModel.canSendMail {
			presentEmailView = true
		} else {
			MailComposeModel.support.sendEmail(openURL: openURL)
		}
	}
	
	@ViewBuilder
	private func ShareApp() -> some View {
		if let appURL = URL(string: AppConstants.appStoreUrl) {
			#warning("Fix the action related to this - And texts")
			ShareLink(
				item: appURL,
				subject: Text("YegoB App - Your Rwandan Music companion"),
				message: Text("Join me on YegoB by downloading the app from App store"),
				preview: SharePreview("YegoB App", image: Image(.logo))) {
					row(icon: "square.and.arrow.up", title: "Share the App", description: "Let your friends know about the beauty of this app!", disclosure: false)
						.foregroundStyle(Color(uiColor: .label))
				}
		} else {
			EmptyView()
		}
	}
}

#Preview {
    SettingsView()
		.environmentObject(AppTheme())
		.environmentObject(BookmarkStorage())
}
