// THOverLabel.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THOverLabel: THOverView {

	@objc var stringValue: String?
	@objc var font: NSFont = NSFont.th_systemFont(ofControlSize: .regular)
	@objc var textColor: NSColor = .black
	@objc var textAlignment: NSTextAlignment = .left

	@objc var textNormal: NSAttributedString? { didSet { needsDisplay = true } }
	@objc var textDisabled: NSAttributedString?
	@objc var textOver: NSAttributedString?
	@objc var textPressed: NSAttributedString?

	private func textFromState() -> NSAttributedString? {

		if isPressed {
			return self.textPressed ?? self.textNormal
		}
		if isEntered {
			return self.textOver ?? self.textNormal
		}
		//(self.isEnabled==NO && self.textDisabled!=nil)?self.textDisabled:self.textNormal;
	
		return self.textNormal
	}
	
	override func draw(_ dirtyRect: NSRect) {
		if self.isHidden == true {
			return
		}

//		let frameSz = self.frame.size

#if DEBUG
		if drawOrange == true {
			NSColor.orange.set()
			NSBezierPath .fill(self.bounds)
		}
#endif

		guard let text = textFromState()
		else {
			return
		}

		text.draw(in: self.bounds)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension THOverLabel {

	@objc func setTextNormal(_ text: String?, font: NSFont?, color: NSColor?) {
		let attrs: [NSAttributedString.Key: Any] = [	.font: font ?? self.font,
																			.foregroundColor: color ?? NSColor.black,
																			.paragraphStyle: NSParagraphStyle.th_paragraphStyle(withAlignment: self.textAlignment)]
		self.textNormal = NSAttributedString(string: text ?? stringValue ?? "", attributes: attrs)
	}

	@objc func setTextDisabled(_ text: String?, font: NSFont?, color: NSColor?) {
		let attrs: [NSAttributedString.Key: Any] = [	.font: font ?? self.font,
																			.foregroundColor: color ?? NSColor.disabledControlTextColor,
																			.paragraphStyle: NSParagraphStyle.th_paragraphStyle(withAlignment: self.textAlignment)]
		self.textDisabled = NSAttributedString(string: text ?? stringValue ?? "", attributes: attrs)
	}

	@objc func setTextOver(_ text: String?, font: NSFont?, color: NSColor?, underlineStyle: Int) {
		var attrs: [NSAttributedString.Key: Any] = [	.font: font ?? self.font,
																			.foregroundColor: color ?? self.textColor,
																			.paragraphStyle: NSParagraphStyle.th_paragraphStyle(withAlignment: self.textAlignment)]
		if underlineStyle > 0 {
			attrs[.underlineStyle] = NSNumber(integerLiteral: underlineStyle)
		}

		self.textOver = NSAttributedString(string: text ?? stringValue ?? "", attributes: attrs)
	}

	@objc func setTextPressed(_ text: String?, font: NSFont?, color: NSColor?, underlineStyle: Int) {
		var attrs: [NSAttributedString.Key: Any] = [	.font: font ?? self.font,
																			.foregroundColor: color ?? self.textColor,
																			.paragraphStyle: NSParagraphStyle.th_paragraphStyle(withAlignment: self.textAlignment)]
		if underlineStyle > 0 {
			attrs[.underlineStyle] = NSNumber(integerLiteral: underlineStyle)
		}

		self.textPressed = NSAttributedString(string: text ?? stringValue ?? "", attributes: attrs)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------



//--------------------------------------------------------------------------------------------------------------------------------------------
extension THOverLabel {

	func contentTextSize() -> NSSize {
		if let text = self.textNormal {
			return text.size()
		}
		return .zero
	}

	@objc func sizeToFitWidthOnly(alignment: NSTextAlignment) {
		let textSz = contentTextSize()

		if alignment == .left {
			self.frame.size.width = textSz.width.rounded(.up)//, f.size.height)
		}
		else if alignment == .right {
			let f = self.frame
			let oldEnd = f.origin.x + f.size.width

			let nW = textSz.width.rounded(.up)
			self.frame = NSRect(oldEnd - nW, f.origin.y, nW, f.size.height)
		}
		else if alignment == .center {
			let f = self.frame
			let nW = textSz.width.rounded(.up)
			let offset = nW - f.size.width

			self.frame = NSRect(f.origin.x - (offset / 2.0).rounded(.down), f.origin.y, nW, f.size.height)
		}
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
