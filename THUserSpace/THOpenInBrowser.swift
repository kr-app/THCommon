// THOpenInBrowser.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
class THOpenInBrowser {
	static let shared = THOpenInBrowser()

	var browser: String? { didSet {
						UserDefaults.standard.set(browser, forKey: "THOpenInBrowser-browser")
					}}

	private var mBrowsers: [[String: Any]]!
	
	func browsers() -> [[String: Any]] {
		var browsers = [[String: Any]]()

		for br in [	//	["name": "safari", "path": "/Applications/Safari.app"],
							["name": "firefox", "path": "/Applications/Firefox.app"],
							["name": "firefox", "path": ("~/Applications/Firefox.app" as NSString).expandingTildeInPath]] {

			let p = br["path"]! as String
			if FileManager.default.fileExists(atPath: p) == true {
				browsers.append(["name": br["name"]!, "url": URL(fileURLWithPath: p)])
			}
		}
		
		mBrowsers = browsers
		return browsers
	}
	
	init() {
		browser = UserDefaults.standard.string(forKey: "THOpenInBrowser-browser")
		if browser == nil {
			browser = self.browsers().first!["name"] as? String
		}
	}

	func open(url: URL, completion: @escaping (Bool) -> Void) {
		var browser = mBrowsers.first(where: { ($0["name"] as! String) == self.browser })?["url"] as? URL
		if browser == nil {
			browser = mBrowsers.first!["url"] as? URL
		}

		let config = NSWorkspace.OpenConfiguration()

		NSWorkspace.shared.open([url], withApplicationAt: browser!, configuration: config, completionHandler: {(app: NSRunningApplication?, error: Error?) in
			DispatchQueue.main.async {
				completion((app != nil || error == nil) ? true : false)
			}
		})
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
