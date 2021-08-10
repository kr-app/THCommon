// THFinderTools.m

#import "THFinderTools.h"
#import "THLog.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THFinderTools

+ (BOOL)displayFinderGetInfoOfPath:(NSString*)path
{
	if (path==nil || [[NSFileManager defaultManager] fileExistsAtPath:path]==NO)
		return NO;

	NSString *source=[NSString stringWithFormat:
					  @"tell application \"Finder\"\n"
					  	"set aPath to POSIX file \"%@\"\n"
					  	"open information window of item aPath\n"
					  	"activate\n"
					  "end tell\n",
					  path];

	NSDictionary *errorInfo=nil;
	NSAppleEventDescriptor *aed=[[[NSAppleScript alloc] initWithSource:source] executeAndReturnError:&errorInfo];
	if (aed==nil)
		THLogError(@"aed==nil errorInfo:%@",errorInfo);
	return aed!=nil?YES:NO;
}

+ (BOOL)isSystemFileNameInFolder:(NSString*)fileName mode:(NSInteger)mode
{
   const char *c_filename=fileName.fileSystemRepresentation;
   if (fileName==nil || c_filename==NULL)
	   return NO;
	return THIsFilenameHiddenExcluded(c_filename,strlen(c_filename),(int)mode)==true?YES:NO;
}

+ (BOOL)isVolumeHiddenFilename:(NSString*)filename
{
   const char *c_filename=filename.fileSystemRepresentation;
   if (filename==nil || c_filename==NULL)
	   return NO;
   return THIsVolumeHiddenFilename(c_filename,strlen(c_filename))==true?YES:NO;
}

+ (BOOL)isVolumeSystemHiddenFilename:(NSString*)filename mode:(NSInteger)mode
{
   const char *c_filename=filename.fileSystemRepresentation;
   if (filename==nil || c_filename==NULL)
	   return NO;
   return THIsVolumeSystemHiddenFilename(c_filename,strlen(c_filename),(int)mode)==true?YES:NO;
}

+ (NSArray*)finderLabels
{
	NSArray *labels=[[NSWorkspace sharedWorkspace] fileLabels];
	NSArray *colors=[[NSWorkspace sharedWorkspace] fileLabelColors];

	NSMutableArray *results=[NSMutableArray array];

	for (NSString *label in labels)
	{
		if (label==labels[0]) // le premier est "None"
			continue;

		NSImage *badge=[[NSImage alloc] initWithSize:NSMakeSize(16.0,16.0)];
		[badge lockFocus];
			NSBezierPath *bezierPath=[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(2.0,2.0,12.0,12.0)];
			[(NSColor*)colors[[labels indexOfObject:label]] set];
			[bezierPath fill];
			[[NSColor colorWithCalibratedWhite:0.5 alpha:0.33] set];
			[bezierPath stroke];
		[badge unlockFocus];

		[results addObject:@{@"label":label,@"badge":badge}];
	}

	return [NSArray arrayWithArray:results];
}

+ (NSImage*)iconWithAliasMaskForType:(NSString*)type
{
	static NSImage *aliasMask=nil;
	if (aliasMask==nil)
	{
		aliasMask=[[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kAliasBadgeIcon)] copy];
		aliasMask.size=NSMakeSize(16.0,16.0);
	}

	NSImage *icon=type==nil?nil:[[[NSWorkspace sharedWorkspace] iconForFileType:type] copy];
	icon.size=NSMakeSize(16.0,16.0);

	NSImage *result=[[NSImage alloc] initWithSize:NSMakeSize(16.0,16.0)];
	[result lockFocus];
		[icon drawAtPoint:NSMakePoint(0.0,0.0) fromRect:NSMakeRect(0.0,0.0,16.0,16.0) operation:NSCompositingOperationSourceOver fraction:1.0];
		[aliasMask drawAtPoint:NSMakePoint(0.0,0.0) fromRect:NSMakeRect(0.0,0.0,16.0,16.0) operation:NSCompositingOperationSourceOver fraction:1.0];
	[result unlockFocus];

	return result;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
