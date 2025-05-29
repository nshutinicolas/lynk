//
//  AppView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import SwiftUI

enum SortingPill: Equatable, CaseIterable, Identifiable {
	case scheduled
	case all
	case text
	case web
	
	var id: String {
		switch self {
		case .scheduled: return "scheduled"
		case .all: return "all"
		case .text: return "text"
		case .web: return "web"
		}
	}
	
	var title: String {
		switch self {
		case .scheduled:
			return "Scheduled"
		case .all:
			return "All"
		case .text:
			return "Text"
		case .web:
			return "Websites"
		}
	}
	
	var iconName: String {
		switch self {
		case .scheduled: return "clock"
		case .all: return "list.bullet"
		case .text: return "textformat"
		case .web: return "safari"
		}
	}
}

struct AppView: View {
	@EnvironmentObject private var coordinator: AppCoordinator
	@Environment(\.managedObjectContext) private var localStorage
	@Environment(\.openURL) private var openURL
	
	// Top Bar
	@State private var searchText: String = ""
	@State private var showSearchBar: Bool = false
	@State private var rotateSettingsIcon: Bool = false
	@Namespace private var searchBarAnimation
	@State private var showSettings = false
	@FocusState private var searchFieldIsFocused: Bool
	
	private var filteredBookmarks: [Bookmark] {
		guard !searchText.isEmpty else {
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
		NavigationStack(path: $coordinator.path) {
			VStack {
				// Header
				HStack {
					Text("Lynk")
						.font(.title2)
						.fontDesign(.serif)
						.fontWeight(.semibold)
				}
				.frame(maxWidth: .infinity, alignment: .center)
				.overlay(alignment: .trailing) {
					HStack {
						ZStack {
							if showSearchBar {
								HStack {
									HStack {
										TextField("Search bookmark", text: $searchText)
											.focused($searchFieldIsFocused)
											.textInputAutocapitalization(.never)
											.autocorrectionDisabled()
											.padding(.vertical, 10)
											.padding(.horizontal, 8)
										Image(systemName: "xmark")
											.font(.footnote)
											.padding(8)
											.background(Color.gray.opacity(0.2))
											.clipShape(.circle)
											.padding(4)
											.onTapGesture {
												searchText = ""
											}
									}
									.roundedBorder(color: .gray.opacity(0.8), lineWidth: 1)
									Image(systemName: "xmark")
										.font(.title3)
										.padding(10)
										.onTapGesture {
											withAnimation {
												showSearchBar = false
											}
										}
										.roundedBorder(color: .gray.opacity(0.8), lineWidth: 1)
								}
								.matchedGeometryEffect(id: "SEARCH_BAR", in: searchBarAnimation)
							} else {
								if bookmarksFetch.isEmpty == false {
									Image(systemName: "magnifyingglass")
										.font(.title3)
										.onTapGesture {
											withAnimation {
												showSearchBar = true
											}
										}
										.padding(10)
										.roundedBorder(color: .gray.opacity(0.8), lineWidth: 1)
										.matchedGeometryEffect(id: "SEARCH_BAR", in: searchBarAnimation)
								}
							}
						}
						if showSearchBar == false {
							Image(systemName: "gearshape")
								.font(.title3)
								.rotationEffect(.degrees(rotateSettingsIcon ? 180 : 0))
								.animation(.default, value: rotateSettingsIcon)
								.onTapGesture {
									rotateSettingsIcon.toggle()
									showSettings = true
								}
								.padding(10)
								.roundedBorder(color: .gray.opacity(0.8), lineWidth: 1)
						}
					}
				}
				.padding([.horizontal, .top])
				
				if filteredBookmarks.isEmpty {
					VStack {
						Image(systemName: "paperclip.badge.ellipsis")
							.font(.largeTitle)
							.foregroundStyle(Color.pink.gradient)
							.padding()
							.overlay {
								Circle()
									.stroke(lineWidth: 2)
									.fill(Color.green.opacity(0.7).gradient)
							}
							.padding(28)
							.overlay {
								Circle()
									.stroke(lineWidth: 2)
									.fill(Color.blue.opacity(0.4).gradient)
							}
						Text("No Bookmarks Found")
							.font(.title3)
						
						Button("Learn how to add a bookmark") {
							
						}
						.padding()
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
				} else {
					VStack(spacing: 0) {
						List {
							Section {
								ForEach(filteredBookmarks, id: \.self) { bookmark in
									// TODO: Change to shareable after implementing the share sheet
									if let model = bookmark.createItemCellViewModel(shareable: false) {
										ItemCellView(model: model)
											.shareIconTapped { item in
												shareBookmark(item)
											}
											.padding(8)
											.background()
											.clipShape(.rect(cornerRadius: 8))
											.shadow(color: .gray.opacity(0.3), radius: 4)
											.onTapGesture {
												bookmarkTapped(model)
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
								.onDelete(perform: deleteBookmarks)
							}
							.listRowSeparator(.hidden)
							.listRowInsets(.init(edge: 8))
						}
						.listStyle(.plain)
					}
				}
			}
		}
		.fullScreenCover(isPresented: $showSettings) {
			SettingsView()
		}
		.onChange(of: showSearchBar) { value in
			searchFieldIsFocused = value
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
	
	private func shareBookmark(_ bookmark: BookmarkModel) {
		// TODO: Implement the share logic
		switch bookmark.category {
		case .text(let text):
			ShareSheetHelper.present(items: [text])
		case .url(let stringUrl, let title):
			if let url = URL(string: stringUrl) {
				ShareSheetHelper.present(items: [url])
			} else {
				ShareSheetHelper.present(items: [stringUrl, title ?? "No title"])
			}
		case .webPage(let title, let url, _):
			ShareSheetHelper.present(items: [title, url])
		}
	}
	
	private func bookmarkTapped(_ bookmark: BookmarkModel) {
		switch bookmark.category {
		case .text(let string):
			print(string)
			// TODO: Implement a bottom sheet that will show this text
			break
		case .url(let urlString, _):
			guard let url = URL(string: urlString) else { return }
			openURL(url)
		case .webPage(_, let urlString, _):
			guard let url = URL(string: urlString) else { return }
			openURL(url)
		}
	}
}

#Preview {
	let context = BookmarkStorage(inMemory: true).container.viewContext
	AppView()
		.environmentObject(AppCoordinator())
		.environment(\.managedObjectContext, context)
}

// TODO: Revisit this when implementing the share icon action
struct ShareSheetHelper {
	static func present(items: [Any]) {
		let keyWindow = UIApplication.shared.connectedScenes
			.filter({$0.activationState == .foregroundActive})
			.map({$0 as? UIWindowScene})
			.compactMap({$0})
			.first?.windows
			.filter({$0.isKeyWindow}).first
		
		if let rootViewController = keyWindow?.rootViewController {
			let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
			rootViewController.present(activityViewController, animated: true)
		}
	}
}
