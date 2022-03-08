// THNSMenuExtensions.m

#import "THNSMenuExtensions.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation NSMenuItem (THNSMenuExtensions)

+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title target:(id)target action:(SEL)action representedObject:(id)representedObject tag:(NSInteger)tag isEnabled:(BOOL)isEnabled
{
	NSMenuItem *result=[[self alloc] initWithTitle:title!=nil?title:@"" action:action keyEquivalent:@""];
	result.target=target;
	result.representedObject=representedObject;
	result.tag=tag;
	[result setEnabled:isEnabled];
	return result;
}

+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title target:(id)target action:(SEL)action representedObject:(id)representedObject isEnabled:(BOOL)isEnabled
{
	NSMenuItem *result=[[self alloc] initWithTitle:title!=nil?title:@"" action:action keyEquivalent:@""];
	result.target=target;
	result.representedObject=representedObject;
	[result setEnabled:isEnabled];
	return result;
}

+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title target:(id)target action:(SEL)action tag:(NSInteger)tag
{
	NSMenuItem *result=[[self alloc] initWithTitle:title!=nil?title:@"" action:action keyEquivalent:@""];
	result.target=target;
	result.tag=tag;
	return result;
}

+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title target:(id)target action:(SEL)action tag:(NSInteger)tag isEnabled:(BOOL)isEnabled
{
	NSMenuItem *result=[self th_menuItemWithTitle:title target:target action:action tag:tag];
	[result setEnabled:isEnabled];
	return result;
}

+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
	NSMenuItem *result=[[self alloc] initWithTitle:title!=nil?title:@"" action:action keyEquivalent:@""];
	result.target=target;
	result.action=action;
	return result;
}

+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title tag:(NSInteger)tag
{
	NSMenuItem *result=[[self alloc] initWithTitle:title!=nil?title:@"" action:nil keyEquivalent:@""];
	result.tag=tag;
	return result;
}

+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title tag:(NSInteger)tag isEnabled:(BOOL)isEnabled
{
	NSMenuItem *result=[[self alloc] initWithTitle:title!=nil?title:@"" action:nil keyEquivalent:@""];
	result.tag=tag;
	[result setEnabled:isEnabled];
	return result;
}

+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title tag:(NSInteger)tag representedObject:(id)representedObject
{
	NSMenuItem *result=[[self alloc] initWithTitle:title!=nil?title:@"" action:nil keyEquivalent:@""];
	result.tag=tag;
	result.representedObject=representedObject;
	return result;
}

+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title representedObject:(id)representedObject
{
	NSMenuItem *result=[[self alloc] initWithTitle:title!=nil?title:@"" action:nil keyEquivalent:@""];
	result.representedObject=representedObject;
	return result;
}

+ (NSMenuItem*)th_menuItemWithTitle:(NSString*)title representedObject:(id)representedObject isEnabled:(BOOL)isEnabled
{
	NSMenuItem *result=[[self alloc] initWithTitle:title!=nil?title:@"" action:nil keyEquivalent:@""];
	result.representedObject=representedObject;
	[result setEnabled:isEnabled];
	return result;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
