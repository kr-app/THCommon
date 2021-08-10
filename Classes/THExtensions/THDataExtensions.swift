// THDataExtensions.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
extension Data {
	
	func th_write(to url: URL) -> Bool {
		do {
			try write(to: url)
			return true
		}
		catch {
			THLogError("writeTo url:\(url) error: \(error)")
		}
		return false
	}

	func th_write(to url: URL, options: Data.WritingOptions = []) -> Bool {
		do {
			try write(to: url, options: options)
			return true
		}
		catch {
			THLogError("writeTo:options: url:\(url) error: \(error)")
		}
		return false
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------
