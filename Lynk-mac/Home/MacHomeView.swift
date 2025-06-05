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
	@Environment(\.managedObjectContext) private var localStorage
	
	private var filteredBookmarks: [Bookmark] {
		guard searchText.isEmpty == false else {
			return Array(bookmarksFetch)
		}
		
		return Array(bookmarksFetch).filter { bookmark in
			let model = bookmark.createItemCellViewModel()
			switch model?.category {
			case .text(let text):
				return text.lowercased().contains(searchText.lowercased())
			case .url(let url, let title):
				return url.lowercased().contains(searchText.lowercased()) || ((title?.lowercased().contains(searchText.lowercased())) != nil)
			case .webPage(let title, let url , _):
				return title.lowercased().contains(searchText.lowercased()) || url.lowercased().contains(searchText.lowercased())
			default:
				return false
			}
		}
	}
	
	@FetchRequest(
		entity: Bookmark.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \Bookmark.date, ascending: false)]
	) var bookmarksFetch: FetchedResults<Bookmark>
	
    var body: some View {
		NavigationSplitView {
			VStack(spacing: 16) {
				#if DEBUG
				HStack {
					Image(systemName: "gear")
						.font(.title3)
						.padding(4)
						.background(Color.gray.opacity(0.3))
						.clipShape(.rect(cornerRadius: 8))
					Spacer()
					HStack(spacing: 16) {
						Image(systemName: "line.3.horizontal.decrease")
							.font(.title3)
							.padding(4)
						Image(systemName: "plus")
							.font(.title3)
							.padding(4)
					}
				}
				#endif
				HStack {
					Image(systemName: "magnifyingglass")
					TextField("Search", text: $searchText)
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
				List {
					Section {
						ForEach(filteredBookmarks) { bookmark in
							if let model = bookmark.createItemCellViewModel() {
								ItemCellView(model: model)
									.onTapGesture {
										selectedBookmark = model
									}
									.contextMenu {
										Button {
											
										} label: {
											Label("Copy", systemImage: "document.on.document")
										}
										Button {
											
										} label: {
											Label("Edit", systemImage: "pencil.and.list.clipboard")
										}
										Button {
											deleteBookmark(bookmark)
										} label: {
											Label("Delete", systemImage: "trash")
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
						Text("What article would you like to read?")
					}
				}
			}
			.toolbar {
				Image(systemName: "arrow.up.forward.app")
					.font(.title2)
					.onTapGesture {
						openExternalBookmarkLink()
					}
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)) { _ in
			localStorage.refreshAllObjects()
		}
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
}

#Preview {
	MacHomeView()
}
