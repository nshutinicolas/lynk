//
//  WebPageMetadata.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 16/05/2025.
//

import Foundation

class WebPageMetadata {
	static let shared = WebPageMetadata()
	
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
		extractTitleWithRegex(from: html)
	}
	
	func extractFaviconURL(from html: String, baseURL: URL) -> URL? {
		let pattern = "<link[^>]+rel=[\"'][^\"']*icon[^\"']*[\"'][^>]+href=[\"']([^\"']+)[\"']"
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
	
	// ChatGPT code 😎
	// Went this route to take care of scenarios where title has multiline text
	// The alternative is to use SwiftSoup<https://github.com/scinfu/SwiftSoup>
	func extractTitleWithRegex(from html: String) -> String? {
		// Use dotMatchesLineSeparators so `.` matches newlines, and non-greedy capture (.*?) for the title content.
		let pattern = "<title[^>]*>(.*?)</title>"
		guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators, .caseInsensitive]) else {
			return nil
		}
		
		let ns = html as NSString
		let range = NSRange(location: 0, length: ns.length)
		guard let match = regex.firstMatch(in: html, options: [], range: range), match.numberOfRanges > 1 else {
			return nil
		}
		
		var title = ns.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
		
		// collapse runs of whitespace/newlines to single spaces
		let collapsed = title.components(separatedBy: .whitespacesAndNewlines)
			.filter { !$0.isEmpty }
			.joined(separator: " ")
		title = decodeHTMLEntities(collapsed)
		
		return title
	}
	
	func decodeHTMLEntities(_ string: String) -> String {
		guard let data = string.data(using: .utf8) else { return string }
		let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
			.documentType: NSAttributedString.DocumentType.html,
			.characterEncoding: String.Encoding.utf8.rawValue
		]
		guard let attr = try? NSAttributedString(data: data, options: options, documentAttributes: nil)  else {
			return string
		}
		return attr.string
	}
}
