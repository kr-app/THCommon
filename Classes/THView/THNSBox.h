// THNSBox.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THNSBox : NSBox
{
	BOOL _isEnabled;
	NSInteger _flags;
}

- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)isEnabled;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THNSBoxHighlightable_FadeView : NSView
{
	BOOL _isPressed;
}
@end

@interface THNSBoxHighlightable : NSBox
{
	id _targetor;
	
	NSTrackingArea *_trackingArea;
	THNSBoxHighlightable_FadeView *_fadeView;
	BOOL _isFading;
	BOOL _isDefading;
	NSPoint _downPoint;
	NSPoint _winPosition;
}

- (void)setTargetor:(id)targetor;

@end

@protocol THNSBoxHighlightableDelegateProtocol <NSObject>
- (void)boxHighlightableClicked:(THNSBoxHighlightable*)sender;
@end
//--------------------------------------------------------------------------------------------------------------------------------------------
