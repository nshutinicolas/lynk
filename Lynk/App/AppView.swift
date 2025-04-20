//
//  AppView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import SwiftUI

enum SortingPill: Equatable, CaseIterable, Identifiable {
	case Scheduled
	case all
	case text
	case web
	
	var id: String {
		switch self {
		case .Scheduled: return "scheduled"
		case .all: return "all"
		case .text: return "text"
		case .web: return "web"
		}
	}
	
	var title: String {
		switch self {
		case .Scheduled:
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
		case .Scheduled: return "clock"
		case .all: return "list.bullet"
		case .text: return "textformat"
		case .web: return "safari"
		}
	}
}

struct AppView: View {
	@EnvironmentObject private var coordinator: AppCoordinator
	
	@State private var searchText: String = ""
	@Environment(\.managedObjectContext) private var localStorage
	@FetchRequest(sortDescriptors: []) var bookmarksFetch: FetchedResults<Bookmark>
	
	var bookmarks: [ItemCellView.Model] = [
		.init(id: UUID().uuidString, category: .text("This is the long ass text")),
		.init(id: UUID().uuidString, category: .url("https://www.ibirori.rw/events")),
		.init(id: UUID().uuidString, category: .webPage(
			title: "The long ass title for the web page",
			url: "https://ibirori.rw/events",
			imageUrl: "https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg"
		))
	]
	var body: some View {
		NavigationStack(path: $coordinator.path) {
			VStack {
				// Search Bar - Using native for now
				List {
					Section {
						ScrollView(.horizontal, showsIndicators: false) {
							HStack {
								ForEach(SortingPill.allCases, id: \.self) { pill in
									HStack {
										IconView(.systemName(pill.iconName))
											.frame(width: 16, height: 16)
										Text(pill.title)
									}
									.padding(.vertical, 8)
									.padding(.leading, 8)
									.padding(.trailing, 16)
									.background(Color.gray.opacity(0.2))
									.clipShape(.capsule)
								}
							}
						}
					}
					.listRowSeparator(.hidden)
					.listRowInsets(.init(edge: 0))
					Section {
						ForEach(bookmarksFetch, id: \.self) { bookmark in
							if let model = bookmark.createItemCellViewModel() {
								ItemCellView(model: model)
									.padding(8)
									.background()
									.clipShape(.rect(cornerRadius: 8))
									.shadow(color: .gray.opacity(0.3), radius: 4)
							}
						}
						.onDelete(perform: deleteBookmarks)
					}
					.listRowSeparator(.hidden)
					.listRowInsets(.init(vertical: 4, horizontal: 8))
				}
				.listStyle(.plain)
			}
			.safeAreaInset(edge: .bottom) {
				Button {
					let last = bookmarks.randomElement()
					do {
						try BookmarkStorage.shared.save(with: last!)
					} catch {
						print("Saving error: \(error.localizedDescription)")
					}
				} label: {
					Text("Save random bookmarks")
						.font(.caption)
				}

			}
		}
		.searchable(text: $searchText, prompt: "Search with a keyword")
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
	AppView()
		.environmentObject(AppCoordinator())
		
}
