//  THFrontmostAppSaver.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THFrontmostAppSaver: NSObject {
	@objc static let shared = THFrontmostAppSaver()

	private let myPid = NSRunningApplication.current.processIdentifier
	private var lastFrontmostApp: pid_t?

	@objc func save() {
		let frontApp = NSWorkspace.shared.frontmostApplication
		lastFrontmostApp = frontApp == nil ? nil : frontApp!.processIdentifier == myPid ? nil : frontApp!.processIdentifier
	}

	@objc func hasVisibleWindow() -> Bool {
		for window in NSApplication.shared.windows {
			if window.th_className == "NSStatusBarWindow" || window.th_className.hasSuffix("PWPaneWindow") || window.th_className.hasSuffix("PCalWindow") {
				continue
			}
			if window.isVisible == true {
				return true
			}
		}
		return false
	}
	
	@objc func restore() {
		guard let frontmostPid = lastFrontmostApp
		else {
			return
		}

		if hasVisibleWindow() {
			return
		}

		let frontApp = NSWorkspace.shared.frontmostApplication
		if frontApp == nil || frontApp!.processIdentifier != myPid {
			return
		}
	
		let app = NSRunningApplication(processIdentifier: frontmostPid)
		app?.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
	}
	
}
//--------------------------------------------------------------------------------------------------------------------------------------------
