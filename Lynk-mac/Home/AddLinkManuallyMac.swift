//
//  AddLinkManuallyMac.swift
//  Lynk-mac
//
//  Created by Musoni nshuti Nicolas on 16/02/2026.
//

import Combine
import SwiftUI

// This is a copy/paste of AddLinkManually
// Was a bit lazy to refactor but will look into it with this TODO
// TODO: Make this view generic to be able to work on both platforms
// Remove the duplication
struct AddLinkManuallyMac: View {
	@Flag(.enableReminders) private var enableReminders
	@Environment(\.dismiss) private var dismiss
	@Environment(\.isPresented) private var isPresented
	@EnvironmentObject private var bookmark: BookmarkStorage
	
	init() { }
	
	@State private var addedLink = ""
	@State private var addLinkFieldHasError = false
	@State private var addedLinkSubject = PassthroughSubject<URL, Never>()
	@State private var cancellable = Set<AnyCancellable>()
	@State private var linkTitle = ""
	@State private var linkTitleHasError = false
	
	@State private var linkFavicon: String?
	@State private var loading = false
	@State private var saveStatus: SaveStatus = .idle
	
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
						// To remove the default background color, use plain field style
						.textFieldStyle(.plain)
						.font(.body)
						.autocorrectionDisabled()
						.padding(.vertical, 12)
						.padding(.horizontal, 8)
						.roundedBorder(color: addLinkFieldHasError ? .red : .gray.opacity(0.5))
						if addLinkFieldHasError {
							Text(L10n.AddLinkManuallyView.TextField.linkFieldError)
								.font(.footnote)
								.foregroundStyle(Color.red)
						}
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
						.textFieldStyle(.plain)
						.font(.body)
						.autocorrectionDisabled()
						.padding(.vertical, 12)
						.padding(.horizontal, 8)
						.roundedBorder(color: linkTitleHasError ? .red : .gray.opacity(0.5))
						if linkTitleHasError {
							Text(L10n.AddLinkManuallyView.TextField.titleTextError)
								.font(.footnote)
								.foregroundStyle(Color.red)
						}
					}
					
					Button {
						var hasError = false
						if addedLink.isEmpty {
							addLinkFieldHasError = true
							hasError = true
						}
						let url = URL(string: addedLink)
						if url == nil || url?.isValid == false {
							addLinkFieldHasError = true
							hasError = true
						}
						if linkTitle.count <= 4 {
							linkTitleHasError = true
							hasError = true
						}
						guard hasError == false else { return }
						var category: BookmarkModel.Category
						if let linkFavicon {
							category = .webPage(title: linkTitle, url: addedLink, imageUrl: linkFavicon)
						} else {
							category = .url(url: addedLink, title: linkTitle.isEmpty ? nil : linkTitle)
						}
						let model = BookmarkModel(id: UUID().uuidString, category: category)
						saveBookmark(model)
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
			SaveStatusView(status: saveStatus)
		}
		.onChange(of: linkTitle) { _ in
			linkTitleHasError = false
		}
		.onChange(of: addedLink) { link in
			addLinkFieldHasError = false
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

extension AddLinkManuallyMac {
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
	
	func saveBookmark(_ model: BookmarkModel) {
		Task {
			do {
				saveStatus = .loading
				try bookmark.save(model: model)
				try? await Task.sleep(for: .seconds(1))
				saveStatus = .success
				try? await Task.sleep(for: .seconds(1))
				dismiss()
			} catch {
				// Handle coredata failure
			}
		}
	}
}

#Preview {
    AddLinkManuallyMac()
}

// MARK: - View+Extension

extension View {
	func addLinkManuallyMac(_ isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil) -> some View {
		self.sheet(isPresented: isPresented) {
			onDismiss?()
		} content: {
			AddLinkManuallyMac()
		}
	}
}
