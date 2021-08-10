// THCocoaExtensions.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
extension NSColor {
	
	@objc func th_stringRepresentation() -> String? {
		guard let rgbColor = self.usingColorSpace(NSColorSpace.sRGB)
		else {
			return nil
		}
	
		var red: CGFloat = 0.0
		var green: CGFloat = 0.0
		var blue: CGFloat = 0.0
		var alpha: CGFloat = 0.0
		rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

		return String(format: "NSColor-sRGB:%f-%f-%f-%f", red, green, blue, alpha)
	}

	@objc convenience init?(fromStringRepresentation stringRepresentation: Any?) {

		guard let stringRepresentation = stringRepresentation as? String
		else {
			return nil
		}
		
		if stringRepresentation.hasPrefix("NSColor-sRGB:") == true {
			let string = stringRepresentation.dropFirst("NSColor-sRGB:".count)

			let comps = string.components(separatedBy: "-")

			if comps.count == 4 {
				if 	let red = Float(comps[0]),
					let green = Float(comps[1]),
					let blue = Float(comps[2]),
					let alpha = Float(comps[3]) {
					self.init(srgbRed: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
					return
				}
			}
		}

		return nil
	}

	@objc func th_draw(inRect rect: NSRect) {
		set()
		NSBezierPath.fill(rect)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
