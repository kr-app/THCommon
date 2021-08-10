//THBgColorView.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THBgColorView: NSView {
	@objc var bgColor: NSColor? { didSet { needsDisplay = true }}

	private var lineFlags: Int = 0
	private var position: CGFloat = 0.0

	@objc class func horizontalLine(withColor color: NSColor, topPosition: CGFloat) -> THBgColorView {

		let r = THBgColorView(frame: NSRect(0.0, 0.0, 100.0, 1.0), bgColor: color)
		r.autoresizingMask = [ .width, .minYMargin ]
		r.lineFlags = 1 | 2
		r.position = topPosition

		return r
	}

	@objc class func horizontalLine(withColor color: NSColor, bottomPosition: CGFloat) -> THBgColorView {

		let r = THBgColorView(frame: NSRect(0.0, 0.0, 100.0, 1.0), bgColor: color)
		r.autoresizingMask = [ .width, .minYMargin ]
		r.lineFlags = 1 | 4
		r.position = bottomPosition

		return r
	}

	@objc override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
	}

	@objc init(frame frameRect: NSRect, bgColor: NSColor) {
		super.init(frame: frameRect)
		self.bgColor = bgColor
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func viewDidMoveToSuperview() {
		super.viewDidMoveToSuperview()
		if (lineFlags & 1) != 0 {
			let sSz = superview!.frame.size
			frame = NSRect(	0.0,
							   			(lineFlags & 2) != 0 ? sSz.height - position : position,
										sSz.width,
										frame.size.height)
		}
	}

	override func draw(_ dirtyRect: NSRect) {
		if let bgColor = bgColor {
			bgColor.set()
			NSBezierPath.fill(self.bounds)
		}
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
