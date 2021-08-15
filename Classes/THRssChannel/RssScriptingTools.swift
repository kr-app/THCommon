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

		guard let r = r
		else {
			sitesWithoutRss.append(site)
			return nil
		}

		return r
	}
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
struct RssFromSource {
	let site: URL
	let rss: URL
	let title: String

	private static func recomposedUrl(href: String, site: URL) -> URL? {
		if href.hasPrefix("http") == true {
			return URL(string: href)
		}
		if let sc = site.scheme, let h = site.host {
			return URL(string: sc + "://" + h)!.appendingPathComponent(href)
		}
		return nil
	}
	
	private static func getAttributeValue(from text: NSString) -> String? {
		let b = text.range(of: "\"")
		if b.location == NSNotFound {
			return nil
		}
		let be = b.location + b.length

		let e = text.range(of: "\"", range: NSRange(be, text.length - be))
		if e.location == NSNotFound {
			return nil
		}
		
		return text.substring(with: NSRange(b.location + b.length, e.location - be))
	}

	fileprivate static func extractFromParser(site: URL, source: String) -> [RssFromSource]? {

		guard let data = source.data(using: .utf8)
		else {
			THLogError("data == nil")
			return nil
		}

		let options = THXMLParserOptions_recover
		guard let parser = THXMLParser(data: data, baseURL: nil, options: options)
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

				guard let url = recomposedUrl(href: href, site: site)
				else {
					THLogError("can not create url for href:\(href)")
					continue
				}

				r.append(RssFromSource(site: site, rss: url, title: title))
			}
		}

		if r.count > 0 {
			return r
		}

		THLogError("refs:\(refs)")
		return nil
	}

	fileprivate static func extractFromSearch(site: URL, source: String) -> [RssFromSource]? {
	
		var result = [RssFromSource]()

		source.enumerateLines( invoking: { (line: String, stop: inout Bool) in
			let l = line.trimmingCharacters(in: .whitespaces) as NSString

			let type = l.range(of: "application/rss+xml")
			if type.location == NSNotFound {
				return
			}
			stop = true

			let title = l.range(of: "title=")
			let href = l.range(of: "href=")
			if href.location == NSNotFound || title.location == NSNotFound {
				THLogError("href.location == NSNotFound || title.location == NSNotFound")
				return
			}
		
			guard 	let href = getAttributeValue(from: l.substring(from: href.location) as NSString),
						let title = getAttributeValue(from: l.substring(from: title.location) as NSString)
			else {
				THLogError("href == nil title == nil")
				return
			}
		
			guard let url = self.recomposedUrl(href: href, site: site)
			else {
				THLogError("can not create url for href:\(href)")
				return
			}

			result.append(RssFromSource(site: site, rss: url, title: title))
		})

		return result
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
