// THNSBezierPathExtensions.m

#import "THNSBezierPathExtensions.h"
#import "THFoundation.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation NSBezierPath (THNSBezierPathExtensions)

+ (NSBezierPath*)th_bezierPathTriangleInRect:(NSRect)rect sens:(NSInteger)sens
{
	NSBezierPath *bz=[NSBezierPath bezierPath];
	if (sens=='t' || sens=='T')
	{
		[bz moveToPoint:NSMakePoint(rect.origin.x,rect.origin.y)];
		[bz lineToPoint:NSMakePoint(rect.origin.x+(rect.size.height/2.0),rect.origin.y+rect.size.height)];
		[bz lineToPoint:NSMakePoint(rect.origin.x+rect.size.width,rect.origin.y)];
		[bz closePath];
	}
	else if (sens=='r' || sens=='R')
	{
		[bz moveToPoint:NSMakePoint(rect.origin.x,rect.origin.y+rect.size.height)];
		[bz lineToPoint:NSMakePoint(rect.origin.x+rect.size.width,rect.origin.y+(rect.size.height/2.0))];
		[bz lineToPoint:NSMakePoint(rect.origin.x,rect.origin.y)];
		[bz closePath];
	}
	else if (sens=='b' || sens=='B')
	{
		[bz moveToPoint:NSMakePoint(rect.origin.x,rect.origin.y+rect.size.height)];
		[bz lineToPoint:NSMakePoint(rect.origin.x+rect.size.width,rect.origin.y+rect.size.height)];
		[bz lineToPoint:NSMakePoint(rect.origin.x+(rect.size.width/2.0),rect.origin.y)];
		[bz closePath];
	}
	return bz;
}

+ (NSBezierPath*)bezierPathWithRoundedRect:(NSRect)frameRect borderLineWidth:(CGFloat)borderLineWidth
								   corners:(NSInteger)corners cornerRadius:(CGFloat)cornerRadius
							 arrowPosition:(NSInteger)arrowPosition arrowSize:(NSSize)arrowSize
{
	CGFloat margin=0.0;
	NSRect rect=NSMakeRect(frameRect.origin.x+margin,frameRect.origin.y+margin,frameRect.size.width-margin*2.0,frameRect.size.height-margin*2.0);
	
	CGFloat moitPtX=rect.origin.x+CGFloatFloor(rect.size.width/2.0);
	CGFloat moitPtY=rect.origin.y+CGFloatFloor((rect.size.height-arrowSize.height)/2.0);
	
	NSBezierPath *bezierPath=[NSBezierPath bezierPath];
	if (borderLineWidth>0.0)
		bezierPath.lineWidth=borderLineWidth;
	
	/* | */
	[bezierPath moveToPoint:NSMakePoint(rect.origin.x,moitPtY)];

	/* / */
	NSPoint pt1=NSMakePoint(rect.origin.x,rect.origin.y+rect.size.height-arrowSize.height);
	NSPoint pt2=NSMakePoint(moitPtX-arrowSize.width/2.0,rect.origin.y+rect.size.height-arrowSize.height);
	[bezierPath appendBezierPathWithArcFromPoint:pt1 toPoint:pt2 radius:cornerRadius];
	
	/* ^ */
	[bezierPath lineToPoint:NSMakePoint(moitPtX-arrowSize.width/2.0,rect.origin.y+rect.size.height-arrowSize.height)];
	[bezierPath lineToPoint:NSMakePoint(moitPtX,rect.origin.y+rect.size.height)];
	[bezierPath lineToPoint:NSMakePoint(moitPtX+arrowSize.width/2.0,rect.origin.y+rect.size.height-arrowSize.height)];
	
	/* \ */
	pt1=NSMakePoint(rect.origin.x+rect.size.width,rect.origin.y+rect.size.height-arrowSize.height);
	pt2=NSMakePoint(rect.origin.x+rect.size.width,moitPtY);
	[bezierPath appendBezierPathWithArcFromPoint:pt1 toPoint:pt2 radius:cornerRadius];
	
	/* | */
	[bezierPath lineToPoint:NSMakePoint(rect.origin.x+rect.size.width,moitPtY)];
	
	/* / */
	pt1=NSMakePoint(rect.origin.x+rect.size.width,rect.origin.y);
	pt2=NSMakePoint(moitPtX,rect.origin.y);
	[bezierPath appendBezierPathWithArcFromPoint:pt1 toPoint:pt2 radius:cornerRadius];
	
	/* \ */
	pt1=NSMakePoint(rect.origin.x,rect.origin.y);
	pt2=NSMakePoint(rect.origin.x,moitPtY);
	[bezierPath appendBezierPathWithArcFromPoint:pt1 toPoint:pt2 radius:cornerRadius];
	
	[bezierPath closePath];
	
	return bezierPath;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
