//
//  AuthView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 10/09/2025.
//

import SwiftUI

struct AuthView: View {
	let action: () -> Void
	
	init(action: @escaping() -> Void) {
		self.action = action
	}
	
	var body: some View {
		VStack {
			Text("Welcome to Lynk")
				.font(.largeTitle)
				.padding()
			Image(systemName: "faceid")
				.resizable()
				.frame(width: 80, height: 80)
				.padding()
			Button {
				action()
			} label: {
				Text("Authenticate")
					.foregroundStyle(.white)
					.padding(.vertical, 12)
					.padding(.horizontal, 32)
			}
			.background(Color.blue)
			.clipShape(.rect(cornerRadius: 8))
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

#Preview {
	AuthView { }
}
