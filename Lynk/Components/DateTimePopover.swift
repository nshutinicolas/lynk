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
	func dateTimePopover(
		for displayedComponent: DatePickerComponents,
		isPresented: Binding<Bool>,
		selected: Binding<Date>,
		/// Using `PartialRangeFrom` since I only need the users to set notification from now onward.
		in dateRange: PartialRangeFrom<Date> = Date.now...
	) -> some View {
		self.nativePopover(isPresented: isPresented, arrowDirection: .unknown) {
			DateTimePopover(display: displayedComponent, selected: selected, in: dateRange)
		}
	}
}

struct DateTimePopover: View {
	let displayedComponent: DatePickerComponents
	@Binding var selected: Date
	let dateRange: PartialRangeFrom<Date>
	
	init(display: DatePickerComponents, selected: Binding<Date>, in dateRange: PartialRangeFrom<Date>) {
		self.displayedComponent = display
		self._selected = selected
		self.dateRange = dateRange
	}
	
	var body: some View {
		DatePicker("", selection: $selected, in: dateRange, displayedComponents: displayedComponent)
			.applyPickerStyle(for: displayedComponent)
			.labelsHidden()
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
		DateTimePopover(display: .date, selected: .constant(.now), in: Date.now...)
		DateTimePopover(display: .hourAndMinute, selected: .constant(.now), in: Date.distantPast...)
	}
}
