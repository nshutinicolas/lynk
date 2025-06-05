//
//  Lynk_macApp.swift
//  Lynk-mac
//
//  Created by Musoni nshuti Nicolas on 31/05/2025.
//

import SwiftUI

@main
struct Lynk_macApp: App {
	@StateObject private var localStorate = BookmarkStorage.shared
	var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(\.managedObjectContext, localStorate.container.viewContext)
        }
    }
}
