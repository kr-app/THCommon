// PWPaneWindow.swift

import Cocoa

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@objc protocol PWPaneWindowEventDelegateProtocol {
	func paneWindow(_ sender: PWPaneWindow, sendEvent event: NSEvent, firstResponder: Any?) -> Bool
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@objc class PWPaneWindow : NSWindow {

	@objc static let winRightMargin: CGFloat = 20.0
	@objc static let winMinWidthSize: CGFloat = 300.0

	@objc var sensSrientation: NSTextAlignment = .right
	@objc var ignoresUserFrameResizing = false
	@objc var hasUserCustomFrameSize = false

	override var canBecomeKey: Bool { get { return true } }

	override func sendEvent(_ event: NSEvent) {

		if event.window == self {
			if self.ignoresUserFrameResizing == true && (event.type == .leftMouseDown || event.type == .rightMouseDown) {
				self.ignoresUserFrameResizing = false
			}

			if self.isKeyWindow == true && event.type == .keyDown && event.isARepeat == false {
				if let delegate = self.delegate as? PWPaneWindowEventDelegateProtocol {
					if delegate.paneWindow(self, sendEvent: event, firstResponder: self.firstResponder) == true {
						return
					}
				}
			}
		}

		super.sendEvent(event)
	}

	//- (void)mouseDown:(NSEvent*)theEvent
	//{
	//	if (self.ignoresUserFrameResizing==YES)
	//		self.ignoresUserFrameResizing=NO;
	//	[super mouseDown:theEvent];
	//}
	
	override func setFrame(_ frameRect: NSRect, display flag: Bool) {

		var frameRect = frameRect

		if inLiveResize == true && self.ignoresUserFrameResizing == false {
			let cFrame = self.frame
			let vScreen = self.screen!.visibleFrame

			if frameRect.origin.y != cFrame.origin.y {
				frameRect.origin.y = cFrame.origin.y.rounded(.down)
			}

			if frameRect.size.height != cFrame.size.height {
				frameRect.size.height = cFrame.size.height.rounded(.down)
			}

			if frameRect.size.width < Self.winMinWidthSize {
				frameRect.origin.x = cFrame.origin.x
				frameRect.size.width = Self.winMinWidthSize
			}
			else if frameRect.size.width > (vScreen.size.width / 2.0) {
				frameRect.origin.x = cFrame.origin.x;
				frameRect.size.width = (vScreen.size.width / 2.0).rounded(.down)
			}
			else if (frameRect.origin.x + frameRect.size.width) > (vScreen.size.width - Self.winRightMargin) {
				frameRect.size.width = (vScreen.size.width - frameRect.origin.x - Self.winRightMargin).rounded(.down)
			}
//		if ((frameRect.origin.x-WinRightMargin)<vScreen.origin.x)
//		{
//			frameRect.origin.x=-WinRightMargin;
//		}
			
			if self.sensSrientation == .left {
				if frameRect.origin.x == cFrame.origin.x {
//				CGFloat offSet=CGFloatFloor(cFrame.size.width-frameRect.size.width);
//				frameRect.origin.x+=offSet;
//				frameRect.size.width=cFrame.size.width;
				}
			}
			//else

			self.hasUserCustomFrameSize = true
		}

		super.setFrame(frameRect, display: flag)
	}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
