//
//  ShareViewController.swift
//  LynkBookmark
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import Combine
import CoreData
import Social
import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
	// Flags
	@Flag(.showSavePreview) private var showSavePreview: Bool
	
	private let bookmarkStorage = BookmarkStorage.shared
	private var modelToSave: Model?
	private let network = Network.shared
	private var savingStatus: SaveStatus = .loading
	
	private lazy var closeButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "xmark"), for: .normal)
		button.tintColor = .label
		button.backgroundColor = .secondarySystemBackground
		button.layer.cornerRadius = 22
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
		return button
	}()
	
	private lazy var closeButtonContainer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(closeButton)
		return view
	}()
	
	private lazy var saveButton: UIButton = {
		let button = UIButton()
		button.setTitle("Bookmark", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = .systemBlue
		button.layer.cornerRadius = 16
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(saveBookmark), for: .touchUpInside)
		return button
	}()
	
	private var mainView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 16
		stack.distribution = .fill
		stack.alignment = .fill
		stack.backgroundColor = .systemBackground
		stack.layer.cornerRadius = 20
		stack.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		stack.layoutMargins = .init(top: 10, left: 20, bottom: 20, right: 20)
		stack.isLayoutMarginsRelativeArrangement = true
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()
	
	private var successIconView = UIView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .clear
		// Split the UI into 2 with the
		// Add Subviews
		successIconView = SuccessSaveView(status: Binding(
			get: { [weak self] in
				self?.savingStatus ?? .loading
			},
			set: { [weak self] newValue in
				self?.savingStatus = newValue
			}
		)).uiView()
		setAlternativeConstraints()
//		view.addSubview(mainView)
//		mainView.addArrangedSubview(closeButtonContainer)
//		mainView.addArrangedSubview(saveButton)
		
		getSharedContent()
