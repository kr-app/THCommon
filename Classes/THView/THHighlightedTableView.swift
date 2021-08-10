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
