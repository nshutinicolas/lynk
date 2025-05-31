//
//  ImageLoader.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 31/05/2025.
//

import Combine
import Foundation

final class ImageLoader: ObservableObject {
	enum LoadingState: Equatable {
		case loading
		case loaded(PlatformImage)
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
	
	// TODO: Transform this to be an async method
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
			.map { PlatformImage(data: $0.data) }
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
