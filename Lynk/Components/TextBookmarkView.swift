//
//  TextBookmarkView.swift
//  Keep Track
//
//  Created by Musoni nshuti Nicolas on 28/03/2025.
//

import SwiftUI

struct TextBookmarkView: View {
	struct Model {
		let text: String
		var date: Date = .now
	}
	
	var model: Model
	
	var body: some View {
		HStack(alignment: .top) {
			IconView(.systemName("text.cursor"))
				.padding()
				.frame(width: 60, height: 60)
				.background(Color.gray.opacity(0.2))
				.clipShape(.rect(cornerRadius: 8))
			VStack(alignment: .leading) {
				Text(model.text)
				// TODO: Fix the date
				Text("\(Date.now.description(with: .current))")
					.font(.footnote)
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

#Preview {
	TextBookmarkView(model: .init(text: "This is a long as text that should be saved as is. how long can you get man?"))
		.padding()
}
