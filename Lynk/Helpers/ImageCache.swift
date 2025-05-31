//
//  ImageCache.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 31/05/2025.
//

#if os(macOS)
import AppKit

typealias PlatformImage = NSImage
#else
import UIKit

typealias PlatformImage = UIImage
#endif
import Foundation

protocol ImageCacheProtocol {
	func get(forKey key: String) -> PlatformImage?
	func set(_ image: PlatformImage, forKey key: String)
}

final class ImageCache: ImageCacheProtocol {
	static let shared = ImageCache()
	private let cache = NSCache<NSString, PlatformImage>()
	
	private init() { }
	
	func get(forKey key: String) -> PlatformImage? {
		cache.object(forKey: key as NSString)
	}
	
	func set(_ image: PlatformImage, forKey key: String) {
		cache.setObject(image, forKey: key as NSString)
	}
}
