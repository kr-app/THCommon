// THWebPageJsonLdAttrs.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate class THWebPageJsonLdAttrs {

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
