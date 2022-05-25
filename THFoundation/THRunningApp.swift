// THRunningApp.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THRunningApp: NSObject {

	@objc static let bundleIdentifier = Bundle.main.bundleIdentifier!
	@objc static let appName = (Bundle.main.executablePath! as NSString).lastPathComponent
	@objc static let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	@objc static let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String

#if os(macOS)
	@objc static let processId = NSRunningApplication.current.processIdentifier

	private static var isSandboxed = 0
#endif
}
//--------------------------------------------------------------------------------------------------------------------------------------------


#if os(macOS)
//--------------------------------------------------------------------------------------------------------------------------------------------
extension THRunningApp {

	@objc class func isSandboxedApp() -> Bool {
		if Self.isSandboxed == 0 {
			let environment = ProcessInfo.processInfo.environment
			Self.isSandboxed = environment["APP_SANDBOX_CONTAINER_ID"] != nil ? 1 : -1
		}
		return Self.isSandboxed == 1
	}

	@objc class func buildDate() -> Date? {
		FileManager.th_modDate1970(atPath: Bundle.main.executablePath)
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

		results["pid"] = Int(processId)
		results["sandboxedApp"] = isSandboxedApp() ? 1 : 0
		results["buildDate"] = buildDate()

		return results
	}

#if DEBUG
	@objc class func printConfig() {
		THLogDebug("app configuration:\(config() as NSDictionary)")
	}
#endif

	private class func killApp(withPid pid: pid_t) -> Int32 {
		let p = Process()
		p.launchPath = "/bin/kill"
		p.arguments  = ["-9", String(pid)]
		p.launch()
		p.waitUntilExit()
		return p.terminationStatus
	}

	@objc class func killOtherApps(_ bundleId: String? = nil) {

		if isSandboxedApp() {
			THLogError("not yet supported by sandboxed environement")
			return
		}
		
		guard let bundleId = bundleId ?? Bundle.main.bundleIdentifier
		else {
			THFatalError("bundleId == nil bundle:\(Bundle.main)")
		}

		let apps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId)

		for app in apps.filter({ $0.processIdentifier != processId }) {
			var tryCount = 0
			while tryCount < 10 {

				if tryCount == 0 {
					if app.terminate() || app.forceTerminate() {
						break
					}
				}

				let r = killApp(withPid: app.processIdentifier)
				if r == 0 {
					break
				}

				tryCount += 1
				THLogError("can not kill app:\(app) with pid:\(app.processIdentifier), r:\(r), tryCount:\(tryCount)")
				Thread.sleep(forTimeInterval: 0.5)
			}
		}
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
#endif
