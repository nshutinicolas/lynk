//
//  ColorTheme.swift
//  Lynk
//
//  Created by Musoni nshuti Nicolas on 03/06/2025.
//

import SwiftUI

#if os(macOS)
typealias PlatformColor = NSColor
#else
typealias PlatformColor = UIColor
#endif

struct ColorTheme: Equatable {
	let averageColor: Color
	let contrastingTone: Color
	let bodyDark: Color
	let bodyLight: Color
}

extension ColorTheme {
	static func generate(from image: PlatformImage) throws -> ColorTheme {
		let baseColor = try getAverage(from: image)
		
		var hue: CGFloat = 0
		var saturation: CGFloat = 0
		var brightness: CGFloat = 0
		var alpha: CGFloat = 0
		
		baseColor.getHue(
			&hue,
			saturation: &saturation,
			brightness: &brightness,
			alpha: &alpha
		)
		
		let contrastingTone = isLight(baseColor) ?
		PlatformColor(
			hue: hue,
			saturation: 0.9,
			brightness: 0.1,
			alpha: alpha
		) :
		PlatformColor(
			hue: hue,
			saturation: min(saturation, 0.15),
			brightness: 0.95,
			alpha: alpha
		)
		
		// MARK: Body Colors
		let bodyDark = PlatformColor(
			hue: hue,
			saturation: min(saturation, 0.8),
			brightness: min(brightness, 0.2),
			alpha: alpha
		)
		
		let bodyLight = PlatformColor(
			hue: hue,
			saturation: min(saturation, 0.2),
			brightness: max(brightness, 0.9),
			alpha: alpha
		)
		#if os(macOS)
		return ColorTheme(
			averageColor: Color(nsColor: baseColor),
			contrastingTone: Color(nsColor: contrastingTone),
			bodyDark: Color(nsColor: bodyDark),
			bodyLight: Color(nsColor: bodyLight)
		)
		#else
		return ColorTheme(
			averageColor: Color(uiColor: baseColor),
			contrastingTone: Color(uiColor: contrastingTone),
			bodyDark: Color(uiColor: bodyDark),
			bodyLight: Color(uiColor: bodyLight)
		)
		#endif
	}
	
	private static func isLight(_ color: PlatformColor) -> Bool {
		var white: CGFloat = 0
		var alpha: CGFloat = 0
		
		color.getWhite(&white, alpha: &alpha)
		
		return white >= 0.5
	}
	
	private static func getAverage(from image: PlatformImage) throws -> PlatformColor {
		#if os(macOS)
		guard let imageData = image.tiffRepresentation else {
			throw CocoaError(.fileNoSuchFile)
		}
		let ciImage = CIImage(data: imageData)
		#else
		let ciImage = CIImage(image: image)
		#endif
		let filtered = CIFilter(name: "CIAreaAverage", parameters: [
			kCIInputImageKey: ciImage ?? .init(),
			kCIInputExtentKey: CIVector(cgRect: ciImage?.extent ?? .init())
		])?.outputImage
		
		var pixel = [UInt8](repeating: 0, count: 4)
		let context = CIContext(options: [.workingColorSpace: kCFNull!])
		
		context.render(
			filtered ?? .init(),
			toBitmap: &pixel,
			rowBytes: 4,
			bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
			format: .RGBA8,
			colorSpace: nil
		)
		
		return PlatformColor(
			red: CGFloat(pixel[0]) / 255,
			green: CGFloat(pixel[1]) / 255,
			blue: CGFloat(pixel[2]) / 255,
			alpha: 1
		)
	}
}
