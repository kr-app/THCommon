// SfScript.m

#import "SfScript.h"
#import "THAsScriptEnlacement.h"
#import "THFoundation.h"
#import "THLog.h"
#import "THStringEnlacement.h"
#import "Safari_DeleteWindows.scpt.h"
#import "Safari_RestoreSwitch.scpt.h"
#import "Safari_TakeSnapshot.scpt.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation SfScript

#ifdef DEBUG
+ (void)autoEnlaceScripts
{
	NSString *file=[NSString stringWithFormat:@"%s",__FILE__];
	NSString *dir=[[file stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"SfScripts"];
	[THAsScriptEnlacement autoEnlaceScripts:dir];
}
#endif

+ (nonnull NSString*)source_TakeSnapshot
{
	static NSString *string=nil;
	if (string!=nil)
		return string;
	Safari_TakeSnapshot_scpt
	THException(string==nil,@"string==nil");
	return string;
}

+ (nonnull NSString*)source_RestoreSwitch
{
	static NSString *string=nil;
	if (string!=nil)
		return string;
	Safari_RestoreSwitch_scpt
	THException(string==nil,@"string==nil");
	return string;
}

+ (nonnull NSString*)source_DeleteWindows
{
	static NSString *string=nil;
	if (string!=nil)
		return string;
	Safari_DeleteWindows_scpt
	THException(string==nil,@"string==nil");
	return string;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
