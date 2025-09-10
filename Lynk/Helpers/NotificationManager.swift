//
//  NotificationManager.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 08/08/2025.
//

import Foundation
import UserNotifications

final class NotificationManager {
	static let shared = NotificationManager()
	// Make it accessible for reuse
	let notificationCenter = NotificationCenter.default
	
	@Flag(.enableReminders) private var enableReminders
	
	private init() { }
	
	func notificationPermissionStatus() async -> UNAuthorizationStatus {
		await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
	}
	
	func requestNotificationPermission() async throws -> Bool {
		let options: UNAuthorizationOptions = [.alert, .badge, .sound]
		let response = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
		return response
	}
	
	func scheduleNotification(for model: BookmarkModel, date: Date, time: Date) {
		let content = UNMutableNotificationContent()
		content.title = "Lynk Review Reminder" // Find a better title than this
		let notificationSubtitle: String
		switch model.category {
		case .text(let title):
			notificationSubtitle = title
		case .url(let url, let title):
			notificationSubtitle = title ?? url
		case .webPage(let title, _, _):
			notificationSubtitle = title
		}
		content.subtitle = notificationSubtitle
		content.sound = .default
		
		// Format the time properly
		var dateComponents = DateComponents()
		dateComponents.year = date.components.year
		dateComponents.month = date.components.month
		dateComponents.day = date.components.day
		dateComponents.hour = time.components.hour
		dateComponents.minute = time.components.minute
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
		
		let request = UNNotificationRequest(identifier: model.id, content: content, trigger: trigger)
		
		UNUserNotificationCenter.current().add(request)
	}
}
