// THRunningAppExtensions.swift

import Cocoa

//-----------------------------------------------------------------------------------------------------------------------------------------
extension NSRunningApplication {

	func isAgentOrBackgroundApplication() -> Bool {
		guard let bundleUrl = self.bundleURL
		else {
			return true
		}

		if self.bundleIdentifier == nil {
			return true
		}

		if bundleUrl.path.hasPrefix("/System/Library") == true || bundleUrl.path.hasPrefix("/Library/Developer/PrivateFrameworks/") == true {
			return true
		}

		guard let bundle = Bundle(url: bundleUrl), let infoplist = bundle.infoDictionary
		else {
			return true
		}

		if let uiElement = infoplist["LSUIElement"] {
			if (uiElement as? Bool) == true ||  (uiElement as? String) == "1" {
				return true
			}
		}

		if let isBackgroundOnly = infoplist["LSBackgroundOnly"] {
			if (isBackgroundOnly as? Bool) == true || (isBackgroundOnly as? String) == "1" {
				return true
			}
		}

		return false
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
