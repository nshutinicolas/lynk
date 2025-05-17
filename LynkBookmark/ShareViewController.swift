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
	private var sharedItemView = UIView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .clear
		sharedItemView = ExtensionShareView(
			context: extensionContext,
			onClose: { [weak self] in
				self?.closeAction()
			}
		).uiView()
		setShareViewConstraints()
	}
	
	@objc func closeAction() {
		self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
	}
	
	func setShareViewConstraints() {
		view.addSubview(sharedItemView)
		sharedItemView.translatesAutoresizingMaskIntoConstraints = false
		sharedItemView.backgroundColor = UIColor.clear
		NSLayoutConstraint.activate([
			sharedItemView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			sharedItemView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			sharedItemView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			sharedItemView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
		])
	}
}
