// THOverView.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc enum THOverViewState: Int {
	case normal = 0
	case highlighted = 1
	case pressed = 2
	case disabled = 3
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@objc protocol THOverViewDelegateProtocol: AnyObject {
	@objc func overView(_ sender: THOverView, drawRect rect: NSRect, withState state: THOverViewState)
	@objc func overView(_ sender: THOverView, didPressed withInfo: [String: Any]?)
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THOverView : NSView {

	@objc var repInfo: Any?
	@objc var repImage: NSImage?
	@objc var repString: String?

	@objc var respondsWhenIsNotKeyWindow = false
	@objc @IBOutlet weak var delegator: THOverViewDelegateProtocol?

	override var isHidden: Bool { didSet { updateAfterHidden(self.isHidden) }}
	
	private var trackingArea: NSTrackingArea?

	private(set) var isEntered = false
	private(set) var isPressed = false
	private(set) var isDisabled = false
#if DEBUG
	private(set) var drawOrange = false
#endif

	private var downWinPoint: NSPoint = .zero
	private var downPoint: NSPoint = .zero
	private var mouseUpPoint: NSPoint = .zero

	// MARK: -

	override func awakeFromNib() {
		super.awakeFromNib()
		if trackingArea == nil {
			generate_trackingArea()
		}
	}
	
	deinit {
		delegator = nil
		if trackingArea != nil {
			removeTrackingArea(trackingArea!)
			trackingArea = nil
		}
	}

	// MARK: -

	override func updateTrackingAreas() {
		super.updateTrackingAreas()
		generate_trackingArea()
	}

	private func generate_trackingArea() {
		if let trackingArea = trackingArea {
			removeTrackingArea(trackingArea)
		}

		let options: NSTrackingArea.Options = [ .mouseEnteredAndExited,
																		//NSTrackingMouseMoved|
																		.activeInActiveApp,
																		.inVisibleRect]
	
		trackingArea = NSTrackingArea(	rect: NSRect(0.0, 0.0, self.frame.size.width, self.frame.size.height),
																options: options,
																owner: self,
																userInfo: nil)
		addTrackingArea(trackingArea!)
	}

	@objc func cleanAllStates() {
		isEntered = false
		isPressed = false
		isDisabled = false
		needsDisplay = true
	}

	private func updateAfterHidden(_ hidden: Bool) {
		if hidden == true && trackingArea != nil {
			removeTrackingArea(trackingArea!)
		}
		else if hidden == false {
			generate_trackingArea()
			needsDisplay = true
		}
	}

	@objc func setIsDisabled(_ disabled: Bool) {
		if disabled == isDisabled {
			return
		}

		isDisabled = disabled
		needsDisplay = true
	}

	// MARK: -

	override func mouseEntered(with event: NSEvent) {
		if isDisabled == true || isEntered == true {
			return
		}

#if DEBUG
		drawOrange = event.modifierFlags.contains(.command)
#endif

		isEntered = true
		needsDisplay = true
	}

	override func mouseExited(with event: NSEvent) {
		if isDisabled == true || isEntered == false {
			return
		}

#if DEBUG
		drawOrange = false
#endif

		isEntered = false
		needsDisplay = true
	}

	override func mouseDown(with event: NSEvent) {
		if isDisabled == true {
			return
		}

		downWinPoint = self.window!.frame.origin
		downPoint = convert(event.locationInWindow, from: nil)

		isEntered = true
		isPressed = true
		needsDisplay = true
	}

	override func mouseDragged(with event: NSEvent) {
		if isDisabled == true || isPressed == false {
			return
		}

		let pt = convert(event.locationInWindow, from: nil)
		if pt.th_isEqual(to: downPoint, tolerance: 3.0) == true {
			return
		}

		isEntered = false
		isPressed = false
		needsDisplay = true
	}

	//- (void)mouseMoved:(NSEvent*)event
	//{
	//	if (_isDisabled == true)
	//		return;
	//	if (isEntered == false)
	//	{
	//		isEntered=YES;
	//		[self setNeedsDisplay:YES];
	//	}
	//}

	override func mouseUp(with event: NSEvent) {
		if isDisabled == true || isEntered == false {
			return
		}

		isPressed = false

		let pt = convert(event.locationInWindow, from: nil)
		mouseUpPoint = pt

		if let delegator = delegator,
		   NSApp.isActive == true {

			if pt.th_isEqual(to: downPoint, tolerance: 3.0) == true && (downWinPoint == self.window!.frame.origin) {

				let isKeyWin = self.window!.isKeyWindow
				if (self.respondsWhenIsNotKeyWindow == false && isKeyWin == true) || self.respondsWhenIsNotKeyWindow == true {
					delegator.overView(self, didPressed: ["event": event])
				}
			}
		}

		downWinPoint = .zero
		downPoint = .zero

		needsDisplay = true
	}

	override func rightMouseDown(with event: NSEvent) {
		if NSApp.isActive == true && self.window!.isKeyWindow == true {
			delegator?.overView(self, didPressed: ["isRightClick": true, "event" : event])
		}

		downWinPoint = .zero
		downPoint = .zero

		needsDisplay = true
	}

	// MARK: -

	override func draw(_ dirtyRect: NSRect) {
		if self.isHidden == true {
			return
		}

		let frameSz = self.frame.size

#if DEBUG
		if drawOrange == true {
			NSColor.orange.set()
			NSBezierPath .fill(self.bounds)
		}
#endif

		var state = THOverViewState.normal
		if isDisabled == true { state = .disabled }
		else if isPressed == true { state = .pressed }
		else if isEntered == true { state = .highlighted }

		delegator?.overView(self, drawRect: NSRect(0.0, 0.0, frameSz.width, frameSz.height), withState: state)
	}
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension THOverView {

	@objc func popMenu(_ menu: NSMenu, isPull: Bool) {

		let ml = self.window!.mouseLocationOutsideOfEventStream

		let location = NSPoint(		(ml.x - mouseUpPoint.x).rounded(),
												(ml.y - mouseUpPoint.y - (isPull == true ? 8.0 : 0.0)).rounded())

		let event = NSEvent.mouseEvent(with: .leftMouseDown,
									   location: location,
									   modifierFlags: [],
									   timestamp: 0,
									   windowNumber: self.window!.windowNumber,
									   context: nil,
									   eventNumber: 0,
									   clickCount: 1,
									   pressure: 0.0)
	
		NSMenu.popUpContextMenu(menu, with: event!, for: self)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension THOverView {

	@objc func drawRepImage(opacity: CGFloat, rect: NSRect) {
		guard let img = self.repImage
		else {
			return
		}

		img.draw(at: NSPoint(((rect.size.width - img.size.width) / 2.0).rounded(.down), ((rect.size.height - img.size.height) / 2.0).rounded(.down)),
							from: NSRect(0.0, 0.0, img.size.width, img.size.height),
							operation: .sourceOver,
							fraction: opacity)
	}

	@objc func drawRepString(withAttrs attrs: [NSAttributedString.Key: Any], rect: NSRect, offSet: NSPoint = .zero) {
		guard let string = self.repString
		else {
			return
		}

		let sz = string.size(withAttributes: attrs)
		string.draw(at: NSPoint(((rect.size.width - sz.width) / 2.0).rounded(.down) + offSet.x, ((rect.size.height - sz.height) / 2.0).rounded(.down) + offSet.y), withAttributes: attrs)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
