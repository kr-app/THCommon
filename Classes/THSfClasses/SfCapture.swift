// SfCapture.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class SfCapture: NSObject, THDictionarySerializationProtocol, THLikeComparisonProtocol {

	static var isRunning = false
	
	var safariRef: Int = 0
	@objc var date: Date!
	@objc var windows: [SfWindow]!

	@objc var frontWindow: SfWindow? { get { windows.first } }

	class func captureCurrentWindows(_ safariRef: Int) -> SfCapture? {

		isRunning = true
		let windows = SfWindow.takeWindowsCapture()
		isRunning = false

		if windows == nil {
			THLogError("windows == nil")
			return nil
		}

		return SfCapture(safariRef: safariRef, date: Date(), windows: windows!)
	}

	class func emptyCapture() -> SfCapture {
		return SfCapture(safariRef: 0, date: Date(), windows: [])
	}

	init(safariRef: Int, date: Date, windows: [SfWindow]) {
		self.safariRef = safariRef
		self.date = date
		self.windows = windows
	}

	override var description: String {
		th_description("safariRef:\(safariRef) date:\(date) windows:\(windows)")
	}

	func restoreWindows(_ safariRef: Int, makeEmptyWin: Bool) -> Bool {
		if safariRef == 0 || windows == nil {
			THLogError("safariRef == 0 || safari != 0 || windows == nil")
			return false
		}

		var allInfos = ""
		for window in windows {

			var bounds = "null"
			if let wbRect = window.boundsRect {
				if wbRect != .zero && (wbRect.size.height - wbRect.origin.y > 20.0) && (wbRect.size.width - wbRect.origin.x) > 20.0 {
					let i = [wbRect.origin.x, wbRect.origin.y, wbRect.size.width, wbRect.size.height]
					let s = i.map({ String(Int($0)) })
					bounds = "{" + s.joined(separator: ", ") + "}"
				}
			}

			if window != self.windows[0] {
				allInfos += ", "
			}

			let wId = safariRef == self.safariRef ? window.wId : 0
//			allInfos += "{%ld, %ld, %@, %d, %ld, {",wId,window.position,bounds,window.isMiniatuzied==YES?1:0,window.selectedTab];

			// window-info
			let wi: [String] = [	String(wId),
										String(window.position),
										bounds,
										String(Int(window.miniatuzied ? 1 : 0)),
										String(window.selectedTab) ]
			allInfos += "{" + wi.joined(separator: ", ")

			// window-tabs
			let tw = window.tabs!.map({ "\"" + ($0.url ?? "") + "\"" })
			allInfos += ", {" + tw.joined(separator: ", ") + "}"
		
			allInfos += "}"
		}

		let makeWin = (makeEmptyWin == true && self.windows.count == 0) ? "true" :  "false"
		let source = NSString(format: SfScript.source_RestoreSwitch() as NSString, allInfos, makeWin)

		Self.isRunning = true
		let script = THAsScript(name: "RestoreSwitch", source: source as String)
		let aed = script.execute(forRunner: self.th_className)
		Self.isRunning = false

		if aed == nil || aed!.int32Value != 1 {
			THLogError("aed == nil || aed.int32Value != 1")
			return false
		}

		return true
	}

	func closeWindows(_ safariRef: Int) -> Bool {
		if safariRef == 0 || safariRef != self.safariRef {
			return true
		}

		let allInfos = windows!.map({ String($0.wId) }).joined(separator: ", ")
		
		Self.isRunning = true
		let source = NSString(format: SfScript.source_DeleteWindows() as NSString, allInfos)
		let script = THAsScript(name: "DeleteWindows", source: source as String)
		let aed = script.execute(forRunner: self.th_className)
		Self.isRunning = false

		if aed == nil || aed!.int32Value != 1 {
			THLogError("aed == nil || aed.int32Value != 1")
			return false
		}
	
		return true
	}

	func dictionaryRepresentation() -> THDictionaryRepresentation {
		let coder = THDictionaryRepresentation()

		coder.setInt(safariRef, forKey: "safariRef")
		coder.setDate(date, forKey: "date")
		coder.setObjects(windows, forKey: "windows")

		return coder
	}
	
	required init(withDictionaryRepresentation dictionaryRepresentation: THDictionaryRepresentation) {
		super.init()

		safariRef = dictionaryRepresentation.int(forKey: "safariRef")!
		date = dictionaryRepresentation.date(forKey: "date")!
		windows = SfWindow.th_objects(fromDictionaryRepresentation: dictionaryRepresentation, forKey: "windows")!
	}

	func isLike(_ other: Any?) -> Bool {
		if let object = other as? SfCapture {
			return windows.isLike(object.windows)
		}
		return false
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
