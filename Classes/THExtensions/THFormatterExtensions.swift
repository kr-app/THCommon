// THFormatterExtensions.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate class DfCache {
	static var numberFormatter_decimal: NumberFormatter?
	static var byteCountFormatter_bin1024: ByteCountFormatter?
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THTodayDateFormatter: DateFormatter {
	private var todayFormatter: DateFormatter!
	private var otherFormatter: DateFormatter?

	private let currentCalendar = Calendar.current

	@objc init(todayFormat: String, otherFormatter: DateFormatter? = nil) {
		super.init()
		self.todayFormatter = todayFormat == "HM" ? DateFormatter.th_HM : DateFormatter.th_HMS
		self.otherFormatter = otherFormatter
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func string(from date: Date) -> String {
		return string(from: date, otherFormatter: otherFormatter!)
	}

	@objc func string(from date: Date, otherFormatter: DateFormatter) -> String {
		if currentCalendar.isDateInToday(date) {
			return THLocalizedString("Today, ") + todayFormatter.string(from: date)
		}
		if currentCalendar.isDateInYesterday(date) {
			return THLocalizedString("Yesterday, ") + todayFormatter.string(from: date)
		}
		return otherFormatter.string(from: date)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension DateFormatter {

	@objc static let th_HM = DateFormatter(dateFormat: "HH:mm")
	@objc static let th_HMS = DateFormatter(dateFormat: "HH:mm:ss")
	@objc static let th_YMD = DateFormatter(dateFormat: "yyyy-MM-dd")
	@objc static let th_YMD_HMS = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss")

	@objc convenience init(dateFormat: String) {
		self.init()
		self.dateFormat = dateFormat
	}

	@objc convenience init(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) {
		self.init()
		self.dateStyle = dateStyle
		self.timeStyle = timeStyle
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@available(macOS 10.15, *)
extension RelativeDateTimeFormatter {
	
	convenience init(withUnitsStyle unitsStyle: RelativeDateTimeFormatter.UnitsStyle) {
		self.init()
		self.unitsStyle = unitsStyle
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension NumberFormatter {

	@objc static let th_decimal: NumberFormatter = { 	let formatter = NumberFormatter()
																					formatter.numberStyle = .decimal
																					return formatter
																				}()

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension ByteCountFormatter {

	@objc static let th_bin1024: ByteCountFormatter = { 	let formatter = ByteCountFormatter()
																						formatter.countStyle = .binary
																						return formatter
																					}()

}
//--------------------------------------------------------------------------------------------------------------------------------------------
