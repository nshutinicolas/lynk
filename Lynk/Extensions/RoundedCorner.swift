//
//  RoundedCorner.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 02/05/2025.
//

import SwiftUI

extension View {
	func roundedBorder(
		_ radius: CGFloat = 8,
		color: Color = .gray.opacity(0.5),
		lineWidth: CGFloat = 1
	) -> some View {
		self
			.overlay {
				RoundedRectangle(cornerRadius: radius)
					.stroke(color, lineWidth: lineWidth)
			}
			.background()
			.clipShape(.rect(cornerRadius: radius))
	}
}

#Preview {
	VStack {
		Rectangle()
			.frame(width: 100, height: 100)
			.roundedBorder(240)
	}
}
