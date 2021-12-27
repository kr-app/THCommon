// THWebPageAttributes.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
class RssArticleImage: NSObject {
	private static let urlSession = URLSession(configuration: URLSessionConfiguration.th_ephemeral())
	
	private static var once = [URL]()
	
	var link: URL!
	var extractedImage: URL?

	private var task: URLSessionTask?

	init(link: URL) {
		self.link = link
	}

	func start(_ completion: @escaping (Bool, String?) -> Void) {
		if Self.once.contains(link) == true {
			return
		}
		Self.once.append(link)
	
		THLogInfo("link:\(link.absoluteString)")

		let request = URLRequest(url: link, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)

		task = Self.urlSession.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
			if self.task == nil {
				THLogInfo("cancelled")
				return
			}

			if let rep = response as? HTTPURLResponse, let data = data {
				if rep.statusCode == 200 {

					if let html = String(data: data, encoding: .utf8) {
						let image = RssArticleImage_AJ.extractImageArticle(html)
						self.extractedImage = image

						let json = JsonLd.extract(html)
					}

					DispatchQueue.main.async {
						completion(true, nil)
					}
					return
				}
			}
	
			let e = error?.localizedDescription ?? (response as? HTTPURLResponse)?.th_displayStatus()
			DispatchQueue.main.async {
				THLogError("request:\(request.url?.absoluteString), error:\(e)")
				completion(false, e)
			}

		})
		task!.resume()
	}
	
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate class JsonLd {

	class func extract(_ html: String) -> URL? {

//		if let ld_json = html.th_search(firstRangeOf: "<script type=\"application/ld+json\">", endRange: "</script>") {
//
//			if let d = ld_json.data(using: .utf8) {
//				let json = try? JSONSerialization.jsonObject(with: d, options: [])
//				NSLog("json:\(json)")
//			}
//
//		}
		return nil
	}
	
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate class RssArticleImage_AJ {

	class func extractImageArticle(_ html: String) -> URL? {

		if let link = html.th_search(firstRangeOf: "<meta data-rh=\"true\" property=\"og:image\" name=\"og:image\" content=\"", endRange: "\"") {
			return URL(string: link)
		}

		if let link = html.th_search(firstRangeOf: "<meta property=\"og:image\" content=\"", endRange: "\"") {
			return URL(string: link)
		}
		
/*		let options = THXMLParserOptions_recover
		guard let parser = THXMLParser(data: data, baseURL: nil, options: options)
		else {
			THLogError("parser == nil")
			return nil
		}
	
//		let xmlp = XMLParser(data: data)
//		let ok = xmlp.parse()

		var error: NSString?
//		guard let og_image = parser.elements(fromXPathQuery: "//meta[@data-rh=\"true\" property=\"og:image\" name=\"og:image\"]", error: &error)
		guard let items = parser.elements(fromXPathQuery: "//meta", error: &error)
		else {
			THLogError("items == nil error:\(error)")
			return nil
		}
		
		//<meta data-rh="true" property="og:image" name="og:image" content=
		*/
		return nil
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
struct RssFromSource {
	let site: URL
	let rss: URL
	let title: String
	
	static func extractFromParser(site: URL, source: String) -> [RssFromSource]? {

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

		var r = [RssFromSource]()
	
		for ref in refs {
			if 	let href = ref.attributes()?["href"] as? String,
				let title = ref.attributes()?["title"] as? String {

				guard let url = URL.th_recomposedUrl(href: href, site: site)
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

	static func extractFromSearch(site: URL, source: String) -> [RssFromSource]? {
	
		var result = [RssFromSource]()

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

			result.append(RssFromSource(site: site, rss: url, title: title))
		})

		return result
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
