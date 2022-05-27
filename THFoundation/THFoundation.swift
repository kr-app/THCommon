// THFoundation.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
#if os(macOS)
typealias TH_NSUI_Image = NSImage
#elseif os(iOS)
typealias TH_NSUI_Image = UIImage
#endif
//-----------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
//func CGFloatFloor(_ value: CGFloat) -> CGFloat { value.rounded(.down) } 	// arrondi inferieur */
//CGFloat CGFloatCeil(CGFloat value) { return ceil(value); }		/* arrondi supperieur */
//CGFloat CGFloatRint(CGFloat value) { return rint(value); }		/* arrondi normal */
//--------------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
func THLocalizedString(_ string: String) -> String {
	NSLocalizedString(string, comment: "")
}

func THLocalizedStringClass(_ classObject: NSObject, _ string: String) -> String {
	NSLocalizedString(string, tableName: classObject.th_className, comment: "")
}

func THLocalizedStringTable(_ table: String, _ string: String) -> String {
	NSLocalizedString(string, tableName: table, comment: "")
}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
#if os(macOS)
func TH_RGBCOLOR(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) -> NSColor {
	NSColor(deviceRed: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
}
#elseif os(iOS)
func TH_RGBCOLOR(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) -> UIColor {
	UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
}
#endif
//-----------------------------------------------------------------------------------------------------------------------------------------
