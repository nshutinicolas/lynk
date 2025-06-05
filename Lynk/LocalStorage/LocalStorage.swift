//
//  LocalStorage.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import Foundation
import CoreData
import CloudKit
import UniformTypeIdentifiers

extension Bookmark {
	static let containerName = "Bookmarks"
}

class BookmarkStorage: ObservableObject {
	static let shared = BookmarkStorage()
	let container = NSPersistentCloudKitContainer(name: Bookmark.containerName)
	
	init(inMemory: Bool = false) {
		let description: NSPersistentStoreDescription = {
			if inMemory {
				// For unit testing
				let url = URL(fileURLWithPath: "/dev/null")
				return NSPersistentStoreDescription(url: url)
			}
			return container.persistentStoreDescriptions.first ?? NSPersistentStoreDescription()
		}()
		
		description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
		description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
		description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
			containerIdentifier: AppConstants.icloudContainer
		)
		container.persistentStoreDescriptions = [description]
		container.loadPersistentStores { [weak self] _, error in
			if let error = error as NSError? {
				// TODO: Handle this error correctly
				print("🚨Failed to initialize store: \(error.localizedDescription)")
				return
			}
			print("🎉Store Initialized🎉")
			// For Previews only
			if inMemory {
				self?.addDummyData()
			}
			
			// Enable automatic merging of changes
			self?.container.viewContext.automaticallyMergesChangesFromParent = true
			self?.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		}
		#if DEBUG
		checkCloudKitAvailability()
		#endif
	}
	
	// Debugging
	func checkCloudKitAvailability() {
		do {
			try container.initializeCloudKitSchema(options: [.printSchema])
			print("CloudKit schema initialized successfully")
		} catch {
			print("Failed to initialize CloudKit schema: \(error.localizedDescription)")
		}
		let container = CKContainer(identifier: "iCloud.rw.lynk.app.ernest.ios")
		container.accountStatus { status, error in
			if let error = error {
				print("iCloudc error: \(error.localizedDescription)")
			}
			print("iCloud status: \(status)")
		}
	}
	
	func save(model: BookmarkModel) throws {
		let bookmark = Bookmark(context: container.viewContext)
		bookmark.id = UUID(uuidString: model.id)
		bookmark.date = .now
		
		let category = BookmarkCategory(context: container.viewContext)
		category.type = model.category.rawValue
		switch model.category {
		case .text(let text):
			category.textContent = text
		case .url(let urlString, let title):
			category.textContent = title
			category.urlContent = urlString
		case .webPage(let title, let url, let imageUrl):
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
	
	func fetchStoredBookmarks() -> [BookmarkModel] {
		let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
		do {
			let bookmarks = try container.viewContext.fetch(request)
			print("Stored content: \(bookmarks.count)")
			let stored = bookmarks.compactMap { $0.createItemCellViewModel() }
			return stored
		} catch {
			print("Fetching Error: \(error)")
			return []
		}
	}
	
	func deleteStoredBookmark(_ bookmark: BookmarkModel) {
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
	
	func findStoredBookmark(_ bookmark: BookmarkModel) -> Bookmark? {
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
	
	func searchBookmarks(containingText text: String) -> [BookmarkModel] {
		let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
		request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", text)
		request.predicate = NSPredicate(format: "description CONTAINS[cd] %@", text)
		do {
			let bookmarks = try container.viewContext.fetch(request)
			return bookmarks.compactMap { $0.createItemCellViewModel() }
		} catch {
			return []
		}
	}
	
	// For Previews only
	private func addDummyData() {
		let data: [BookmarkModel] = [
			.init(id: UUID().uuidString, category: .text("Text to share or view")),
			.init(id: UUID().uuidString, category: .url(url: "https://localhost.com/whatever", title: nil)),
			.init(id: UUID().uuidString, category: .webPage(title: "Title of the website underneath", url: "https://yegob.com", imageUrl: "https://radio.yegob.rw/wp-content/uploads/2022/05/cropped-YEGOBRADIO.jpg")),
			.init(id: UUID().uuidString, category: .webPage(title: "Title of the website underneath", url: "https://yegob.com", imageUrl: "https://radio.yegob.rw/wp-content/uploads/2022/05/cropped-YEGOBRADIO.jpg")),
			.init(id: UUID().uuidString, category: .webPage(title: "Title of the website underneath", url: "https://localhost.com/ahandi-hose", imageUrl: "")),
			.init(id: UUID().uuidString, category: .webPage(title: "Title of the website underneath", url: "https://m.youtube.com/inama-nziza", imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLKtkLz6Q_ouCtcto4FCIkEkKfJwVmpjHcRA&s")),
			.init(id: UUID().uuidString, category: .url(url: "https://github.githubassets.com/assets/GitHub-Mark-ea2971cee799.png", title: "Some weird repository on gituhb")),
			.init(id: UUID().uuidString, category: .url(url: "https://localhost.com/whatever", title: nil))
		]
		deleteAllStoredBookmarks()
		for item in data {
			try? save(model: item)
		}
	}
}

extension Bookmark {
	func createItemCellViewModel(shareable: Bool = false) -> BookmarkModel? {
		guard let id, let date, let category, let categoryType = category.type else { return nil }
		var itemCategory: BookmarkModel.Category?
		switch categoryType {
		case "text":
			guard let text = category.textContent else { return nil }
			itemCategory = .text(text)
		case "url":
			guard let urlString = category.urlContent else { return nil }
			itemCategory = .url(url: urlString, title: category.textContent)
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
		return .init(id: id.uuidString, category: itemCategory, date: date, showShareIcon: shareable)
	}
}
