// THOSAppearance.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate class Caches {
	static var isDarkMode: Int = 0
	static var universalAccess: (status: Int?, path: String?, dateMod: TimeInterval?) = (nil, nil, nil)
}

@objc class THOSAppearance: NSObject {
	static let shared = THOSAppearance()

	@objc class func updateDarkMode()  {
		if #available(macOS 10.14, *) {
			Caches.isDarkMode = NSApplication.shared.effectiveAppearance.name == .darkAqua ? 1 : -1
		} else {
			Caches.isDarkMode = -1
		}
	}

	@objc class func isDarkMode() -> Bool {
		if Caches.isDarkMode == 0 {
			updateDarkMode()
		}
		return Caches.isDarkMode == 1
	}

	@objc class func hasReduceTransparency() -> Bool {

		THFatalError(THRunningApp.isSandboxedApp(), "isSandboxedApp")

		if Caches.universalAccess.path == nil {
			let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true);
			let path = (paths.first! as NSString).appendingPathComponent("Preferences/com.apple.universalaccess.plist")
			Caches.universalAccess.path = path
		}

		let path = Caches.universalAccess.path!

		if FileManager.default.fileExists(atPath: path) == false {
			THLogError("file does not exist path:\(path)")
			return false
		}

		guard let date = FileManager.th_modDate1970(atPath: path)
		else {
			THLogError("date == nil path:\(path)")
			return false
		}

		let dateTi = date.timeIntervalSinceReferenceDate
		
		if let status = Caches.universalAccess.status,
		   let date = Caches.universalAccess.dateMod {
			if dateTi == date {
				return status == 1 ? true : false
			}
		}

		Caches.universalAccess.dateMod = dateTi

		let plist = NSDictionary(contentsOfFile: path)
		if plist == nil {
			THLogError("can not init dictionary at path:\(path)")
		}
		
		var nStatus: Int?

		if let reduceTransparency = plist?["reduceTransparency"] {
			if let nb = reduceTransparency as? NSNumber {
				nStatus = nb.boolValue == true ? 1 : -1
			}
			else if let s = reduceTransparency as? String {
				if let sv = Int(s) {
					nStatus = sv > 0 ? 1 : -1
				}
			}
		}

		if nStatus == nil {
			THLogError("not status from plist:\(plist)")
		}

		Caches.universalAccess.status = nStatus ?? -1

		return Caches.universalAccess.status == 1 ? true : false
	}
	
}
//--------------------------------------------------------------------------------------------------------------------------------------------
