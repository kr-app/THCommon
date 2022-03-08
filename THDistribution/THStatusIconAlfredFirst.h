// THStatusIconAlfredFirst.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THStatusIconAlfredFirst : NSObject <NSWindowDelegate>
{
	NSView *_view;
	NSWindow *_myWindow;
}

+ (BOOL)needsDisplayAlfredFirst;
+ (void)setNeedsDisplayAlfredFirst:(BOOL)needsDisplayAlfredFirst;

+ (void)showAtPosition:(CGFloat)position onScreen:(NSScreen*)screen;
+ (void)hide;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
