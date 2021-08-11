// SfUserPref.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
class SfUserPref {
	static let shared = SfUserPref()

	static let defaultRefreshInterval: TimeInterval = 60.0
	static let defaultMaxCaptures = 250

	var refreshInterval: TimeInterval?
	var maxCaptures: Int?

	init() {
		self.loadFromUserDefaults()
	}
	
	private func loadFromUserDefaults() {
		let ud = UserDefaults.standard

		refreshInterval = ud.object(forKey: "refreshInterval") != nil ? TimeInterval(ud.integer(forKey: "refreshInterval")) : nil
		maxCaptures = ud.object(forKey: "maxCaptures") != nil ? ud.integer(forKey: "maxCaptures") : nil
	}

	func synchronize() {
		let ud = UserDefaults.standard

		ud.set((refreshInterval != nil && refreshInterval! > 0.0) ? refreshInterval! : nil, forKey: "refreshInterval")
		ud.set((maxCaptures != nil && maxCaptures! > 0) ? maxCaptures!: nil, forKey: "maxCaptures")
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
