//
//  ItemCellView.swift
//  Keep Track
//
//  Created by Musoni nshuti Nicolas on 04/04/2025.
//

import SwiftUI

struct ItemCellView: View {
	private let model: BookmarkModel
	
	init(model: BookmarkModel) {
		self.model = model
	}
	
	var body: some View {
		HStack(alignment: .top, spacing: 4) {
			switch model.category {
			case .text(let text):
				TextBookmarkView(model: .init(text: text, date: model.date))
			case .url(let url, let title):
				/**
				 Ideally we shouldn't have a url save as is.
				 Possible reasons it happened is saving when no network was available
				 TODO: Reload this url and transform it to webPage if network is available
				 */
				URLBookmark(model: .init(url: url, text: title, date: model.date))
			case .webPage(title: let title, url: let url, imageUrl: let iconName):
				WebPageBookmark(model: .init(title: title, url: url, date: model.date, icon: iconName))
			}
			if model.showShareIcon {
				shareIcon
					.onTapGesture {
						_shareIconTapped(model)
					}
			}
		}
		.frame(maxWidth: .infinity)
		.background()
		.overlay(alignment: .topLeading) {
			if model.opened == false {
				Circle()
					.fill(Color.orange)
					.frame(width: 12, height: 12)
			}
		}
	}
	
	// Computed properties
	private var _shareIconTapped: (BookmarkModel) -> Void = { _ in }
	
	@ViewBuilder
	private var shareIcon: some View {
		Image(systemName: "square.and.arrow.up")
			.resizable()
			.scaledToFit()
			.frame(width: 16, height: 16)
			.padding(8)
			.background()
			.clipShape(.rect(cornerRadius: 4))
			.shadow(color: .gray, radius: 2)
	}
}

extension ItemCellView {
	func shareIconTapped(_ action: @escaping(BookmarkModel) -> Void) -> Self {
		var modified = self
		modified._shareIconTapped = action
		return modified
	}
}

#Preview("Cell view") {
	VStack(spacing: 16) {
		ItemCellView(model: .init(id: "1", category: .text("Hello text")))
		ItemCellView(model: .init(id: "2", category: .url(url: "https://ibirori.rw", title: "Ibirori event")))
		ItemCellView(model: .init(id: "5", category: .webPage(title: "Who knew that this would happen", url: "https://yegob.rw/who-knew-this-would-happen", imageUrl: "house")))
		ItemCellView(model: .init(id: "7", category: .webPage(title: "YegoB News Feed", url: "https://yegob.rw/news-feed", imageUrl: "https://picsum.photos/200/300"), date: .now, showShareIcon: true))
	}
	.padding()
}
