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
        }
    }
}
