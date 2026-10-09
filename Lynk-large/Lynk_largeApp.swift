//
//  Lynk_macApp.swift
//  Lynk-mac
//
//  Created by Musoni nshuti Nicolas on 31/05/2025.
//

import SwiftUI

@main
struct Lynk_macApp: App {
	@Environment(\.scenePhase) private var scenePhase
	@StateObject private var storage = BookmarkStorage.shared
	
	@StateObject private var localStorate = BookmarkStorage.shared
	var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(\.managedObjectContext, localStorate.container.viewContext)
				.environmentObject(storage)
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
