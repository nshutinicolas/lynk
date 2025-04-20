//
//  LocalStorage.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import Foundation
import CoreData
import UniformTypeIdentifiers

class BookmarkStorage: ObservableObject {
	static let shared = BookmarkStorage()
	let container = NSPersistentContainer(name: "Bookmarks")
	private var storageFileURL: URL? = { FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroup)?.appendingPathComponent(AppConstants.coreDataStorage, conformingTo: UTType.text)
	}()
	
	private init() {
		guard let storageFileURL else {
			print("🚨failed to load the storage file🚨")
			return
		}
		let description = NSPersistentStoreDescription(url: storageFileURL)
		container.persistentStoreDescriptions = [description]
		container.loadPersistentStores { _, error in
			if let _ = error as NSError? {
				// TODO: Handle this error correctly
				return
			}
			print("🎉Store Initialized🎉")
		}
	}
	
	func save(with model: ItemCellView.Model) throws {
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
	
	func fetchStoredBookmarks() -> [ItemCellView.Model] {
		let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
		do {
			let bookmarks = try container.viewContext.fetch(request)
			print("Stored content: \(bookmarks.count)")
			let stored = bookmarks.compactMap { $0.createItemCellViewModel() }
			return stored
//			return bookmarks.compactMap(\.createItemCellViewModel)
		} catch {
			print("Fetching Error: \(error)")
			return []
		}
	}
	
	func deleteStoredBookmark(_ bookmark: ItemCellView.Model) {
		let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
		request.predicate = NSPredicate(format: "id == %@", bookmark.id)
		do {
			let bookmarksToDelete = try container.viewContext.fetch(request)
			for bookmark in bookmarksToDelete {
				container.viewContext.delete(bookmark)
			}
			try container.viewContext.save()
		} catch {
			print("Deleting Error: \(error)")
		}
	}
	
	func deleteAllStoredBookmarks() {
		let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
		do {
			let bookmarksToDelete = try container.viewContext.fetch(request)
			for bookmark in bookmarksToDelete {
				container.viewContext.delete(bookmark)
			}
			try container.viewContext.save()
		} catch {
			print("Delete error: \(error)")
		}
	}
	
	func findStoredBookmark(_ bookmark: ItemCellView.Model) -> Bookmark? {
		let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
		request.predicate = NSPredicate(format: "id == %@", bookmark.id)
		do {
			let bookmarksToFind = try container.viewContext.fetch(request)
			print("Found \(bookmarksToFind.count) bookmarks")
			return bookmarksToFind.first
		} catch {
			print("Failed to get bookmark matching: \(error)")
			return nil
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
