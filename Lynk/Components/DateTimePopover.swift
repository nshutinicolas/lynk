//
//  DateTimePopover.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 08/08/2025.
//

import Foundation
import SwiftUI

extension View {
	@ViewBuilder
	func calendarPopover(
		for displayedComponent: DatePickerComponents,
		isPresented: Binding<Bool>,
		selected: Binding<Date>,
		in dateRange: DateTimePopover.DateRange = .none,
		arrowDirection: UIPopoverArrowDirection = .any
	) -> some View {
		self.nativePopover(isPresented: isPresented, arrowDirection: arrowDirection) {
			DateTimePopover(display: displayedComponent, selected: selected, in: dateRange)
		}
	}
}

struct DateTimePopover: View {
	let displayedComponent: DatePickerComponents
	@Binding var selected: Date
	let dateRange: DateRange
	
	init(display: DatePickerComponents, selected: Binding<Date>, in dateRange: DateRange) {
		self.displayedComponent = display
		self._selected = selected
		self.dateRange = dateRange
	}
	
	var body: some View {
		Group {
			if let range = dateRange.range {
				DatePicker("", selection: $selected, in: range, displayedComponents: displayedComponent)
					.applyPickerStyle(for: displayedComponent)
			} else {
				DatePicker("", selection: $selected, displayedComponents: displayedComponent)
					.applyPickerStyle(for: displayedComponent)
			}
		}
		.labelsHidden()
	}
	
	enum DateRange {
		case partial(PartialRangeFrom<Date>)
		case partialThrough(PartialRangeThrough<Date>)
		case closed(ClosedRange<Date>)
		case none
		
		var range: ClosedRange<Date>? {
			switch self {
			case .partial(let partialRangeFrom):
				return partialRangeFrom.lowerBound...Date.distantFuture
			case .partialThrough(let partialRangeThrough):
				return Date.distantPast...partialRangeThrough.upperBound
			case .closed(let closedRange): return closedRange
			case .none: return nil
			}
		}
	}
}

private extension View {
	/// Applies a graphical style for date-only pickers and a wheel style for time pickers.
	/// This is done specifically to match the intended design
	/// - Parameter components: `DatePickerComponents`
	/// - Returns ViewBuilder
	@ViewBuilder
	func applyPickerStyle(for components: DatePickerComponents) -> some View {
		if components == .date {
			self.datePickerStyle(.graphical)
		} else {
			self.datePickerStyle(.wheel)
		}
	}
}

#Preview("Date Time Picker Popover") {
	Group {
		DateTimePopover(display: .date, selected: .constant(.now), in: .partialThrough(...Date.now))
		DateTimePopover(display: .hourAndMinute, selected: .constant(.now), in: .partial(Date.now...))
	}
}
