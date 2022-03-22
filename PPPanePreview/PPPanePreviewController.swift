//  PPPanePreviewController.swift

import Cocoa

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class PPPanePreviewController : NSViewController, NSWindowDelegate {
	var isVisiblePane: Bool { myWindow?.isVisible == true }
	private var myWindow: PPPanePreviewWindow?

	func showWindow(at point: NSPoint, on screen: NSScreen?) {
		guard let screen = screen, point.th_isZero() == false
		else {
			THLogError("point == .zero || screen == nil")
			return
		}

		let visibleRect = screen.visibleFrame

		let wMinSize = NSSize(300.0, 300.0)
		let wMaxSize = NSSize(2000.0, 2000.0)

		var frameSize = NSSize((point.x / 2.0).rounded(.down), (visibleRect.size.height * 0.8).rounded(.down))
		if let myWindow = myWindow {
			frameSize = myWindow.frame.size
		}
		else if let frameSizeStr = UserDefaults.standard.string(forKey: "PanePreviewViewController-FrameSize") {
			frameSize = NSSizeFromString(frameSizeStr)
		}

		frameSize.width = max(frameSize.width, wMinSize.width)
		frameSize.height = max(frameSize.height, wMinSize.height)

		if frameSize.width > point.x - (visibleRect.origin.x + 20.0) {
			frameSize.width=point.x - (visibleRect.origin.x + 20.0)
		}
		if frameSize.height > (visibleRect.size.height - 20.0 * 2.0) {
			frameSize.height = visibleRect.size.height - 20.0 * 2.0
		}

		let spacePanel: CGFloat = 8.0
		var wFrame = NSRect(	point.x - frameSize.width - spacePanel, point.y - (frameSize.height / 2.0).rounded(.down),
												frameSize.width, frameSize.height)
		var trianglePosition = (wFrame.size.height / 2.0).rounded(.down)

		if wFrame.origin.x < (visibleRect.origin.x + 20.0) {
			let delta = visibleRect.origin.x - wFrame.origin.x + 20.0
			wFrame.origin.x = visibleRect.origin.x + 20.0
			wFrame.size.width -= delta.rounded(.down)
		}

		if wFrame.origin.y < (visibleRect.origin.y + 20.0) {
			let delta = (visibleRect.origin.y + 20.0) - wFrame.origin.y
			trianglePosition -= delta
			wFrame.origin.y += delta
		}
		else if (wFrame.origin.y + wFrame.size.height + 20.0) > (visibleRect.origin.y + visibleRect.size.height) {
			let delta = (wFrame.origin.y + wFrame.size.height + 20.0) - (visibleRect.origin.y + visibleRect.size.height)
			trianglePosition += delta
			wFrame.origin.y -= delta
		}
	
		if let myWindow = myWindow {
			myWindow.setFrame(wFrame, display: true, animate: false)
		}
		else {
			let myWindow = PPPanePreviewWindow(contentRect: wFrame, screen: screen)
			myWindow.minSize = wMinSize
			myWindow.maxSize = wMaxSize
			myWindow.delegate = self
			myWindow.contentView = self.view
			//_myWindow.alphaValue = 0.0
			self.myWindow = myWindow
		}

		guard let myWindow = myWindow
		else {
			return
		}

		myWindow.alphaValue = 1.0
		myWindow.pointAnchor = point

		panePreviewControllerWillShow()
		myWindow.makeKeyAndOrderFront(nil)
	}

	func hideWindow(animated: Bool) {
		guard let myWindow = self.myWindow, myWindow.isVisible == true
		else {
			return
		}

		panePreviewControllerWillHide()
		UserDefaults.standard.set(NSStringFromSize(myWindow.frame.size), forKey: "PanePreviewViewController-FrameSize")

		myWindow.delegate = nil

		NSAnimationContext.runAnimationGroup({ (context) in
			context.duration = 0.15
			myWindow.animator().alphaValue = 0.0
		}, completionHandler: {() in
			myWindow.orderOut(nil)
			self.panePreviewControllerDidHide()
		})
	}

	// MARK: -

	func panePreviewControllerWillShow() {
	}

	func panePreviewControllerWillHide() {
	}

	func panePreviewControllerDidHide() {
	}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
