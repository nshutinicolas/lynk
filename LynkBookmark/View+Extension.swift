//
//  View+Extension.swift
//  LynkBookmark
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import SwiftUI

extension View {
	func uiView(autoContraint: Bool = false) -> UIView {
		UIHostingController(rootView: self).view
	}
}
