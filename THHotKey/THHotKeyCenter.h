// THHotKeyCenter.h

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THHotKeyRepresentation : NSObject

@property (nonatomic) NSUInteger keyCode;
@property (nonatomic) NSUInteger modifierFlags;
@property (nonatomic) BOOL isEnabled;

- (id)initWithKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags isEnabled:(BOOL)isEnabled;

- (NSString*)stringRepresentation;
- (id)initWithStringRepresentation:(NSString*)stringRepresentation;

+ (instancetype)hotKeyRepresentationFromUserDefaults;
- (void)saveToUserDefaults;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@class THHotKeyCenter;

@protocol THHotKeyCenterProtocol <NSObject>
@required
- (void)hotKeyCenter:(THHotKeyCenter*)hotKeyCenter pressedHotKey:(NSDictionary*)hotKey;
@end

@interface THHotKeyCenter : NSObject
{
	NSMutableArray *_hotKeys;
	EventHandlerRef _eventHandler;
}

+ (instancetype)shared;

- (NSInteger)registerableStatusOfHotKeyWithKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags keyCodeString:(NSString**)keyCodeString errorMsg:(NSString**)errorMsg;
- (BOOL)registerHotKeyWithKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags tag:(NSInteger)tag;
- (BOOL)unregisterHotKeyWithTag:(NSInteger)tag;

- (void)tryToRegisterHotKeyRepresentation:(THHotKeyRepresentation*)hotKey withTag:(NSInteger)tag;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
