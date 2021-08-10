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

	@objc class func setIsLoginItem(_ isLoginItem: Bool) {
		if isLoginItem == true {
			THSharedLoginItems.addLoginItem(Bundle.main.bundleURL)
		}
		else {
			THSharedLoginItems.removeLoginItem(Bundle.main.bundleURL)
		}
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
