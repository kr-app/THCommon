// THDataExtensions.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
extension NSData {
	
	func th_write(to file: String, options: NSData.WritingOptions = [.atomic]) -> Bool {
		do {
			try write(toFile: file, options: options)
			return true
		}
		catch {
			THLogError("writeToFile:options: file:\(file) error: \(error)")
		}
		return false
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension Data {
	
	func th_write(to url: URL, options: Data.WritingOptions = [.atomic]) -> Bool {
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
