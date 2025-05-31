//
//  NSWebview.swift
//  Lynk-mac
//
//  Created by Musoni nshuti Nicolas on 31/05/2025.
//

import SwiftUI
import WebKit

struct NSWebView: NSViewRepresentable {
	let url: String
	
	func makeNSView(context: Context) -> WKWebView {
		return WKWebView()
	}
	
	func updateNSView(_ nsView: WKWebView, context: Context) {
		if let url = URL(string: url) {
			nsView.load(URLRequest(url: url))
		}
	}
}
