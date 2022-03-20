// THHighlightedTableView.swift

import Cocoa

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@objc class THHighlightedTableRowView : NSTableRowView {

	//@property (nonatomic,strong) NSColor *highlightedBackgroundColor;
	//@property (nonatomic,strong) NSColor *selectionBackgroundColor;

	@objc var isHighlightedRow = false { didSet {
		
		needsDisplay = true

		for view in self.subviews {
			if let cell = view as? THHighlightedTableCellView {
				cell.isHighlightedRow = isHighlightedRow
			}
		}

	}}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@objc class THHighlightedTableCellView : NSTableCellView {

	@objc var isHighlightedRow = false { didSet {
		updateHighlighted()
		}
	}

	func updateHighlighted() {
	}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@objc class THHighlightedTableViewScrollView: NSScrollView {

	private var mEnclosedTableView: THHighlightedTableView?
	
	override func scrollWheel(with event: NSEvent) {
		super.scrollWheel(with: event)
		//	[self updateHighLightedCellAfterScroll];
	}

	override func reflectScrolledClipView(_ cView: NSClipView) {
		super.reflectScrolledClipView(cView)
		updateHighLightedCellAfterScroll()
	}

	@objc func updateHighLightedCellAfterScroll() {
		if mEnclosedTableView == nil {
			mEnclosedTableView = self.documentView as? THHighlightedTableView
			THFatalError(mEnclosedTableView == nil, "mEnclosedTableView == nil")
		}
		mEnclosedTableView?.updateHighLightedCellAfterScroll()

		//	[(id<THHighlightedTableViewScrollViewDelegateProtocol>)self.delegatePageController highlightedTableViewScrollViewDidScroll:self];
	}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@objc protocol THHighlightedTableViewDelegateProtocol: NSTableViewDelegate {
	func highlightedTableView(_ tableView: THHighlightedTableView, didHighlightRow highlightedRow: Int, previousHighlightedRow: Int)
}

@objc class THHighlightedTableView: NSTableView {
	private var mHighlightedTrackingArea: NSTrackingArea?
	private var mFirstHighlightedPoint: NSPoint?
	private var mHighlightedRow = -1
	private var mHighlightedRowIsChanging = false

	private var highlightedDelegate: THHighlightedTableViewDelegateProtocol? { self.delegate as? THHighlightedTableViewDelegateProtocol }

	override func awakeFromNib() {
		super.awakeFromNib()

		THFatalError((self.enclosingScrollView is THHighlightedTableViewScrollView) == false, "unexpected kind of enclosingScrollView")
	}

	deinit {
		if let highlightedTrackingArea = mHighlightedTrackingArea {
			removeTrackingArea(highlightedTrackingArea)
		}
	}

	// MARK: -

	override func reloadData() {
		mHighlightedRow = -1
		super.reloadData()
	}

	// MARK: -

	@objc func startHighlightedTracking() {
		if mHighlightedTrackingArea != nil {
			return
		}

		mHighlightedRow = -1
		refreshHighlightedTracking()
	}

	@objc func stopHighlightedTracking() {
		mHighlightedRow = -1

		if let highlightedTrackingArea = mHighlightedTrackingArea {
			removeTrackingArea(highlightedTrackingArea)
		}
	}

	@objc func refreshHighlightedTracking() {
		if let highlightedTrackingArea = mHighlightedTrackingArea {
			removeTrackingArea(highlightedTrackingArea)
		}

		mHighlightedTrackingArea = NSTrackingArea(	rect: NSRect(0.0, 0.0, self.frame.size.width, self.frame.size.height),
																					options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways, .inVisibleRect],
																					owner: self,
																					userInfo: nil)

		addTrackingArea(mHighlightedTrackingArea!)
	}

	override func updateTrackingAreas() {
		super.updateTrackingAreas()
		refreshHighlightedTracking()
	}

	// MARK: -

	@objc func updateHighLightedCell(withPoint point: NSPoint) {
		if mFirstHighlightedPoint == nil && mHighlightedRow == 0 {
			mHighlightedRow = -1
		}

		if mHighlightedRow >= self.numberOfRows {
			mHighlightedRow = -1
		}

		mFirstHighlightedPoint = point
		
		let row = self.row(at: point)
		if row == mHighlightedRow {
			return
		}

		mHighlightedRowIsChanging = true

	//	if (self.selectedRow!=-1)
	//		[self deselectRow:self.selectedRow];

		self.highlightedDelegate?.highlightedTableView(self, didHighlightRow: row, previousHighlightedRow: mHighlightedRow)
		mHighlightedRow = row
	
		mHighlightedRowIsChanging = false
	}

	// MARK: -

	@objc func canHightlight() -> Bool {
		if self.window?.isKeyWindow == true || NSApplication.shared.isActive == false {
			return true
		}
		if NSApplication.shared.keyWindow == self.window {
			return true
		}
		return false
	}

	override func mouseEntered(with event: NSEvent) {
		if NSApplication.shared.isActive == false {
			NSApplication.shared.activate(ignoringOtherApps: true)
		}

		self.window?.makeFirstResponder(nil)

		if self.canHightlight() == false {
			return
		}
		
		updateHighLightedCell(withPoint: self.convert(event.locationInWindow, from: nil))
	}
	
	override func mouseExited(with event: NSEvent) {
		if self.canHightlight() == false {
			return
		}

		self.highlightedDelegate?.highlightedTableView(self, didHighlightRow: -1, previousHighlightedRow: mHighlightedRow)
		mHighlightedRow = -1
	}

	override func mouseMoved(with event: NSEvent) {
		if self.canHightlight() == false {
			return
		}

		updateHighLightedCell(withPoint: self.convert(event.locationInWindow, from: nil))
	}

	// MARK: -

	@objc func updateHighLightedRowFromSelectionDidChange() {
		if mHighlightedRowIsChanging == true {
			return
		}

		let pRow = mHighlightedRow
		mHighlightedRow = self.selectedRow

		self.highlightedDelegate?.highlightedTableView(self, didHighlightRow: mHighlightedRow, previousHighlightedRow: pRow)
	}

	@objc func updateHighLightedCellAfterScroll() {
		guard let location = self.window?.mouseLocationOutsideOfEventStream
		else {
			return
		}
		updateHighLightedCell(withPoint: self.convert(location, from: nil))
	}

	@objc func updateHighLightedCellAfterDeletion() {
		mHighlightedRow = -1
		updateHighLightedCellAfterScroll()
	}

	@objc func unhighlightRow() {
		let pRow = mHighlightedRow
		mHighlightedRow = -1
		
		self.highlightedDelegate?.highlightedTableView(self, didHighlightRow: mHighlightedRow, previousHighlightedRow: pRow)
	}

	// MARK: -

	@objc func convertWindowPoint(forRow row: Int) -> NSPoint {
		let rowRect = self.rect(ofRow: row)

		var pt = NSPoint(rowRect.origin.x, rowRect.origin.y + (rowRect.size.height / 2.0).rounded(.down))
		pt = convertToBacking(pt)
		//NSPoint p=[self.view.window.contentView convertPoint:rowPoint toView:self.tableView];
		pt = self.window!.convertToScreen(NSMakeRect(pt.x,pt.y,0.0,0.0)).origin

		return pt
	}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
