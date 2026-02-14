//
//  AddLinkManuallyView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 14/02/2026.
//

import SwiftUI
import Combine

struct AddLinkManuallyView: View {
	@Flag(.enableReminders) private var enableReminders
	@Environment(\.dismiss) private var dismiss
	@Environment(\.isPresented) private var isPresented
	
	init() { }
	
	@ObservedObject private var viewModel = ExtensionShareViewModel()
	@State private var addedLink = ""
	@State private var addedLinkSubject = PassthroughSubject<URL, Never>()
	@State private var cancellable = Set<AnyCancellable>()
	@State private var linkTitle = ""
	@State private var setReminder = false
	@State private var selectedDate = Date()
	@State private var selectedTime = Date()
	@State private var linkFavicon: String?
	@State private var loading = false
	
    var body: some View {
		VStack(spacing: .zero) {
			headerView
				.padding(.bottom)
			Divider()
			ScrollView {
				VStack(spacing: 16) {
					if let linkFavicon {
						RemoteImage(url: linkFavicon)
							.frame(width: 100, height: 100)
							.roundedBorder()
					}
					VStack(alignment: .leading, spacing: 4) {
						Text(L10n.AddLinkManuallyView.TextField.linkTitle)
							.fontWeight(.medium)
						TextField(text: $addedLink, axis: .vertical) {
							Text(L10n.AddLinkManuallyView.TextField.linkPlaceholder)
						}
						.font(.body)
						.keyboardType(.URL)
						.autocorrectionDisabled()
						.textInputAutocapitalization(.never)
						.padding(.vertical, 12)
						.padding(.horizontal, 8)
						.roundedBorder()
					}
					if loading {
						ProgressView()
					}
					VStack(alignment: .leading, spacing: 4) {
						Text(L10n.AddLinkManuallyView.TextField.titleText)
							.fontWeight(.medium)
						TextField(text: $linkTitle, axis: .vertical) {
							Text(L10n.AddLinkManuallyView.TextField.titleTextPlaceholder)
						}
						.font(.body)
						.keyboardType(.default)
						.autocorrectionDisabled()
						.textInputAutocapitalization(.never)
						.padding(.vertical, 12)
						.padding(.horizontal, 8)
						.roundedBorder()
					}
					#if DEBUG
					// Reminder has an issue where dismissing the calendar picker dismisses the view too
					// Fix that issue and remove the DEBUB flag
					// Reminder
					Button {
						setReminder.toggle()
					} label: {
						HStack {
							Image(systemName: setReminder ? "checkmark.square" : "square")
								.resizable()
								.scaledToFit()
								.frame(width: 20, height: 20)
							Text(L10n.AddLinkManuallyView.setReminderText)
								.font(.title3)
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.background()
					}
					.buttonStyle(.plain)
					.padding()
					.roundedBorder()
					
					if setReminder {
						ReminderView(selectedDate: $selectedDate, selectedTime: $selectedTime)
					}
					#endif
					Button {
						guard let model = viewModel.model else { return }
						var reminder: ExtensionShareViewModel.ReminderContent? {
							enableReminders && setReminder ? ExtensionShareViewModel.ReminderContent(date: selectedDate, time: selectedTime) : nil
						}
						viewModel.saveBookmark(model, reminder: reminder) {
							Task {
								try? await Task.sleep(for: .seconds(2))
								dismiss()
							}
						}
					} label: {
						Label(L10n.AddLinkManuallyView.Button.title, systemImage: "square.and.arrow.down")
							.foregroundStyle(Color.white)
							.padding(12)
							.frame(maxWidth: .infinity)
							.background(Color.blue)
							.roundedBorder(color: .blue, lineWidth: 12)
					}
					.buttonStyle(.plain)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.padding(.vertical)
			}
		}
		.padding()
		.background()
		.overlay {
			SaveStatusView(status: viewModel.saveStatus)
		}
		.onChange(of: addedLink) { link in
			guard let url = URL(string: link), url.isValid else { return }
			addedLinkSubject.send(url)
		}
		.onAppear {
			addedLinkSubject
				.debounce(for: .milliseconds(500), scheduler: RunLoop.main)
				.sink { url in
					updateLinkInfo(url: url)
				}
				.store(in: &cancellable)
		}
    }
	
	var headerView: some View {
		HStack {
			Text(L10n.AddLinkManuallyView.title)
				.font(.title2)
				.fontWeight(.semibold)
				.frame(maxWidth: .infinity)
			if isPresented {
				Button {
					dismiss()
				} label: {
					Image(systemName: "xmark")
						.resizable()
						.scaledToFit()
						.frame(width: 16, height: 16)
						.padding(12)
						.background(Color.gray.opacity(0.2))
						.roundedBorder(for: .circle)
				}
				.buttonStyle(.plain)
			}
		}
		.frame(maxWidth: .infinity)
	}
}

extension AddLinkManuallyView {
	func updateLinkInfo(url: URL) {
		Task {
			do {
				loading = true
				let metadata = WebPageMetadata.shared
				let content = try await metadata.fetchPageMetadata(from: url)
				if let title = content.title {
					linkTitle = title
				}
				linkFavicon = content.faviconURL?.absoluteString
			} catch {
				// Handle failure to get the data
			}
			loading = false
		}
	}
}

#Preview {
	AddLinkManuallyView()
}

extension View {
	func addLinkManually(_ isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil) -> some View {
		self.sheet(isPresented: isPresented) {
			onDismiss?()
		} content: {
			AddLinkManuallyView()
		}
	}
}
