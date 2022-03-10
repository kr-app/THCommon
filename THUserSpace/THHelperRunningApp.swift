// THHelperRunningApp.swift

import Cocoa

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@objc class THHelperRunningApp: NSObject {
	
	@objc static let shared = THHelperRunningApp()

	private(set) var appIdentifier: String?
	private(set) var appLocation: URL?

	private var runningApp: pid_t?
	private var waitingAppOpenedEnd = false
	
	private func searchBundle(withAppIdentifier appIdentifier: String) -> Bundle? {
		if let dirPath = Bundle.main.builtInPlugInsPath {
			if let content = try? FileManager.default.contentsOfDirectory(atPath: dirPath) {
				for file in content {
					if let bundle = Bundle(path: dirPath.th_appendingPathComponent(file)) {
						if let bId = bundle.bundleIdentifier {
							if bId == appIdentifier {
								return bundle
							}
						}
					}
				}
			}
		}
		return nil
	}

	@objc func configure(withAppIdentifier appIdentifier: String, appLocation: URL? = nil) {

		terminateAll(appIdentifier: appIdentifier)

		var appLocation = appLocation
		if appLocation == nil {
			guard let bundle = searchBundle(withAppIdentifier: appIdentifier)
			else {
				THLogError("could not found bundle \(appIdentifier)")
				return
			}
			appLocation = bundle.bundleURL
		}

		if appLocation == nil || FileManager.default.fileExists(atPath: appLocation!.path) == false {
			THLogError("file not found at appLocation:\(appLocation)")
			return
		}

		self.appIdentifier = appIdentifier
		self.appLocation = appLocation
	}
	
	private func terminateAll(appIdentifier: String) {
		let apps = NSRunningApplication.runningApplications(withBundleIdentifier: appIdentifier)
		for app in apps {
			if app.terminate() == true || app.forceTerminate() == true {
				continue
			}
			THLogError("can not terminate app:\(app)")
		}
	}
	
	@objc func openApp(wait: Bool) -> Bool {
		guard 	let appIdentifier = appIdentifier,
					let appLocation = appLocation
		else {
			THFatalError("appIdentifier|appLocation")
		}

		if let pid = runningApp {
			if let appId = NSRunningApplication(processIdentifier: pid)?.bundleIdentifier {
				if appId == appIdentifier {
					return true
				}
			}
			THLogError("found not running trying to reopen")
			runningApp = nil
		}
		
		if waitingAppOpenedEnd == true {
			THLogError("waiting another openning")
			return false
		}

		let apps = NSRunningApplication.runningApplications(withBundleIdentifier: appIdentifier)
		for app in apps.dropLast() {
			if app.terminate() == true || app.forceTerminate() == true {
				continue
			}
			THLogError("can not terminate app:\(app)")
		}
		
		if let last = apps.last {
			runningApp = last.processIdentifier
			return true
		}

		waitingAppOpenedEnd = true

		let config = NSWorkspace.OpenConfiguration()
		config.promptsUserIfNeeded = false
		config.addsToRecentItems = false
		config.activates = true

//		NSError *error=nil;
//		_previewApp=[[NSWorkspace sharedWorkspace] launchApplicationAtURL:qlURL
//																	options:NSWorkspaceLaunchWithoutAddingToRecents/*|NSWorkspaceLaunchWithoutActivation*/
//																	configuration:@{NSWorkspaceLaunchConfigurationArguments:args} error:&error];

		NSWorkspace.shared.openApplication(at: appLocation, configuration: config, completionHandler: {( app: NSRunningApplication?, error: Error?) in
			if app != nil && error == nil {
				THLogInfo("opened app:\(app!), pid:\(app!.processIdentifier)")
				self.runningApp = app!.processIdentifier
			}
			else {
				THLogError("can not open app, appLocation:\(appLocation) error:\(error)")
			}

			self.waitingAppOpenedEnd = false

//			DispatchQueue.main.async {
//				completion(app != nil && error == nil)
//			}
		})

		if wait == true {
			for i in 0..<20 {
				Thread.sleep(forTimeInterval: 0.1)

				if waitingAppOpenedEnd == false {
					if let pid = self.runningApp {
						if NSRunningApplication(processIdentifier: pid) != nil {
							break
						}
					}
				}
			
				THLogInfo("waiting for openApplication response (\(i + 1))")
			}
		}

		return true
	}

	private func isRunningApp() -> (running: Bool, active: Bool)? {
		guard let appIdentifier = appIdentifier
		else {
			return nil
		}

		guard let pid = runningApp,
				  let app = NSRunningApplication(processIdentifier: pid),
				  let appId = app.bundleIdentifier
		else {
			return nil
		}

		if appId != appIdentifier {
			return nil
		}

		return (running: true, active: app.isActive)
	}

	@objc func isActiveApp() -> Bool {
		return isRunningApp()?.active == true
	}

	@objc func terminateApp() {
		runningApp = nil

		if let appIdentifier = appIdentifier {
			terminateAll(appIdentifier: appIdentifier)
		}
	}
	
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
