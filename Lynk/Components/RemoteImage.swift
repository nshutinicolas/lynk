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
				Image(uiImage: image)
					.resizable()
					.animation(.easeIn(duration: 0.5), value: loader.loadingState != .loading)
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

final class ImageCache {
	static let shared = ImageCache()
	
	private let cache = NSCache<NSString, UIImage>()
	
	private init() { }
	
	func get(forKey key: String) -> UIImage? {
		cache.object(forKey: key as NSString)
	}
	
	func set(_ image: UIImage, forKey key: String) {
		cache.setObject(image, forKey: key as NSString)
	}
}

final class ImageLoader: ObservableObject {
	enum LoadingState: Equatable {
		case loading
		case loaded(UIImage)
		case failed
	}
	@Published var loadingState = LoadingState.loading
	
	init() { }
	
	// Private
	private var cancellable: AnyCancellable?
	private let cache = ImageCache.shared
	
	deinit {
		cancellable?.cancel()
	}
	
	func load(for urlString: String) {
		if let cachedImage = ImageCache.shared.get(forKey: urlString) {
			DispatchQueue.main.async { [weak self] in
				self?.loadingState = .loaded(cachedImage)
			}
			return
		}
		
		guard let url = URL(string: urlString) else {
			DispatchQueue.main.async { [weak self] in
				self?.loadingState = .failed
			}
			return
		}
		cancellable = URLSession.shared.dataTaskPublisher(for: url)
			.map { UIImage(data: $0.data) }
			.replaceError(with: nil)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] downloaded in
				guard let self, let downloaded else {
					self?.loadingState = .failed
					return
				}
				self.cache.set(downloaded, forKey: urlString)
				self.loadingState = .loaded(downloaded)
			}
	}
}
