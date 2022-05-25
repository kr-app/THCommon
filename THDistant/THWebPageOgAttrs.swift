// THWebPageOgAttrs.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
class THWebPageOgAttrs {

	static func extractImage(_ html: String) -> URL? {

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
