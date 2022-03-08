// PubDateConvertor.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
class PubDateConvertor {
	
	private let df_iso = ISO8601DateFormatter()
	private let df_alt0 = DateFormatter(dateFormat: "E, d MMM yyyy HH:mm:ss Z")
	private let df_alt1 = DateFormatter(dateFormat: "E, dd MMM yyyy HH:mm:ss zzz")
	private let df_alt2 = DateFormatter(dateFormat: "E, dd MMM yyyy HH:mm:ss")
	
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
