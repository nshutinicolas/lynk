//
//  UIEdgeInsets+Extension.swift
//  Keep Track
//
//  Created by Musoni nshuti Nicolas on 28/03/2025.
//

import SwiftUI

extension UIEdgeInsets {
	// TODO: Can use a better naming for this
	init(edge: CGFloat) {
		self.init(top: edge, left: edge, bottom: edge, right: edge)
	}
}

extension EdgeInsets {
	init(edge: CGFloat) {
		self.init(top: edge, leading: edge, bottom: edge, trailing: edge)
	}
	
	init(vertical: CGFloat, horizontal: CGFloat) {
		self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
	}
}
