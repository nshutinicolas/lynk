//
//  URLBookmark.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 22/05/2025.
//

import SwiftUI

struct URLBookmark: View {
	@State private var edittedTitle: String
	@State private var editTitle = false
	struct Model {
		let url: String
		let text: String?
		var date: Date = .now
	}
	
	var model: Model
	
	init(model: Model) {
		self.model = model
		self._edittedTitle = .init(initialValue: model.text ?? "")
	}
	
	var body: some View {
		HStack(alignment: .top) {
			IconView(.systemName("globe"))
				.padding()
				.frame(width: 60, height: 60)
				.background(Color.gray.opacity(0.2))
				.clipShape(.rect(cornerRadius: 8))
			VStack(alignment: .leading) {
				if let text = model.text {
					HStack {
						Text(text)
							.lineLimit(3)
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
				Text(model.url)
					.lineLimit(2)
					.font(.footnote)
					.foregroundStyle(.blue)
					.underline()
				Text(model.date.formatted())
					.font(.footnote)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

#if DEBUG
#Preview {
	VStack {
		URLBookmark(model: .init(url: "https://ibirori.rw/events/go-over-here", text: "Ibirori event"))
	}
	.padding()
}
#endif
