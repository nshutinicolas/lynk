//
//  ExtensionShareView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 16/05/2025.
//

import SwiftUI

class ExtensionShareViewModel: ObservableObject {
	@Flag(.showSavePreview) private(set) var showSavePreview
	@Published var saveStatus: SaveStatus = .loading
	@Published var showSavePreviewOverlay: Bool = false
	@Published var model: BookmarkModel?
	
	private let network = Network.shared
	
	init() { }
	
	/// Change the value for `saveStatus`
	/// - Parameter status: `SaveStatus`
	@MainActor
	func updateSaveStatus(to status: SaveStatus) {
		saveStatus = status
	}
	
	@MainActor
	func getSharedContent(with context: NSExtensionContext?) async {
		do {
			try await asyncGetSharedData(for: context)
			saveStatus = .success
		} catch let error as SaveError {
			// Handle errors
			print(error.errorDescription)
			saveStatus = .error(error)
		} catch {
			// Handle unknow errors
			saveStatus = .error(.custom(error.localizedDescription))
		}
	}
	@MainActor
	private func asyncGetSharedData(for context: NSExtensionContext?) async throws {
		guard let extensionItems = context?.inputItems as? [NSExtensionItem] else {
			saveStatus = .error(.invalidInputItems)
			throw SaveError.invalidInputItems
		}
		
		await withTaskGroup(of: Void.self) { [weak self] group in
			for extensionItem in extensionItems {
				let attachments = extensionItem.attachments ?? []
				for attachment in attachments {
					guard let contentType = attachment.registeredContentTypes.first?.identifier else { continue }
					group.addTask {
						do {
							let sharedData = try await attachment.loadItem(forTypeIdentifier: contentType, options: nil)
							try await self?.updateContent(with: sharedData, contentType: contentType)
						} catch {
							self?.saveStatus = .error(.invalidData)
						}
					}
				}
			}
		}
	}
	
	@MainActor
	private func updateContent(with data: NSSecureCoding, contentType: String) async throws {
		switch SupportedContentType(rawValue: contentType) {
		case .note:
			if let sharedText = data as? String {
				model = BookmarkModel(id: UUID().uuidString, category: .text(sharedText))
			} else {
				throw SaveError.invalidData
			}
		case .url:
			if let url = data as? URL {
				do {
					let metadata = try await self.network.fetchPageMetadata(from: url)
					guard let title = metadata.title, let iconUrl = metadata.faviconURL?.absoluteString else {
						throw NSError(domain: "INVALID_DATA", code: 400)
					}
					model = BookmarkModel(id: UUID().uuidString, category: .webPage(title: title , url: url.absoluteString, imageUrl: iconUrl))
				} catch {
					model = BookmarkModel(id: UUID().uuidString, category: .url(url.absoluteString))
				}
			} else {
				throw SaveError.invalidData
			}
		case .webPage:
			guard let sharedData = data as? NSDictionary, let jsonValue = sharedData[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { break }
			guard let title = jsonValue["title"] as? String, let urlString = jsonValue["url"] as? String, let url = URL(string: urlString), let iconUrl = jsonValue["icon"] as? String else { break }
			
			do {
				let metadata = try await network.fetchPageMetadata(from: url)
				// Learn the behavior of getting the favicon - sometimes it fails
				guard let title = metadata.title, let _ = metadata.faviconURL?.absoluteString else {
					throw NSError(domain: "INVALID_DATA", code: 400)
				}
				model = BookmarkModel(id: UUID().uuidString, category: .webPage(title: title , url: url.absoluteString, imageUrl: iconUrl))
			} catch {
				model = BookmarkModel(id: UUID().uuidString, category: .webPage(title: title, url: urlString, imageUrl: iconUrl))
			}
		default:
			throw SaveError.invalidType
		}
	}
	
	enum SupportedContentType: String {
		case note = "public.plain-text"
		case url = "public.url"
		case webPage = "com.apple.property-list" // When Shared with Safari
	}
}

struct ExtensionShareView: View {
	@Flag(.showSavePreview) private var showSavePreview
	// Using it this way as a hack to make it shared with the extension
	private var localStorage = BookmarkStorage.shared
	
	@ObservedObject private var viewModel = ExtensionShareViewModel()
	
	// Private
	private let context: NSExtensionContext?
	
	private var onClose: () -> Void
	init(context: NSExtensionContext?, onClose: @escaping () -> Void) {
		self.onClose = onClose
		self.context = context
	}
	
	var body: some View {
		VStack {
			if showSavePreview {
				VStack(spacing: 16) {
					HStack {
						Circle()
							.fill(Color(uiColor: .secondarySystemBackground))
							.frame(width: 44, height: 44)
							.overlay {
								Image(systemName: "xmark")
									.resizable()
									.scaledToFit()
									.foregroundStyle(Color(uiColor: .label))
									.frame(width: 16, height: 16)
							}
							.onTapGesture {
								onClose()
							}
					}
					.frame(maxWidth: .infinity, alignment: .trailing)
					if let model = viewModel.model {
						ItemCellView(model: model)
					}
					Button {
						// When user attampts to save a non-existing bookmark, show an error/warning or inform them
						guard let model = viewModel.model else { return }
						saveBookmark(model)
					} label: {
						Label("Bookmark", systemImage: "square.and.arrow.down")
							.fontWeight(.medium)
							.foregroundStyle(.white)
					}
					.padding(.vertical, 12)
					.frame(maxWidth: .infinity)
					.background(Color.blue)
					.roundedBorder()
					.padding(.bottom)
				}
				.padding([.horizontal, .top])
				.background()
				.clipShape(.rect(cornerRadii: .init(topLeading: 12, bottomLeading: 0, bottomTrailing: 0, topTrailing: 12)))
			} else {
				EmptyView()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
		.overlay(alignment: .center) {
			if viewModel.showSavePreviewOverlay {
				SaveStatusView(status: viewModel.saveStatus)
					.animation(.easeInOut, value: viewModel.showSavePreviewOverlay)
			} else if viewModel.showSavePreview == false {
				SaveStatusView(status: viewModel.saveStatus)
					.animation(.easeInOut, value: viewModel.showSavePreview)
			}
		}
		.onChange(of: viewModel.model) { model in
			guard let model else { return }
			if viewModel.showSavePreview == false {
				saveBookmark(model)
			}
		}
		.task {
			await viewModel.getSharedContent(with: context)
		}
	}
	
	private func saveBookmark(_ model: BookmarkModel) {
		Task {
			do {
				try localStorage.save(model: model)
				viewModel.updateSaveStatus(to: .success)
				// Introduce in a little delay in-between
				try? await Task.sleep(for: .seconds(2))
				onClose()
			} catch {
				viewModel.updateSaveStatus(to: .error(.custom(error.localizedDescription)))
				// Introduce in a little delay in-between
				try? await Task.sleep(for: .seconds(2))
				onClose()
			}
		}
	}
}

#Preview {
	ExtensionShareView(context: nil, onClose: { })
		.environmentObject(BookmarkStorage())
}
