// THNSButtonBlock.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
class THNSButtonBlock: NSButton {
	var actionBlock: (() -> Void)? { didSet { 	self.target = self
																	self.action = #selector(button_action)
													}}

	@objc private func button_action(_ sender: NSButton) {
		actionBlock?()
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
