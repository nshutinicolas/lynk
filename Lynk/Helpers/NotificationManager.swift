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
		content.title = "📖Reminding you to read this" // Find a better title than this
		let notificationSubtitle: String
		switch model.category {
		case .text(let title):
			notificationSubtitle = title
		case .url(let url, let title):
			notificationSubtitle = title ?? url
		case .webPage(let title, _, _):
			notificationSubtitle = title
		}
		content.body = notificationSubtitle
		content.sound = .default
		content.userInfo = model.userInfo
		
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

// Created this to keep all the pending notifications to be displayed when `AppView` is opened
// This will happen when the user has the app locked and they take some time to open the app before they can view the deeplink values
class NotificationContainer: ObservableObject {
	static let shared = NotificationContainer()
	
	/// Holds the value for the link to be opened when user accepts to open it
	/// Only the last one tapped will be stored
	@Published var pendingDeeplinkNotification: AlertInfo?
	
	private init() { }
	
	func setPendingDeeplinkNotification(_ info: AlertInfo) {
		pendingDeeplinkNotification = info
	}
	
	func clearPendingDeeplinkNotification() {
		pendingDeeplinkNotification = nil
	}
	
	/// Parses a deeplink and stores it as the pending notification
	/// `Format of valid url:` `lynk://open?link=<url>&title=<text>&id=<bookmark id>`. title and id are optional
	@discardableResult
	func handleDeeplink(_ url: URL) -> Bool {
		// Validate the url first
		guard url.scheme == "lynk" else { return false }
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			print("🚨Invalid components for url: \(url)🚨")
			return false
		}
		guard let host = components.host, host == "open" else {
			print("🚨Invalid host name in url: \(url) - \(components.host ?? "No Hostname")🚨")
			return false
		}
		// Get the value of link from the url
		guard let linkValue = components.queryItems?.first(where: { $0.name == "link" })?.value else {
			print("🚨Invalid link value for url: \(url)🚨")
			return false
		}
		let titleValue = components.queryItems?.first(where: { $0.name == "title" })?.value
		let idValue = components.queryItems?.first(where: { $0.name == "id" })?.value
		setPendingDeeplinkNotification(.init(url: linkValue, title: titleValue, bookmarkId: idValue))
		return true
	}
	
	struct AlertInfo: Equatable {
		/// Unique per tap so that tapping the same notification twice still triggers a change
		let id = UUID()
		let url: String
		let title: String?
		/// Older notifications were scheduled without the bookmark id
		var bookmarkId: String? = nil
	}
}
