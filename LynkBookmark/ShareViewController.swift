//
//  ShareViewController.swift
//  LynkBookmark
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import CoreData
import Social
import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
	private let bookmarkStorage = BookmarkStorage.shared
	private var modelToSave: Model?
	
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Add Subviews
		view.addSubview(mainView)
		mainView.addArrangedSubview(closeButtonContainer)
		mainView.addArrangedSubview(saveButton)
		
		getSharedContent()
		setViewConstraints()
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
		guard let extensionItems = extensionContext?.inputItems as? [ NSExtensionItem] else {
			closeAction()
			return
		}
		// Allowed data types
		extensionItems.forEach { extensionItem in
			let attachments = extensionItem.attachments ?? []
			attachments.forEach { item in
				guard let contentType = item.registeredContentTypes.first?.identifier else { return }
				item.loadItem(forTypeIdentifier: contentType, options: nil) { [weak self] data, error in
					guard let self = self else { return }
					guard error == nil else {
						print("Error Encountered: \(String(describing: error))")
						closeAction()
						return
					}
					
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
							// Show the user that the text is empty
						}
					case .url:
						if let url = data as? URL {
							modelToSave = Model(.init(id: UUID().uuidString, category: .url(url.absoluteString)))
							DispatchQueue.main.async { [weak self] in
								let urlView = ItemCellView(model: .init(id: UUID().uuidString, category: .url(url.absoluteString))).uiView()
								urlView.translatesAutoresizingMaskIntoConstraints = false
								self?.mainView.insertArrangedSubview(urlView, at: 1)
							}
						} else {
							// Provide a warning about this error
						}
					case .webPage:
						guard let sharedData = data as? NSDictionary, let jsonValue = sharedData[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { break }
						guard let title = jsonValue["title"] as? String, let url = jsonValue["url"] as? String, let iconUrl = jsonValue["icon"] as? String else { break }
						modelToSave = Model(.init(id: UUID().uuidString, category: .webPage(title: title, url: url, imageUrl: iconUrl)))
						DispatchQueue.main.async { [weak self] in
							let webPageView = ItemCellView(model: .init(id: UUID().uuidString, category: .webPage(title: title, url: url, imageUrl: iconUrl))).uiView()
							webPageView.translatesAutoresizingMaskIntoConstraints = false
							self?.mainView.insertArrangedSubview(webPageView, at: 1)
						}
					default:
						break
					}
				}
			}
		}
	}
	
	enum SupportedContentType: String {
		case note = "public.plain-text"
		case url = "public.url"
		case webPage = "com.apple.property-list"
	}
	// Doing this as a shortcut
	@objc(Model)
	class Model: NSObject {
		let itemViewModel: ItemCellView.Model
		init(_ itemViewModel: ItemCellView.Model) {
			self.itemViewModel = itemViewModel
		}
	}
}
