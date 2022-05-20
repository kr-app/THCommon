// THWebBrowserScriptingTools.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
struct THWebBrowserScriptingTools {
	private static let safariBundleId = "com.apple.Safari"

	private static func hasRunningSafari() -> Bool {
		NSRunningApplication.runningApplications(withBundleIdentifier: safariBundleId).count > 0
	}

	static func createWindowIfNecessary(page: URL? = nil) -> Int {
		FirefoxScriptingTools.createWindowIfNecessary(page: page)
	}

	static func sourceOfFrontTab(targetUrl: String) -> String? {
		hasRunningSafari() ? SafariScriptingTools.sourceOfFrontSite(targetUrl: targetUrl) : nil
	}

	static func rssFeedsOfFrontTab() -> [THWebPageRssAttrs]? {
		hasRunningSafari() ? SafariScriptingTools.frontRssFeeds() : nil
	}

	static func getFrontTab() -> (empty: Bool, title: String?, url: String?)? {
		hasRunningSafari() ? SafariScriptingTools.getFrontTab() : nil
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate struct FirefoxScriptingTools {

	static func createWindowIfNecessary(page: URL? = nil) -> Int {
		var script = THAsScriptManager.shared.script(named: "CreateWindowIfNecessary")

		let p = FileManager.th_appCachesDir().th_appendingPathComponent("FirefoxScriptingTools-createWindowIfNecessary.html")

		let redir = """
						<html>
						<head>
							<meta http-equiv=\"Refresh\" content=\"0; url='\(page?.absoluteString)'\"/>
						</head>
						</html>
					"""

		if redir.th_write(toFile: p) == false {
			THLogError("th_write == false p:\(p)")
			return -1
		}

		if script == nil {
			let s = """
						tell application \"Firefox\"
							try
								set w to front window
									if w is visible and w is not miniaturized then
										return \"has window\"
								end if
							end try
						open \"\(p)"
						return \"new win\"
					end tell
					"""
			script = THAsScriptManager.shared.addScript(withSource: s, forName : "CreateWindowIfNecessary")
		}

		guard let result = script?.execute(forRunner: self)?.stringValue
		else {
			THLogError("script.execute() == nil")
			return -1
		}

		if result == "has window" {
			return 0
		}
		if result == "new window" {
			return 1
		}

		THLogError("script result:\(script?.resultAed)")
		return -1
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

		THLogInfo("script result:\(script!.resultAed)")

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
							return 1
						end if

						set sDoc to document of sWindow

						if (class of sDoc is not document) then
							return 2
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
			if let title = aed.atIndex(1)?.stringValue, let url = aed.atIndex(2)?.stringValue {
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

	static func frontRssFeeds() -> [THWebPageRssAttrs]? {
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

		var r = THWebPageRssAttrs.extractFromParser(site: siteUrl, source: source)
		if r == nil {
			THLogError("can not get source from parser, retrying with text searching…")
			r = THWebPageRssAttrs.extractFromSearch(site: siteUrl, source: source)
		}

		if r == nil || r!.count == 0 {
			THLogError("can not get")
			return nil
		}

		return r
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
