//
//  PopoverController.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 08/08/2025.
//
// Source: https://www.youtube.com/watch?v=5VPEcZy0FaQ

import Foundation
import SwiftUI

/// Extending the popover to the view
extension View {
	@ViewBuilder
	func nativePopover<Content: View>(
		isPresented: Binding<Bool>,
		arrowDirection: UIPopoverArrowDirection,
		@ViewBuilder content: @escaping () -> Content
	) -> some View {
		self
			.background {
				PopoverController(
					isPresented: isPresented,
					arrowDirection: arrowDirection,
					content: content()
				)
			}
	}
}

struct PopoverController<Content: View>: UIViewControllerRepresentable {
	@Binding var isPresented: Bool
	var arrowDirection: UIPopoverArrowDirection
	var content: Content
	
	@State private var alreadyPresented: Bool = false
	
	func makeCoordinator() -> Coordinator {
		return Coordinator(parent: self)
	}
	
	func makeUIViewController(context: Context) -> UIViewController {
		let controller = UIViewController()
		controller.view.backgroundColor = .clear
		return controller
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
		if alreadyPresented {
			/// Updating SwiftUI view, when It's Changed
			if let hostingController = uiViewController.presentedViewController as? PopoverHostingViewController<Content> {
				hostingController.rootView = content
				/// Updating View size when it's updated
				/// Or you can define your own size in swiftUI view
				hostingController.preferredContentSize = hostingController.view.intrinsicContentSize
			}
			/// Close view, if it's toggled Back
			if isPresented == false {
				uiViewController.dismiss(animated: true) {
					self.alreadyPresented = false
				}
			}
		} else {
			if isPresented {
				let controller = PopoverHostingViewController(rootView: content)
				controller.view.backgroundColor = .clear
				controller.modalPresentationStyle = .popover
				controller.popoverPresentationController?.permittedArrowDirections = arrowDirection
				// Connecting Delegate
				controller.presentationController?.delegate = context.coordinator
				controller.popoverPresentationController?.sourceView = uiViewController.view
				uiViewController.present(controller, animated: true)
			}
		}
	}
	
	class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
		var parent: PopoverController
		init(parent: PopoverController) {
			self.parent = parent
		}
		
		func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
			return .none
		}
		
		/// Observing the status of the Popover
		/// When it's dismissed updating the isPresented State
		func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
			parent.isPresented = false
		}
		
		/// When the popover is presented, updating the alreadyPresented state
		func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
			DispatchQueue.main.async {
				self.parent.alreadyPresented = true
			}
		}
	}
}

/// Custom Hosting Controller for wrapping to it's SwiftUI View Size
class PopoverHostingViewController<Content: View>: UIHostingController<Content> {
	override func viewDidLoad() {
		super.viewDidLoad()
		preferredContentSize = view.intrinsicContentSize
	}
}
