//
//  IconView.swift
//  Keep Track
//
//  Created by Musoni nshuti Nicolas on 28/03/2025.
//

import SwiftUI

struct IconView: View {
	private let iconType: IconType
	private let contentMode: ContentMode
	
	init(_ iconType: IconType, contentMode: ContentMode = .fit) {
		self.iconType = iconType
		self.contentMode = contentMode
	}
	
	var body: some View {
		switch iconType {
		case .image(let image):
			Image(uiImage: image)
				.resizable()
				.aspectRatio(contentMode: contentMode)
		case .systemName(let icon):
			Image(systemName: icon)
				.resizable()
				.aspectRatio(contentMode: contentMode)
		case .remote:
			EmptyView()
		}
	}
	
	enum IconType {
		case systemName(String)
		case image(UIImage)
		case remote(String)
	}
}

#Preview("Icon") {
	IconView(.systemName("house"))
		.foregroundStyle(.white)
		.padding()
		.background(Color.red)
		.clipShape(.rect(cornerRadius: 8))
		.frame(width: 100, height: 100)
}
