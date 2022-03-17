// THCocoaExtensions.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
extension NSParagraphStyle {

	@objc class func th_paragraphStyle(withAlignment alignment: NSTextAlignment) -> NSParagraphStyle {
		let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		paragraphStyle.alignment = alignment
		return paragraphStyle
	}

	@objc class func th_paragraphStyle(withLineBreakMode lineBreakMode: NSLineBreakMode) -> NSParagraphStyle {
		let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		paragraphStyle.lineBreakMode = lineBreakMode
		return paragraphStyle
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension DateComponents {

	init(withYear year: Int, month: Int, day: Int) {
		self = Self.init()
		self.year = year
		self.month = month
		self.day = day
	}

	init(withHour hour: Int, min: Int, sec: Int) {
		self = Self.init()
		self.hour = hour
		self.minute = min
		self.second = sec
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension Calendar {

	func th_midnight(of date: Date) -> Date {
		self.date(from: self.dateComponents([.year, .month, .day], from: date))!
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------



//--------------------------------------------------------------------------------------------------------------------------------------------
extension URLSessionConfiguration {

	class func th_ephemeral() -> URLSessionConfiguration {
		
		let conf = URLSessionConfiguration.ephemeral
		conf.timeoutIntervalForRequest = 30.0
		conf.httpMaximumConnectionsPerHost = 1

		let cookieStorage = HTTPCookieStorage()
		cookieStorage.cookieAcceptPolicy = .never

		conf.httpShouldSetCookies = false
		conf.httpCookieStorage = cookieStorage

		return conf
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


#if os(macOS)
//--------------------------------------------------------------------------------------------------------------------------------------------
extension NSShadow {

	@objc convenience init(withOffSet offSet: NSSize, blurRadius: CGFloat, color: NSColor) {
		self.init()

		self.shadowOffset = offSet
		self.shadowBlurRadius = blurRadius
		self.shadowColor = color
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension NSControl {

	@objc func th_sizeToFitWidthOnly(alignment: NSTextAlignment) {
		if alignment == .left {
			let f = self.frame
			sizeToFit()
			self.frame = NSRect(f.origin.x ,f.origin.y, (self.frame.size.width).rounded(.up), f.size.height)
		}
		else if alignment == .right {
			let f = self.frame
			let oldEnd = f.origin.x + f.size.width

			sizeToFit()
			let nW = (self.frame.size.width).rounded(.up)
			self.frame = NSRect(oldEnd - nW, f.origin.y, nW, f.size.height)
		}
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension NSScrollView {

	@objc func th_scrollTo(visiblePoint point: NSPoint) {
		let pt = NSPoint(point.x, point.y - self.frame.size.height)
		let br = NSRect(0.0, pt.y, self.contentView.frame.size.width, self.contentView.frame.size.height)

		self.contentView.scroll(self.contentView.constrainBoundsRect(br).origin)
		reflectScrolledClipView(self.contentView)
	}
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension NSTableView {

	@objc func th_reloadData(forRowIndexes indexSet: IndexSet, columnIndexes: IndexSet? = nil) {
		let tcIdx = columnIndexes ?? NSIndexSet(indexesIn: NSRange(location: 0, length: self.tableColumns.count)) as IndexSet
		self.reloadData(forRowIndexes: indexSet, columnIndexes: tcIdx)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------

	
//--------------------------------------------------------------------------------------------------------------------------------------------
@objc extension NSView {

	@objc func th_removeAllSubviews() {
		self.subviews.forEach({ $0.removeFromSuperview() })
	}

	@objc func th_isFirstResponder() -> Bool {
		if let resp = self.window?.firstResponder {
			if resp == self {
				return true
			}
			if let rv = resp as? NSView {
				return rv.isDescendant(of: self)
			}
		}
		return false
	}
	
	@objc func th_enclosedTableView() -> NSTableView? {
		var supView = self.superview
		while supView != nil && (supView is NSTableView) == false {
			supView = supView!.superview
		}
		return supView as? NSTableView
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension NSFont {

	class func th_boldSystemFont(ofControlSize controlSize: NSControl.ControlSize) -> NSFont {
		NSFont.boldSystemFont(ofSize: NSFont.systemFontSize(for: controlSize))
	}

	class func th_systemFont(ofControlSize controlSize: NSControl.ControlSize) -> NSFont {
		NSFont.systemFont(ofSize: NSFont.systemFontSize(for: controlSize))
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@objc extension NSVisualEffectView {

	@objc class func th_maskImage(cornerRadius: CGFloat) -> NSImage {

		let edgeLength = 2.0 * cornerRadius + 1.0
		let img = NSImage(size: NSSize(width: edgeLength, height: edgeLength), flipped: false) { rect in
			let bezierPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
			NSColor.black.set()
			bezierPath.fill()
			return true
		}

		img.capInsets = NSEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
		img.resizingMode = .stretch

		return img
	}
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension NSTextField {

	@objc class func th_size(for controlSize: ControlSize) -> NSSize {
		return controlSize == .regular ? NSSize(16.0, 0.0) : controlSize == .small ? NSSize(14.0, 0.0) : .zero
	}

	@objc class func th_label(withFrame frame: NSRect, controlSize: ControlSize = .regular) -> Self {
		let label = Self(frame: frame)
		label.isBezeled = false
		label.drawsBackground = false
		label.isEditable = false

#if DEBUG
		if controlSize == .regular && frame.size.height != 16.0 {
			THLogDebug("incorrect frame.height, should be 16.0")
		}
		else if controlSize == .small && frame.size.height != 15.0 {
			THLogDebug("incorrect frame.height, should be 15.0")
		}
#endif
		
		if controlSize != .regular {
			(label.cell as! NSTextFieldCell).controlSize  = controlSize
			label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: controlSize))
		}
	
		return label
	}
	
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension NSPopUpButton {
	
	func selectItem(withRepresentedObject representedObject: String?) {
		for mi in self.itemArray {
			if mi.isSeparatorItem == true {
				continue
			}

			let ro = mi.representedObject as? String
			if (ro == nil && representedObject == nil) || (ro == representedObject) {
				select(mi)
				return
			}
		}
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension NSAlert {

	@objc convenience init(withTitle title: String, message: String?) {
		self.init(withTitle: title, message: message, buttons: ["Ok"])
	}

	@objc convenience init(withTitle title: String, message: String?, buttons: [String]) {
		self.init()

		let buttons = buttons.count > 0 ? buttons : ["Ok"]

		self.messageText = title
		self.informativeText =  message ?? ""

		for button in buttons {
			self.addButton(withTitle: button)
		}
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------

#endif
