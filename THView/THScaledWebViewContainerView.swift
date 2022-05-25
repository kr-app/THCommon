// THScaledWebViewContainerView.swift

import Cocoa
import WebKit

//--------------------------------------------------------------------------------------------------------------------------------------------
class THScaledWebViewContainerView: NSView {

	private var zoomScale: CGFloat

	init(frame frameRect: NSRect, scale: CGFloat) {
		zoomScale = scale
		super.init(frame: frameRect)
		self.scaleUnitSquare(to: NSSize(scale, scale))
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func setFrameSize(_ newSize: NSSize) {
		super.setFrameSize(newSize)

		if let webView = self.subviews.first(where: { $0 is WKWebView }) {
			webView.frame.size = NSSize(newSize.width / zoomScale, newSize.height / zoomScale)
		}
	}

	override func addSubview(_ view: NSView) {
		if let webView = view as? WKWebView {
			webView.frame.size = NSSize(view.frame.width / zoomScale, view.frame.height / zoomScale)
		}
		super.addSubview(view)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
