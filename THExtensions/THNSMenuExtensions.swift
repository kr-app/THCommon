// THNSMenuExtensions.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
extension NSMenu {

	@objc convenience init(title: String?, delegate: NSMenuDelegate, autoenablesItems: Bool) {
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
		self.numberOfItems > 0 ? self.item(at: self.numberOfItems - 1) : nil
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension NSMenuItem {

	@objc convenience init(title: String, target: AnyObject? = nil, action: Selector? = nil, representedObject: Any? = nil, tag: Int = 0, enabled: Bool = true, submenu: NSMenu? = nil) {
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

		if let submenu = submenu {
			self.submenu = submenu
		}
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
class THMenuItem: NSMenuItem {
	var actionBlock: (() -> Void)!

	convenience init(title: String, representedObject: Any? = nil, tag: Int = 0, enabled: Bool = true, block: @escaping () -> Void) {
		self.init(title: title, target: nil, action: #selector(mi_action), representedObject: representedObject, tag: tag, enabled: enabled)
		self.target = self
		self.actionBlock = block
	}

	@objc func mi_action(_ sender: NSMenuItem) {
		actionBlock()
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
