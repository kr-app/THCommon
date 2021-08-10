//  THLocalizedString.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

#if os(macOS)
//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THLocalizeFunctions: NSObject {

	@objc class func localizeHeader(ofTableView tableView: NSTableView) {
		for tableColumn in tableView.tableColumns {
			let cell = tableColumn.headerCell
			let string = cell.stringValue
			if string.isEmpty {
				continue
			}
			cell.stringValue = THLocalizedString(string)
		}
	}

}

@objc class THNSTextFieldLocalized: NSTextField {

	private var localized = false

	override func awakeFromNib() {
		super.awakeFromNib()

		if localized == false {
			localized = true
			self.stringValue = THLocalizedString(self.stringValue)
		}
	}

}

@objc class  THNSButtonLocalized: NSButton {
	private var localized = false

	override func awakeFromNib() {
		super.awakeFromNib()

		if localized == false {
			localized = true
			self.title = THLocalizedString(self.title)
		}
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
#endif
