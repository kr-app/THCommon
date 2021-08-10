// THExtensions.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
extension NSObject {

	var th_className: String {
		String(describing: type(of: self))
    }

	private var th_pointer: String {
		String(format: "%p", self)
	}
	
	@objc func th_description(_ more: String) -> String {
		var s = "<\(th_className): \(th_pointer)"
		if more.isEmpty == false {
			s += " \(more)"
		}
		return s + ">"
	}

	class var th_className: String {
		String(describing: self)
    }
}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension DefaultStringInterpolation {
	mutating func appendInterpolation<T>(_ optional: T?) {
		switch optional {
		case .some(let value):
			appendInterpolation(String(describing: value))
		case _:
			appendInterpolation("nil")
		}
	}
}

//extension Optional {
//	var d: String {
//		switch self {
//			case .some(let value):
//				return String(describing: value)
//			case _:
//				return "nil"
//		}
//	}
//}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension Double {

	func th_string(_ digit: Int = 3) -> String {
		return String(format: "%.\(digit)f", self)
	}

}

extension TimeInterval {
	var th_min: TimeInterval { return self * 60.0 }
	var th_hour: TimeInterval { return self * 60.0.th_min }
	var th_day: TimeInterval { return self * 24.0.th_hour }
}

extension Int {
	var th_Kio: Int { return self * 1024 }
	var th_Mio: Int { return self * 1024.th_Kio }
	var th_Gio: Int { return self * 1024.th_Mio }
}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension HTTPURLResponse {
	func th_displayStatus() -> String {
		Self.localizedString(forStatusCode: self.statusCode) + " (\(self.statusCode))"
	}
}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension URL {
	var th_reducedHost: String { get {
		guard let host = self.host
		else {
			return self.absoluteString
		}
		if host.hasPrefix("www.") == true {
			return String(host.dropFirst("www.".count))
		}
		return host
	}
	}
}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
#if os(macOS)
extension NSRect {
	init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
		self.init(x: x, y: y, width: width, height: height)
	}
}

extension NSSize {
	init(_ width: CGFloat, _ height: CGFloat) {
		self.init(width: width, height: height)
	}
}

extension NSPoint {
	init(_ x: CGFloat, _ y: CGFloat) {
		self.init(x: x, y: y)
	}
	
	func th_isEqual(to anotherPoint: NSPoint?, tolerance: CGFloat = 0.0) -> Bool {
		guard let anotherPoint = anotherPoint
		else {
			return false
		}

		if tolerance == 0.0 {
			return (self.x == anotherPoint.x && self.y == anotherPoint.y)
		}

		let dX = self.x - anotherPoint.x
		let dY = self.y - anotherPoint.y
		return ((dX <= tolerance && dX >= tolerance * -1.0) && (dY <= tolerance && dY >= tolerance * -1.0)) ? true : false
	}
}

extension NSRange {
	init(_ location: Int, _ length: Int) {
		self.init(location: location, length: length)
	}
}
#endif
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
#if os(iOS)
extension CGRect {
	init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
		self.init(x: x, y: y, width: width, height: height)
	}
}

extension CGSize {
	
	init(_ width: CGFloat, _ height: CGFloat) {
		self.init(width: width, height: height)
	}

	init(_ widthAndHeight: CGFloat) {
		self.init(width: widthAndHeight, height: widthAndHeight)
	}

}

extension CGPoint {
	init(_ x: CGFloat, _ y: CGFloat) {
		self.init(x: x, y: y)
	}
}

extension UIEdgeInsets {
	
	init(_ tlbr: CGFloat) {
		self.init(top: tlbr, left: tlbr, bottom: tlbr, right: tlbr)
	}

	init(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) {
		self.init(top: top, left: left, bottom: bottom, right: right)
	}
	
}
#endif
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension NSDate {

	@objc func th_dateAtMidnight() -> Self? {
		let cal = Calendar.current
		let dc = Calendar.current.dateComponents([.year, .month, .day], from: self as Date)
		return cal.date(from: dc) as? Self
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------


#if os(iOS)
//-----------------------------------------------------------------------------------------------------------------------------------------
extension UIViewController {

	func th_showAlert(_ title: String, _ message: String?) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: THLocalizedString("Ok"), style: .default, handler: {(alert: UIAlertAction!) in
			ac.dismiss(animated: true, completion: nil)
		}))
		self.present(ac, animated: true, completion: nil)
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------
#endif
