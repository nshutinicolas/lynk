//
//  SettingsView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 01/05/2025.
//

import SwiftUI

struct SettingsView: View {
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var appTheme: AppTheme
	
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
				Image(systemName: "xmark")
					.font(.title3)
					.padding(10)
					.onTapGesture {
						withAnimation {
							dismiss()
						}
					}
					.roundedBorder(color: .gray.opacity(0.8), lineWidth: 1)
			}
			.padding(.vertical, 12)
			.padding(.horizontal)
			ScrollView {
				VStack {
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
									Image(systemName: "iphone.gen2")
										.font(.title2)
										.padding(12)
										.roundedBorder(lineWidth: appTheme.colorScheme == .none ? 3 : 1)
										.onTapGesture {
											appTheme.colorScheme = .none
										}
									Image(systemName: "sun.max.fill")
										.font(.title2)
										.padding(12)
										.roundedBorder(lineWidth: appTheme.colorScheme == .light ? 3 : 1)
										.onTapGesture {
											appTheme.colorScheme = .light
										}
									Image(systemName: "moon.fill")
										.font(.title2)
										.padding(12)
										.roundedBorder(lineWidth: appTheme.colorScheme == .dark ? 3 : 1)
										.onTapGesture {
											appTheme.colorScheme = .dark
										}
								}
							}
						}
						// Data
						container(title: "DATA") {
							row(icon: "icloud", title: "iCloud Sync", description: "Sync with your icloud to access your data across devices.", disclosure: true)
							separator()
							row(icon: "faceid", title: "Biometric Authentication", description: "Protect your data on this app", disclosure: true)
							separator()
							row(icon: "trash", title: "Delete all your saved data", description: "This action will delete all the data shared or saved by this App")
						}
						
						// App
						container(title: "APP") {
							row(icon: "star", title: "Rate the app", description: "Are you enjoying the app? Share your experience with others", disclosure: false)
							separator()
							row(icon: "square.and.arrow.up", title: "Share the App", description: "Let your friends know about the beauty of this app!", disclosure: false)
							separator()
							row(icon: "bubble.and.pencil.rtl", title: "Leave a feedback", description: "Do you have something to let us know about this app?", disclosure: false)
						}
						
						// Legal
						container(title: "LEGAL") {
							row(icon: "person.badge.key", title: "Privacy Policy", disclosure: false)
							separator()
							row(icon: "document", title: "Privacy Policy", disclosure: false)
						}
						
						// Help & Support
						container(title: "HELP & ABOUT") {
							row(icon: "info.circle", title: "About", description: "Know more about Lynk")
							separator()
							row(icon: "envelope", title: "Contact Support", description: "Reach out to our support team for any assistance")
							separator()
							row(icon: "airplayvideo", title: "How to use the app", description: "Finding it difficult to get started, here are some tips")
						}
						Text("Version 1.0.0(12)")
							.font(.callout)
							.foregroundStyle(.secondary)
					}
					.padding()
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
			}
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
	private func row(icon: String, title: String, description: String? = nil, disclosure: Bool = true) -> some View {
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
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			if disclosure {
				Image(systemName: "chevron.right")
					.fontWeight(.semibold)
			}
		}
		.padding(.vertical, 4)
	}
	
	@ViewBuilder
	private func separator() -> some View {
		Rectangle()
			.fill(Color.gray.opacity(0.5))
			.frame(height: 0.5)
	}
}

#Preview {
    SettingsView()
		.environmentObject(AppTheme())
}
