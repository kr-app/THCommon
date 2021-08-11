// SfWorkspace.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class SfWorkspace : NSObject, THDictionarySerializationProtocol {

	var identifier: Int = 0
	@objc var name: String!
	var isSelected = false
	var autoCapture = false

	@objc var captures: [SfCapture]?
	@objc var lastCapture: SfCapture? { get { return captures?.first }}
	
	init(identifier: Int, name: String) {
		self.identifier = identifier
		self.name = name
	}

	override var description: String {
		th_description("identifier:\(identifier) name:\(name) captures:\(captures?.count)")
	}

	func dictionaryRepresentation() -> THDictionaryRepresentation {
		let coder = THDictionaryRepresentation()

		coder.setInt(identifier, forKey: "identifier")
		coder.setString(name, forKey: "name")
		coder.setObjects(captures, forKey: "captures")
		coder.setBool(autoCapture, forKey: "autoCapture")

		return coder
	}
	
	required init(withDictionaryRepresentation dictionaryRepresentation: THDictionaryRepresentation) {
		super.init()

		identifier = dictionaryRepresentation.int(forKey: "identifier")!
		name = dictionaryRepresentation.string(forKey: "name")!
		captures = SfCapture.th_objects(fromDictionaryRepresentation: dictionaryRepresentation, forKey: "captures")!
		autoCapture = dictionaryRepresentation.bool(forKey: "autoCapture")!
	}
	
	class func workspace(fromFile path: String) -> SfWorkspace? {
		return Self.th_unarchive(fromDictionaryRepresentationAtPath: path)
	}

	func remove(fromDir dirPath: String) -> Bool {
		let path = dirPath.th_appendingPathComponent("\(name!).plist")
	
		if FileManager.default.fileExists(atPath: path) == true {
			if FileManager.default.th_traskItem(atPath: path) == false {
				THLogError("th_traskItem == false path:\(path)")
				return false
			}
		}
		return true
	}

	func save(toDir dirPath: String) -> Bool {
		let path = dirPath.th_appendingPathComponent("\(name!).plist")
		THLogInfo("saving at :\(path)")

		if dictionaryRepresentation().write(toFile: path) == false {
			THLogError("write == false path:\(path)")
			return false
		}

		return true
	}
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension SfWorkspace {

	func takeCapture(_ safariRef: Int) -> Bool {
		if SfCapture.isRunning {
			return false
		}

		guard let capture = SfCapture.captureCurrentWindows(safariRef)
		else {
			THLogError("capture == nil")
			return false
		}

		if captures == nil {
			captures = []
		}
	
		if capture.isLike(self.lastCapture) {
			THLogInfo("capture == lastCap")
			return true
		}

		let maxCaptures = SfUserPref.shared.maxCaptures ?? SfUserPref.defaultMaxCaptures
		if captures!.count > maxCaptures {
			captures!.removeLast(captures!.count - maxCaptures)
		}

		captures!.append(capture)
		captures!.sort(by: { $0.date > $1.date })

		return true
	}

	func restoreCapture(_ capture: SfCapture?, safariRef: Int) -> Bool {
		if SfCapture.isRunning {
			return false
		}
		
		let capt = capture ?? self.lastCapture ?? SfCapture.emptyCapture()
		if capt.restoreWindows(safariRef, makeEmptyWin: true) == false {
			THLogError("restoreWindows == false capt:(capt)")
			return false
		}

		return true
	}

	func deleteCapture(_ capture: SfCapture) -> Bool {

		let lastCap = lastCapture
		if lastCap == nil || capture.date == lastCap!.date {
			THLogError("capture:\(capture) lastCap:\(lastCap)")
			return false
		}

		captures?.removeAll(where: { $0.date == capture.date })

		return true
	}

	func closeWindows(ofCapture capture: SfCapture?, safariRef: Int) -> Bool {
		if SfCapture.isRunning {
			return false
		}

		let capt = capture ?? self.lastCapture ?? SfCapture.emptyCapture()
		if capt.closeWindows(safariRef) == false {
			THLogError("closeWindows == false capt:\(capt)")
			return false
		}

		return true
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
