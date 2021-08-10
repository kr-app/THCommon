// THRunningApp.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate class RunningAppCache {
	static var isSandboxed = 0
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THRunningApp: NSObject {

	@objc static let bundleIdentifier = Bundle.main.bundleIdentifier!
	@objc static let appName = (Bundle.main.executablePath! as NSString).lastPathComponent
	@objc static let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	@objc static let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String

	#if os(macOS)
		@objc static let processId = NSRunningApplication.current.processIdentifier
	#endif

}
//--------------------------------------------------------------------------------------------------------------------------------------------


#if os(macOS)
//--------------------------------------------------------------------------------------------------------------------------------------------
extension THRunningApp {

	@objc class func isSandboxedApp() -> Bool {
		if RunningAppCache.isSandboxed == 0 {
			let environment = ProcessInfo.processInfo.environment
			RunningAppCache.isSandboxed = environment["APP_SANDBOX_CONTAINER_ID"] != nil ? 1 : -1
		}
		return RunningAppCache.isSandboxed == 1
	}

	@objc class func buildDate() -> Date? {
		return FileManager.th_modDate1970(atPath: Bundle.main.executablePath)
	}
	
	@objc class func config() -> [String: Any] {
		var results = [String: Any]()

#if DEBUG
		results["debug"] = 1
		results["debuggerAttached"] = TH_isDebuggerAttached() ? 1 : 0
#else
		results["debug"] = 0
		results["debuggerAttached"] = 0
#endif

		results["sandboxedApp"] = isSandboxedApp() ? 1 : 0
		results["buildDate"] = buildDate()

		return results
	}

	private class func killApp(withPid pid: pid_t) -> Int32 {
		let p = Process()
		p.launchPath = "/bin/kill"
		p.arguments  = ["-9", String(pid)]
		p.launch()
		p.waitUntilExit()
		return p.terminationStatus
	}

	@objc class func killOtherApps(_ bundleId: String? = nil) {

		if isSandboxedApp() == true {
			THLogError("not yet supported in sandboxed environement")
			return
		}
		
		let bundleId = bundleId ?? Bundle.main.bundleIdentifier
		THFatalError(bundleId == nil, "bundleId == nil bundle:\(Bundle.main)")

		let myPid = NSRunningApplication.current.processIdentifier
		let apps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId!)

		for app in apps {
			if app.processIdentifier == myPid {
				continue
			}

			var nb_try = 0
			while nb_try < 10 {
				
				if nb_try == 0 {
					if app.terminate() == true || app.forceTerminate() == true {
						break
					}
				}

				let r = killApp(withPid: app.processIdentifier)
				if r == 0 {
					break
				}

				nb_try += 1
				THLogError("can not kill app:\(app) with pid:\(app.processIdentifier), r:\(r), retrying:\(nb_try)")
				Thread.sleep(forTimeInterval: 1.0)
			}
		}
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
#endif
