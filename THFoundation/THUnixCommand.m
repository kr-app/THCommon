// THUnixCommand.m

#import "THUnixCommand.h"
#import "THLog.h"
#import <sys/stat.h>
#import <sys/sysctl.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THUnixCommand

+ (BOOL)executeCommand:(NSString*)command args:(NSArray*)args status:(NSInteger*)pStatus stdOut:(NSString**)pStdOut stdErr:(NSString**)pStdErr
{
	return [self executeCommand:command args:args environment:nil currentDir:nil status:pStatus stdOut:pStdOut stdErr:pStdErr];
}

+ (BOOL)executeCommand:(NSString*)command args:(NSArray*)args environment:(NSDictionary*)environment currentDir:(NSString*)currentDir status:(NSInteger*)pStatus stdOut:(NSString**)pStdOut stdErr:(NSString**)pStdErr
{
	*pStatus=0;
	if (pStdOut!=NULL) *pStdOut=nil;
	if (pStdErr!=NULL) *pStdErr=nil;

	if (command==nil || command.length==0 || [command isEqualToString:@"/"]==YES)
		return NO;

	BOOL isDir=NO;
	if (command==nil || [[NSFileManager defaultManager] fileExistsAtPath:command isDirectory:&isDir]==NO || isDir==YES)
		return NO;

	if ([[NSFileManager defaultManager] isExecutableFileAtPath:command]==NO)
		return NO;

	NSPipe *outPipe=[NSPipe pipe];
	NSPipe *errPipe=[NSPipe pipe];
	NSTask *task=[[NSTask alloc] init];

	task.launchPath=command;
	task.arguments=[NSArray arrayWithArray:args];
	if (environment!=nil)
		task.environment=environment;
	if (currentDir!=nil)
		task.currentDirectoryPath=currentDir;
	task.standardOutput=outPipe;
	task.standardError=errPipe;

	BOOL hasRunned=NO;
	NS_DURING
	{
		[task launch];
		[task waitUntilExit];
		hasRunned=YES;
	}
	NS_HANDLER
	{
		THLogError(@"exception:%@ command:%@",localException,command);
		hasRunned=NO;
	}
	NS_ENDHANDLER

	if (hasRunned==NO)
		return NO;

	NSFileHandle *outHandle=[outPipe fileHandleForReading];
	NSFileHandle *errHandle=[errPipe fileHandleForReading];
	NSMutableData *outData=[NSMutableData data];
	NSMutableData *errData=[NSMutableData data];

	NSUInteger nb=0;
	while (1)
	{
		nb+=1;
		//usleep(20*1000);

		NSData *dataOut=[outHandle availableData];
		if (dataOut!=nil && dataOut.length>0)
			[outData appendData:dataOut];

		NSData *dataErr=[errHandle availableData];
		if (dataErr!=nil && dataErr.length>0)
			[errData appendData:dataErr];

		if ((dataOut==nil || dataOut.length==0) && (dataErr==nil || dataErr.length==0))
			break;
	}

	if (pStdErr!=NULL && errData.length>0)
	{
		NSString *errString=[[NSString alloc] initWithData:errData encoding:NSUTF8StringEncoding];
		if (errString==nil)
			errString=[[NSString alloc] initWithData:errData encoding:NSASCIIStringEncoding];
		*pStdErr=errString!=nil?errString:@"errString==nil";
	}

	if (pStdOut!=NULL && outData.length>0)
	{
		NSString *outString=[[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
		if (outString==nil)
			outString=[[NSString alloc] initWithData:outData encoding:NSASCIIStringEncoding];
		*pStdOut=outString!=nil?outString:@"outString==nil";
	}

	int terminationStatus=task.terminationStatus;
	*pStatus=terminationStatus;

	return YES;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
