// THParentAppAlive.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
class THParentAppAlive: NSObject {

	private var parentPid: pid_t?
	private var parentAppIdentifier: String!
	private var parentChecker: Timer?

	// MARK: -

	init(withParentAppIdentifier parentAppIdentifier: String) {
		self.parentAppIdentifier = parentAppIdentifier
	}

	func update(withParentPid parentPid: pid_t) {
		if self.parentPid != nil && self.parentPid! != parentPid {
			THLogInfo("terminated because parentPid changed")
			NSApplication.shared.terminate(nil)
			return
		}
		else if self.parentPid == nil {
			self.parentPid = parentPid
			parentChecker = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
		}
	}

	@objc func timerAction(_ sender: Timer) {
		let parentPid = self.parentPid!

		let app = NSRunningApplication(processIdentifier: pid_t(parentPid))
		let appId = app?.bundleIdentifier

		if appId != nil && appId! == parentAppIdentifier {
			return
		}

		THLogError("terminated because no parent app was found app:\(app), appId:\(appId)")
		NSApplication.shared.terminate(nil)
	}
	
}
//--------------------------------------------------------------------------------------------------------------------------------------------
