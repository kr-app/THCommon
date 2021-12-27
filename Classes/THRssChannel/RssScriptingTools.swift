// RssScriptingTools.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
class RssScriptingTools {
	static let shared = RssScriptingTools()
	private var sitesWithoutRss = [String]()

	func rssFeedOfFrontBrowser() -> [RssFromSource]? {
		return rssFeedFromSafariBrowser()
	}
	
	private func rssFeedFromSafariBrowser() -> [RssFromSource]? {

		var script = THAsScriptManager.shared.script(named: "rssFeedFromSafariBrowser")

		if script == nil {
			let s = "tell application \"Safari\"\n"
						+ "try\n"
							+ "set d to document of front window\n"
							+ "set u to URL of d\n"
							+ "return {u, source of d}\n"
						+ "end try\n"
						+ "return -1\n"
					+ "end tell\n"

			script = THAsScriptManager.shared.addScript(withSource: s, forName : "rssFeedFromSafariBrowser")
		}
		
		guard let aed = script!.execute(forRunner: self)
		else {
			THLogError("script.execute() == nil")
			return nil
		}

		guard 	let site = aed.atIndex(1)?.stringValue,
					let source = aed.atIndex(2)?.stringValue
		else {
			THLogError("site == nil || source == nil aed:\(aed)")
			return nil
		}

		if sitesWithoutRss.contains(site) == true {
			return nil
		}
		
		let siteUrl = URL(string: site)!
		
		var r = RssFromSource.extractFromParser(site: siteUrl, source: source)
		if r == nil {
			THLogError("can not get source from parser, retrying with text searching…")
			r = RssFromSource.extractFromSearch(site: siteUrl, source: source)
		}

		if r == nil {
			sitesWithoutRss.append(site)
			return nil
		}

		return r
	}
}
//--------------------------------------------------------------------------------------------------------------------------------------------
