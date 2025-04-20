//
//  LynkApp.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import SwiftUI

@main
struct LynkApp: App {
	@StateObject private var coordinator = AppCoordinator()
	@StateObject private var storage = BookmarkStorage.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environmentObject(coordinator)
				.environment(\.managedObjectContext, storage.container.viewContext)
        }
    }
}
