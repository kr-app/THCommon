// RssChannel.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate class PubDateConvertor {
	
	private let df_iso = ISO8601DateFormatter()
	private let df_alt0 = DateFormatter(withDateFormat: "E, d MMM yyyy HH:mm:ss Z")
	private let df_alt1 = DateFormatter(withDateFormat: "E, dd MMM yyyy HH:mm:ss zzz")
	private let df_alt2 = DateFormatter(withDateFormat: "E, dd MMM yyyy HH:mm:ss")
	
	private var df_alt2_tz: TimeZone?
	
	func pubDate(from string: String) -> Date? {
		
		if let date = df_iso.date(from: string) {
			return date
		}

		if let date = df_alt0.date(from: string) {
			return date
		}

		if let date = df_alt1.date(from: string) {
			return date
		}

		let nbChars = string.count
		if nbChars > 10 {
			if (string as NSString).range(of: " ", options: .backwards, range: NSRange(nbChars - 4, 4)).location != NSNotFound {
				if df_alt2_tz == nil {
					let tz = (string as NSString).substring(from: nbChars - 3)
					df_alt2.timeZone = TimeZone(abbreviation: tz)
				}
				if let date = df_alt2.date(from: String(string.dropLast(4))) {
					return date
				}
			}
		}

		return nil
	}
	
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
protocol RssChannelDelegate {
	func channel(_ channel: RssChannel, canIncludeItem item: RssChannelItem) -> Bool
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
class RssChannel: THDistantItem, THDictionarySerializationProtocol {

	var creationDate: Date!
	var identifier: String!

	var url: URL!
	private var firstCreation = false

	var title: String?
	var webLink: URL?
	var poster: URL?

	var items: [RssChannelItem] = []

	var pendingSave = false

	// MARK: -

	class func channel(fromFile path: String) -> Self? {
		let channel = Self.th_unarchive(fromDictionaryRepresentationAtPath: path)
		channel?.identifier = path.th_lastPathComponent().th_deletingPathExtension()
		return channel
	}

	// MARK: -
	
	override init() {
		super.init()
		self.creationDate = Date()
		self.identifier = UUID().uuidString
	}

	init(url: URL) {
		super.init()
		self.creationDate = Date()
		self.identifier = UUID().uuidString
		self.url = url
		THLogInfo("created new \(self)")
	}

	override var description: String {
		th_description("host:\(url.th_reducedHost)")
	}
	
	// MARK: -
	
	func save(toDir dirPath: String) -> Bool {
		pendingSave = false

		let path = dirPath.th_appendingPathComponent("\(identifier).plist")

#if DEBUG
		THLogDebug("saving at path:\(path)")
#endif

		if dictionaryRepresentation().write(toFile: path) == false {
			THLogError("dictionaryRepresentation().write == false path:\(path)")
			return false
		}

		return true
	}

	func dictionaryRepresentation() -> THDictionaryRepresentation {

		let coder = THDictionaryRepresentation()

		coder.setDate(creationDate, forKey: "creationDate")
		
		coder.setUrl(url, forKey: "url")
		coder.setDate(lastUpdate, forKey: "lastUpdate")
		coder.setString(lastError, forKey: "lastError")

		coder.setString(title, forKey: "title")
		coder.setUrl(webLink, forKey: "webLink")
		coder.setUrl(poster, forKey: "poster")

		coder.setObjects(items, forKey: "items")

		return coder
	}

	func remove(fromDir dirPath: String) -> Bool {
		let path = dirPath.th_appendingPathComponent("\(identifier).plist")

		if FileManager.default.fileExists(atPath: path) == true {
			if FileManager.default.th_traskItem(at: URL(fileURLWithPath: path)) == false {
				THLogError("th_traskItem == false path:\(path)")
				return false
			}
		}

		return true
	}
	
	// MARK: -
	
