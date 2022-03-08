// THCookiesCleaner.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
@objc class THCookiesCleaner: NSObject {

	@objc class func cleanWebData() {

		let libDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!

		let libContents = try! FileManager.default.contentsOfDirectory(atPath: libDir)
		THLogDebug("libContents:\(libContents)")

		let cachesDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
		
		let cachesContents = try! FileManager.default.contentsOfDirectory(atPath: cachesDir)
		THLogDebug("cachesContents:\(cachesContents)")
		
		var dirsToDelete  = [	"Caches/com.apple.WebKit.Networking",
											"Caches/com.apple.WebKit.WebContent",
										]

		let last = UserDefaults.standard.object(forKey: "THCookiesCleaner-last-wk-clean-dirs") as? Date
		let now = Date()

		if last == nil || (now.timeIntervalSince(last!) < (-24 * 3600)) {
			UserDefaults.standard.set(now, forKey: "THCookiesCleaner-last-wk-clean-dirs")
			dirsToDelete += ["Cookies", "WebKit"]
		}
		
		THLogDebug("expected dirsToDelete:\(dirsToDelete)")

		for dir in dirsToDelete {
			let p = (libDir as NSString).appendingPathComponent(dir)
			if FileManager.default.fileExists(atPath: p) == true {
				if FileManager.default.th_removeItem(atPath: p) == false {
				THLogInfo("removed dir:\((p as NSString).abbreviatingWithTildeInPath)")
				}
			}
		}
	}
	
	@objc class func cleanUrlCache() {

		let c_cap = URLCache.shared.diskCapacity
		let c_usage = URLCache.shared.currentDiskUsage

		THLogInfo("URLCache diskCapacity:\(c_cap) usage:\(c_usage)")
		URLCache.shared.removeAllCachedResponses()
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------
