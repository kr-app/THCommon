// THFoundation.m

#import "THFoundation.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
CGFloat CGFloatFloor(CGFloat value) { return floor(value); } 	/* arrondi inferieur */
CGFloat CGFloatCeil(CGFloat value) { return ceil(value); }		/* arrondi supperieur */
CGFloat CGFloatRint(CGFloat value) { return rint(value); }		/* arrondi normal */
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
//BOOL TH_IsEqualNSString(NSString *aString, NSString *anotherString)
//{
//	if (aString==anotherString)
//		return YES;
//	if (aString!=nil && anotherString!=nil && CFStringCompare((__bridge CFStringRef)aString,(__bridge CFStringRef)anotherString,0)==kCFCompareEqualTo)
//		return YES;
//	return NO;
//}
//
//BOOL TH_IsEqualNSPoint(NSPoint point, NSPoint anotherPoint, CGFloat tolerance)
//{
//	if (tolerance==0.0)
//		return (point.x==anotherPoint.x && point.y==anotherPoint.y)?YES:NO;
//	CGFloat dX=point.x-anotherPoint.x;
//	CGFloat dY=point.y-anotherPoint.y;
//	return ((dX<=tolerance && dX>=tolerance*-1.0) && (dY<=tolerance && dY>=tolerance*-1.0))?YES:NO;
//}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
//NSColor* TH_RGBACOLOR(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
//{
//	return [NSColor colorWithDeviceRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
//}
//
//NSColor* TH_RGBCOLOR(CGFloat r, CGFloat g, CGFloat b)
//{
//	return [NSColor colorWithDeviceRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
//}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
//id TH_ReturnNilWithMessage(NSString *msg, NSString **pMessage)
//{
//	if (pMessage!=NULL)
//		*pMessage=msg;
//	return nil;
//}

//BOOL TH_ReturnNoWithMessage(NSString *msg, NSString **pMessage)
//{
//	if (pMessage!=NULL)
//		*pMessage=msg;
//	return NO;
//}
//--------------------------------------------------------------------------------------------------------------------------------------------
