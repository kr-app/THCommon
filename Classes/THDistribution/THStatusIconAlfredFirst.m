// THStatusIconAlfredFirst.m

#import "THStatusIconAlfredFirst.h"
#import "THFoundation.h"
#import "THNSBezierPathExtensions.h"
#import "TH_APP-Swift.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface AlfredFirstView : NSView
@property (nonatomic,strong) NSTextField *textField;
@end

@implementation AlfredFirstView

- (id)initWithFrame:(NSRect)frameRect
{
	if (self=[super initWithFrame:frameRect])
	{
		self.textField=[NSTextField th_labelWithFrame:NSMakeRect(20.0, 20.0, frameRect.size.width, 17.0) controlSize:NSControlSizeRegular];
		self.textField.autoresizingMask=NSViewMaxXMargin|NSViewMaxYMargin;
		self.textField.lineBreakMode=NSLineBreakByTruncatingTail;
		[self addSubview:self.textField];
	}
	return self;
}

- (void)setLabel:(NSAttributedString*)label andResize:(BOOL)resize
{
	NSTextField *textField=self.textField;

	textField.attributedStringValue=label;
	[textField th_sizeToFitWidthOnlyWithAlignment:NSTextAlignmentLeft];

	[self setFrameSize:NSMakeSize(textField.frame.size.width+textField.frame.origin.x*2.0, self.frame.size.height)];
}

- (void)drawRect:(NSRect)dirtyRect
{
	BOOL isDark=[self.effectiveAppearance.name isEqualToString:NSAppearanceNameDarkAqua];

	NSSize arrowSize=NSMakeSize(20.0,12.0);
	NSBezierPath *bezierPath=[NSBezierPath bezierPathWithRoundedRect:self.bounds
																	borderLineWidth:0.0
																	corners:0
																	cornerRadius:6.0
																	arrowPosition:1
																	arrowSize:arrowSize];

	[[NSColor colorWithCalibratedWhite:isDark?0.0:1.0 alpha:isDark?0.5:1.0] set];
	[bezierPath fill];
}

- (void)mouseDown:(NSEvent *)event
{
	[self.window.delegate performSelector:@selector(hide) withObject:nil];
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THStatusIconAlfredFirst

+ (BOOL)needsDisplayAlfredFirst
{
#ifdef DEBUG
	//return YES;
#endif
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"THStatusIconAlfredFirst:0"]==NO)
		return YES;
	return NO;
}

+ (void)setNeedsDisplayAlfredFirst:(BOOL)needsDisplayAlfredFirst
{
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"THStatusIconAlfredFirst:0"];
}

+ (THStatusIconAlfredFirst*)sharedInstance:(BOOL)allowCreation
{
	static THStatusIconAlfredFirst *shared=nil;
	if (shared==nil && allowCreation)
		shared=[[THStatusIconAlfredFirst alloc] init];
	return shared;
}

+ (void)showAtPosition:(CGFloat)position onScreen:(NSScreen*)screen
{
	[[self sharedInstance:YES] showAtPosition:position onScreen:screen];
}

+ (void)hide
{
	[[self sharedInstance:NO] hide];
}

- (void)dealloc
{
	if (_myWindow!=nil)
	{
		[_myWindow orderOut:nil];
		_myWindow=nil;
	}
}

- (void)showAtPosition:(CGFloat)position onScreen:(NSScreen*)screen
{
	if (_myWindow!=nil || position==0.0 || screen==nil)
		return;
	
	AlfredFirstView *alfredFirstView=[[AlfredFirstView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 480.0, 67.0)];
	_view=alfredFirstView;

	BOOL isDark=[[NSApplication sharedApplication].effectiveAppearance.name isEqualToString:NSAppearanceNameDarkAqua];

	NSColor *tColor=[NSColor colorWithCalibratedWhite:isDark==YES?1.0:0.0 alpha:1.0];

	NSDictionary *b_attrs=@{	NSFontAttributeName:[NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeRegular]],
												NSForegroundColorAttributeName:tColor};
	NSMutableAttributedString *mas=[[NSMutableAttributedString alloc] initWithString:[THRunningApp appName] attributes:b_attrs];

	NSDictionary *attrs=@{	NSFontAttributeName:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeRegular]],
											NSForegroundColorAttributeName:tColor};
	[mas appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:attrs]];
	[mas appendAttributedString:[[NSAttributedString alloc] initWithString:THLocalizedString(@"ALFRED_FIRST_STARTED_FROM_MENU_BAR") attributes:attrs]];

	[alfredFirstView setLabel:mas andResize:YES];

	NSSize vSize=alfredFirstView.frame.size;
	NSRect sFrame=screen.frame;
	NSRect wRect=NSMakeRect(		sFrame.origin.y+CGFloatFloor(position-(vSize.width/2.0)),
														sFrame.size.height-vSize.height-30.0,
														vSize.width,
														vSize.height);
	
	NSRect vScreen=screen.visibleFrame;
	if (wRect.origin.x+wRect.size.width>vScreen.origin.x+vScreen.size.width)
		wRect.origin.x=vScreen.origin.x+vScreen.size.width-wRect.size.width-20.0;

	_myWindow=[[NSWindow alloc] initWithContentRect:	wRect
																							styleMask:NSWindowStyleMaskBorderless
																							backing:NSBackingStoreBuffered
																							defer:YES
																							screen:screen];
	_myWindow.hasShadow=YES;
	_myWindow.backgroundColor=[NSColor clearColor];
	_myWindow.opaque=NO;
	_myWindow.alphaValue=0.0;
	_myWindow.level=NSScreenSaverWindowLevel;
	_myWindow.delegate=self;
	_myWindow.contentView=alfredFirstView;
	_myWindow.alphaValue=0.0;
	[_myWindow makeKeyAndOrderFront:nil];

	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
	{
		context.duration=0.20;
		[(NSWindow*)_myWindow.animator setAlphaValue:1.0];
	}
	completionHandler:^
	{
	}];

	[self performSelector:@selector(autoHide) withObject:nil afterDelay:10.0];
}

- (void)autoHide
{
	[self hide];
}

- (void)hide
{
	if (_myWindow==nil)
		return;

	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHide) object:nil];

	NSWindow *win=_myWindow;
	win.delegate=nil;
	_myWindow=nil;

	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
	{
		context.duration=0.20;
		[(NSWindow*)win.animator setAlphaValue:0.0];
	}
	completionHandler:^
	{
		[win orderOut:nil];
	}];
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
