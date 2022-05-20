// THHotKey.m

#import "THHotKey.h"
#import "THFoundation.h"
#import "THLog.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THHotKey

+ (OSType)hotKeySignature { return 'THHT'; }

+ (UInt32)carbonModifierFlagsFromCocoaModifierFlags:(NSUInteger)modifierFlags
{
    UInt32 result=0;
	if ((modifierFlags&NSEventModifierFlagControl)>0)
		result|=controlKey;
	if ((modifierFlags&NSEventModifierFlagCommand)>0)
		result|=cmdKey;
	if ((modifierFlags&NSEventModifierFlagShift)>0)
		result|=shiftKey;
	if ((modifierFlags&NSEventModifierFlagOption)>0)
		result|=optionKey;
	if ((modifierFlags&NSEventModifierFlagCapsLock)>0)
		result|=alphaLock;
	return result;
}

+ (NSUInteger)cleanedModifierFlags:(NSUInteger)modifierFlags
{
	return (modifierFlags&(	NSEventModifierFlagControl|
											NSEventModifierFlagShift|
											NSEventModifierFlagOption|
											NSEventModifierFlagCommand));
}

+ (BOOL)isValidKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags
{
	if (keyCode==0)
		return NO;
	
    if (		keyCode==kVK_F1 ||
			keyCode==kVK_F2 ||
			keyCode==kVK_F3 ||
			keyCode==kVK_F4 ||
			keyCode==kVK_F5 ||
			keyCode==kVK_F6 ||
			keyCode==kVK_F7 ||
			keyCode==kVK_F8 ||
			keyCode==kVK_F9 ||
			keyCode==kVK_F10 ||
			keyCode==kVK_F11 ||
			keyCode==kVK_F12 ||
			keyCode==kVK_F13 ||
			keyCode==kVK_F14 ||
			keyCode==kVK_F15 ||
			keyCode==kVK_F16 ||
			keyCode==kVK_F17 ||
			keyCode==kVK_F18 ||
			keyCode==kVK_F19 ||
			keyCode==kVK_F20)
		return YES;

	if (modifierFlags==0)
		return NO;

    return YES;
}

+ (BOOL)hasMenuItemKeyEquivalent:(NSString*)keyEquivalent modifierFlags:(NSUInteger)modifierFlags takenInMenu:(NSMenu*)menu
{
    for (NSMenuItem *menuItem in menu.itemArray)
	{
		if ([self cleanedModifierFlags:menuItem.keyEquivalentModifierMask]==modifierFlags)
		{
			if ([menuItem.keyEquivalent.lowercaseString isEqualToString:keyEquivalent]==YES)
	            return YES;
		}
		if (menuItem.hasSubmenu==YES && [self hasMenuItemKeyEquivalent:keyEquivalent modifierFlags:modifierFlags takenInMenu:menuItem.submenu]==YES)
			return YES;
	}
    return NO;
}

+ (BOOL)hasEquivalentOfKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags
{
	CFArrayRef globalHotKeys=NULL;
	if (CopySymbolicHotKeys(&globalHotKeys)==noErr)
	{
        for (CFIndex i=0, count=CFArrayGetCount(globalHotKeys);i<count;i++)
		{
            CFDictionaryRef hotKeyInfo=CFArrayGetValueAtIndex(globalHotKeys,i);
            CFNumberRef code=CFDictionaryGetValue(hotKeyInfo,kHISymbolicHotKeyCode);
            CFNumberRef flags=CFDictionaryGetValue(hotKeyInfo,kHISymbolicHotKeyModifiers);
			if (code!=NULL && [(__bridge NSNumber*)code unsignedIntegerValue]==keyCode && [(__bridge NSNumber*)flags unsignedIntegerValue]==modifierFlags)
				return YES;
		}
		CFRelease(globalHotKeys);
	}
	
	NSString *keyCodeString=[self keyCodeStringOfKeyCode:keyCode modifierFlags:0];
	if (keyCodeString==nil)
		return NO;

	return [self hasMenuItemKeyEquivalent:keyCodeString modifierFlags:modifierFlags takenInMenu:[NSApp mainMenu]];
}

