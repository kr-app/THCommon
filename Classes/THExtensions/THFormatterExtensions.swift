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

	@objc init(withTodayFormat todayFormat: String, otherFormatter: DateFormatter? = nil) {
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

	@objc static let th_HM = DateFormatter(withDateFormat: "HH:mm")
	@objc static let th_HMS = DateFormatter(withDateFormat: "HH:mm:ss")
	@objc static let th_YMD = DateFormatter(withDateFormat: "yyyy-MM-dd")
	@objc static let th_YMD_HMS = DateFormatter(withDateFormat: "yyyy-MM-dd HH:mm:ss")

	@objc convenience init(withDateFormat dateFormat: String) {
		self.init()
		self.dateFormat = dateFormat
	}

	@objc convenience init(withDateStyle dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) {
		self.init()
		self.dateStyle = dateStyle
		self.timeStyle = timeStyle
	}

	@objc convenience init(withDateFormat_HMS dateFormat: String) {
		self.init()
		self.dateFormat = dateFormat
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

//	@objc class func th_string_decimal(from number: NSNumber?) -> String? {
//		if DfCache.numberFormatter_decimal == nil {
//			DfCache.numberFormatter_decimal = NumberFormatter()
//			DfCache.numberFormatter_decimal?.numberStyle = .decimal
//		}
//		return number == nil ? nil : DfCache.numberFormatter_decimal!.string(from: number!)
//	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension ByteCountFormatter {

	@objc class func th_string_bin1024(from byteCount: Int64) -> String? {
		if DfCache.byteCountFormatter_bin1024 == nil {
			DfCache.byteCountFormatter_bin1024 = ByteCountFormatter()
			DfCache.byteCountFormatter_bin1024?.countStyle = .binary
		}
		return DfCache.byteCountFormatter_bin1024!.string(fromByteCount: byteCount)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
