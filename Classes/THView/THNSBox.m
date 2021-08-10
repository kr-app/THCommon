// THNSBox.m

#import "THNSBox.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THNSBox

- (BOOL)isEnabled { return _isEnabled ; }

- (void)setEnabled:(BOOL)isEnabled
{
	// On ne change pas si "pareil" sauf la premiere fois
	if (_isEnabled==isEnabled && (_flags&1)!=0)
		return;

	 if ((_flags&1)==0)
		 _flags|=1;

	_isEnabled=isEnabled;
	[self updateControls:self];
}

- (void)updateControls:(NSView*)view
{
	for (NSControl *subControl in view.subviews)
	{
		if ([subControl respondsToSelector:@selector(setEnabled:)]==YES)
			[subControl setEnabled:_isEnabled];
		[self updateControls:subControl];
	}
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THNSBoxHighlightable_FadeView

- (void)setIsPressed:(BOOL)isPressed
{
	if (_isPressed!=isPressed)
	{
		_isPressed=isPressed;
		[self setNeedsDisplay:YES];
	}
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSSize frameSz=self.frame.size;
	[[NSColor colorWithCalibratedWhite:0.0 alpha:_isPressed==YES?0.10:0.05] set];
	[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(2.0,2.0,frameSz.width-3.0*2.0,frameSz.height-(2.0*2.0)-0.0) xRadius:8.0 yRadius:8.0] fill];
}

@end

@implementation THNSBoxHighlightable

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self p_updateTrackingArea];
}

- (void)updateTrackingAreas
{
	[super updateTrackingAreas];
	[self p_updateTrackingArea];
}

- (void)p_updateTrackingArea
{
	if (_trackingArea!=nil)
	{
		[self removeTrackingArea:_trackingArea];
		_trackingArea=nil;
	}
	
	NSSize frameSz=self.frame.size;
	NSTrackingAreaOptions options=		NSTrackingMouseEnteredAndExited|
																				NSTrackingActiveInKeyWindow|
																				NSTrackingAssumeInside;
	_trackingArea=[[NSTrackingArea alloc] initWithRect:NSMakeRect(0.0,0.0,frameSz.width,frameSz.height) options:options owner:self userInfo:nil];
	[self addTrackingArea:_trackingArea];
}

- (void)setHasFadeView:(BOOL)hasView animated:(BOOL)animated
{
	if (hasView==YES && _fadeView==nil)
	{
		_fadeView=[[THNSBoxHighlightable_FadeView alloc] initWithFrame:self.bounds];
		_fadeView.alphaValue=0.0;
		[self addSubview:_fadeView];

		_isFading=YES;
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext* context)
		{
			context.duration=0.2;
			[(NSView*)_fadeView.animator setAlphaValue:1.0];
		}
		completionHandler:^(void)
		{
			_isFading=NO;
		}];
	}
	else if (hasView==NO && _fadeView!=nil)
	{
		_isDefading=YES;
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext* context)
		{
			context.duration=0.2;
			[(NSView*)_fadeView.animator setAlphaValue:0.0];
		}
		completionHandler:^(void)
		{
			_isDefading=NO;
			[_fadeView removeFromSuperview];
			_fadeView=nil;
		}];
	}
}

- (void)mouseEntered:(NSEvent*)event
{
	[super mouseEntered:event];

	if (self.frame.size.height<150.0)
	{
		[self setHasFadeView:YES animated:YES];
	}
}

- (void)mouseExited:(NSEvent*)event
{
	[super mouseExited:event];
	[self setHasFadeView:NO animated:YES];
}

- (void)setTargetor:(id)targetor
{
	_targetor=targetor;
}

- (void)mouseDown:(NSEvent*)event
{
	if ([self alphaValue]<1.0)
		return;

	_downPoint=[self convertPoint:[event locationInWindow] fromView:nil];
	_winPosition=self.window.frame.origin;

	[self setHasFadeView:YES animated:YES];
	[_fadeView setIsPressed:YES];

	[super mouseDown:event];
}

- (void)mouseUp:(NSEvent *)event
{
	[self setHasFadeView:NO animated:YES];

	NSPoint pt=[self convertPoint:[event locationInWindow] fromView:nil];
	NSPoint downPoint=_downPoint;
	NSPoint winPosition=_winPosition;

	_downPoint=NSZeroPoint;
	_winPosition=NSZeroPoint;

	if (TH_IsEqualNSPoint(pt,downPoint,3.0)==YES && NSEqualPoints(winPosition,self.window.frame.origin))
		[_targetor boxHighlightableClicked:self];

	[super mouseUp:event];
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
