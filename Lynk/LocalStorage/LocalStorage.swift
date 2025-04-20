//
//  LocalStorage.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import Foundation
import CoreData

class BookmarkStorage: ObservableObject {
	static let shared = BookmarkStorage()
	let container = NSPersistentContainer(name: "Bookmarks")
	
	private init() {
		container.loadPersistentStores { _, error in
			if let _ = error as NSError? {
				// TODO: Handle this error correctly
				return
			}
			print("🎉Store Initialized🎉")
		}
	}
	
	func saveContext(for context: NSManagedObjectContext, model: ItemCellView.Model) throws {
		let bookmark = Bookmark(context: context)
		bookmark.id = UUID()
		bookmark.date = Date()
		
		let category = BookmarkCategory(context: context)
		switch model.category {
		case .text(let text):
			category.type = "text"
			category.textContent = text
		case .url(let urlString):
			category.type = "url"
			category.urlContent = urlString
		case .webPage(let title, let url, let imageUrl):
			category.type = "web"
			category.textContent = title
			category.urlContent = url
			category.imageUrl = imageUrl
		}
		bookmark.category = category
		
		if bookmark.hasChanges {
			try context.save()
		} else {
			print("🚨Nothing to save🚨")
		}
	}
	
	func save(with model: ItemCellView.Model) throws {
		print("Saving model")
		let bookmark = Bookmark(context: container.viewContext)
		bookmark.id = UUID(uuidString: model.id)
		bookmark.date = .now
		
		let category = BookmarkCategory(context: container.viewContext)
		switch model.category {
		case .text(let text):
			category.type = "text"
			category.textContent = text
		case .url(let urlString):
			category.type = "url"
			category.urlContent = urlString
		case .webPage(let title, let url, let imageUrl):
			category.type = "web"
			category.textContent = title
			category.urlContent = url
			category.imageUrl = imageUrl
		}
		bookmark.category = category
		
		if bookmark.hasChanges {
			print("Model can be saved")
			try container.viewContext.save()
			print("Saved")
		} else {
			print("🚨Nothing to save🚨")
		}
	}
}

extension Bookmark {
	func createItemCellViewModel() -> ItemCellView.Model? {
		guard let id, let date, let category, let categoryType = category.type else { return nil }
		var itemCategory: ItemCellView.Category?
		switch categoryType {
		case "text":
			guard let text = category.textContent else { return nil }
			itemCategory = .text(text)
		case "url":
			guard let urlString = category.urlContent else { return nil }
			itemCategory = .url(urlString)
		case "web":
			guard let text = category.textContent,
				  let url = category.urlContent,
				  let imageUrl = category.imageUrl
			else { return nil }
			itemCategory = .webPage(title: text, url: url, imageUrl: imageUrl)
		default:
			return nil
		}
		guard let itemCategory else { return nil }
		return .init(id: id.uuidString, category: itemCategory, date: date)
	}
}
