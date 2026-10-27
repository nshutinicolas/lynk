//
//  MacHomeView.swift
//  Lynk-mac
//
//  Created by Musoni nshuti Nicolas on 31/05/2025.
//

import SwiftUI

struct MacHomeView: View {
	@State private var searchText: String = ""
	@State private var selectedBookmark: BookmarkModel?
	@State private var presentAddLink = false
	@State private var presentSettings = false
	@Environment(\.managedObjectContext) private var localStorage
	
	@FetchRequest(fetchRequest: Bookmark.listFetchRequest) var bookmarksFetch: FetchedResults<Bookmark>
	
    var body: some View {
		NavigationSplitView {
			VStack(spacing: 16) {
				HStack {
					Button {
						presentSettings = true
					} label: {
						Image(systemName: "gear")
							.font(.title3)
							.padding(4)
							.background(Color.gray.opacity(0.3))
							.roundedBorder()
							.hoverPopover(enabled: true, text: L10n.MacHomeView.Header.settingsHoverText)
					}
					.buttonStyle(.plain)
					Spacer()
					HStack(spacing: 16) {
						Button {
							presentAddLink = true
						} label: {
							Image(systemName: "plus")
								.font(.title3)
								.padding(4)
								.hoverPopover(enabled: true, text: L10n.MacHomeView.Header.addLinkManuallyHoverText)
						}
						.buttonStyle(.plain)
						#if DEBUG
						// TODO: Remove the flag after implementing these options
						Button { } label: {
							Image(systemName: "line.3.horizontal.decrease")
								.font(.title3)
								.padding(4)
						}
						.buttonStyle(.plain)
						#endif
						
						Button {
							localStorage.refreshAllObjects()
						} label: {
							Image(systemName: "arrow.clockwise")
								.font(.title3)
								.padding(4)
								.hoverPopover(enabled: true, text: L10n.MacHomeView.Header.refreshContentHoverText)
						}
						.buttonStyle(.plain)
					}
				}
				HStack {
					Image(systemName: "magnifyingglass")
					TextField(String(localized: L10n.MacHomeView.SearchTextField.placeholder), text: $searchText)
						.textFieldStyle(.plain)
					Image(systemName: "xmark")
						.font(.caption2)
						.padding(4)
						.background(Color.gray.opacity(0.2))
						.clipShape(.circle)
						.opacity(searchText.isEmpty ? 0 : 1)
						.animation(.smooth, value: searchText.isEmpty == false)
						.onTapGesture {
							searchText = ""
						}
				}
				.padding(8)
				.background(
					RoundedRectangle(cornerRadius: 8)
						.stroke(lineWidth: 0.5)
				)
				if bookmarksFetch.isEmpty {
					emptyBookmarksView
				} else {
					List {
						Section {
							ForEach(bookmarksFetch) { bookmark in
								if let model = bookmark.createItemCellViewModel() {
									ItemCellView(model: model)
										.onTapGesture {
											selectedBookmark = model
										}
										.contextMenu {
											Button {
												copyToClipboard(model.category)
											} label: {
												Label(L10n.Button.copy, systemImage: "document.on.document")
											}
											Button {
											} label: {
												Label(L10n.Button.edit, systemImage: "pencil.and.list.clipboard")
											}
											Button {
												deleteBookmark(bookmark)
											} label: {
												Label(L10n.Button.delete, systemImage: "trash")
													.tint(Color.red)
											}
										}
								}
							}
						}
						.listRowSeparator(.hidden)
						.listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
					}
					.listStyle(.plain)
				}
			}
			.padding(.horizontal, 8)
			.frame(minWidth: 320)
		} detail: {
			Group {
				if let selectedBookmark {
					switch selectedBookmark.category {
					case .text(let text):
						Text(text)
					case .url(let url, _):
						NSWebView(url: url)
					case .webPage(_, let url, _):
						NSWebView(url: url)
					}
				} else {
					VStack(spacing: 16) {
						Image(systemName: "contextualmenu.and.cursorarrow")
							.font(.title)
						Text(L10n.MacHomeView.ArticleViewer.whatArticleToReadTitle)
					}
				}
			}
			.toolbar {
				if let selectedBookmark {
					Button {
						copyToClipboard(selectedBookmark.category)
					} label: {
						Image(systemName: "paperclip")
							.font(.title2)
							.padding(8)
							.hoverPopover(enabled: true, text: L10n.MacHomeView.Toolbar.copyToClipboardHoverText)
					}
					.buttonStyle(.plain)
					
					Button {
						openExternalBookmarkLink()
					} label: {
						Image(systemName: "arrow.up.forward.app")
							.font(.title2)
							.padding(8)
							.hoverPopover(enabled: true, text: L10n.MacHomeView.Toolbar.openInExternalBrowserHoverText)
					}
					.buttonStyle(.plain)
				}
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange).receive(on: DispatchQueue.main)) { _ in
			localStorage.refreshAllObjects()
		}
		.task(id: searchText) {
			await updateSearchPredicate()
		}
		.addLinkManuallyMac($presentAddLink)
		.sheet(isPresented: $presentSettings) {
			MacSettingsView()
		}
		.navigationTitle(selectedBookmark?.title ?? "Lynk")
    }

	private var emptyBookmarksView: some View {
		VStack(spacing: 12) {
			Image(systemName: "iphone.and.arrow.forward")
				.font(.system(size: 34, weight: .medium))
				.foregroundStyle(.secondary)
			Text(L10n.MacHomeView.EmptyState.title)
				.font(.headline)
			Text(L10n.MacHomeView.EmptyState.message)
				.font(.subheadline)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding(.horizontal, 24)
	}
	
	/// Let CoreData do the filtering, debounced to avoid a fetch on every keystroke
	private func updateSearchPredicate() async {
		let predicate = Bookmark.searchPredicate(for: searchText)
		if predicate != nil {
			try? await Task.sleep(for: .milliseconds(250))
			guard Task.isCancelled == false else { return }
		}
		guard bookmarksFetch.nsPredicate != predicate else { return }
		bookmarksFetch.nsPredicate = predicate
	}
	
	private func openExternalBookmarkLink() {
		guard let selectedBookmark else { return }
		switch selectedBookmark.category {
		case .url(let url, _):
			guard let url = URL(string: url) else { return }
			NSWorkspace.shared.open(url)
		case .webPage(_, let url, _):
			guard let url = URL(string: url) else { return }
			NSWorkspace.shared.open(url)
		default:
			break
		}
	}
	
	private func deleteBookmark(_ bookmark: Bookmark) {
		localStorage.delete(bookmark)
		do {
			try localStorage.save()
		} catch {
			print("Failed to delete bookmarks: \(error.localizedDescription)")
		}
	}
	
	private func deleteBookmarks(_ indexSet: IndexSet) {
		for index in indexSet {
			let bookmark = bookmarksFetch[index]
			localStorage.delete(bookmark)
		}
		do {
			try localStorage.save()
		} catch {
			print("Failed to delete bookmarks: \(error.localizedDescription)")
		}
	}
	
	private func copyToClipboard(_ item: BookmarkModel.Category) {
		let pasteboard = NSPasteboard.general
		pasteboard.clearContents()
		switch item {
		case .text(let text):
			pasteboard.setString(text, forType: .string)
		case .url(let url, _):
			pasteboard.setString(url, forType: .string)
		case .webPage(_, let url, _):
			pasteboard.setString(url, forType: .string)
		}
	}
}

#Preview {
	MacHomeView()
}
