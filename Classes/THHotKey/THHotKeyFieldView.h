// THHotKeyFieldView.h

#import <Cocoa/Cocoa.h>
#import "THHotKeyCenter.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THHotKeyFieldView : NSView
{
	BOOL _hasNotificationInstalled;

	__weak id _changeObserver;
	NSControlSize _controlSize;
	BOOL _isEnabled;
	BOOL _isClicked;
	BOOL _isOnError;
	NSString *_string;

	NSInteger _lastStatus;
	NSUInteger _lastKeyCode;
	NSUInteger _lastModifierFlags;
}

@property (nonatomic,strong) IBOutlet NSTextField *mesLabel;

- (void)setControlSize:(NSControlSize)controlSize;
- (void)setIsEnabled:(BOOL)isEnabled;
- (void)setChangeObserver:(id)changeObserver keyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags isEnabled:(BOOL)isEnabled;

@end

@protocol THHotKeyFieldViewChangeObserverProtocol <NSObject>
@required
- (BOOL)hotKeyFieldView:(THHotKeyFieldView*)hotKeyFieldView didChangeWithKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags isEnabled:(BOOL)isEnabled;
@end
//--------------------------------------------------------------------------------------------------------------------------------------------
