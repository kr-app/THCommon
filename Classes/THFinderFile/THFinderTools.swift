// THFinderTools.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THFinderTools: NSObject {

	@objc class func displayFinderGetInfo(ofPath path: String) -> Bool {
		if path == nil || FileManager.default.fileExists(atPath: path) == false {
			return false
		}

		var source = ""
		source += "tell application \"Finder\"\n"
		source += "set aPath to POSIX file \"\(path)\"\n"
		source += "open information window of item aPath\n"
		source += "activate\n"
		source += "end tell\n"

		var errorInfo: NSDictionary?
		if NSAppleScript(source: source)?.executeAndReturnError(&errorInfo) == nil {
			THLogError("executeAndReturnError == nil errorInfo:\(errorInfo)")
			return false
		}

		return true
	}

	@objc class func isSystemFilename(_ name: String, mode: Int) -> Bool {
		let c_name = (name as NSString).fileSystemRepresentation
		return THIsFilenameHiddenExcluded(c_name, strlen(c_name), Int32(mode))
	}

	@objc class func isVolumeHiddenFilename(_ name: String) -> Bool {
		let c_name = (name as NSString).fileSystemRepresentation
		return THIsVolumeHiddenFilename(c_name, strlen(c_name))
	}

	@objc class func isVolumeSystemHiddenFilename(_ name: String, mode: Int) -> Bool {
		let c_name = (name as NSString).fileSystemRepresentation
		return THIsVolumeSystemHiddenFilename(c_name, strlen(c_name), Int32(mode))
	}

	@objc class func finderLabels() -> [[String: Any]]? {
		let labels = NSWorkspace.shared.fileLabels
		let colors = NSWorkspace.shared.fileLabelColors

		var results = [[String: Any]]()

		for (idx, label) in labels.dropFirst().enumerated() { // le premier est "None"
			let badge = NSImage(size: NSSize(16.0, 16.0))
			
			badge.lockFocus()
				let bz = NSBezierPath(ovalIn: NSRect(2.0, 2.0, 12.0, 12.0))

				colors[idx].set()
				bz.fill()

				NSColor(calibratedWhite: 0.5, alpha: 0.33).set()
				bz.stroke()
			badge.unlockFocus()

			results.append(["label": label, "badge": badge])
		}

		return results
	}

//	@objc class func iconWithAliasMask(forType type: String) -> NSImage? {
//	private static let aliasMask = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kAliasBadgeIcon))).th_copyAndResize(NSSize(16.0, 16.0))
//
//		let icon = NSWorkspace.shared.icon(forFileType: type).copy() as! NSImage
//		icon.size = NSMakeSize(16.0, 16.0)
//
//		NSImage *result=[[NSImage alloc] initWithSize:NSMakeSize(16.0,16.0)];
//		[result lockFocus];
//			[icon drawAtPoint:NSMakePoint(0.0,0.0) fromRect:NSMakeRect(0.0,0.0,16.0,16.0) operation:NSCompositingOperationSourceOver fraction:1.0];
//			[aliasMask drawAtPoint:NSMakePoint(0.0,0.0) fromRect:NSMakeRect(0.0,0.0,16.0,16.0) operation:NSCompositingOperationSourceOver fraction:1.0];
//		[result unlockFocus];
//
//		return result
//	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
