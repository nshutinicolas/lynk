//
//  ShareSheet.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 13/01/2026.
//

import SwiftUI
import UIKit

struct ShareSheetModel {
	let title: String
	let message: String
	let url: URL
	
	init(title: String, message: String, url: URL) {
		self.title = title
		self.message = message
		self.url = url
	}
	
	var dictionary: [Any] {
		var items: [Any] = []
		items.append(title)
		items.append(message)
		items.append(url)
		return items
	}
}

struct ShareSheet: UIViewControllerRepresentable {
	let items: ShareSheetModel
	let excludedActivityTypes: [UIActivity.ActivityType]? = nil
	
	func makeUIViewController(context: Context) -> UIActivityViewController {
		let controller = UIActivityViewController(
			activityItems: items.dictionary,
			applicationActivities: nil
		)
		controller.excludedActivityTypes = excludedActivityTypes
		return controller
	}
	
	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
		
	}
}

extension View {
	func shareSheet(isPresented: Binding<Bool>, items: ShareSheetModel) -> some View {
		self.sheet(isPresented: isPresented) {
			ShareSheet(items: items)
				.presentationDetents([.fraction(0.5)])
		}
	}
}
