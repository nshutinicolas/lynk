//
//  Date+Extension.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 24/04/2025.
//

import Foundation

extension Date {
	// DateFormatter is expensive to create, reuse them across the list cells
	private static let todayFormatter = dateFormatter(with: "'Today at' h:mm a")
	private static let yesterdayFormatter = dateFormatter(with: "'Yesterday at' h:mm a")
	private static let fullDateFormatter = dateFormatter(with: "h:mm a dd/MM/yyyy")
	
	private static func dateFormatter(with format: String) -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter
	}
	
	func formatted() -> String {
		let calendar = Calendar.current
		
		if calendar.isDateInToday(self) {
			return Self.todayFormatter.string(from: self)
		} else if calendar.isDateInYesterday(self) {
			return Self.yesterdayFormatter.string(from: self)
		} else {
			return Self.fullDateFormatter.string(from: self)
		}
	}
	
	var components: DateComponents {
		Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
	}
	
	func `is`(_ sign: ComparizonSign, to date: Date, for components: Set<Calendar.Component>) -> Bool {
		let calendar = Calendar.current
		let selfComponents = calendar.dateComponents(components, from: self)
		let dateComponents = calendar.dateComponents(components, from: date)
		guard let selfDate = calendar.date(from: selfComponents), let dateDate = calendar.date(from: dateComponents) else {
			return false
		}
		
		// Can move this to ComparizonSign
		switch sign {
		case .lessThan:
			return selfDate < dateDate
		case .lessOrEqual:
			return selfDate <= dateDate
		case .equal:
			return selfDate == dateDate
		case .greaterThan:
			return selfDate > dateDate
		case .greaterOrEqual:
			return selfDate >= dateDate
		}
	}
	
	enum ComparizonSign {
		case lessThan, lessOrEqual, equal, greaterThan, greaterOrEqual
	}
}
