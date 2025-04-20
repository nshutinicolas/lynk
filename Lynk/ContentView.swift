//
//  ContentView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 09/04/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		AppView()
    }
}

#Preview {
    ContentView()
		.environmentObject(AppCoordinator())
}
