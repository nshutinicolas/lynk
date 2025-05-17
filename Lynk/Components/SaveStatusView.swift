//
//  SuccessSaveView.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 16/05/2025.
//

import SwiftUI

enum SaveStatus: Equatable {
	case loading
	case success
	case error(SaveError)
}

enum SaveError: Error, Equatable {
	case invalidType
	case invalidInputItems
	case invalidData
	case custom(String)
	
	var errorDescription: String {
		switch self {
		case .invalidType:
			return "Unsupported type"
		case .invalidInputItems:
			return "Invalid input items"
		case .invalidData:
			return "Invalid data"
		case .custom(let stringValue):
			return stringValue
		}
	}
}

struct SaveStatusView: View {
	@State private var scale: CGFloat = 0
	private var status: SaveStatus
	
	init(status: SaveStatus) {
		self.status = status
	}
	
	var body: some View {
		ZStack {
			switch status {
			case .loading:
				VStack {
					ProgressView()
						.controlSize(.large)
						.frame(width: 48, height: 48)
				}
				.padding(32)
				.background(.thinMaterial)
				.roundedBorder()
				.scaleEffect(scale - 1)
			case .success:
				VStack {
					Image(systemName: "checkmark")
						.resizable()
						.frame(width: 48, height: 48)
						.foregroundStyle(.green)
				}
				.padding(32)
				.background(.thinMaterial)
				.roundedBorder()
				.scaleEffect(scale)
				.onAppear {
					withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
						scale = 1.0
					}
				}
			case .error:
				VStack {
					Image(systemName: "xmark")
						.resizable()
						.frame(width: 48, height: 48)
						.foregroundStyle(.red)
				}
				.padding(32)
				.background(.thinMaterial)
				.roundedBorder()
				.scaleEffect(scale)
				.onAppear {
					withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
						scale = 1.0
					}
				}
			}
		}
		.task {
#if targetEnvironment(simulator)
			try? await Task.sleep(nanoseconds: 1000_000_000)
//			status = .success
			try? await Task.sleep(nanoseconds: 2000_000_000)
//			status = .error(.invalidInputItems)
#endif
		}
	}
}

@available(iOS 17.0, *)
#Preview {
	@Previewable @State var status: SaveStatus = .loading
	return SaveStatusView(status: status)
}
