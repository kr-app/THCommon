// PPPanePreviewWindow.swift

import Cocoa

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@objc class PPPanePreviewBgView : NSView {

	private var trackingArea: NSTrackingArea?
	private var isEntered = false

	// MARK: -

	override func awakeFromNib() {
		super.awakeFromNib()

		if trackingArea == nil {
			generate_trackingArea()
		}
	}
	
	deinit {
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

		trackingArea = NSTrackingArea(		rect: NSRect(0.0, 0.0, self.frame.size.width, self.frame.size.height),
																options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
																owner: self,
																userInfo: nil)
		addTrackingArea(trackingArea!)
	}

	// MARK: -

	override func draw(_ dirtyRect: NSRect) {
		NSColor.white.set()
		NSBezierPath(roundedRect: self.bounds, xRadius: 5.0, yRadius: 5.0).fill()
	}
	
	// MARK: -
	
	override func mouseEntered(with event: NSEvent) {
		if isEntered == true {
			return
		}
		isEntered = true

		if NSApplication.shared.isActive == false {
			NSApplication.shared.activate(ignoringOtherApps: true)
		}
	}

	override func mouseExited(with event: NSEvent) {
		if isEntered == false {
			return
		}
		isEntered = false
		
	}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@objc class PPPanePreviewWindow : NSWindow {

	override var canBecomeKey: Bool { get { return true } }

	@objc var pointAnchor: NSPoint = .zero
	
	@objc convenience init(contentRect: NSRect, screen: NSScreen) {
		self.init(contentRect: contentRect,
				   styleMask: [.borderless, .resizable],
				   backing: .buffered,
				   defer: true,
				   screen: screen)

		self.level = .floating
		self.isReleasedWhenClosed = false
		self.hasShadow = true
		self.backgroundColor = .clear
		self.isOpaque = false
	}

	deinit {
		THLogDebug("")
	}
	
	override func setFrame(_ frameRect: NSRect, display flag: Bool) {
		if self.inLiveResize == false {
			super.setFrame(frameRect, display: flag)
			return
		}

		let cFrame = self.frame
		var nRect = frameRect

		// width min/max
		if frameRect.size.width < minSize.width {
			nRect.size.width = minSize.width
		}
		else if frameRect.size.width > maxSize.width {
			nRect.size.width = maxSize.width
		}
		
		// height min/max
		if frameRect.size.height < minSize.height {
			nRect.size.height = minSize.height
		}
		else if frameRect.size.height > maxSize.height {
			nRect.size.height = maxSize.height
		}

		//
		if (nRect.origin.x + nRect.size.width) != (cFrame.origin.x+cFrame.size.width) {
			nRect.size.width = cFrame.size.width
			nRect.origin.x = cFrame.origin.x
		}

		if cFrame.origin.y != nRect.origin.y {
			if nRect.origin.y + 20.0 > self.pointAnchor.y {
				nRect.origin.y = self.pointAnchor.y - 20.0
			}
		}

		//
		if (nRect.origin.y + nRect.size.height) != (cFrame.origin.y + cFrame.size.height) {
			if (nRect.origin.y+frameRect.size.height) < (self.pointAnchor.y + 20.0) {
				nRect.size.height=cFrame.size.height;// self.pointAnchor.y+20.0-cFrame.origin.y;
			}
		}

		super.setFrame(nRect, display: flag)
	}

//	- (void)setFrame:(NSRect)frameRect display:(BOOL)flag animate:(BOOL)animateFlag
//	{
//		[super setFrame:frameRect display:flag animate:animateFlag];
//	}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
