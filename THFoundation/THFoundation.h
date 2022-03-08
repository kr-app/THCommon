// THFoundation.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
#define THLocalizedString(_key_) 										NSLocalizedStringFromTable(_key_,nil,nil)
#define THLocalizedStringTable(_table_,_key_) 				NSLocalizedStringFromTable(_key_,_table_,nil)
#define THLocalizedStringClass(_key_) 							NSLocalizedStringFromTable(_key_,NSStringFromClass([self class]),nil)

#define THLocalizedStringFormat(_key_,...) 						[NSString stringWithFormat:THLocalizedString((_key_)),##__VA_ARGS__]
#define THLocalizedStringFormatTable(_table_,_key_,...)	[NSString stringWithFormat:THLocalizedStringTable(_table_,(_key_)),##__VA_ARGS__]
//#define THLocalizedStringFormatClass(_key_,...) 				[NSString stringWithFormat:THLocalizedStringClass((_key_)),##__VA_ARGS__]
//--------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------------------------
CGFloat CGFloatFloor(CGFloat value);		/* arrondi inferieur */
CGFloat CGFloatCeil(CGFloat value);		/* arrondi supperieur */
CGFloat CGFloatRint(CGFloat value);		/* arrondi normal */
//--------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------------------------
BOOL TH_IsEqualNSString(NSString *aString, NSString *anotherString);
BOOL TH_IsEqualNSPoint(NSPoint point, NSPoint anotherPoint, CGFloat tolerance);
//--------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------------------------
NSColor* TH_RGBACOLOR(CGFloat r, CGFloat g, CGFloat b, CGFloat a);
NSColor* TH_RGBCOLOR(CGFloat r, CGFloat g, CGFloat b);
//--------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------------------------
//id TH_ReturnNilWithMessage(NSString *msg, NSString **pMessage);
BOOL TH_ReturnNoWithMessage(NSString *msg, NSString **pMessage);
//--------------------------------------------------------------------------------------------------------------------------------------------
