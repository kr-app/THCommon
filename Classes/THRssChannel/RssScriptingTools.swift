// RssScriptingTools.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
struct RssFromSource {
	let site: URL!
	let rss: URL!
	let title: String!
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
class RssScriptingTools: NSObject {
	
	static let shared = RssScriptingTools()

	private var sitesWithoutRss = [String]()


	func rssFeedOfFrontBrowser() -> [RssFromSource]? {

		
		return rssFeedOfSafariBrowser()
		
	}
	
	private func rssFeedOfSafariBrowser() -> [RssFromSource]? {

		var script = THAsScriptManager.shared.script(named: "rssFeedOfFrontBrowser")

		if script == nil {
			let s = "tell application \"Safari\"\n"
						+ "try\n"
							+ "set d to document of front window\n"
							+ "set u to URL of d\n"
							+ "return {u, source of d}\n"
						+ "end try\n"
						+ "return -1\n"
					+ "end tell\n"

			script = THAsScriptManager.shared.addScript(withSource: s, forName : "rssFeedOfFrontBrowser")
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
		
		guard let r = rssFeedOfFrontBrowser(fromSite: site, source: source)
		else {
			sitesWithoutRss.append(site)
			return nil
		}

		return r
	}
	
	private func rssFeedOfFrontBrowser(fromSite siteUrl: String, source: String) -> [RssFromSource]? {

		guard let data = source.data(using: .utf8)
		else {
			THLogError("data == nil")
			return nil
		}

		guard let parser = THXMLParser(data: data, baseURL: nil, options: 0)
		else {
			THLogError("parser == nil")
			return nil
		}
	
		var error: NSString?
		guard let refs = parser.elements(fromXPathQuery: "//link[@type=\"application/rss+xml\"]", error: &error)
		else {
			//THLogError("refs == nil")
			return nil
		}

		var r = [RssFromSource]()
	
		for ref in refs {
			if 	let href = ref.attributes()?["href"] as? String,
				let title = ref.attributes()?["title"] as? String {

				let site = URL(string: siteUrl)!

				var url: URL?
				if href.hasPrefix("http") == true {
					url = URL(string: href)
				}
				else {
					if let sc = site.scheme, let h = site.host {
						url = URL(string: sc + "://" + h)!.appendingPathComponent(href)
					}
				}

				if url == nil {
					THLogError("can not create url for href:\(href)")
					continue
				}

				r.append(RssFromSource(site: site, rss: url!, title: title))
			}
		}

		if r.count > 0 {
			return r
		}

		THLogError("refs:\(refs)")
		return nil
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
