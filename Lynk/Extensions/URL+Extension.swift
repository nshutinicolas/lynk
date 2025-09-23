//
//  URL+Extension.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 23/09/2025.
//

import Foundation

extension URL {
	var isValid: Bool {
		let string = self.absoluteString
		let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
		let range = NSRange(string.startIndex..., in: string)
		let matches = detector?.matches(in: string, range: range)
		return matches?.count == 1 && matches?.first?.range == range
	}
}
