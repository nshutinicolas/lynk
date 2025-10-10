//
//  BookmarkModel.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 31/05/2025.
//

import Foundation

struct BookmarkModel: Identifiable, Hashable {
	let id: String
	var category: Category
	let date: Date
	var opened: Bool
	let showShareIcon: Bool
	init(id: String, category: Category, date: Date = .now, opened: Bool = false, showShareIcon: Bool = false) {
		self.id = id
		self.category = category
		self.date = date
		self.showShareIcon = showShareIcon
		self.opened = opened
	}
	
	mutating func updateOpenedState(to state: Bool) {
		opened = state
	}
	
	/// Update category title
	mutating func updateTitle(_ title: String) {
		switch self.category {
		case .text(_):
			category = .text(title)
		case .url(let url, _):
			category = .url(url: url, title: title)
		case .webPage(_, let url, let imageUrl):
			category = .webPage(title: title, url: url, imageUrl: imageUrl)
		}
	}
	
	/// Category Title - Optional
	var title: String? {
		switch self.category {
		case .text(let string):
			return string
		case .url(_, let title):
			return title
		case .webPage(let title, _, _):
			return title
		}
	}
	
	/// For deeplink, create a url to pass in the userInfo
	/// The format is `lynk://open?link=<string>&title=<string>` where title is optional for url option
	var userInfo: [String: String] {
		var url: String = "\(AppConstants.deeplinkUrl)open?"
		switch self.category {
		case .text(let string):
			url.append("title=\(string)") // This will always fail the link check
		case .url(let urlString, let title):
			url.append("link=\(urlString)")
			if let title {
				url.append("&title=\(title)")
			}
		case .webPage(let title, let urlString, _):
			url.append("link=\(urlString)&title=\(title)")
		}
		return ["url": url]
	}
	
	static func == (lhs: BookmarkModel, rhs: BookmarkModel) -> Bool {
		lhs.id == rhs.id &&
		lhs.category == rhs.category &&
		lhs.date == rhs.date &&
		lhs.showShareIcon == rhs.showShareIcon &&
		lhs.opened == rhs.opened
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
		BookmarkModel(id: UUID().uuidString, category: .url(url: "https://ibirori.rw/event/hahiye-kwa-popo", title: "Ibirori event"), opened: true),
		BookmarkModel(id: UUID().uuidString, category: .webPage(title: "The we title that is kinder longer", url: "https://ibirori.rw/event/hahiye-kwa-popo", imageUrl: "https://github.com/favicon.ico"), opened: true)
	]
}