+ (NSString*)keyCodesStringFromKeyCode:(NSUInteger)keyCode
{
	if (keyCode==kVK_Return) return @"↩";
	if (keyCode==kVK_Tab) return @"⇥";
	if (keyCode==kVK_Space) return @"⎵";
	if (keyCode==kVK_Delete) return @"⌫";
	if (keyCode==kVK_Escape) return @"⎋";
	if (keyCode==kVK_Command) return @"⌘";
	if (keyCode==kVK_Shift) return @"⇧";
	if (keyCode==kVK_CapsLock) return @"⇪";
	if (keyCode==kVK_Option) return @"⌥";
	if (keyCode==kVK_Control) return @"⌃";
	if (keyCode==kVK_RightShift) return @"⇧";
	if (keyCode==kVK_RightOption) return @"⌥";
	if (keyCode==kVK_RightControl) return @"⌃";
	if (keyCode==kVK_VolumeUp) return @"";
	if (keyCode==kVK_VolumeDown) return @"";
	if (keyCode==kVK_Mute) return @"";
	if (keyCode==kVK_Function) return @"\u2318";
	if (keyCode==kVK_F1) return @"F1";
	if (keyCode==kVK_F2) return @"F2";
	if (keyCode==kVK_F3) return @"F3";
	if (keyCode==kVK_F4) return @"F4";
	if (keyCode==kVK_F5) return @"F5";
	if (keyCode==kVK_F6) return @"F6";
	if (keyCode==kVK_F7) return @"F7";
	if (keyCode==kVK_F8) return @"F8";
	if (keyCode==kVK_F9) return @"F9";
	if (keyCode==kVK_F10) return @"F10";
	if (keyCode==kVK_F11) return @"F11";
	if (keyCode==kVK_F12) return @"F12";
	if (keyCode==kVK_F13) return @"F13";
	if (keyCode==kVK_F14) return @"F14";
	if (keyCode==kVK_F15) return @"F15";
	if (keyCode==kVK_F16) return @"F16";
	if (keyCode==kVK_F17) return @"F17";
	if (keyCode==kVK_F18) return @"F18";
	if (keyCode==kVK_F19) return @"F19";
	if (keyCode==kVK_F20) return @"F20";
	if (keyCode==kVK_Help) return @"";
	if (keyCode==kVK_ForwardDelete) return @"⌦";
	if (keyCode==kVK_Home) return @"↖";
	if (keyCode==kVK_End) return @"↘";
	if (keyCode==kVK_PageUp) return @"⇞";
	if (keyCode==kVK_PageDown) return @"⇟";
	if (keyCode==kVK_LeftArrow) return @"←";
	if (keyCode==kVK_RightArrow) return @"→";
	if (keyCode==kVK_DownArrow) return @"↓";
	if (keyCode==kVK_UpArrow) return @"↑";
	return nil;
}