//		setViewConstraints()
	}
	
	@objc func closeAction() {
		self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
	}
	
	@objc func saveBookmark(model: Model) {
		defer { closeAction() }
		guard let modelToSave else { return }
		do {
			try bookmarkStorage.save(with: modelToSave.itemViewModel)
			let stored = bookmarkStorage.fetchStoredBookmarks()
			print("Stored: \(stored.count)")
		} catch {
			print("Saving error: \(error.localizedDescription)")
		}
	}
	
	func setAlternativeConstraints() {
		successIconView.translatesAutoresizingMaskIntoConstraints = false
		successIconView.backgroundColor = UIColor.clear
		view.addSubview(successIconView)
		NSLayoutConstraint.activate([
			successIconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			successIconView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			successIconView.widthAnchor.constraint(equalToConstant: 100),
			successIconView.heightAnchor.constraint(equalToConstant: 100)
		])
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			// MainView Constraints
			mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
			mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			closeButtonContainer.heightAnchor.constraint(equalToConstant: 44),
			closeButton.topAnchor.constraint(equalTo: closeButtonContainer.topAnchor),
			closeButton.trailingAnchor.constraint(equalTo: closeButtonContainer.trailingAnchor),
			closeButton.bottomAnchor.constraint(equalTo: closeButtonContainer.bottomAnchor),
			closeButton.widthAnchor.constraint(equalToConstant: 44),
			saveButton.heightAnchor.constraint(equalToConstant: 46)
		])
	}
	
	private func getSharedContent() {
		Task {
			do {
				try await asyncGetSharedData()
			} catch let error as SaveError {
				// Handle errors
				print(error.localizedDescription)
			} catch {
				// Handle unknow errors
			}
		}
	}
	
	private enum SupportedContentType: String {
		case note = "public.plain-text"
		case url = "public.url"
		case webPage = "com.apple.property-list" // When Shared with Safari
	}
	// Doing this as a shortcut
	@objc(Model)
	class Model: NSObject {
		let itemViewModel: ItemCellView.Model
		init(_ itemViewModel: ItemCellView.Model) {
			self.itemViewModel = itemViewModel
		}
	}
	
	private func asyncGetSharedData() async throws {
		guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
			closeAction()
			savingStatus = .error(.invalidInputItems)
			throw SaveError.invalidInputItems
		}
		
		await withTaskGroup(of: Void.self) { [weak self] group in
			for extensionItem in extensionItems {
				let attachments = extensionItem.attachments ?? []
				for attachment in attachments {
					guard let contentType = attachment.registeredContentTypes.first?.identifier else { continue }
					group.addTask {
						do {
							let sharedData = try await attachment.loadItem(forTypeIdentifier: contentType, options: nil)
							try await self?.updateContent(with: sharedData, contentType: contentType)
						} catch {
							DispatchQueue.main.async {
								self?.savingStatus = .error(.invalidData)
//								try? await Task.sleep(for: .seconds(1)) // Figure out how to introduce a delay before closing
								self?.closeAction()
							}
						}
					}
				}
			}
		}
	}
	
	private func updateContent(with data: NSSecureCoding, contentType: String) async throws {
		switch SupportedContentType(rawValue: contentType) {
		case .note:
			if let sharedText = data as? String {
				modelToSave = Model(.init(id: UUID().uuidString, category: .text(sharedText)))
				DispatchQueue.main.async { [weak self] in
					let textView = ItemCellView(model: .init(id: UUID().uuidString, category: .text(sharedText))).uiView()
					textView.translatesAutoresizingMaskIntoConstraints = false
					self?.mainView.insertArrangedSubview(textView, at: 1)
				}
			} else {
				throw SaveError.invalidData
			}
		case .url:
			if let url = data as? URL {
				Task {
					do {
						let metadata = try await self.network.fetchPageMetadata(from: url)
						guard let title = metadata.title, let iconUrl = metadata.faviconURL?.absoluteString else {
							throw NSError(domain: "INVALID_DATA", code: 400)
						}
						DispatchQueue.main.async {
							self.modelToSave = Model(.init(id: UUID().uuidString, category: .webPage(title: title , url: url.absoluteString, imageUrl: iconUrl)))
							let webPageView = ItemCellView(model: .init(id: UUID().uuidString, category: .webPage(title: title, url: url.absoluteString, imageUrl: iconUrl))).uiView()
							webPageView.translatesAutoresizingMaskIntoConstraints = false
							self.mainView.insertArrangedSubview(webPageView, at: 1)
						}
					} catch {
						DispatchQueue.main.async {
							self.modelToSave = Model(.init(id: UUID().uuidString, category: .url(url.absoluteString)))
							let urlView = ItemCellView(model: .init(id: UUID().uuidString, category: .url(url.absoluteString))).uiView()
							urlView.translatesAutoresizingMaskIntoConstraints = false
							self.mainView.insertArrangedSubview(urlView, at: 1)
						}
					}
				}
			} else {
				throw SaveError.invalidData
			}
		case .webPage:
			guard let sharedData = data as? NSDictionary, let jsonValue = sharedData[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { break }
			guard let title = jsonValue["title"] as? String, let urlString = jsonValue["url"] as? String, let url = URL(string: urlString), let iconUrl = jsonValue["icon"] as? String else { break }
			
			do {
				let metadata = try await network.fetchPageMetadata(from: url)
				// Learn the behavior of getting the favicon - sometimes it fails
				guard let title = metadata.title, let _ = metadata.faviconURL?.absoluteString else {
					throw NSError(domain: "INVALID_DATA", code: 400)
				}
				DispatchQueue.main.async {
					self.modelToSave = Model(.init(id: UUID().uuidString, category: .webPage(title: title , url: url.absoluteString, imageUrl: iconUrl)))
					let webPageView = ItemCellView(model: .init(id: UUID().uuidString, category: .webPage(title: title, url: url.absoluteString, imageUrl: iconUrl))).uiView()
					webPageView.translatesAutoresizingMaskIntoConstraints = false
					self.mainView.insertArrangedSubview(webPageView, at: 1)
				}
			} catch {
				DispatchQueue.main.async {
					self.modelToSave = Model(.init(id: UUID().uuidString, category: .webPage(title: title, url: urlString, imageUrl: iconUrl)))
					let webPageView = ItemCellView(model: .init(id: UUID().uuidString, category: .webPage(title: title, url: urlString, imageUrl: iconUrl))).uiView()
					webPageView.translatesAutoresizingMaskIntoConstraints = false
					self.mainView.insertArrangedSubview(webPageView, at: 1)
				}
			}
		default:
			throw SaveError.invalidType
		}
	}
}
