//
//  ReminderView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 08/08/2025.
//

import SwiftUI

struct ReminderView: View {
	@State private var showDatePicker = false
	@Binding var selectedDate: Date
	@State private var showTimePicker = false
	@Binding var selectedTime: Date
	
	init(selectedDate: Binding<Date>, selectedTime: Binding<Date>) {
		self._selectedDate = selectedDate
		self._selectedTime = selectedTime
	}
	
	var body: some View {
		HStack {
			Button {
				showDatePicker.toggle()
			} label: {
				HStack {
					Image(systemName: "calendar")
						.resizable()
						.frame(width: 20, height: 20)
						.padding(8)
						.background(Color.gray.opacity(0.2))
						.clipShape(.rect(cornerRadius: 4))
					VStack(alignment: .leading, spacing: 0) {
						Text("Date")
							.font(.caption)
						Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
							.font(.body)
					}
					.foregroundStyle(Color(uiColor: .label))
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.dateTimePopover(for: .date, isPresented: $showDatePicker, selected: $selectedDate)
			Button {
				showTimePicker.toggle()
			} label: {
				HStack {
					Image(systemName: "clock")
						.resizable()
						.frame(width: 20, height: 20)
						.padding(8)
						.background(Color.gray.opacity(0.2))
						.clipShape(.rect(cornerRadius: 4))
					VStack(alignment: .leading, spacing: 0) {
						Text("Time")
							.font(.caption)
						Text(selectedTime.formatted(date: .omitted, time: .shortened))
							.font(.body)
					}
					.foregroundStyle(Color(uiColor: .label))
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.dateTimePopover(for: .hourAndMinute, isPresented: $showTimePicker, selected: $selectedTime)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

#Preview("Reminder View") {
	ReminderView(selectedDate: .constant(.now), selectedTime: .constant(.now))
}
