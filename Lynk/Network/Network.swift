//
//  Network.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 16/05/2025.
//

import Foundation

class Network {
	static let shared = Network()
	
	private init() {}
	
	func fetchPageMetadata(from url: URL) async throws -> (title: String?, faviconURL: URL?, description: String?) {
		let (data, _) = try await URLSession.shared.data(from: url)
		let html = String(data: data, encoding: .utf8)
		guard let html else {
			throw NSError(domain: "Invalid data", code: 400)
		}
		let title = self.extractTitle(from: html)
		let faviconURL = self.extractFaviconURL(from: html, baseURL: url)
		let description = self.extractDescription(from: html)
		return (title: title, faviconURL: faviconURL, description: description)
	}
	
	func extractTitle(from html: String) -> String? {
		let pattern = "<title>(.*?)</title>"
		if let range = html.range(of: pattern, options: .regularExpression) {
			return String(html[range]).replacingOccurrences(of: "<title>", with: "").replacingOccurrences(of: "</title>", with: "")
		}
		return nil
	}
	
	func extractFaviconURL(from html: String, baseURL: URL) -> URL? {
		let pattern = "<link[^>]+rel=[\"'](?:shortcut )?icon[\"'][^>]+href=[\"']([^\"']+)[\"']"
		if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
		   let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)),
		   let hrefRange = Range(match.range(at: 1), in: html) {
			let href = String(html[hrefRange])
			return URL(string: href, relativeTo: baseURL)?.absoluteURL
		}
		return nil
	}
	
	func extractDescription(from html: String) -> String? {
		let pattern = "<meta[^>]*name=[\"']description[\"'][^>]*content=[\"']([^\"']+)[\"']"
		if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
		   let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)),
		   let contentRange = Range(match.range(at: 1), in: html) {
			return String(html[contentRange])
		}
		return nil
	}
}