	required init(withDictionaryRepresentation dictionaryRepresentation: THDictionaryRepresentation) {
		super.init()

		creationDate = dictionaryRepresentation.date(forKey: "creationDate")
		if creationDate == nil {
			creationDate = dictionaryRepresentation.date(forKey: "createdDate") ?? Date()
		}

		url = dictionaryRepresentation.url(forKey: "url")!
		lastUpdate = dictionaryRepresentation.date(forKey: "lastUpdate")
		lastError = dictionaryRepresentation.string(forKey: "lastError")
		
		title = dictionaryRepresentation.string(forKey: "title")
		webLink = dictionaryRepresentation.url(forKey: "webLink") ?? dictionaryRepresentation.url(forKey: "link")
		poster = dictionaryRepresentation.url(forKey:  "poster")

		items = RssChannelItem.th_objects(fromDictionaryRepresentation: dictionaryRepresentation, forKey: "items")!
	}
	
	// MARK: -

	func unreaded() -> Int {
		var r = 0
		for item in items {
			if item.checkedDate == nil {
				r += 1
			}
		}
		return r
	}

	func hasUnreaded() -> Bool {
		return items.contains(where: {$0.checkedDate == nil })
	}

	func hasRecent(refDate: TimeInterval) -> Bool {
		return items.contains(where: {$0.isRecent(refDate: refDate) })
	}
	
	func contains(stringValue: String) -> Bool {
		for s in [self.url.absoluteString, self.webLink?.absoluteString] {
			if s != nil && s!.contains(stringValue) == true {
				return true
			}
		}		
		return false
	}

	// MARK: -
	
	override func updateRequest() -> URLRequest {
		return URLRequest(url: self.url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15.0)
	}
	
