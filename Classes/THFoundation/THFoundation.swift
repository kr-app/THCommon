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
func CGFloatFloor(_ value: CGFloat) -> CGFloat { value.rounded(.down) } 	// arrondi inferieur */
//CGFloat CGFloatCeil(CGFloat value) { return ceil(value); }		/* arrondi supperieur */
//CGFloat CGFloatRint(CGFloat value) { return rint(value); }		/* arrondi normal */
//--------------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
func THLocalizedString(_ string: String) -> String {
	return NSLocalizedString(string, comment: "")
}

func THLocalizedStringClass(_ classObject: NSObject, _ string: String) -> String {
	let table = classObject.th_className
	return NSLocalizedString(string, tableName: table, comment: "")
}

func THLocalizedStringTable(_ table: String, _ string: String) -> String {
	return NSLocalizedString(string, tableName: table, comment: "")
}
//-----------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
func TH_isMAS() -> Bool {
	return false
}

func TH_isDebug() -> Bool {
#if DEBUG
	return true
#else
	return false
#endif
}

#if DEBUG
func TH_isDebuggerAttached() -> Bool {
//	static int isAttached=0;

	var info = kinfo_proc()
	var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
	var size = MemoryLayout<kinfo_proc>.stride
	let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
	assert(junk == 0, "sysctl failed")
	return (info.kp_proc.p_flag & P_TRACED) != 0
	
//	if (isAttached==0)
//	{
//		struct kinfo_proc info;
//		size_t info_size=sizeof(info);
//		int name[]={CTL_KERN,KERN_PROC,KERN_PROC_PID,getpid()};
//
//		if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
//			THLogErrorFc(@"sysctl==-1 errno:%d (%s)",errno,strerror(errno));
//			return NO;
//		}
//
//		isAttached=(info.kp_proc.p_flag&P_TRACED)!=0?1:-1;
//	}
//
//	return isAttached==1?YES:NO;
}
#endif
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
#if os(macOS)
func TH_RGBACOLOR(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> NSColor {
	return NSColor(deviceRed: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha > 1.0 ? 1.0 : alpha)
}

func TH_RGBCOLOR(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> NSColor {
	return TH_RGBACOLOR(red, green, blue, 1.0)
}

#elseif os(iOS)
//return [UIColor colorWithRed:(r)/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];

//UIColor* NT_RGBACOLOR(CGFloat r, CGFloat g, CGFloat b, CGFloat alpha)
//{
//return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alpha];
//}
#endif
//-----------------------------------------------------------------------------------------------------------------------------------------
