//
//  LynkApp.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import SwiftUI

@main
struct LynkApp: App {
	@Environment(\.scenePhase) var scenePhase
	@StateObject private var coordinator = AppCoordinator()
	@StateObject private var storage = BookmarkStorage.shared
	@StateObject private var appTheme = AppTheme()
	@StateObject private var notificationContainer = NotificationContainer()
	
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environmentObject(coordinator)
				.environment(\.managedObjectContext, storage.container.viewContext)
				.environmentObject(appTheme)
				.environmentObject(storage)
				.environmentObject(notificationContainer)
				.onAppear {
					appTheme.updateFromLocalStorage()
				}
				.onChange(of: scenePhase) { newValue in
					switch newValue {
					case .active:
						// This solves the issue when the app is in the background and the extention adds a new item
						// Not sure if this is the right way
						storage.container.viewContext.refreshAllObjects()
					default:
						break
					}
				}
				.onOpenURL { url in
					/**
					 `Format of valid url:`
					 - From PN to open a link`lynk://open?link=<url>&title=<text>`. title is optional
					 - TODO: Look into using the item id from coredata instead of the url
					 */
					handleDeeplink(with: url)
					// FFT: - What if we introduced universal link? How would we do this?
					// TBD
				}
        }
    }
	
	private func handleDeeplink(with url: URL) {
		// Validate the url first
		guard url.scheme == "lynk" else { return }
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			print("🚨Invalid components for url: \(url)🚨")
			return
		}
		guard let host = components.host, host == "open" else {
			print("🚨Invalid host name in url: \(url) - \(components.host ?? "No Hostname")🚨")
			return
		}
		// Get the value of link from the url
		guard let linkValue = components.queryItems?.first(where: { $0.name == "link" })?.value else {
			print("🚨Invalid link value for url: \(url)🚨")
			return
		}
		let titleValue = components.queryItems?.first(where: { $0.name == "title" })?.value
		notificationContainer.setPendingDeeplinkNotification(.init(url: linkValue, title: titleValue))
	}
}

// Using only onOpenUrl was not working, the solution to handling PN taps is this with the usage of modern
// SwiftUI app delegate adaptor
// <Claude code suggested it>
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		UNUserNotificationCenter.current().delegate = self
		return true
	}
	
	// Called when the user taps the notification
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo
		
		if let openString = userInfo["open"] as? String,
		   let url = URL(string: openString) {
			// Manually trigger the deeplink
			DispatchQueue.main.async {
				UIApplication.shared.open(url)
			}
		}
		
		completionHandler()
	}
}

