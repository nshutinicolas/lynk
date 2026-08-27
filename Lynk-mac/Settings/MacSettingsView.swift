//
//  MacSettingsView.swift
//  Lynk-mac
//
//  Created by Musoni nshuti Nicolas on 28/08/2026.
//

import SwiftUI

struct MacSettingsView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.openURL) private var openURL
	@EnvironmentObject private var storage: BookmarkStorage

	@State private var presentDeleteAllAlert = false
	@State private var showAbout = false

	var body: some View {
		VStack(spacing: 0) {
			header
			ScrollView {
				VStack(spacing: 16) {
					dataSection
					appSection
					legalSection
					helpAndSupportSection
					versionView
				}
				.padding()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.alert(L10n.SettingsView.Alert.DeleteAllData.title, isPresented: $presentDeleteAllAlert) {
			Button(L10n.Button.delete, role: .destructive) {
				storage.deleteAllStoredBookmarks()
			}
		} message: {
			Text(L10n.SettingsView.Alert.DeleteAllData.message)
		}
		.alert(L10n.appTitle, isPresented: $showAbout) {
			Button(L10n.SettingsView.Alert.About.Button.viewOnGithub) {
				openExternalURL(AppConstants.githubUrl)
			}
			Button(L10n.Button.cancel, role: .cancel) { }
		} message: {
			Text(L10n.SettingsView.Alert.About.bodyMessage)
		}
	}

	private var header: some View {
		HStack {
			Text(L10n.SettingsView.title)
				.font(.title2)
				.fontWeight(.semibold)
				.fontDesign(.serif)
			Spacer()
			Button {
				dismiss()
			} label: {
				Image(systemName: "xmark")
					.font(.title3)
					.padding(10)
					.roundedBorder(color: .gray.opacity(0.8), lineWidth: 1)
			}
			.buttonStyle(.plain)
		}
		.padding(.top, 12)
		.padding(.horizontal)
	}

	private var dataSection: some View {
		settingsContainer(title: String(localized: L10n.SettingsView.Section.Data.title)) {
			HStack {
				settingsLabel(
					icon: "icloud",
					title: L10n.SettingsView.Section.Data.icloudSync,
					description: L10n.SettingsView.Section.Data.icloudSyncDescription
				)
				Toggle(isOn: .constant(true)) { EmptyView() }
					.labelsHidden()
					.disabled(true)
			}
			settingsSeparator()
			settingsRow(
				icon: "trash",
				title: L10n.SettingsView.Section.Data.deleteAllData,
				description: L10n.SettingsView.Section.Data.deleteAllDataDescription,
				isDestructive: true
			) {
				presentDeleteAllAlert = true
			}
		}
	}

	private var appSection: some View {
		settingsContainer(title: String(localized: L10n.SettingsView.Section.App.title)) {
			settingsRow(
				icon: "captions.bubble",
				title: L10n.SettingsView.Section.App.leaveFeedback,
				description: L10n.SettingsView.Section.App.leaveFeedbackDescription
			) {
				openSupportEmail(subject: String(localized: L10n.MailCompose.Model.Subject.feedback))
			}
		}
	}

	private var legalSection: some View {
		settingsContainer(title: String(localized: L10n.SettingsView.Section.Legal.title)) {
			settingsRow(icon: "person.badge.key", title: L10n.SettingsView.Section.Legal.privacyPolicy) {
				openExternalURL(AppConstants.privacyPolicy)
			}
			settingsSeparator()
			settingsRow(icon: "doc", title: L10n.SettingsView.Section.Legal.termsAndConditions) {
				openExternalURL(AppConstants.termsAndConditions)
			}
		}
	}

	private var helpAndSupportSection: some View {
		settingsContainer(title: String(localized: L10n.SettingsView.Section.HelpAndSupport.title)) {
			settingsRow(
				icon: "info.circle",
				title: L10n.SettingsView.Section.HelpAndSupport.about,
				description: L10n.SettingsView.Section.HelpAndSupport.aboutDescription
			) {
				showAbout = true
			}
			settingsSeparator()
			settingsRow(
				icon: "envelope",
				title: L10n.SettingsView.Section.HelpAndSupport.contactSupport,
				description: L10n.SettingsView.Section.HelpAndSupport.contactSupportDescription
			) {
				openSupportEmail(subject: String(localized: L10n.MailCompose.Model.Subject.support))
			}
		}
	}

	private var versionView: some View {
		Group {
			if let appVersion = Bundle.main.appVersion, let appBuild = Bundle.main.appBuild {
				Text(L10n.SettingsView.appVersion(appVersion: appVersion, appBuild: appBuild))
					.font(.callout)
					.foregroundStyle(.secondary)
			}
		}
	}

	private func openExternalURL(_ urlString: String) {
		guard let url = URL(string: urlString) else { return }
		openURL(url)
	}

	private func openSupportEmail(subject: String) {
		// TODO: Implement opening the email app
	}

	@ViewBuilder
	private func settingsContainer<Content: View>(
		title: String,
		@ViewBuilder content: () -> Content
	) -> some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(title)
				.foregroundStyle(.secondary)
			VStack(spacing: 8) {
				content()
			}
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
			.roundedBorder(color: .gray)
		}
	}

	private func settingsLabel(
		icon: String,
		title: LocalizedStringResource,
		description: LocalizedStringResource
	) -> some View {
		HStack(alignment: .top) {
			Image(systemName: icon)
				.padding(8)
				.roundedBorder(color: .gray.opacity(0.3))
			VStack(alignment: .leading, spacing: 4) {
				Text(title)
				Text(description)
					.font(.caption)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.leading)
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	private func settingsRow(
		icon: String,
		title: LocalizedStringResource,
		description: LocalizedStringResource? = nil,
		isDestructive: Bool = false,
		action: @escaping () -> Void
	) -> some View {
		Button(action: action) {
			HStack {
				HStack(alignment: description == nil ? .center : .top) {
					Image(systemName: icon)
						.foregroundStyle(isDestructive ? Color.white : Color.primary)
						.padding(8)
						.background(isDestructive ? Color.red : Color.clear)
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
				}
				Spacer()
				Image(systemName: "chevron.right")
					.fontWeight(.semibold)
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.background()
		}
		.buttonStyle(.plain)
	}

	private func settingsSeparator() -> some View {
		Rectangle()
			.fill(Color.gray.opacity(0.5))
			.frame(height: 0.5)
	}
}

#if DEBUG
#Preview {
	MacSettingsView()
		.environmentObject(BookmarkStorage.shared)
}
#endif
