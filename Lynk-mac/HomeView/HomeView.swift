//
//  HomeView.swift
//  Lynk-mac
//
//  Created by Musoni nshuti Nicolas on 31/05/2025.
//

import SwiftUI

struct HomeView: View {
	@State private var searchText: String = ""
	@State private var selectedBookmark: BookmarkModel?
	
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
				List(BookmarkModel.mockData) { bookmark in
					ItemCellView(model: bookmark)
						.onTapGesture {
							selectedBookmark = bookmark
						}
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
}

#Preview {
    HomeView()
}
