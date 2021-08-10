// SfWindow.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class SfWindow: NSObject, THDictionarySerializationProtocol, THLikeComparisonProtocol {

	@objc static let genericIcon16 = NSImage(named: "SfWindowIcon")?.th_copyAndResize(NSSize(16.0, 16.0))

	var wId: Int = 0
	@objc var position: Int = 0
	var boundsRect: NSRect?
	var miniatuzied = false
	@objc var tabs: [SfTab]!
	var selectedTab: Int = 0 // 1 based. premier == 1, dernier == 4 quand il y a 4 tabs.

	class func takeWindowsCapture() -> [SfWindow]? {
		var script = THAsScriptManager.shared.script(named: "TakeSnapshot")
		if script == nil {
			let source = SfScript.source_TakeSnapshot()
			script = THAsScriptManager.shared.addScript(withSource: source, forName: "TakeSnapshot")
		}

		guard let aed = script?.execute(forRunner: self.th_className)
		else {
			THLogError("aed == nil")
			return nil
		}

		var windows = [SfWindow]()

		for aedIdx in 0..<aed.numberOfItems {
			guard let aedWin = aed.atIndex(aedIdx + 1), aedWin.numberOfItems == 6
			else {
				THLogError("aedWin == nil || aedWin.numberOfItems != 6")
				return nil;
			}

			let wId = Int(aedWin.atIndex(1)!.int32Value)
			let position = Int(aedWin.atIndex(2)!.int32Value)
			let boundsAed = aedWin.atIndex(3)!
			let miniatuzied = aedWin.atIndex(4)!.booleanValue
			let selectedTab = Int(aedWin.atIndex(5)!.int32Value)
			let wTabsAed = aedWin.atIndex(6)!

			var boundsRect: NSRect?
			if boundsAed.numberOfItems == 4 {
				// bounds/rectange px min (left right), py min (top), px max (right), py max (bottom)
				boundsRect = NSRect(	CGFloat(boundsAed.atIndex(1)!.int32Value),
														CGFloat(boundsAed.atIndex(2)!.int32Value),
														CGFloat(boundsAed.atIndex(3)!.int32Value),
														CGFloat(boundsAed.atIndex(4)!.int32Value))
			}

			var tabs = [SfTab]()
			for tabIndex in 1...wTabsAed.numberOfItems {
				let tabAed = wTabsAed.atIndex(tabIndex)!
				THFatalError(tabAed.numberOfItems != 2, "tabAed.numberOfItems!=2")

				let title = tabAed.atIndex(1)!.stringValue
				let url = tabAed.atIndex(2)!.stringValue // url NULL si un onglet est en cours de chargement...

				var isEmpty = false
				if title != nil && url == nil && title == "Untitled" {
					isEmpty = true
				}

				if url == nil && isEmpty == false {
					THLogError("url == nil title:\(title)")
				}

				let tab = SfTab(url: url, title: title, isEmpty: isEmpty)
				tabs.append(tab)
			}

			let wsWindow = SfWindow()
			wsWindow.wId = wId
			wsWindow.position = position
			wsWindow.boundsRect = boundsRect
			wsWindow.miniatuzied = miniatuzied
			wsWindow.tabs = tabs
			wsWindow.selectedTab = selectedTab

			windows.append(wsWindow)
		}

		return windows.sorted(by: { $0.position < $1.position })
	}

	override var description: String {
		let tabs = self.tabs.map( { $0.title })
		return th_description("wId:\(wId) position:\(position) boundsRect:\(boundsRect) miniatuzied:\(miniatuzied) selectedTab:\(selectedTab) tabs:\(tabs)")
	}

	override init() {
		super.init()
	}

	func dictionaryRepresentation() -> THDictionaryRepresentation {
		let coder = THDictionaryRepresentation()

		coder.setInt(wId, forKey: "wId")
		coder.setInt(position, forKey: "position")
		coder.setNSRect(boundsRect, forKey: "boundsRect")
		if miniatuzied == true {
			coder.setBool(miniatuzied, forKey: "miniatuzied")
		}
		coder.setInt(selectedTab, forKey: "selectedTab")
		coder.setObjects(tabs, forKey: "tabs")

		return coder
	}
	
	required init(withDictionaryRepresentation dictionaryRepresentation: THDictionaryRepresentation) {
		super.init()

		wId = dictionaryRepresentation.int(forKey: "wId")!
		position = dictionaryRepresentation.int(forKey: "position")!
		boundsRect = dictionaryRepresentation.nsRect(forKey: "boundsRect")
		miniatuzied = dictionaryRepresentation.bool(forKey: "miniatuzied") ?? false
		selectedTab = dictionaryRepresentation.int(forKey: "selectedTab")!
		tabs = SfTab.th_objects(fromDictionaryRepresentation: dictionaryRepresentation, forKey: "tabs")!
	}

	@objc func visibleTab() -> SfTab? {
		let selected = selectedTab - 1
		return (selected >= 0 && tabs != nil && selected < tabs!.count) ? tabs![selected] : nil
	}

	func isLike(_ other: Any?) -> Bool {
		if let object = other as? SfWindow {
			return wId == object.wId && selectedTab == object.selectedTab && tabs.isLike(object.tabs)
		}
		return false
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
