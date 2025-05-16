//
//  ItemCellView.swift
//  Keep Track
//
//  Created by Musoni nshuti Nicolas on 04/04/2025.
//

import SwiftUI

struct ItemCellView: View {
	struct Model: Identifiable, Hashable {
		let id: String
		let category: Category
		let date: Date
		let showShareIcon: Bool
		init(id: String, category: Category, date: Date = .now, showShareIcon: Bool = false) {
			self.id = id
			self.category = category
			self.date = date
			self.showShareIcon = showShareIcon
		}
		
		static func == (lhs: ItemCellView.Model, rhs: ItemCellView.Model) -> Bool {
			lhs.id == rhs.id &&
			lhs.category == rhs.category &&
			lhs.date == rhs.date &&
			lhs.showShareIcon == rhs.showShareIcon
		}
	}
	
	private let model: Model
	init(model: Model) {
		self.model = model
	}
	
	var body: some View {
		HStack(alignment: .top, spacing: 4) {
			ZStack {
				switch model.category {
				case .text(let text):
					TextBookmarkView(model: .init(text: text, date: model.date))
				case .url(let url):
					/**
					 Idealy we shouldn't have a url save as is.
					 Possible reasons it happened is saving when no network was available
					 TODO: Reload this url and transform it to webPage if network is available
					 */
					TextBookmarkView(model: .init(text: url, date: model.date))
				case .webPage(title: let title, url: let url, imageUrl: let iconName):
					URLBookMark(model: .init(title: title, url: url, date: model.date, icon: iconName))
				}
			}
			if model.showShareIcon {
				ZStack {
					Image(systemName: "square.and.arrow.up")
						.resizable()
						.scaledToFit()
						.frame(width: 16, height: 16)
				}
				.padding(8)
				.background(Color(.systemBackground))
				.clipShape(.rect(cornerRadius: 4))
				.shadow(color: .gray, radius: 2)
				.onTapGesture {
					_shareIconTapped(model)
				}
			}
		}
		.frame(maxWidth: .infinity)
	}
	
	enum Category: Hashable {
		case text(String)
		case url(String)
		case webPage(title: String, url: String, imageUrl: String?)
	}
	
	// Computed properties
	private var _shareIconTapped: (Model) -> Void = { _ in }
}

extension ItemCellView {
	func shareIconTapped(_ action: @escaping(Model) -> Void) -> Self {
		var modified = self
		modified._shareIconTapped = action
		return modified
	}
}

#Preview("Cell view") {
	VStack(spacing: 16) {
		ItemCellView(model: .init(id: "1", category: .text("Hello text")))
		ItemCellView(model: .init(id: "2", category: .url("https://ibirori.rw")))
		ItemCellView(model: .init(id: "5", category: .webPage(title: "Who knew that this would happen", url: "https://yegob.rw/who-knew-this-would-happen", imageUrl: "house")))
		ItemCellView(model: .init(id: "7", category: .webPage(title: "YegoB News Feed", url: "https://yegob.rw/news-feed", imageUrl: "https://picsum.photos/200/300"), date: .now, showShareIcon: true))
	}
	.padding()
}
