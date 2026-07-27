//
//  Buttons.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 24/07/2026.
//

import Foundation
import SwiftUI

struct PrimaryButton: View {
	let title: String
	let action: () -> Void
	
	init(_ title: String, action: @escaping () -> Void) {
		self.action = action
		self.title = title
	}
	var body: some View {
		Button {
			action()
		} label: {
			Text(title)
				.fontWeight(.medium)
				.foregroundStyle(.white)
				.frame(maxWidth: .infinity)
				.contentShape(.rect)
		}
		.buttonStyle(.plain)
		.padding()
		.background(Color.blue)
		.roundedBorder(for: .capsule)
	}
}

struct SecondaryButton: View {
	let title: String
	let action: () -> Void
	
	init(_ title: String, action: @escaping () -> Void) {
		self.action = action
		self.title = title
	}
	
	var body: some View {
		Button {
			action()
		} label: {
			Text(title)
				.fontWeight(.medium)
				.frame(maxWidth: .infinity)
				.contentShape(.rect)
		}
		.buttonStyle(.plain)
	}
}

