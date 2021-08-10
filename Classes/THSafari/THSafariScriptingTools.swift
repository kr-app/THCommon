// THSafariScriptingTools.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
class THSafariScriptingTools: NSObject {

	class func createWindowIfNecessary() -> Bool {
		
		var script: THAsScript?

		if let event = NSApplication.shared.currentEvent {
			let flags = event.modifierFlags
			if flags.intersection(.deviceIndependentFlagsMask) == .command || flags.intersection(.deviceIndependentFlagsMask) == .option {

				let s = "tell application \"Safari\"\n"
						+ "make new document\n"
						+ "return 1\n"
					+ "end tell\n"

				script = THAsScript(name: "create_win", source: s)
			}
		}

		if script == nil {
			script = THAsScriptManager.shared.script(named: "CreateWindowIfNeeded")
		
			if script == nil {

				let s = "tell application \"Safari\"\n"
						+ "try\n"
						+ "set cw to front window\n"
						+ "get cw\n"
						+ "if ((cw is visible) and (cw is not miniaturized)) then\n"
							+ "set wTabs to (tabs of cw)\n"
							+ "if (count of wTabs) >= 1 then\n"
								+ "set wTab to first item of wTabs\n"
								+ "set dURL to URL of wTab\n"
								+ "if dURL is missing value then\n"
									+ "return 2\n"
								+ "end if\n"
	//							+ "if dURL contains \"www.youtube.com\" then\n"
									+ "return 3\n"
	//							+ "end if\n"
							+ "end if\n"
						+ "end if\n"
						+ "on error\n"
							+ "return -2\n"
						+ "end try\n"
						+ "make new document\n"
						+ "return 1\n"
					+ "end tell\n"

				script = THAsScriptManager.shared.addScript(withSource: s, forName : "AtLeastOne")
			}
		}

		if script!.execute(forRunner: self) == nil {
			THLogError("script.execute() == nil")
			return false
		}

		THLogInfo("scrupt result:\(script!.resultAed)")

		return true
	}
	
	class func sourceOfFrontSite(targetUrl: String) -> String? {

		let s = "tell application \"Safari\"\n"
					+ "try\n"
						+ "set d to document of front window\n"
						+ "set u to URL of d\n"
						+ "if u is equal to \"\(targetUrl)\"\n"
							+ "return {u, source of d}\n"
						+ "end if\n"
				
						+ "return -2\n"
					+ "end try\n"

					+ "return -1\n"
				+ "end tell\n"

		let script = THAsScript(name: "SourceOfFrontSite", source: s)
		guard let aed = script.execute(forRunner: self)
		else {
			THLogError("script.execute() == nil")
			return nil
		}

		if 	let site = aed.atIndex(1)?.stringValue,
			let source = aed.atIndex(2)?.stringValue {

			if site == targetUrl {
				return source
			}
		}

		if aed.int32Value == -2 {
			return nil
		}

		THLogError("aed:\(aed)")
		return nil
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
