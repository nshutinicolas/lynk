//
//  WebPageBookmark.swift
//  Keep Track
//
//  Created by Musoni nshuti Nicolas on 28/03/2025.
//

import SwiftUI

struct WebPageBookmark: View {
	struct Model {
		let title: String
		let url: String
		let date: Date
		let icon: String?
		
		init(title: String, url: String, date: Date = .now, icon: String?) {
			self.title = title
			self.url = url
			self.date = date
			self.icon = icon
		}
	}
	
	var model: Model
	
	var body: some View {
		HStack(alignment: .top) {
			ZStack {
				if let iconUrl = model.icon {
					RemoteImage(url: iconUrl)
						.setErrorView {
							IconView(.systemName("globe"))
								.frame(width: 24, height: 24)
								.padding()
								.background(Color.gray.opacity(0.2))
								.clipShape(.rect(cornerRadius: 8))
						}
						.frame(width: 60, height: 60)
						.background()
				} else {
					IconView(.systemName("globe"))
						.frame(width: 24, height: 24)
						.padding()
						.background(Color.gray.opacity(0.2))
						.clipShape(.rect(cornerRadius: 8))
				}
			}
			.clipShape(.rect(cornerRadius: 8))
			VStack(alignment: .leading, spacing: 12) {
				Text(model.title)
					.fontWeight(.medium)
					.lineLimit(3)
				Text(model.url)
					.lineLimit(2)
					.font(.footnote)
					.foregroundStyle(.blue)
					.underline()
				Text(model.date.formatted())
					.font(.caption)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

#Preview {
	VStack {
		WebPageBookmark(model: .init(
			title: "Title of the article",
			url: "https://ibirori.rw",
			icon: "https://hatrabbits.com/wp-content/uploads/2017/01/random.jpg"
		))
		WebPageBookmark(model: .init(
			title: "Title of the article",
			url: "https://ibirori.rw",
			icon: nil
		))
	}
	.frame(maxWidth: .infinity)
}
