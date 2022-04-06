// THWebPageRssAttrs.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
struct THWebPageRssAttrs {
	let site: URL
	let rss: URL
	let title: String
	
	static func extractFromParser(site: URL, source: String) -> [THWebPageRssAttrs]? {

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
			THLogError("refs == nil error:\(error)")
			return nil
		}

		var r = [THWebPageRssAttrs]()
	
		for ref in refs {
			if 	let href = ref.attributes()?["href"] as? String,
				let title = ref.attributes()?["title"] as? String {

				guard let url = URL.th_recomposedUrl(href: href, site: site)
				else {
					THLogError("can not create url for href:\(href)")
					continue
				}

				r.append(THWebPageRssAttrs(site: site, rss: url, title: title))
			}
		}

		if r.count > 0 {
			return r
		}

		THLogError("refs:\(refs)")
		return nil
	}

	static func extractFromSearch(site: URL, source: String) -> [THWebPageRssAttrs]? {
	
		var result = [THWebPageRssAttrs]()

		source.enumerateLines( invoking: { (line: String, stop: inout Bool) in
			let l = line.trimmingCharacters(in: .whitespaces)

			let type = (l as NSString).range(of: "application/rss+xml")
			if type.location == NSNotFound {
				return
			}
			stop = true

			let rl = (l as NSString).substring(from: type.location)

			guard 	let title = rl.th_search(firstRangeOf: "title=\"", endRange: "\""),
						let href = rl.th_search(firstRangeOf: "href=\"", endRange: "\"")
			else {
				THLogError("href == nil title == nil")
				return
			}
		
			guard let url = URL.th_recomposedUrl(href: href, site: site)
			else {
				THLogError("can not create url for href:\(href)")
				return
			}

			result.append(THWebPageRssAttrs(site: site, rss: url, title: title))
		})

		return result.count > 0 ? result : nil
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
