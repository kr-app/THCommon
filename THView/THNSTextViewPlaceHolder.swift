// THNSTextViewPlaceHolder.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THNSTextViewPlaceHolder: NSTextView {

	@objc var placeHolder: NSAttributedString?
	@objc var phInset: NSPoint = .zero
	
	@objc func th_setPlaceHolder(_ placeHolder: String?, withAttrs attrs: [NSAttributedString.Key: Any]) {

		if placeHolder != nil && self.placeHolder == nil {
			var mAttrs = attrs
			if mAttrs[NSAttributedString.Key.font] == nil {
				mAttrs[NSAttributedString.Key.font] = self.font != nil ? self.font : NSFont.th_systemFont(ofControlSize: .small)
			}
			if mAttrs[NSAttributedString.Key.foregroundColor] == nil {
				mAttrs[NSAttributedString.Key.foregroundColor] = NSColor(white: 0.5, alpha: 1.0)
			}
		
			self.placeHolder = NSAttributedString(string: placeHolder!, attributes: mAttrs)
			needsDisplay = true
		}
		else if placeHolder == nil && self.placeHolder != nil {
			self.placeHolder = nil
			needsDisplay = true
		}
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		if let ph = placeHolder, self.string.isEmpty {
			ph.draw(at: NSPoint(5.0 + phInset.x, phInset.y))
		}
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