+ (NSString*)keyCodeStringOfKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags
{
	NSMutableString *result=[NSMutableString stringWithString:@""];
	if ((modifierFlags&NSEventModifierFlagControl)!=0)
        [result appendString:[self keyCodesStringFromKeyCode:kVK_Control]];
	if ((modifierFlags&NSEventModifierFlagOption)!=0)
        [result appendString:[self keyCodesStringFromKeyCode:kVK_Option]];
	if ((modifierFlags&NSEventModifierFlagShift)!=0)
        [result appendString:[self keyCodesStringFromKeyCode:kVK_Shift]];
	if ((modifierFlags&NSEventModifierFlagCommand)!=0)
        [result appendString:[self keyCodesStringFromKeyCode:kVK_Command]];

	if (keyCode==kVK_Control || keyCode==kVK_Option || keyCode==kVK_Shift || keyCode==kVK_Command)
		return result;

	NSString *keyCodeString=[self keyCodesStringFromKeyCode:keyCode];
	if (keyCodeString!=nil)
		return [result stringByAppendingFormat:@"%@",keyCodeString];
	
    TISInputSourceRef inputSource=TISCopyCurrentKeyboardLayoutInputSource();
    if (inputSource==NULL)
	{
		THLogError(@"inputSource==NULL");
		return nil;
	}
	
	CFDataRef layoutDataRef=TISGetInputSourceProperty(inputSource,kTISPropertyUnicodeKeyLayoutData);
	UCKeyboardLayout *layoutData=(UCKeyboardLayout*)CFDataGetBytePtr(layoutDataRef);
 	if (layoutDataRef==NULL || layoutData==NULL)
	{
		THLogError(@"layoutDataRef==NULL");
		return nil;
	}
	
	UInt32 deadKeyState=0;
	UniCharCount maxLen=255;
	UniCharCount length=0;
	UniChar chars[266]={0};
	UInt32 keyModifiers=[self carbonModifierFlagsFromCocoaModifierFlags:modifierFlags];
	
	OSStatus status=UCKeyTranslate(layoutData,(UInt16)keyCode,kUCKeyActionDisplay,keyModifiers,LMGetKbdType(),0/*kUCKeyTranslateNoDeadKeysMask*/,&deadKeyState,maxLen,&length,chars);
	if (status!=noErr)
	{
		THLogError(@"UCKeyTranslate:%d",status);
		return nil;
	}
	
	CFRelease(inputSource);
	
	NSString *charsString=[NSString stringWithCharacters:chars length:length];
	if (charsString==nil)
	{
		THLogError(@"UCKeyTranslate:%d",status);
		return nil;
	}
	
	static NSMutableCharacterSet *validChars=nil;
	if (validChars==nil)
	{
		validChars=[[NSMutableCharacterSet alloc] init];
		[validChars formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
		[validChars formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
		[validChars formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
	}
	
	for (NSUInteger i=0;i<charsString.length;i++)
	{
		if ([validChars characterIsMember:[charsString characterAtIndex:i]]==NO)
		{
			THLogError(@"characterIsMember==NO");
			return nil;
		}
	}
	
	return [result stringByAppendingFormat:@"%@",charsString];
}

- (NSUInteger)keyCode { return _keyCode; }
- (NSUInteger)modifierFlags { return _modifierFlags; }
- (NSInteger)tag { return _tag; }
- (UInt32)hotKeyId { return _hotKeyId; }

- (id)initWithKeyCode:(NSUInteger)keyCode modifierFlags:(NSUInteger)modifierFlags tag:(NSInteger)tag
{
	if (self=[super init])
	{
		_keyCode=keyCode;
		_modifierFlags=[[self class] cleanedModifierFlags:modifierFlags];
		_tag=tag;
	}
	return self;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<%@ %p keyCode:%lu modifierFlags:%lu tag:%ld>",[self className],self,_keyCode,_modifierFlags,_tag];
}

- (BOOL)registerHotKey
{
	UInt32 cKeyCode=(UInt32)_keyCode;
	UInt32 cModifierFlags=[[self class] carbonModifierFlagsFromCocoaModifierFlags:_modifierFlags];

	static UInt32 carbonHotKeyId=0;
	carbonHotKeyId+=1;

	EventHotKeyID hotKeyId;
	hotKeyId.signature=[THHotKey hotKeySignature];
	hotKeyId.id=carbonHotKeyId;

	EventHotKeyRef eventHotKeyRef=NULL;
	OSStatus status=RegisterEventHotKey(cKeyCode,cModifierFlags,hotKeyId,GetEventDispatcherTarget(),kEventHotKeyExclusive,&eventHotKeyRef);
	if (status!=noErr)
	{
		THLogError(@"RegisterEventHotKey:%d",status);
		return NO;
	}

	_eventHotKeyRef=eventHotKeyRef;
	_hotKeyId=carbonHotKeyId;

	return YES;
}

- (BOOL)unregisterHotKey
{
	if (_eventHotKeyRef==NULL)
		return YES;

	OSStatus status=UnregisterEventHotKey(_eventHotKeyRef);
	if (status!=noErr)
		THLogError(@"UnregisterEventHotKey:%d",status);

	_eventHotKeyRef=NULL;
	return YES;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
