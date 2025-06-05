//
//  BookmarkModel.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 31/05/2025.
//

import Foundation

struct BookmarkModel: Identifiable, Hashable {
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
	
	static func == (lhs: BookmarkModel, rhs: BookmarkModel) -> Bool {
		lhs.id == rhs.id &&
		lhs.category == rhs.category &&
		lhs.date == rhs.date &&
		lhs.showShareIcon == rhs.showShareIcon
	}
	
	enum Category: Hashable {
		case text(String)
		case url(url: String, title: String? = nil)
		case webPage(title: String, url: String, imageUrl: String?)
		
		var rawValue: String {
			switch self {
			case .text: return "text"
			case .url: return "url"
			case .webPage: return "web"
			}
		}
	}
	
	static let mockData: [BookmarkModel] = [
		BookmarkModel(id: UUID().uuidString, category: .text("This is the text value")),
		BookmarkModel(id: UUID().uuidString, category: .url(url: "https://ibirori.rw/event/hahiye-kwa-popo", title: "Ibirori event")),
		BookmarkModel(id: UUID().uuidString, category: .webPage(title: "The we title that is kinder longer", url: "https://ibirori.rw/event/hahiye-kwa-popo", imageUrl: "https://github.com/favicon.ico"))
	]
}
