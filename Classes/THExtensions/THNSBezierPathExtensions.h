// THNSBezierPathExtensions.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface NSBezierPath (THNSBezierPathExtensions)

+ (NSBezierPath*)th_bezierPathTriangleInRect:(NSRect)rect sens:(NSInteger)sens;

+ (NSBezierPath*)bezierPathWithRoundedRect:(NSRect)frameRect borderLineWidth:(CGFloat)borderLineWidth
								   corners:(NSInteger)corners cornerRadius:(CGFloat)cornerRadius
							 arrowPosition:(NSInteger)arrowPosition arrowSize:(NSSize)arrowSize;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
