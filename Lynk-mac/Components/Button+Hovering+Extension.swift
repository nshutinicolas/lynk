//
//  Button+Hovering+Extension.swift
//  Lynk-mac
//
//  Created by Musoni nshuti Nicolas on 16/02/2026.
//

import SwiftUI

struct HoverableButton<PopoverContent: View>: ViewModifier {
	@State private var isHovered = false
	private let hoverable: Bool
	private var popoverContent: () -> PopoverContent
	
	init(
		hoverable: Bool,
		@ViewBuilder popoverContent: @escaping () -> PopoverContent
	) {
		self.hoverable = hoverable
		self.popoverContent = popoverContent
	}
	
	init(hoverable: Bool, text: String) where PopoverContent == Text {
		self.hoverable = hoverable
		self.popoverContent = { Text(text) }
	}
	
	func body(content: Content) -> some View {
		content
			.onHover { value in
				guard self.hoverable else { return }
				self.isHovered.toggle()
			}
			.popover(isPresented: $isHovered) {
				popoverContent()
					.padding()
			}
	}
}

extension View {
	func hoverPopover<Content: View>(
		enabled: Bool,
		@ViewBuilder content: @escaping () -> Content
	) -> some View {
		modifier(HoverableButton(hoverable: enabled, popoverContent: content))
	}
	
	func hoverPopover(enabled: Bool, text: String) -> some View {
		modifier(HoverableButton(hoverable: enabled, text: text))
	}
}
