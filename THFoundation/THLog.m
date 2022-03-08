// THLog.m

#import "THLog.h"
#import "TH_APP-Swift.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THLog

#ifdef DEBUG
+ (void)logDebug:(NSString*)string { [self logWithSeverity:THLogSeverity_debug string:string error:nil]; }
#endif

+ (void)logInfo:(NSString*)string { [self logWithSeverity:THLogSeverity_info string:string error:nil]; }

+ (void)logWarning:(NSString*)string { [self logWithSeverity:THLogSeverity_warning string:string error:nil]; }

+ (void)logError:(NSString*)string { [self logWithSeverity:THLogSeverity_error string:string error:nil]; }

+ (void)logCriticalException:(NSString*)string { [self logWithSeverity:THLogSeverity_critical string:string error:nil]; }

+ (void)logWithSeverity:(NSInteger)severity string:(NSString*)string error:(id)error
{
	NSDate *now=[NSDate date];

	NSString *severityStr=nil;
	if (severity==THLogSeverity_debug)
		severityStr=@"DEBUG";
	else if (severity==THLogSeverity_info)
		severityStr=@"INFO";
	else if (severity==THLogSeverity_warning)
		severityStr= @"WARNING";
	else if (severity==THLogSeverity_error)
		severityStr=@"ERROR";
	else if (severity==THLogSeverity_critical)
		severityStr=@"CRITIRAL";

#ifdef DEBUG
	NSMutableString *log=[NSMutableString string];
	if (severity==THLogSeverity_debug)
		[log appendString:@"📘"];
	else if (severity==THLogSeverity_info)
		[log appendString:@"📒"];
	else if (severity==THLogSeverity_warning)
		[log appendString:@"📙"];
	else if (severity==THLogSeverity_error)
		[log appendString:@"📕"];
	else if (severity==THLogSeverity_critical)
		[log appendString:@"💔"];

	[log appendFormat:@" %@",string];
#else
	NSMutableString *log=[NSMutableString stringWithFormat:@"%@ %@",severityStr,string];
#endif

	if (error!=nil)
		[log appendFormat:@"\n{%@\n}",[error description]];

	NSString *r_log=log;

#ifdef DEBUG
	static NSDateFormatter *dateFormatter=nil;
	if (dateFormatter==nil)
		dateFormatter=[[NSDateFormatter alloc] initWithDateFormat:@"HH:mm:ss.SSS"];

	r_log=[NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:now],log];
	printf("%s\n",r_log.UTF8String);
#else
	NSLog(@"%@",r_log);
#endif

	[[THLogger shared] write:r_log for:now];
}

+ (void)raiseCritialException:(NSString*)msg function:(NSString*)function file:(const char*)file line:(NSInteger)line
{
	[THLogFunctions raiseFatalWithMsg:msg function:function file:[NSString stringWithFormat:@"%s",file] line:line];
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
