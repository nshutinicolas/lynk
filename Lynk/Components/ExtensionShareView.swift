//
//  ExtensionShareView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 16/05/2025.
//

import SwiftUI

enum ExtensionShareError: Error {
	case invalidType(String)
	case invalidData
	
	var description: String {
		switch self {
		case .invalidType(let type):
			return "Invalid type - \(type)"
		case .invalidData:
			return "Invalid data"
		}
	}
}

class ExtensionShareViewModel: ObservableObject {
	@Flag(.showSavePreview) private(set) var showSavePreview
	
	@Published var saveStatus: SaveStatus = .loading
	@Published var showSavePreviewOverlay: Bool = false
	@Published var model: BookmarkModel?
	
	private let network = WebPageMetadata.shared
	private let notificationManager = NotificationManager.shared
	private var saveTask: Task<Void, Never>?
	
	init() { }
	
	deinit{
		saveTask?.cancel()
	}
	
	/// Change the value for `saveStatus`
	/// - Parameter status: `SaveStatus`
	@MainActor
	func updateSaveStatus(to status: SaveStatus) {
		saveStatus = status
	}
	
	@MainActor
	func updateOverlayVisibility(_ visible: Bool) {
		showSavePreviewOverlay = visible
	}
	
	func saveBookmark(_ model: BookmarkModel, reminder: ReminderContent? = nil, completion: @escaping () -> Void) {
		guard saveTask == nil, let lightStorage = BookmarkStorage.createLightweightContainer() else { return }
		saveTask = Task {
			await updateSaveStatus(to: .loading)
			await updateOverlayVisibility(true)
			let context = lightStorage.viewContext
			await context.perform {
				let bookmark = BookmarkStorage.nsBookmark(for: model, context: context)
				if bookmark.hasChanges {
					try? context.save()
				}
			}
			if let reminder {
				notificationManager.scheduleNotification(
					for: model,
					date: reminder.date,
					time: reminder.time
				)
			}
//			try lightStorage.save(model: model)
			await updateSaveStatus(to: .success)
			// Introduce in a little delay in-between
			try? await Task.sleep(for: .seconds(2))
			completion()
			saveTask = nil
		}
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
				/**
				 Note: Some apps render their url as a string like linkedin and youtube(only tested on these)
				 The task for this edge case is to check if the string is url or just text
				 
				 When the url is valid, rerun updateContent(with:) with contentType as url
				 */
				if let url = URL(string: sharedText), url.isValid {
					try await updateContent(with: url as NSSecureCoding, contentType: SupportedContentType.url.rawValue)
				} else {
					model = BookmarkModel(id: UUID().uuidString, category: .text(sharedText))
				}
			} else {
				throw ExtensionShareError.invalidData
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
					model = BookmarkModel(id: UUID().uuidString, category: .url(url: url.absoluteString))
				}
			} else {
				throw ExtensionShareError.invalidData
			}
		case .webPage:
			guard let sharedData = data as? NSDictionary, let jsonValue = sharedData[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { break }
			guard let title = jsonValue["title"] as? String,
				  let urlString = jsonValue["url"] as? String,
				  let iconUrl = jsonValue["icon"] as? String
			else { break }
			
			model = BookmarkModel(id: UUID().uuidString, category: .webPage(title: title, url: urlString, imageUrl: iconUrl))
		default:
			throw ExtensionShareError.invalidType(contentType)
		}
	}
	
	enum SupportedContentType: String {
		case note = "public.plain-text"
		case url = "public.url"
		case webPage = "com.apple.property-list" // When Shared with Safari
	}
	
	struct ReminderContent {
		let date: Date
		let time: Date
	}
}

struct ExtensionShareView: View {
	@Flag(.showSavePreview) private var showSavePreview
	@Flag(.enableReminders) private var enableReminders
	
	@ObservedObject private var viewModel = ExtensionShareViewModel()
	@State private var setReminder: Bool = false
	@State private var selectedDate: Date = .now
	@State private var selectedTime: Date = .now
	
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
						Button {
							onClose()
						} label: {
							Image(systemName: "xmark")
								.resizable()
								.scaledToFit()
								.foregroundStyle(Color(uiColor: .label))
								.frame(width: 16, height: 16)
								.frame(width: 44, height: 44)
								.background(Color(uiColor: .secondarySystemBackground))
								.clipShape(.circle)
						}
						.buttonStyle(.plain)
					}
					.frame(maxWidth: .infinity, alignment: .trailing)
					VStack {
						if let model = viewModel.model {
							ItemCellView(model: model)
								.transition(.move(edge: .bottom).combined(with: .opacity))
						} else {
							ProgressView()
								.controlSize(.regular)
								.frame(width: 48, height: 48)
								.transition(.opacity)
						}
					}
					.animation(.default, value: viewModel.model)
					if enableReminders {
						Group {
							HStack {
								Group {
									if setReminder {
										Image(systemName: "checkmark.square")
											.resizable()
											.frame(width: 20, height: 20)
									} else {
										Image(systemName: "square")
											.resizable()
											.frame(width: 20, height: 20)
									}
								}
								.animation(.easeInOut, value: setReminder)
								Text("Set Reminder")
							}
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(12)
							.roundedBorder()
							.onTapGesture {
								withAnimation {
									setReminder.toggle()
								}
							}
							// Reminder View
							if setReminder {
								ReminderView(selectedDate: $selectedDate, selectedTime: $selectedTime)
									.transition(.move(edge: .bottom).combined(with: .opacity))
							}
						}
					}
					Button {
						// When user attampts to save a non-existing bookmark, show an error/warning or inform them
						guard let model = viewModel.model else { return }
						var reminder: ExtensionShareViewModel.ReminderContent? {
							enableReminders && setReminder ? ExtensionShareViewModel.ReminderContent(date: selectedDate, time: selectedTime) : nil
						}
						viewModel.saveBookmark(model, reminder: reminder) {
							onClose()
						}
					} label: {
						Label("Bookmark", systemImage: "square.and.arrow.down")
							.fontWeight(.medium)
							.foregroundStyle(.white)
							.frame(maxWidth: .infinity)
					}
					.padding(.vertical, 12)
					.background(Color.blue)
					.roundedBorder()
					.padding(.bottom, 12)
				}
				.padding([.horizontal, .top])
				.background()
				// TODO: Find an alternative to adding top coners without affecting the safe area fill
//				.clipShape(.rect(cornerRadii: RectangleCornerRadii(
//					topLeading: 12,
//					bottomLeading: 0,
//					bottomTrailing: 0,
//					topTrailing: 12
//				)))
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
				viewModel.saveBookmark(model) {
					onClose()
				}
			}
		}
		.task {
			await viewModel.getSharedContent(with: context)
		}
	}
}

// TODO: Fix the preview to show mocked content
#Preview("Extension") {
	ExtensionShareView(context: nil, onClose: { })
		.environmentObject(BookmarkStorage())
}
