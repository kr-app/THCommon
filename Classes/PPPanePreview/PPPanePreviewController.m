// PPPanePreviewController.m

#import "PPPanePreviewController.h"
#import "THFoundation.h"
#import "THLog.h"
#import "TH_APP-Swift.h"

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation PPPanePreviewController

- (BOOL)isVisiblePane
{
	return (_myWindow!=nil && _myWindow.isVisible==YES)?YES:NO;
}

- (void)showWindowAtPoint:(NSPoint)point onScreen:(NSScreen*)screen
{
	if (NSEqualPoints(point,NSZeroPoint)==YES || screen==nil)
	{
		THLogError(@"point==NSZeroPoint || screen==nil");
		return;
	}

	NSRect visibleRect=screen.visibleFrame;
	
	NSSize wMinSize=NSMakeSize(300.0,300.0);
	NSSize wMaxSize=NSMakeSize(2000.0,2000.0);
	
	NSSize frameSize=NSMakeSize(CGFloatFloor((point.x/2.0)),CGFloatFloor(visibleRect.size.height*0.8));
	if (_myWindow!=nil)
		frameSize=_myWindow.frame.size;
	else
	{
		NSString *frameSizeStr=[[NSUserDefaults standardUserDefaults] stringForKey:@"PanePreviewViewController-FrameSize"];
		if (frameSizeStr!=nil)
			frameSize=NSSizeFromString(frameSizeStr);
	}

	if (frameSize.width<wMinSize.width)
		frameSize.width=wMinSize.width;
	if (frameSize.height<wMinSize.height)
		frameSize.width=wMinSize.height;

	if (frameSize.width>(point.x-(visibleRect.origin.x+20.0)))
		frameSize.width=point.x-(visibleRect.origin.x+20.0);
	if (frameSize.height>(visibleRect.size.height-20.0*2.0))
		frameSize.height=visibleRect.size.height-20.0*2.0;

	CGFloat spacePanel=8.0;
	NSRect wFrame=NSMakeRect(point.x-frameSize.width-spacePanel,point.y-CGFloatFloor(frameSize.height/2.0),frameSize.width,frameSize.height);

	CGFloat trianglePosition=CGFloatFloor(wFrame.size.height/2.0);

	if ((wFrame.origin.x)<(visibleRect.origin.x+20.0))
	{
		CGFloat delta=(visibleRect.origin.x-wFrame.origin.x+20.0);
		wFrame.origin.x=visibleRect.origin.x+20.0;
		wFrame.size.width-=CGFloatCeil(delta);
	}

	if (wFrame.origin.y<(visibleRect.origin.y+20.0))
	{
		CGFloat delta=(visibleRect.origin.y+20.0)-wFrame.origin.y;
		trianglePosition-=delta;
		wFrame.origin.y+=delta;
	}
	else if ((wFrame.origin.y+wFrame.size.height+20.0)>(visibleRect.origin.y+visibleRect.size.height))
	{
		CGFloat delta=(wFrame.origin.y+wFrame.size.height+20.0)-(visibleRect.origin.y+visibleRect.size.height);
		trianglePosition+=delta;
		wFrame.origin.y-=delta;
	}

	if (_myWindow==nil)
	{
		_myWindow=[[PPPanePreviewWindow alloc] initWithContentRect:wFrame screen:screen];
		_myWindow.minSize=wMinSize;
		_myWindow.maxSize=wMaxSize;
		_myWindow.delegate=self;
		_myWindow.contentView=self.view;
		//_myWindow.alphaValue=0.0;
	}
	else
	{
		[_myWindow setFrame:wFrame display:YES animate:NO];
	}

	_myWindow.alphaValue=1.0;
	_myWindow.pointAnchor=point;

	[self panePreviewControllerWillShow];
	[_myWindow makeKeyAndOrderFront:nil];

//	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
//	{
//		context.duration=0.15;
//		[(NSWindow*)_myWindow.animator setAlphaValue:1.0];
//	}
//	completionHandler:^
//	{
//	}];
}

- (void)hideWindowAnimated:(BOOL)animated
{
	if (_myWindow==nil || _myWindow.isVisible==NO)
		return;

	[self panePreviewControllerWillHide];
	[[NSUserDefaults standardUserDefaults] setObject:NSStringFromSize(_myWindow.frame.size) forKey:@"PanePreviewViewController-FrameSize"];

	_myWindow.delegate=nil;

	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
	{
		context.duration=0.15;
		[(NSWindow*)_myWindow.animator setAlphaValue:0.0];
	}
	completionHandler:^
	{
		[_myWindow orderOut:nil];
		[self panePreviewControllerDidHide];
	}];
}

#pragma mark: -

- (void)panePreviewControllerWillShow
{
}

- (void)panePreviewControllerWillHide
{
}

- (void)panePreviewControllerDidHide
{
}

@end
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
