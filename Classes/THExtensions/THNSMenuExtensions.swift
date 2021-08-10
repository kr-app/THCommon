// THNSMenuExtensions.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
extension NSMenu {

	@objc convenience init(withTitle title: String?, delegate: NSMenuDelegate, autoenablesItems: Bool) {
		if let title = title {
			self.init(title: title)
		}
		else {
			self.init()
		}
		
		self.delegate = delegate
		self.autoenablesItems = autoenablesItems
	}

	@objc func th_lastItem() -> NSMenuItem? {
		if self.numberOfItems > 0 {
			return self.item(at: self.numberOfItems - 1)
		}
		return nil
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension NSMenuItem {

	@objc convenience init(withTitle title: String, target: AnyObject? = nil, action: Selector? = nil, representedObject: Any? = nil, tag: Int = 0, enabled: Bool = true) {
		self.init(title: title, action: action, keyEquivalent: "")

		if let target = target {
			self.target = target
		}
		
		self.isEnabled = enabled
		
		if let representedObject = representedObject {
			self.representedObject = representedObject
		}
		
		if tag != 0 {
			self.tag = tag
		}
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
class THMenuItem: NSMenuItem {
	var actionBlock: (() -> Void)!

	convenience init(withTitle title: String, representedObject: Any? = nil, tag: Int = 0, enabled: Bool = true, block: @escaping () -> Void) {
		self.init(withTitle: title, target: nil, action: #selector(mi_action), representedObject: representedObject, tag: tag, enabled: enabled)
		self.target = self
		self.actionBlock = block
	}

	@objc func mi_action(_ sender: NSMenuItem) {
		actionBlock()
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
