// THFileManagerExtensions.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
fileprivate class Cached {
	static let invalidFsChars = [":", "/", "\\", "|", "\"", "<", ">", "`", "\n"]
											//,@"?",@"*", ";" // autre que macOS
	static var legalCharSets: [CharacterSet] = [.newlines, .illegalCharacters, .controlCharacters, .symbols]

	static var appSupportDirPath: String?
	static var cachesDirPath: String?
}

extension FileManager {

	@objc class func th_isLegalFilename(_ filename: String?) -> Bool {
		guard let filename = (filename != nil && filename!.isEmpty == false && filename!.count <= 255) ? filename : nil
		else {
			return false
		}

		for cs in Cached.legalCharSets {
			if filename.rangeOfCharacter(from: cs) != nil {
				return false
			}
		}

		for invalidFsChar in Cached.invalidFsChars {
			if filename.contains(invalidFsChar) == true {
				return false
			}
		}

		return true
	}

	@objc class func th_securisedFileName(_ filename: String?, subsitution: String?) -> String? {
		guard var nName = filename
		else {
			return nil
		}

		var validChar = false
	
		for invalidFsChar in Cached.invalidFsChars {
			if nName.contains(invalidFsChar) == true {
				nName = nName.replacingOccurrences(of: invalidFsChar, with: subsitution ?? "_")
			}
			else {
				validChar = true
			}
		}

		if validChar == false || nName.isEmpty == true {
			return nil
		}

		return nName
	}

	@objc class func th_checkCreatedDirectory(atPath dirPath: String) -> Bool {

		var isDir = ObjCBool(false)
		if FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDir) == true {
			if isDir.boolValue == true {
				return true
			}
			THLogError("Expected directory at path:\(dirPath)")
			return false
		}

		if FileManager.default.th_createDirectory(atPath: dirPath, withIntermediateDirectories: true) == false {
			THLogError("th_createDirectory == false dirPath:\(dirPath)")
			return false
		}

		return true
	}

	@objc class func th_appSupportPath(_ dirComponent: String? = nil) -> String {

		if Cached.appSupportDirPath == nil {
			let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)

			var dir: String!
			
#if os(macOS)
			if THRunningApp.isSandboxedApp() == true {
				dir = paths.first
			}
			else {
				let bundleId = Bundle.main.bundleIdentifier!
				dir = paths.first!.th_appendingPathComponent(bundleId)
			}
#elseif os(iOS)
			dir = paths.first
#endif
			
			if th_checkCreatedDirectory(atPath: dir) == false {
				THFatalError(true, "th_checkCreatedDirectory == false dir:\(dir)")
			}

			Cached.appSupportDirPath = dir
		}

		if dirComponent == nil {
			return Cached.appSupportDirPath!
		}

		let dirPath = Cached.appSupportDirPath!.th_appendingPathComponent(dirComponent!)
		if th_checkCreatedDirectory(atPath: dirPath) == false {
			THFatalError(true, "th_checkCreatedDirectory == false dirPath:\(dirPath)")
		}

		return dirPath
	}

	@objc class func th_appCachesDir(_ dirComponent: String? = nil) -> String {

		if Cached.cachesDirPath == nil {
			let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)

			var dir: String!
			
#if os(macOS)
			if THRunningApp.isSandboxedApp() == true {
				dir = paths.first
			}
			else {
				let bundleId = Bundle.main.bundleIdentifier!
				dir = paths.first!.th_appendingPathComponent(bundleId)
			}
#elseif os(iOS)
			dir = paths.first
#endif
			
			if th_checkCreatedDirectory(atPath: dir) == false {
				fatalError("th_checkCreatedDirectory == false dir:\(dir)")
			}

			Cached.cachesDirPath = dir
		}

		if dirComponent == nil {
			return Cached.cachesDirPath!
		}

		let dirPath = Cached.cachesDirPath!.th_appendingPathComponent(dirComponent!)
		if th_checkCreatedDirectory(atPath: dirPath) == false {
			fatalError("th_checkCreatedDirectory == false dirPath:\(dirPath)")
		}

		return dirPath
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension FileManager {

	func th_createDirectory(atPath path: String, withIntermediateDirectories: Bool) -> Bool {
		do {
			try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: withIntermediateDirectories, attributes: nil)
			return true
		}
		catch {
			THLogError("createDirectory path:\(path) error: \(error)")
		}
		return false
	}

	func th_contentsOfDirectory(atPath path: String) -> [String]? {
		do {
			return try FileManager.default.contentsOfDirectory(atPath: path)
		}
		catch {
			THLogError("contentsOfDirectory path:\(path) error: \(error)")
		}
		return nil
	}
	
	func th_copyItem(atPath path: String, toPath: String) -> Bool {
		do {
			try FileManager.default.copyItem(atPath: path, toPath: toPath)
			return true
		}
		catch {
			THLogError("copyItem path:\(path) error: \(error)")
		}
		return false
	}
	
	func th_removeItem(atPath path: String) -> Bool {
		do {
			try FileManager.default.removeItem(atPath: path)
			return true
		}
		catch {
			THLogError("path:\(path) error:\(error)")
		}
		return false
	}

	func th_removeItem(at url: URL) -> Bool {
		do {
			try FileManager.default.removeItem(at: url)
			return true
		}
		catch {
			THLogError("url:\(url) error:\(error)")
		}
		return false
	}

	func th_traskItem(atPath path: String) -> Bool {
		return th_traskItem(at: URL(fileURLWithPath: path))
	}

	func th_traskItem(at url: URL) -> Bool {
		var newPath: NSURL?
		do {
			try FileManager.default.trashItem(at: url, resultingItemURL:&newPath)
			return true
		}
		catch {
			THLogError("url:\(url) error:\(error)")
		}
		return false
	}
}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension FileManager {
	
	class func th_creationDate1970(atPath path: String?) -> Date? {
		guard let c_path = (path as NSString?)?.fileSystemRepresentation
		else {
			return nil
		}

		var statfile: stat = stat()
		if stat(c_path, &statfile) != 0 {
			let error = "errno:" + String(format:"%d (%s)",errno,(strerror(errno)))
			THLogError("stat != 0 error:\(error)")
			return nil
		}

		return Date(timeIntervalSince1970: Double(statfile.st_birthtimespec.tv_sec).rounded(.down))
	}

	@objc class func th_modDate1970(atPath path: String?) -> Date? {
		guard let c_path = (path as NSString?)?.fileSystemRepresentation
		else {
			return nil
		}

		var statfile: stat = stat()
		if stat(c_path, &statfile) != 0 {
			let error = "errno:" + String(format:"%d (%s)",errno,(strerror(errno)))
			THLogError("stat != 0 error:\(error)")
			return nil
		}

		return Date(timeIntervalSince1970: Double(statfile.st_mtimespec.tv_sec).rounded(.down))
	}
	
	class func th_fileSize(atPath path: String?) -> Int64? {
		guard let c_path = (path as NSString?)?.fileSystemRepresentation
		else {
			return nil
		}

		var statfile: stat = stat()
		if stat(c_path, &statfile) != 0 {
			let error = "errno:" + String(format:"%d (%s)",errno,(strerror(errno)))
			THLogError("stat != 0 error:\(error)")
			return nil
		}

		return Int64(statfile.st_size)
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------
