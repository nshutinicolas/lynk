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
		init(id: String, category: Category, date: Date = .now) {
			self.id = id
			self.category = category
			self.date = date
		}
		
		static func == (lhs: ItemCellView.Model, rhs: ItemCellView.Model) -> Bool {
			lhs.id == rhs.id &&
			lhs.category == rhs.category &&
			lhs.date == rhs.date
		}
	}
	
	var model: Model
	
	var body: some View {
		ZStack {
			switch model.category {
			case .text(let text):
				TextBookmarkView(model: .init(text: text))
			case .url(let url):
				TextBookmarkView(model: .init(text: url))
			case .webPage(title: let title, url: let url, imageUrl: let iconName):
				URLBookMark(model: .init(title: title, url: url, icon: iconName))
			}
		}
		.frame(maxWidth: .infinity)
	}
	
	enum Category: Hashable {
		case text(String)
		case url(String)
		case webPage(title: String, url: String, imageUrl: String?)
	}
}

#Preview("Cell view") {
	VStack {
		ItemCellView(model: .init(id: "1", category: .text("Hello text")))
		ItemCellView(model: .init(id: "2", category: .url("https://ibirori.rw")))
		ItemCellView(model: .init(id: "5", category: .webPage(title: "Who knew that this would happen", url: "https://yegob.rw/who-knew-this-would-happen", imageUrl: "house")))
	}
}
