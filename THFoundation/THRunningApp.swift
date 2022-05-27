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

#if DEBUG
	private static var debuggerAttached = 0
#endif

#if os(macOS)
	@objc static let processId = NSRunningApplication.current.processIdentifier

	private static var sandboxed = 0
#endif
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension THRunningApp {

#if DEBUG
	@objc class func isDebuggerAttached() -> Bool {
		if debuggerAttached == 0 {
			var info = kinfo_proc()
			var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
			var size = MemoryLayout<kinfo_proc>.stride
			let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
			assert(junk == 0, "sysctl failed")// errno:%d (%s)",errno,strerror(errno))
			debuggerAttached = (info.kp_proc.p_flag & P_TRACED) != 0 ? 1 : -1
		}
		return debuggerAttached == 1
	}
#endif

}
//--------------------------------------------------------------------------------------------------------------------------------------------


#if os(macOS)
//--------------------------------------------------------------------------------------------------------------------------------------------
extension THRunningApp {

	@objc class func isSandboxedApp() -> Bool {
		if sandboxed == 0 {
			let environment = ProcessInfo.processInfo.environment
			sandboxed = environment["APP_SANDBOX_CONTAINER_ID"] != nil ? 1 : -1
		}
		return sandboxed == 1
	}

	@objc class func buildDate() -> Date? {
		FileManager.th_modDate1970(atPath: Bundle.main.executablePath)
	}
	
	@objc class func config() -> [String: Any] {
		var results = [String: Any]()

#if DEBUG
		results["debug"] = 1
		results["debuggerAttached"] = isDebuggerAttached() ? 1 : 0
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
