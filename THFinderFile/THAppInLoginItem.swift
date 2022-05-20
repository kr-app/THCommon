// THAppInLoginItem.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THAppInLoginItem : NSObject {

	@objc class func loginItemStatus() -> NSControl.StateValue {
		if let status = THSharedLoginItems.status(forLoginItem: Bundle.main.bundleURL) {
			return status == "valid" ? .on : .mixed
		}
		return .off
	}

	@discardableResult @objc class func setIsLoginItem(_ isLoginItem: Bool) -> Bool {
		if isLoginItem == true {
			return THSharedLoginItems.addLoginItem(Bundle.main.bundleURL)
		}
		return THSharedLoginItems.removeLoginItem(Bundle.main.bundleURL)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
