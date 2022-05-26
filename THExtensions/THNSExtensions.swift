// THNSExtensions.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
extension NSParagraphStyle {

	@objc class func th_paragraphStyle(withAlignment alignment: NSTextAlignment) -> NSParagraphStyle {
		let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		paragraphStyle.alignment = alignment
		return paragraphStyle
	}

	@objc class func th_paragraphStyle(withLineBreakMode lineBreakMode: NSLineBreakMode) -> NSParagraphStyle {
		let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		paragraphStyle.lineBreakMode = lineBreakMode
		return paragraphStyle
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------
