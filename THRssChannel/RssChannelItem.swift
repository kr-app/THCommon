// RssChannelItem.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
class RssChannelItem: NSObject, THDictionarySerializationProtocol {
	
	var identifier: String!
	
	var received: Date!
	var published: Date?
	var updated: Date?

	var title: String?
	var link: URL?
	var content: String?

	var thumbnail: URL?

	var checkedDate: Date?
	var checked: Bool { get { return checkedDate != nil } }
	//var readed = false
	var pinned = false
//	var wallDate: Date { get { 	return received/*let d: Date! = published ?? received
//												if let checkedDate = checkedDate {
//													return checkedDate > d ? checkedDate : d
//												}
//												return d*/
//											}}

	var articleImage: RssArticleImage?

	override var description: String {
		th_description("identifier: \(identifier) published: \(published) updated:\(updated) title: \(title?.th_truncate(maxChars: 20, by: .byTruncatingTail))")
	}

	override init() {
	}

	func dictionaryRepresentation() -> THDictionaryRepresentation {
		let coder = THDictionaryRepresentation()

		if identifier == link?.absoluteString {
			coder.setString("LINK", forKey: "identifier")
		}
		else {
			coder.setString(identifier, forKey: "identifier")
		}

		coder.setDate(received, forKey: "received")
		coder.setDate(published, forKey: "published")
		coder.setDate(updated, forKey: "updated")

		coder.setString(title, forKey: "title")
		coder.setUrl(link, forKey: "link")
		coder.setString(content, forKey: "content")

		coder.setUrl(thumbnail, forKey: "thumbnail")

		coder.setDate(checkedDate, forKey: "checkedDate")
//		if readed == true {
//			coder.setBool(readed, forKey: "readed")
//		}
		if pinned == true {
			coder.setBool(pinned, forKey: "pinned")
		}

		return coder
	}

	required init(withDictionaryRepresentation dictionaryRepresentation: THDictionaryRepresentation) {
		identifier = dictionaryRepresentation.string(forKey: "identifier")!

		received = dictionaryRepresentation.date(forKey: "received")
		published = dictionaryRepresentation.date(forKey: "published")
		updated = dictionaryRepresentation.date(forKey: "updated")

		title = dictionaryRepresentation.string(forKey: "title")
		link = dictionaryRepresentation.url(forKey: "link")
		content = dictionaryRepresentation.string(forKey: "content")
	
		thumbnail = dictionaryRepresentation.url(forKey: "thumbnail")

		checkedDate = dictionaryRepresentation.date(forKey: "checkedDate")
		if checkedDate == nil {
			if dictionaryRepresentation.bool(forKey: "unreaded") == nil {
				checkedDate = Date().addingTimeInterval(-1.0.th_day)
			}
		}
		//readed = dictionaryRepresentation.bool(forKey: "readed") ?? false
		pinned = dictionaryRepresentation.bool(forKey: "pinned") ?? false

		if identifier == "LINK" {
			identifier = link!.absoluteString
		}
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension RssChannelItem {

	func isRecent(refDate: TimeInterval) -> Bool {
		if self.received.timeIntervalSinceReferenceDate >= refDate {
			return true
		}
		return false
	}

	func isLike(_ item: RssChannelItem) -> Bool {
		guard let title = self.title, let itemTitle = item.title
		else {
			return false
		}
		if title != itemTitle {
			return false
		}

		if let link = self.link, let itemLink = item.link {
			if link != itemLink {
				return false
			}
		}

		// le contenu (content) peut varié, être tronqué, etc.
	
		return true
	}
	
	func contains(stringValue: String) -> Bool {
		for s in [self.title, self.content, self.link?.absoluteString] {
			if s != nil && s!.range(of: stringValue, options: .caseInsensitive) != nil {
				return true
			}
		}
		return false
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