	override func parse(data: Data, withDelegate delegate: Any? = nil) -> String? {

#if DEBUG
		let cachesDir = FileManager.th_appCachesDir("RssChannel")
		let d_path = cachesDir.th_appendingPathComponent("\(identifier).xml")

		if TH_isDebuggerAttached() == true {
			try! data.write(to: URL(fileURLWithPath: d_path))
		}
		else if FileManager.default.fileExists(atPath: d_path) == true {
			try! FileManager.default.removeItem(atPath: d_path)
		}
#endif

		let p = THRSSFeedParser(data: data)
		if p.parse() == false {
			let pe = p.lastError
			return THLocalizedString("Can not parse RSS" + (pe != nil ? " (\(pe))" : ""))
		}

		if let title = p.generalItem.value(named: "title")?.content {
			self.title = title
		}
		if let link = p.generalItem.value(named: "link")?.content {
			self.webLink = URL(string: link)
		}

		var date_error_log_once = false
		var extracted_media_log_once = false
		let pubDateConvertor = PubDateConvertor()
		
		for item in p.items {

			let title = item.value(named: "title")?.content
			let link = item.value(named: "link")?.content
			var content = item.value(named: "description")?.content

			let guid = item.value(named: "guid")?.content
			var mediaUrl = item.value(named: "media:content")?.attributes?["url"] as? String
			let date = item.value(named: "pubDate")?.content

			var pubDate: Date?
			if let date = date {
				pubDate = pubDateConvertor.pubDate(from: date)
				if pubDate == nil && date_error_log_once == false {
					date_error_log_once = true
					THLogError("can not convert date:\(date) for item:\(item)")
				}
			}
			else {
				date_error_log_once = true
				THLogError("can not extract pubDate for item:\(item)")
			}
	
			if mediaUrl == nil {
				if let mUrl = item.value(named: "enclosure")?.attributes?["url"] as? String {

					var take = false

					var type = item.value(named: "enclosure")?.attributes?["type"] as? String
					if type == nil {
						type = item.value(named: "enclosure")?.attributes?["mimetype"] as? String
					}

					if let type = type {
						if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, type as CFString, nil)?.takeRetainedValue() {
							take = UTTypeConformsTo(uti, kUTTypeImage)
						}
					}
					else {
						take = true
					}

					if take == true {
						mediaUrl = mUrl
					}
				}
			}

			if mediaUrl == nil {
				
//				if description?.contains("grimper.com") == true {
//					print("")
//				}

//		"<img src=\"https://www.grimper.com/media/021/05/193968438_10159916305459750_6148016976489071523_n__prop_200x150.jpeg\" style=\"float: left; margin: 10px;\" alt=\"Floating image\" />Les finales de cette nuit ont été pleines de surprises : ce n'est ni un Japonais, ni Adam Ondra (forfait sur blessure), qui gagne chez les hommes tandis que chez les filles Janja Garnbret s'est..."

				if let d = content as NSString?, d.length > 20 {
				
					let r = d.range(of: "<img src=\"", range: NSRange(location: 0, length: "<img src=\"".count))
					if r.location != NSNotFound {
						let srcEnd = d.range(of: "\"", range: NSRange(location: r.location + r.length, length: d.length - (r.location + r.length)))
						if srcEnd.location != NSNotFound {
							let src = d.substring(with: NSRange(location: r.location + r.length, length: srcEnd.location - (r.location + r.length)))
							if URL(string: src) != nil {

								if extracted_media_log_once == false {
									extracted_media_log_once = true
									THLogDebug("mediaUrl:\(mediaUrl) extracted from content text for item:\(item)")
								}
								mediaUrl = src

								let tagEnd = d.range(of: "/>", range: NSRange(location: 0, length: d.length))
								if tagEnd.location != NSNotFound {
									content = d.substring(with: NSRange(location: tagEnd.location + tagEnd.length, length: d.length - (tagEnd.location + tagEnd.length)))
								}
							}
						}
					}
				}
			}
			
			if content?.range(of: "<") != nil {
				if let htmlContent = content {

					var nc  = ""
					var opened = 0
					var charCount = 1
					let maxChars = 300
					
					for (_, ch) in htmlContent.enumerated() {
						if ch == "<" {
							opened += 1
							continue
						}
						if ch == ">" {
							opened -= 1
							continue
						}
						
						if opened > 0 {
							continue
						}

						charCount += 1
						if charCount > maxChars {
							break
						}
						nc += String(ch)
					}
					
	//					let das = try NSAttributedString(		data: c.data(using: .unicode)!,
	//																			options: [.documentType: NSAttributedString.DocumentType.html],
	//																			documentAttributes: nil)
	//					content = das.string
	//				}
	//				catch {
	//					THLogError("can not created attributed string from content:\(c) error: \(error)")
	//				}
					
					content = nc
				}
			}

			guard let identifier = guid ?? link ?? date
			else {
				THLogError("can not obtain identifier for item:\(item)")
				return THLocalizedString("can not obtain item identifier")
			}

			let old_item = items.first(where: { $0.identifier == identifier })

			let item = RssChannelItem()

			item.identifier = identifier

			item.received = old_item?.received ?? Date()
			item.published = old_item?.published ?? pubDate
			item.updated = pubDate
			
			item.title = title
			item.link = link != nil ? URL(string: link!) : nil
			item.content = content

			item.thumbnail = mediaUrl != nil ? URL(string: mediaUrl!) : nil

			if old_item != nil {
				items.removeAll(where: { $0.identifier == identifier })
				item.checkedDate = old_item!.checkedDate
				item.pinned = old_item!.pinned
			}

			if items.first(where: { $0.isLike(item) }) != nil {
				THLogError("found like item for item:\(item)")
				items.removeAll(where: { $0.isLike(item) == true })
			}

//			if onCreation == true {
//				item.checked = true
//			}

			let delegate = delegate as! RssChannelDelegate
			if delegate.channel(self, canIncludeItem: item) == false {
				THLogInfo("excluded item:\(item)")
				continue
			}

			items.append(item)
			items.sort(by: { $0.wallDate >  $1.wallDate })
		}

		let max = 500

		if p.items.count > Int(max / 3) {
			THLogError("received more than 100 items (\(p.items.count))")
		}
	
		// améliorer : limite par temps sur x jours ?
		if items.count > max {
			items.removeLast(items.count - max)
		}
	
		// on error si on à recu des items aucun conservés
		if p.items.count > 0 && items.count == 0 {
			return THLocalizedString("can not parse received items")
		}

		return nil
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
