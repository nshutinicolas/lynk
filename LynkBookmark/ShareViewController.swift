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
	
	// Using these 2 lifecycles to try counter the presentation of solid background UIDropShadowView
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if #available(iOS 26.0, *) {
			removeDropShadowBackground(in: view)
		}
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		if #available(iOS 26.0, *) {
			removeDropShadowBackground(in: view)
		}
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
			sharedItemView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
		])
	}
	
	// iOS 26 introduced a background shadow UIDropShadowView that prevented the usage of clear background
	// This is the work around this issue
	// Source: https://www.reddit.com/r/iOSProgramming/comments/1mj0et8/modal_presentation_in_uikit_adds_solid_background/
	// Known issue: sometimes the white background is visible, can't figrure out how to completely remove it
	private func removeDropShadowBackground(in view: UIView?) {
		guard let view else { return }
		if String(describing: type(of: view)).contains("UIDropShadowView") {
			view.backgroundColor = .clear
			view.isOpaque = false
			return
		}
		removeDropShadowBackground(in: view.superview)
	}

}
