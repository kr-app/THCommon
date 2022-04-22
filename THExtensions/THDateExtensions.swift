// THDateExtensions.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
extension DateComponents {

	init(withYear year: Int, month: Int, day: Int) {
		self = Self.init()
		self.year = year
		self.month = month
		self.day = day
	}

	init(withHour hour: Int, min: Int, sec: Int) {
		self = Self.init()
		self.hour = hour
		self.minute = min
		self.second = sec
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension Calendar {

	func th_midnight(of date: Date) -> Date {
		self.date(from: self.dateComponents([.year, .month, .day], from: date))!
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------
