// THHotKey.h

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THHotKey : NSObject
{
	NSUInteger _keyCode;
	NSUInteger _modifierFlags;
	NSInteger _tag;

	EventHotKeyRef _eventHotKeyRef;
	UInt32 _hotKeyId;
}

+ (OSType)hotKeySignature;
+ (UInt32)carbonModifierFlagsFromCocoaModifierFlags:(NSUInteger)modifierFlags;
+ (NSUInteger)cleanedModifierFlags:(NSUInteger)modifierFlags;
+ (BOOL)isValidKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags;
+ (BOOL)hasMenuItemKeyEquivalent:(NSString*)keyEquivalent modifierFlags:(NSUInteger)modifierFlags takenInMenu:(NSMenu*)menu;
+ (BOOL)hasEquivalentOfKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags;
+ (NSString*)keyCodeStringOfKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags;

- (NSUInteger)keyCode;
- (NSUInteger)modifierFlags;
- (NSInteger)tag;
- (UInt32)hotKeyId;

- (id)initWithKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags tag:(NSInteger)tag;

- (BOOL)registerHotKey;
- (BOOL)unregisterHotKey;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
