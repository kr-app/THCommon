// THDictionarySerialization.swift

#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
protocol THDictionaryRepresentationProtocol: NSObject {
	func dictionaryRepresentation() -> THDictionaryRepresentation
}

class THDictionaryRepresentation: NSObject {
	var values = [String: Any]()

	func setObject(_ object: Any?, forKey key: String) {
		values[key] = object
	}

	func setString(_ string: String?, forKey key: String) {
		values[key] = string
	}

	func setDate(_ date: Date?, forKey key: String) {
		values[key] = date
	}

	func setInt(_ int: Int?, forKey key: String) {
		values[key] = int
	}

	func setBool(_ bool: Bool?, forKey key: String) {
		values[key] = bool
	}

	func setUrl(_ url: URL?, forKey key: String) {
		values[key] = url?.absoluteString
	}

#if os(macOS)
	func setNSRect(_ rect: NSRect?, forKey key: String) {
		values[key] = rect == nil ? nil : NSStringFromRect(rect!)
	}
#endif

	func object(forKey key: String) -> Any? {
		return values[key]
	}

	func string(forKey key: String) -> String? {
		return values[key] as? String
	}

	func date(forKey key: String) -> Date? {
		return values[key] as? Date
	}

	func int(forKey key: String) -> Int? {
		return values[key] as? Int
	}
	
	func bool(forKey key: String) -> Bool? {
		return values[key] as? Bool
	}

	func url(forKey key: String) -> URL? {
		let u = values[key] as? String
		return u != nil ? URL(string: u!) : nil
	}

#if os(macOS)
	func nsRect(forKey key: String) -> NSRect? {
		let s = values[key] as? String
		return s != nil ? NSRectFromString(s!) : nil
	}
#endif

	override var description: String {
		th_description("values:\(values)")
	}
	
	func write(toFile path: String) -> Bool {
		let plist = values as NSDictionary
		if plist.write(toFile: path, atomically: true) == false {
			THLogError("writeToFile == false path:\(path)")
			return false
		}
		return true
	}

	override init() {
		super.init()
	}
	
	fileprivate init(values: [String: Any]) {
		self.values = values
	}

	init?(contentsOfFile path: String) {
		super.init()
	
		guard let plist = NSDictionary(contentsOfFile: path)
		else {
			THLogError("contentsOfFile == nil path:\(path)")
			return nil
		}
	
		self.values = plist as! [String: Any]
	}

	func setObjects(_ objects: [THDictionaryRepresentationProtocol]?, forKey key: String) {
		values[key] = objects?.map( { $0.dictionaryRepresentation().values } )
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
protocol THDictionarySerializationProtocol: THDictionaryRepresentationProtocol {
	init(withDictionaryRepresentation dictionaryRepresentation: THDictionaryRepresentation)
}

extension THDictionarySerializationProtocol {

	static func th_unarchive(fromDictionaryRepresentationAtPath path: String) -> Self? {
		if FileManager.default.fileExists(atPath: path) == false {
			return nil
		}

		guard let dictionaryRepresentation = THDictionaryRepresentation(contentsOfFile: path)
		else {
			THLogError("contentsOfFile == nil path:\(path)")
			return nil
		}

		return Self.init(withDictionaryRepresentation: dictionaryRepresentation)
	}

	static func th_objects(fromDictionaryRepresentation dictionaryRepresentation: THDictionaryRepresentation?, forKey key: String) -> [Self]? {
		if let dr = (dictionaryRepresentation?.values[key]) as? [[String: Any]] {
			return dr.map( { Self(withDictionaryRepresentation: THDictionaryRepresentation(values: $0)) } )
		}
		return nil
	}
	
	
}
//--------------------------------------------------------------------------------------------------------------------------------------------
