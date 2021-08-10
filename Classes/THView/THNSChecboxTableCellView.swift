// THNSChecboxTableCellView.swift

import Cocoa

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
protocol THNSChecboxTableCellViewProtocol {
	func checboxTableCellView(_ cellView: THNSChecboxTableCellView, didCheck check: Bool, at row: Int)
}

class THNSChecboxTableCellView : NSTableCellView {
	@IBOutlet var checkedBox: NSButton!
	
	@IBAction func checkBoxAction(_ sender: NSButton) {
		let tbv = self.th_enclosedTableView()!
		let row = tbv.row(for: self)
		if row == -1 {
			return
		}
		(tbv.delegate as! THNSChecboxTableCellViewProtocol).checboxTableCellView(self, didCheck: sender.state == .on, at: row)
	}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
