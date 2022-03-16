// THWebBrowserScriptingTools.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
struct THWebBrowserScriptingTools {
	private static let safariBundleId = "com.apple.Safari"

	private static func hasRunningSafari() -> Bool {
		NSRunningApplication.runningApplications(withBundleIdentifier: safariBundleId).count > 0
	}

	static func createWindowIfNecessary() -> Bool {
		FirefoxScriptingTools.createWindowIfNecessary()
	}

	static func sourceOfFrontTab(targetUrl: String) -> String? {
		hasRunningSafari() ? SafariScriptingTools.sourceOfFrontSite(targetUrl: targetUrl) : nil
	}

	static func rssFeedsOfFrontTab() -> [RssFromSource]? {
		hasRunningSafari() ? SafariScriptingTools.frontRssFeeds() : nil
	}

	static func getFrontTab() -> (empty: Bool, title: String?, url: String?)? {
		hasRunningSafari() ? SafariScriptingTools.getFrontTab() : nil
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate struct FirefoxScriptingTools {

	static func createWindowIfNecessary() -> Bool {
		var script = THAsScriptManager.shared.script(named: "CreateWindowIfNecessary")
		
		if script == nil {
			let s = 	"tell application \"Firefox\"\n"
							+ "try\n"
								+ "set w to front window\n"
								+ "if w is visible and w is not miniaturized then\n"
									+ "return \"has window\"\n"
								+ "end if\n"
							+ "end try\n"
							+ "open \"about:\"\n"
							+ "return \"new win\"\n"
						+ "end tell\n"
			script = THAsScriptManager.shared.addScript(withSource: s, forName : "CreateWindowIfNecessary")
		}

		guard let script = script
		else {
			THLogError("script == nil")
			return false
		}

		if script.execute(forRunner: self) == nil {
			THLogError("script.execute() == nil")
			return false
		}

		THLogInfo("scrupt result:\(script.resultAed)")
		return true
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate struct SafariScriptingTools {

	/*static func createWindowIfNecessary() -> Bool {

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
	}*/

	static func getFrontTab() -> (empty: Bool, title: String?, url: String?)? {

		var script = THAsScriptManager.shared.script(named: "GetFrontTab")
		if script == nil {
			let s = """
					tell application \"Safari\"

						try
							set sWindow to front window
						on error
							return null
						end try

						if (sWindow is not visible or sWindow is miniaturized) then
							return null
						end if

						set sDoc to document of sWindow

						if (class of sDoc is not document) then
							return null
						end if

						try
							set sTitle to name of current tab of sWindow
							set sURL to URL of current tab of sWindow
							return {sTitle, sURL}
						on error
							return null
						end try

					end tell
				"""
			script = THAsScriptManager.shared.addScript(withSource: s, forName : "GetFrontTab")
		}

		guard let aed = script?.execute(forRunner: self)
		else {
			THLogError("script.execute() == nil")
			return nil
		}

		if aed.numberOfItems == 2 {
			if 		let title = aed.atIndex(1)?.stringValue,
					let url = aed.atIndex(2)?.stringValue {
				return (empty: false, title: title, url: url)
			}
		}
		else if aed.numberOfItems == 1 {
			if let code = aed.atIndex(1)?.int32Value {
				if code > 0 {
					THLogInfo("code:\(code)")
					return (empty: true, title: nil, url: nil)
				}
			}

			THLogError("aed:\(aed)")
			return nil
		}

		THLogError("aed:\(aed)")
		return nil
	}

	static func sourceOfFrontSite(targetUrl: String) -> String? {

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

		if let site = aed.atIndex(1)?.stringValue, let source = aed.atIndex(2)?.stringValue {
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

	static func frontRssFeeds() -> [RssFromSource]? {
		var script = THAsScriptManager.shared.script(named: "safariFrontRssFeeds")

		if script == nil {
			let s = "tell application \"Safari\"\n"
						+ "try\n"
							+ "set d to document of front window\n"
							+ "set u to URL of d\n"
							+ "return {u, source of d}\n"
						+ "end try\n"
						+ "return -1\n"
					+ "end tell\n"

			script = THAsScriptManager.shared.addScript(withSource: s, forName : "safariFrontRssFeeds")
		}

		guard let aed = script?.execute(forRunner: self)
		else {
			THLogError("script.execute() == nil")
			return nil
		}

		guard let site = aed.atIndex(1)?.stringValue, let source = aed.atIndex(2)?.stringValue
		else {
			THLogError("site == nil || source == nil aed:\(aed)")
			return nil
		}

		let siteUrl = URL(string: site)!

		var r = RssFromSource.extractFromParser(site: siteUrl, source: source)
		if r == nil {
			THLogError("can not get source from parser, retrying with text searching…")
			r = RssFromSource.extractFromSearch(site: siteUrl, source: source)
		}

		if r == nil || r!.count == 0 {
			THLogError("can not get")
			return nil
		}

		return r
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
