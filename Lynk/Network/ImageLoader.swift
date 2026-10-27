//
//  ImageLoader.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 31/05/2025.
//

import Foundation
import ImageIO

@MainActor
final class ImageLoader: ObservableObject {
	enum LoadingState: Equatable {
		case loading
		case loaded(PlatformImage)
		case failed
	}
	@Published private(set) var loadingState = LoadingState.loading

	init() { }

	// Private
	private var loadedURL: String?
	private let pipeline = ImagePipeline.shared

	func load(for urlString: String) async {
		if loadedURL == urlString, loadingState != .loading { return }
		if loadingState != .loading {
			loadingState = .loading
		}
		let image = await pipeline.image(for: urlString)
		// The view moved on to another url or went off screen, the next load will pick it up from the cache
		guard Task.isCancelled == false else { return }
		loadedURL = urlString
		if let image {
			loadingState = .loaded(image)
		} else {
			loadingState = .failed
		}
	}
}

/// Downloads, downsamples and caches remote images.
/// Views requesting the same url share one download.
@MainActor
final class ImagePipeline {
	static let shared = ImagePipeline()
	/// Largest side of a cached image in pixels. The biggest slot in the app is 120pt
	nonisolated static let maxPixelSize = 360

	private let cache = ImageCache.shared
	private var inFlight = [String: Task<PlatformImage?, Never>]()
	/// Urls that will keep failing for this session. ie: invalid url, missing file or unsupported format
	private var failedURLs = Set<String>()

	private init() { }

	func image(for urlString: String) async -> PlatformImage? {
		if let cached = cache.get(forKey: urlString) { return cached }
		if failedURLs.contains(urlString) { return nil }
		if let task = inFlight[urlString] { return await task.value }
		guard let url = URL(string: urlString) else {
			failedURLs.insert(urlString)
			return nil
		}

		let task = Task { () -> PlatformImage? in
			let result = await Self.fetch(url)
			inFlight[urlString] = nil
			switch result {
			case .success(let image, let cost):
				cache.set(image, forKey: urlString, cost: cost)
				return image
			case .invalid:
				failedURLs.insert(urlString)
				return nil
			case .unreachable:
				// Possibly offline, allow a retry the next time the image is requested
				return nil
			}
		}
		inFlight[urlString] = task
		return await task.value
	}

	private enum FetchResult {
		case success(PlatformImage, cost: Int)
		case invalid
		case unreachable
	}

	nonisolated private static func fetch(_ url: URL) async -> FetchResult {
		// Detached to keep the download and decoding off the main thread
		await Task.detached(priority: .userInitiated) {
			guard let (data, response) = try? await URLSession.shared.data(from: url) else {
				return FetchResult.unreachable
			}
			if let statusCode = (response as? HTTPURLResponse)?.statusCode, (200..<300).contains(statusCode) == false {
				return (400..<500).contains(statusCode) ? .invalid : .unreachable
			}
			return downsample(data)
		}.value
	}

	nonisolated private static func downsample(_ data: Data) -> FetchResult {
		let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
		guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else { return .invalid }

		// Files like .ico hold multiple sizes, pick the largest one
		var index = 0
		var largestWidth = 0
		for candidate in 0..<CGImageSourceGetCount(source) {
			let properties = CGImageSourceCopyPropertiesAtIndex(source, candidate, nil) as? [CFString: Any]
			let width = properties?[kCGImagePropertyPixelWidth] as? Int ?? 0
			if width > largestWidth {
				largestWidth = width
				index = candidate
			}
		}

		let thumbnailOptions = [
			kCGImageSourceCreateThumbnailFromImageAlways: true,
			kCGImageSourceCreateThumbnailWithTransform: true,
			kCGImageSourceShouldCacheImmediately: true,
			kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
		] as CFDictionary
		guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, index, thumbnailOptions) else { return .invalid }

		#if os(macOS)
		let image = PlatformImage(cgImage: cgImage, size: .zero)
		#else
		let image = PlatformImage(cgImage: cgImage)
		#endif
		return .success(image, cost: cgImage.bytesPerRow * cgImage.height)
	}
}
