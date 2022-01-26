// THHotKeyFieldView.m

#import "THHotKeyFieldView.h"
#import "THFoundation.h"
#import "THLog.h"
#import "TH_APP-Swift.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THHotKeyFieldView

- (BOOL)acceptsFirstResponder { return _isEnabled; }

- (BOOL)becomeFirstResponder { return _isEnabled; }

- (BOOL)resignFirstResponder
{
	_isClicked=NO;
	[self setNeedsDisplay:YES];
	return YES;
}

- (BOOL)canBecomeKeyView { return YES; }

#pragma mark -

- (void)n_windowDidResignMain:(NSNotification*)notification
{
	if (notification.object!=self.window)
		return;

	_isClicked=NO;
	[self setNeedsDisplay:YES];
}

#pragma mark -

- (void)setControlSize:(NSControlSize)controlSize
{
	_controlSize=controlSize;

	if (controlSize==NSControlSizeRegular && self.frame.size.height!=26)
		THLogWarning(@"incorrect frame.height should be 26");
	else if (controlSize==NSControlSizeSmall && self.frame.size.height!=20)
		THLogWarning(@"incorrect frame.height should be 20");

	[self setNeedsDisplay:YES];
}

- (void)setIsEnabled:(BOOL)isEnabled
{
	if (isEnabled==YES && _isEnabled==NO)
	{
		_isEnabled=isEnabled;

		if (_lastStatus==1)
		{
			BOOL isOk=[_changeObserver hotKeyFieldView:self didChangeWithKeyCode:_lastKeyCode modifierFlags:_lastModifierFlags isEnabled:YES];
			self.mesLabel.stringValue=isOk==YES?@"":THLocalizedString(@"Unable to register shortcut.");
		}
		else
		{
			[self.window makeKeyAndOrderFront:nil];
			[self.window makeFirstResponder:self];
		}
	}
	else if (isEnabled==NO && _isEnabled==YES)
	{
		_isEnabled=isEnabled;

		[_changeObserver hotKeyFieldView:self didChangeWithKeyCode:_lastKeyCode modifierFlags:_lastModifierFlags isEnabled:NO];
		[self.window makeFirstResponder:nil];
	}

	[self setNeedsDisplay:YES];
}

- (void)setChangeObserver:(id)changeObserver keyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags isEnabled:(BOOL)isEnabled
{
	if (_hasNotificationInstalled==NO)
	{
		_hasNotificationInstalled=YES;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_windowDidResignMain:) name:NSWindowDidResignMainNotification object:nil];
	}

	_changeObserver=changeObserver;
	_isEnabled=isEnabled;

	NSString *nString=nil;
	NSString *errorMsg=nil;
	NSInteger status=[[THHotKeyCenter shared] registerableStatusOfHotKeyWithKeyCode:keyCode modifierFlags:modifierFlags keyCodeString:&nString errorMsg:&errorMsg];

	_string=status>0?nString:nil;

	_lastStatus=status;
	_lastKeyCode=keyCode;
	_lastModifierFlags=modifierFlags;

	self.mesLabel.stringValue=@"";
	_isOnError=NO;

	[self setNeedsDisplay:YES];
}

#pragma mark -

- (void)mouseDown:(NSEvent *)event
{
	_isOnError=NO;
	if (_isEnabled==NO)
		return;

	_isClicked=!_isClicked;
	[self setNeedsDisplay:YES];
	[super mouseDown:event];
}

