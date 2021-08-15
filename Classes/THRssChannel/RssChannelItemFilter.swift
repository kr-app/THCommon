// RssChannelFilter.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
enum RssChannelFilterStringMode: Int {
	case begin = 1
	case contains = 2
}

struct RssChannelFilterString : THDictionarySerializationProtocol {
	let mode: RssChannelFilterStringMode
	let string: String
	
	init(mode: RssChannelFilterStringMode, string: String) {
		self.mode = mode
		self.string = string.lowercased()
	}
	
	func dictionaryRepresentation() -> THDictionaryRepresentation {
		let coder = THDictionaryRepresentation()
		coder.setInt(mode.rawValue, forKey: "mode")
		coder.setString(string, forKey: "string")
		return coder
	}

	init(withDictionaryRepresentation dictionaryRepresentation: THDictionaryRepresentation) {
		mode = RssChannelFilterStringMode(rawValue: dictionaryRepresentation.int(forKey: "mode")!)!
		string = dictionaryRepresentation.string(forKey: "string")!
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
enum RssChannelFilterKind: Int {
	case exclude = 1
}

struct RssChannelFilter: THDictionarySerializationProtocol {
	var kind: RssChannelFilterKind = .exclude
	let host: String?
	let title: RssChannelFilterString

	static func filters(fromFile file: String) -> [Self]? {
		if FileManager.default.fileExists(atPath: file) == false {
			return nil
		}

		guard let rep = THDictionaryRepresentation(contentsOfFile: file)
		else {
			THLogError("rep == nil file:\(file)")
			return nil
		}

		guard let filters = RssChannelFilter.th_objects(fromDictionaryRepresentation: rep, forKey: "filters")
		else {
			THLogError("filters == nil file:\(file)")
			return nil
		}

		return filters
	}
	
	static func saveFilters(filters: [RssChannelFilter], toFile file: String) -> Bool {
		let rep = THDictionaryRepresentation()
		rep.setObjects(filters, forKey: "filters")
		return rep.write(toFile: file)
	}

	init(host: String? = nil, title: RssChannelFilterString) {
		self.host = host
		self.title = title
	}

	func match(withHost channelHost: String, itemTitle: String) -> Bool {

		if let host = self.host {
			if channelHost.contains(host) == false {
				return false
			}
		}

		let itmTitle = itemTitle.lowercased()
		let filter = self.title
	
		if filter.mode == .begin && itmTitle.hasPrefix(filter.string) == true {
			return true
		}
		if filter.mode == .contains && itmTitle.contains(filter.string) == true {
			return true
		}
	
		return false
	}
	
	func dictionaryRepresentation() -> THDictionaryRepresentation {
		let coder = THDictionaryRepresentation()
		coder.setInt(kind.rawValue, forKey: "kind")
		coder.setString(host, forKey: "host")
		coder.setDictionaryRepresentation(title.dictionaryRepresentation(), forKey: "title")
		return coder
	}

	init(withDictionaryRepresentation dictionaryRepresentation: THDictionaryRepresentation) {
		kind = RssChannelFilterKind(rawValue: dictionaryRepresentation.int(forKey: "kind")!)!
		host = dictionaryRepresentation.string(forKey: "host")
		title = RssChannelFilterString(withDictionaryRepresentation: dictionaryRepresentation.dictionaryRepresentation(forKey: "title")!)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
