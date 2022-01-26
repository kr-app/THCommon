// THOSAppearance.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@available(*, deprecated)
@objc class THOSAppearance: NSObject {
	static let shared = THOSAppearance()

	private static var p_universalAccess: (status: Int?, path: String?, dateMod: TimeInterval?) = (nil, nil, nil)

	@objc class func hasReduceTransparency() -> Bool {

		THFatalError(THRunningApp.isSandboxedApp(), "isSandboxedApp")

		if p_universalAccess.path == nil {
			let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true);
			let path = (paths.first! as NSString).appendingPathComponent("Preferences/com.apple.universalaccess.plist")
			p_universalAccess.path = path
		}

		let path = p_universalAccess.path!

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
		
		if let status = p_universalAccess.status,
		   let date = p_universalAccess.dateMod {
			if dateTi == date {
				return status == 1 ? true : false
			}
		}

		p_universalAccess.dateMod = dateTi

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

		p_universalAccess.status = nStatus ?? -1

		return p_universalAccess.status == 1 ? true : false
	}
	
}
//--------------------------------------------------------------------------------------------------------------------------------------------

