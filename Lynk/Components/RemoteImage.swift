//
//  RemoteImage.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import Combine
import SwiftUI

// TODO: Implement this using NSCache
struct RemoteImage<Placeholder: View, ErrorView: View>: View {
	@StateObject private var loader = ImageLoader()
	private var placeholder: Placeholder?
	private var errorView: ErrorView?
	private let url: String
	
	init(url: String) where Placeholder == EmptyView, ErrorView == EmptyView {
		self.url = url
		self.placeholder = nil
		self.errorView = nil
	}
	
	init(
		url: String,
		placeholder: Placeholder? = nil,
		errorView: ErrorView? = nil
	) {
		self.url = url
		self.placeholder = placeholder
		self.errorView = errorView
	}
	
	var body: some View {
		ZStack {
			switch loader.loadingState {
			case .loading:
				if let placeholder {
					placeholder
				} else {
					ProgressView()
						.animation(.easeOut, value: loader.loadingState != .loading)
				}
			case .loaded(let image):
#if os(macOS)
				Image(nsImage: image)
					.resizable()
					.animation(.easeIn(duration: 0.5), value: loader.loadingState != .loading)
#else
				Image(uiImage: image)
					.resizable()
					.animation(.easeIn(duration: 0.5), value: loader.loadingState != .loading)
#endif
			case .failed:
				if let errorView {
					errorView
				} else {
					Image(systemName: "photo.on.rectangle.fill")
						.resizable()
				}
			}
		}
		.onAppear { loader.load(for: url) }
	}
}

extension RemoteImage {
	func setPlaceholder<NewPlaceholder: View>(
		@ViewBuilder _ placeholder: () -> NewPlaceholder
	) -> RemoteImage<NewPlaceholder, ErrorView>  {
		RemoteImage<NewPlaceholder, ErrorView>(
			url: self.url,
			placeholder: placeholder(),
			errorView: errorView
		)
	}
	
	func setErrorView<NewErrorView: View>(
		@ViewBuilder _ errorView: () -> NewErrorView
	) -> RemoteImage<Placeholder, NewErrorView> {
		RemoteImage<Placeholder, NewErrorView>(
			url: self.url,
			placeholder: placeholder,
			errorView: errorView()
		)
	}
}

#Preview {
	ScrollView {
		RemoteImage(url: "https://images.unsplash.com/photo-1704340142770-b52988e5b6eb?q=80&w=2900&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
//			.setPlaceholder {
//				Image(systemName: "xmark")
//					.resizable()
//			}
			.scaledToFill()
			.frame(width: 300, height: 220)
			.background(Color.gray.opacity(0.3))
			.clipShape(.rect(cornerRadius: 8))
	}
}