- (void)keyDown:(NSEvent*)event
{
	_isOnError=NO;

	if (_isEnabled==NO)
		return;

	if (_isClicked==YES)
	{
		NSUInteger keyCode=event.keyCode;
		NSUInteger modifierFlags=event.modifierFlags;

		NSString *nString=nil;
		NSString *errorMsg=nil;
		NSInteger status=[[THHotKeyCenter shared] registerableStatusOfHotKeyWithKeyCode:keyCode modifierFlags:modifierFlags keyCodeString:&nString errorMsg:&errorMsg];

		_string=status>0?nString:nil;

		_lastStatus=status;
		_lastKeyCode=keyCode;
		_lastModifierFlags=modifierFlags;

		_isOnError=status>0?NO:YES;
		self.mesLabel.stringValue=status==1?@"":errorMsg!=nil?errorMsg:@"?";

		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_dl_keyDownDelayed) object:nil];
		[self performSelector:@selector(_dl_keyDownDelayed) withObject:nil afterDelay:1.0];

		[self setNeedsDisplay:YES];
	}
	else
	{
		if (_string!=nil)
		{
			_string=nil;
			[self setNeedsDisplay:YES];
		}
	}
}

- (void)_dl_keyDownDelayed
{
	self.mesLabel.stringValue=@"";

	if (self.window.isVisible==NO || self.window.alphaValue<1.0)
		return;

	if (_lastStatus==1 && _isEnabled==YES && _isClicked==YES)
	{
		BOOL isOk=[_changeObserver hotKeyFieldView:self didChangeWithKeyCode:_lastKeyCode modifierFlags:_lastModifierFlags isEnabled:YES];
	
		self.mesLabel.stringValue=isOk==YES?@"":THLocalizedString(@"Unable to register shortcut.");
		_isOnError=!isOk;
		[self setNeedsDisplay:YES];
	}
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSSize frameSz=self.frame.size;
	BOOL dark=[[self effectiveAppearance].name isEqualToString:NSAppearanceNameDarkAqua];

	// border
	if (_isEnabled==NO)
		[[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] set];
	else if (_isOnError==YES)
		[[NSColor redColor] set];
	else if (_isClicked==YES)
		[[NSColor colorWithCalibratedWhite:0.4 alpha:1.0] set];
	else
		[[NSColor colorWithCalibratedWhite:0.8 alpha:1.0] set];

	[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0.0,0.0,frameSz.width,frameSz.height) xRadius:4.0 yRadius:4.0] fill];

	// interriour
	[[NSColor colorWithCalibratedWhite:dark==YES?0.0:1.0 alpha:1.0] set];
	[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(2.0,2.0,frameSz.width-4.0,frameSz.height-4.0) xRadius:4.0 yRadius:4.0] fill];

	static NSDictionary *attrs[3]={nil};
	if (attrs[0]==nil)
	{
		NSMutableParagraphStyle *paragraphStyle=[[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		paragraphStyle.alignment=NSTextAlignmentCenter;

		NSFont *font=[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:_controlSize==NSControlSizeSmall?NSControlSizeSmall:NSControlSizeRegular]];
		attrs[0]=@{NSFontAttributeName:font,NSForegroundColorAttributeName:[NSColor blackColor],NSParagraphStyleAttributeName:paragraphStyle};
		attrs[1]=@{NSFontAttributeName:font,NSForegroundColorAttributeName:[NSColor colorWithCalibratedWhite:0.5 alpha:1.0],NSParagraphStyleAttributeName:paragraphStyle};
		attrs[2]=@{NSFontAttributeName:font,NSForegroundColorAttributeName:[NSColor colorWithCalibratedWhite:0.5 alpha:1.0],NSParagraphStyleAttributeName:paragraphStyle};
	}

	NSString *string=_string;
	NSInteger attrIndex=0;
	if (string==nil)
	{
		string=THLocalizedString(@"No Shortcut");
		attrIndex=1;
	}
	if (_isEnabled==NO)
		attrIndex=2;

	NSSize sz=[string sizeWithAttributes:attrs[attrIndex]];
	sz.height=CGFloatCeil(sz.height);

	[string drawInRect:NSMakeRect(0.0,CGFloatFloor((frameSz.height-sz.height)/2.0),frameSz.width,sz.height) withAttributes:attrs[attrIndex]];
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
