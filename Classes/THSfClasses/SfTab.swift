// SfTab.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class SfTab : NSObject, THDictionarySerializationProtocol, THLikeComparisonProtocol {

	@objc var url: String?
	@objc var title: String?
	@objc var isEmpty = false

	private var hostUrl: String?

	init(url: String?, title: String?, isEmpty: Bool) {
		self.url = url
		self.title = title
		self.isEmpty = isEmpty
	}
	
	override var description: String {
		th_description("url: \(url) title: \(title)")
	}

	@objc func displayTitle(_ maxLength: CGFloat, withAttrs  attrs: [NSAttributedString.Key: Any]) -> String? {
		if let t = self.title ?? self.url?.th_lastPathComponent() {
			return t.th_truncate(maxLength: maxLength, withAttrs: attrs, by: .byTruncatingTail, substitutor: "")
		}
		return nil
	}

	@objc func host() -> String? {
		if hostUrl == nil && self.url != nil {
			hostUrl = URL(string: self.url!)?.host
		}
		return hostUrl;
	}
	
	override init() {
	}

	func dictionaryRepresentation() -> THDictionaryRepresentation {
		let coder = THDictionaryRepresentation()

		coder.setString(url, forKey: "url")
		coder.setString(title, forKey: "title")
		coder.setBool(isEmpty == true ? isEmpty : nil, forKey: "isEmpty")

		return coder
	}
	
	required init(withDictionaryRepresentation dictionaryRepresentation: THDictionaryRepresentation) {
		super.init()

		url = dictionaryRepresentation.string(forKey: "url")
		title =  dictionaryRepresentation.string(forKey: "title")
		isEmpty = dictionaryRepresentation.bool(forKey: "isEmpty") ?? false
	}

	func isLike(_ other: Any?) -> Bool {
		if let object = other as? SfTab {
			return url == object.url && title == object.title
		}
		return false
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
