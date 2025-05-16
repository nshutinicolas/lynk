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
	@Environment(\.managedObjectContext) private var localStorage
	@Environment(\.openURL) private var openURL
	
	// Top Bar
	@State private var searchText: String = ""
	@State private var showSearchBar: Bool = false
	@State private var rotateSettingsIcon: Bool = false
	@Namespace private var searchBarAnimation
	@State private var showSettings = false
	@FocusState private var searchFieldIsFocused: Bool
	
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
				/*
				HStack(spacing: 16) {
//					if showSearchBar == false {
//						Text("Lynk")
//							.font(.title)
//							.frame(maxWidth: .infinity, alignment: .leading)
//					}
					ZStack {
						if showSearchBar {
							HStack {
								HStack {
									TextField("Search bookmark", text: $searchText)
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
				.frame(maxWidth: .infinity, alignment: .trailing)
				.padding(.horizontal)
				 */
				/*
				HStack {
					if showSearchBar {
						HStack {
							HStack {
								TextField("Search bookmark", text: $searchText)
									.padding(.vertical, 12)
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
							.overlay {
								RoundedRectangle(cornerRadius: 8)
									.stroke(lineWidth: 0.5)
									.fill(Color.gray.opacity(0.6))
							}
							Image(systemName: "xmark")
								.font(.title3)
								.padding(8)
								.onTapGesture {
									withAnimation {
										showSearchBar = false
									}
								}
						}
						.animation(.interactiveSpring, value: showSearchBar)
					} else {
						HStack {
							Text("Lynk")
								.font(.title)
								.frame(maxWidth: .infinity)
							HStack(spacing: 16) {
								if bookmarksFetch.isEmpty == false {
									Image(systemName: "magnifyingglass")
										.font(.title2)
										.onTapGesture {
											withAnimation {
												showSearchBar = true
											}
										}
								}
								Image(systemName: "gearshape")
									.font(.title2)
									.rotationEffect(.degrees(rotateSettingsIcon ? 180 : 0))
									.animation(.default, value: rotateSettingsIcon)
									.onTapGesture {
										rotateSettingsIcon.toggle()
									}
							}
							.padding(.vertical, 10)
						}
						.animation(.interactiveSpring, value: showSearchBar == false)
					}
				}
				.padding([.horizontal, .top])
				.padding(.bottom, 4)
				 */
				if bookmarksFetch.isEmpty {
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
							/*
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
							.padding(.vertical)
							 */
							Section {
								ForEach(bookmarksFetch, id: \.self) { bookmark in
									if let model = bookmark.createItemCellViewModel(shareable: true) {
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
											} preview: {
												ItemCellView(model: model)
													.padding()
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
		.onChange(of: searchText) { value in
			search(for: value)
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
//		switch bookmark.category {
//		case .text(let text):
//			ShareLink(item: text, subject: Text(text))
//		case .url(let stringUrl):
//			if let url = URL(string: stringUrl) {
//				ShareLink(item: url, subject: Text(stringUrl))
//			} else {
//				ShareLink(item: stringUrl, subject: Text(stringUrl))
//			}
//		case .webPage(let title, let url, let imageUrl):
//			if let url = URL(string: url) {
//				ShareLink(item: url, subject: Text(title), preview: SharePreview(""))
//			}
//			ShareLink(item: URL(string: url), subject: Text(title)
//		}
	}
	
	#warning("Implement the search functionality of the app")
	private func search(for text: String) {
		if searchText.isEmpty {
			
		}
	}
	
	private func bookmarkTapped(_ bookmark: BookmarkModel) {
		switch bookmark.category {
		case .text(let string):
			print(string)
			// TODO: Implement a bottom sheet that will show this text
			break
		case .url(let urlString):
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
