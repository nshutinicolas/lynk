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
					ZStack {
						if editTitle == false {
							HStack {
								Text(text)
									.lineLimit(3)
							}
							.frame(maxWidth: .infinity, alignment: .leading)
							.overlay(alignment: .trailing) {
								Button {
									editTitle = true
								} label: {
									Image(systemName: "pencil")
										.resizable()
										.scaledToFit()
										.frame(width: 12, height: 12)
										.padding(8)
										.roundedBorder()
								}
							}
						} else {
							HStack {
								TextField(model.text ?? "", text: $edittedTitle)
									.padding(8)
									.roundedBorder()
									.overlay(alignment: .trailing) {
										Button {
											edittedTitle = ""
										} label: {
											Image(systemName: "xmark")
												.resizable()
												.scaledToFit()
												.frame(width: 8, height: 8)
												.padding(6)
												.background(Color.gray.opacity(0.5))
												.clipShape(.circle)
										}
										.buttonStyle(.plain)
										.padding(.trailing, 4)
									}
								Button {
									
								} label: {
									Image(systemName: "checkmark")
										.resizable()
										.scaledToFit()
										.frame(width: 20, height: 20)
										.padding(8)
										.roundedBorder()
								}
							}
						}
					}
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

#Preview {
	VStack {
		URLBookmark(model: .init(url: "https://ibirori.rw/events/go-over-here", text: "Ibirori event"))
	}
	.padding()
}
