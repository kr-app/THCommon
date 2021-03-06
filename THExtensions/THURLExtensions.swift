// THURLExtensions.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
extension URLSessionConfiguration {

	class func th_ephemeral(httpMaximumConnectionsPerHost: Int = 1, timeoutIntervalForRequest: TimeInterval = 30.0) -> URLSessionConfiguration {

		let conf = URLSessionConfiguration.ephemeral
		conf.timeoutIntervalForRequest = timeoutIntervalForRequest
		conf.httpMaximumConnectionsPerHost = httpMaximumConnectionsPerHost

		let cookieStorage = HTTPCookieStorage()
		cookieStorage.cookieAcceptPolicy = .never

		conf.httpShouldSetCookies = false
		conf.httpCookieStorage = cookieStorage

		return conf
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension HTTPURLResponse {
	func th_displayStatus() -> String {
		Self.localizedString(forStatusCode: self.statusCode) + " (\(self.statusCode))"
	}
}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension URL {

	var th_reducedHost: String { get {
			guard let host = self.host
			else {
				return self.absoluteString
			}
			if host.hasPrefix("www.") {
				return String(host.dropFirst("www.".count))
			}
			return host
		}
	}

	static func th_recomposedUrl(href: String, site: URL) -> URL? {
		if href.hasPrefix("http") {
			return URL(string: href)
		}
		if let sc = site.scheme, let h = site.host {
			return URL(string: sc + "://" + h)?.appendingPathComponent(href)
		}
		return nil
	}
}
//-----------------------------------------------------------------------------------------------------------------------------------------
