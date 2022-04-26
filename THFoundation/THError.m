// THError.m

#import "THError.h"
#import "TH_APP-Swift.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THError

+ (instancetype)errorWithMessage:(NSString*)message reason:(NSString*)reason
{
	return [self errorWithMessage:message reason:reason depends:nil];
}

+ (instancetype)errorWithMessage:(NSString*)message reason:(NSString*)reason depends:(id)depends
{
	static NSUInteger THErrorCountGlobal=0;
	THErrorCountGlobal+=1;

	THError *result=[[[self class] alloc] init];
	result.errorCount=THErrorCountGlobal;
	result.message=message;
	result.reason=reason;
	result.depends=depends;

	THLogError(@"%@",result);
	return result;
}

- (NSString*)description
{
	NSMutableString *string=[NSMutableString stringWithFormat:@"<%@ %p message:%@ reason:%@",[self className],self,_message,_reason];

	for (NSDictionary *info in self.infos)
		[string appendFormat:@"\n\tInfos[%@]:{%@\n}",info[@"key"],info[@"info"]];

	if ([_depends isKindOfClass:[THError class]]==YES || [_depends isKindOfClass:[NSError class]]==YES)
		[string appendFormat:@"\n\tDepends:%@",[_depends description]];
	else if (_depends!=nil)
		[string appendFormat:@"\n\tDepends:%@",_depends];

	return [string stringByAppendingString:@">"];
}

- (NSArray*)infos { return [NSArray arrayWithArray:_infos]; }

- (void)addInfo:(id)info forKey:(NSString*)key
{
	if (_infos==nil)
		_infos=[NSMutableArray array];
	[_infos addObject:[NSDictionary dictionaryWithObjectsAndKeys:info!=nil?info:[NSNull null],@"info",key,@"key",nil]];
}

- (id)initialError
{
	id depends=self.depends;
	
	if (depends==nil || [depends isKindOfClass:[THError class]]==NO)
		return nil;
	if ([depends isKindOfClass:[THError class]]==NO)
		return depends;

	THError *e=depends;
	while (1)
	{
		if (e.depends==nil)
			return e;
		if ([e.depends isKindOfClass:[THError class]]==NO)
			return e.depends;
		e=e.depends;
	}

	return nil;
}

- (NSString*)initialErrorMessage
{
	id initialError=[self initialError];
	if ([initialError isKindOfClass:[THError class]]==YES)
		return [(THError*)initialError message];
	if ([initialError isKindOfClass:[NSError class]]==YES)
		return [(NSError*)initialError localizedDescription];
	if ([initialError isKindOfClass:[NSString class]]==YES)
		return initialError;
	return [initialError description];
}

- (NSArray*)errorsStack
{
	NSMutableArray *result=[NSMutableArray array];
	return [NSArray arrayWithArray:result];
}

- (void)presentWIthTitle:(NSString*)title asSheetForWIndow:(NSWindow*)parentWindow
{
	NSString *message=nil;
	if (title!=nil)
		message=_message;
	else
	{
		title=_message;
		message=[self initialErrorMessage];
	}

//	title=[title th_terminatingBy:@"."];
//	message=[message th_terminatingBy:@"."];

	NSAlert *alert=[[NSAlert alloc] initWithTitle:title message:message];

	if (parentWindow!=nil && parentWindow.isVisible==YES)
	{
		if ([alert respondsToSelector:@selector(beginSheetModalForWindow:completionHandler:)]==YES) //10.9
			[alert beginSheetModalForWindow:parentWindow completionHandler:NULL];
		else
			[alert runModal];
	}
	else
		[alert runModal];
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
