// THHotKeyCenter.m

#import "THHotKeyCenter.h"
#import "THFoundation.h"
#import "THLog.h"
#import "THHotKey.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THHotKeyRepresentation

- (id)initWithKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags isEnabled:(BOOL)isEnabled
{
	if (self=[super init])
	{
		self.keyCode=keyCode;
		self.modifierFlags=modifierFlags;
		self.isEnabled=isEnabled;
	}
	return self;
}

- (NSString*)stringRepresentation
{
	return [NSString stringWithFormat:@"THHotKeyRepresentation-%lu-%lu-%d",self.keyCode,self.modifierFlags,self.isEnabled==YES?1:0];
}

- (id)initWithStringRepresentation:(NSString*)stringRepresentation
{
	NSArray *comps=[stringRepresentation componentsSeparatedByString:@"-"];
	if (comps==nil || comps.count!=4)
		return nil;
	return [self initWithKeyCode:[(NSString*)comps[1] longLongValue] modifierFlags:[(NSString*)comps[2] longLongValue] isEnabled:[(NSString*)comps[3] integerValue]>0?YES:NO];
}

+ (instancetype)hotKeyRepresentationFromUserDefaultsWithTag:(NSInteger)tag
{
	NSString *stringRepresentation=[[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"HotKey-StringRepresentation-%ld",tag]];
	THHotKeyRepresentation *hotKey=stringRepresentation==nil?nil:[[THHotKeyRepresentation alloc] initWithStringRepresentation:stringRepresentation];
	hotKey.tag=tag;
	return hotKey;
}

- (void)saveToUserDefaultsWithTag:(NSInteger)tag
{
	[[NSUserDefaults standardUserDefaults] setObject:self.stringRepresentation forKey:[NSString stringWithFormat:@"HotKey-StringRepresentation-%ld",tag]];
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THHotKeyCenter

+ (instancetype)shared
{
	static THHotKeyCenter *shared=nil;
	if (shared==nil)
		shared=[[[self class] alloc] init];
	return shared;
}

- (void)dealloc
{
 	[self removeEventHandler];
}

- (BOOL)installEventHandlerIfNecessary
{
	if (_eventHandler!=NULL)
		return YES;

	if (_hotKeys==nil)
		_hotKeys=[NSMutableArray array];

	EventTypeSpec eventTypeSpec;
	eventTypeSpec.eventClass=kEventClassKeyboard;
	eventTypeSpec.eventKind=kEventHotKeyPressed;

	OSStatus status=InstallEventHandler(GetEventDispatcherTarget(),hotKey_carbonEventCb,1,&eventTypeSpec,&_hotKeys,&_eventHandler);
	if (status!=noErr)
	{
		THLogError(@"InstallEventHandler:%d",status);
		return NO;
	}

	return YES;
}

- (void)removeEventHandler
{
	if (_eventHandler==NULL)
		return;
	if (RemoveEventHandler(_eventHandler)!=noErr)
		THLogError(@"RemoveEventHandler");
}

- (THHotKey*)hotKeyWithKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags
{
	for (THHotKey *hotKey in _hotKeys)
		if (hotKey.keyCode==keyCode && hotKey.modifierFlags==modifierFlags)
			return hotKey;
	return nil;
}

- (NSInteger)registerableStatusOfHotKeyWithKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags keyCodeString:(NSString**)keyCodeString errorMsg:(NSString**)errorMsg
{
	modifierFlags=[THHotKey cleanedModifierFlags:modifierFlags];

	if ([THHotKey isValidKeyCode:keyCode modifierFlags:modifierFlags]==NO)
	{
		*errorMsg=THLocalizedString(@"This shortcut is not correct.");
		return -1;
	}

	if (keyCodeString!=NULL)
		*keyCodeString=[THHotKey keyCodeStringOfKeyCode:keyCode modifierFlags:modifierFlags];

	if ([THHotKey hasEquivalentOfKeyCode:keyCode modifierFlags:modifierFlags]==YES)
	{
		*errorMsg=THLocalizedString(@"This shortcut is already used by another combination.");
		return 2;
	}

	if ([self hotKeyWithKeyCode:keyCode modifierFlags:modifierFlags]!=nil)
	{
		*errorMsg=THLocalizedString(@"This shortcut is already registered.");
		return 3;
	}

	return 1;
}

- (BOOL)registerHotKeyWithKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags tag:(NSInteger)tag
{
	modifierFlags=[THHotKey cleanedModifierFlags:modifierFlags];

	if ([THHotKey isValidKeyCode:keyCode modifierFlags:modifierFlags]==NO)
	{
		THLogError(@"isValidKeyCode==NO");
		return NO;
	}

	if ([self unregisterHotKeyWithTag:tag]==NO)
	{
		THLogError(@"unregisterHotKeyWithTag==NO");
		return NO;
	}

	if ([self hotKeyWithKeyCode:keyCode modifierFlags:modifierFlags]!=nil)
	{
		THLogError(@"hotKeyWithKeyCode!=nil");
		return NO;
	}

	if ([self installEventHandlerIfNecessary]==NO)
		return NO;

	THHotKey *hotKey=[[THHotKey alloc] initWithKeyCode:keyCode modifierFlags:modifierFlags tag:tag];
	if ([hotKey registerHotKey]==NO)
		return NO;

	[_hotKeys addObject:hotKey];
	return YES;
}

- (BOOL)unregisterHotKeyWithTag:(NSInteger)tag
{
	for (THHotKey *hotKey in _hotKeys.copy)
	{
		if (hotKey.tag!=tag)
			continue;
		if ([hotKey unregisterHotKey]==NO)
			return NO;
		[_hotKeys removeObject:hotKey];
	}
	return YES;
}

- (void)diffuseHotKeyPressedWithEvent:(EventHotKeyID*)hotKeyId
{
	for (THHotKey *hotKey in _hotKeys)
	{
		if (hotKey.hotKeyId!=hotKeyId->id)
			continue;

		id<THHotKeyCenterProtocol> delegate=(id<THHotKeyCenterProtocol>)[NSApplication sharedApplication].delegate;
		if ([delegate respondsToSelector:@selector(hotKeyCenter:pressedHotKey:)]==YES)
			[delegate hotKeyCenter:self pressedHotKey:@{@"tag":@(hotKey.tag)}];
		else
			THLogError(@"delegate does not respond to hotKeyCenter:pressedHotKey:");

		break;
	}
}

static OSStatus hotKey_carbonEventCb(EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData)
{
	if ([NSThread isMainThread]==NO)
		NSLog(@"ERROR: [NSThread isMainThread]==NO");

	if (GetEventClass(inEvent)!=kEventClassKeyboard)
		return noErr;

	EventHotKeyID hotKeyId;
	OSStatus status=GetEventParameter(inEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,sizeof(hotKeyId),NULL,&hotKeyId);
	if (status!=noErr)
		return status;

	if (hotKeyId.signature!=[THHotKey hotKeySignature])
		return noErr;

	[[THHotKeyCenter shared] diffuseHotKeyPressedWithEvent:&hotKeyId];
	return noErr;
}

- (void)registerHotKeyRepresentation:(THHotKeyRepresentation*)hotKey
{
	if (hotKey==nil || hotKey.isEnabled==NO || hotKey.tag==0)
		return;

	NSString *error=nil;
	NSInteger status=[self registerableStatusOfHotKeyWithKeyCode:hotKey.keyCode modifierFlags:hotKey.modifierFlags keyCodeString:NULL errorMsg:&error];
	if (status!=1)
	{
		THLogError(@"registerableStatusOfHotKeyWithKeyCode:%ld error:%@ hotKey:%@",status,error,hotKey);
		return;
	}

	if ([self registerHotKeyWithKeyCode:hotKey.keyCode modifierFlags:hotKey.modifierFlags tag:hotKey.tag]==NO)
	{
		THLogError(@"registerHotKeyWithKeyCode==NO hotKey:%@",hotKey);
		return;
	}
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
