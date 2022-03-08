// THFinderFileIcon.m

#import "THFinderFileIcon.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THFinderFileIcon

+ (NSImage*)iconForFileAtPath:(NSString*)path size:(CGFloat)size
{
	NSImage *icon=[[[NSWorkspace sharedWorkspace] iconForFile:path] copy];
	icon.size=NSMakeSize(size,size);
	return icon;
}

+ (NSImage*)quickLookFileIconForFileAtURL:(NSURL*)fileURL size:(CGFloat)size bordered:(BOOL)bordered
{
	if (fileURL==nil)
		return nil;

	static CFDictionaryRef dOptions=NULL;
	if (bordered==YES)
	{
		if (dOptions==NULL)
		{
			const void *keys[]={kQLThumbnailOptionIconModeKey};
			const void *values[]={kCFBooleanTrue};
			dOptions=CFDictionaryCreate(NULL,keys,values,1,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
		}
	}

	CGImageRef imgRef=QLThumbnailImageCreate(kCFAllocatorDefault,(__bridge CFURLRef)fileURL,CGSizeMake(size,size),dOptions);
	if (imgRef==NULL)
		return nil;

	NSBitmapImageRep *bitmapImageRep=[[NSBitmapImageRep alloc] initWithCGImage:imgRef];
	NSImage *result=nil;
	if (bitmapImageRep!=nil)
	{
		result=[[NSImage alloc] initWithSize:bitmapImageRep.size];
		[result addRepresentation:bitmapImageRep];
	}

	CFRelease(imgRef);

	return result;
}

- (id)init
{
	if (self=[super init])
	{
		self.iconSize=16.0;

		_fileIcons=[NSMutableDictionary dictionary];
		_previewIcons=[NSMutableDictionary dictionary];
		_loadingPaths=[NSMutableArray array];
		_onErrorPaths=[NSMutableArray array];
	}
	return self;
}

- (NSImage*)iconForFileAtPath:(NSString*)path aliasMask:(BOOL)aliasMask
{
	if (path==nil)
		return nil;

	NSImage *icon=_fileIcons[path];
	if (icon!=nil)
		return icon;

	icon=[[[NSWorkspace sharedWorkspace] iconForFile:path] copy];
	icon.size=NSMakeSize(_iconSize,_iconSize);

	if (aliasMask==YES)
	{
		static NSImage *mask=nil;
		if (mask==nil)
		{
			mask=[[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kAliasBadgeIcon)] copy];
			mask.size=NSMakeSize(_iconSize,_iconSize);
		}

		NSImage *nIcon=[[NSImage alloc] initWithSize:NSMakeSize(_iconSize,_iconSize)];
		[nIcon lockFocus];
			[icon drawAtPoint:NSMakePoint(0.0,0.0) fromRect:NSMakeRect(0.0,0.0,_iconSize,_iconSize) operation:NSCompositingOperationSourceOver fraction:1.0];
			[mask drawAtPoint:NSMakePoint(0.0,0.0) fromRect:NSMakeRect(0.0,0.0,_iconSize,_iconSize) operation:NSCompositingOperationSourceOver fraction:1.0];
		[nIcon unlockFocus];

		icon=nIcon;
	}

	_fileIcons[path]=icon;

	return icon;
}

- (NSImage*)iconPreviewForFileAtPath:(NSString*)filePath fileURL:(NSURL*)fileURL canStartLoad:(BOOL)canStartLoad
{
	if (filePath==nil)
		return nil;

	NSImage *icon=_previewIcons[filePath];
	if (icon!=nil)
		return icon;

	if ([_loadingPaths containsObject:filePath]==NO && [_onErrorPaths containsObject:filePath]==NO && canStartLoad==YES)
	{
		if (fileURL==nil)
			fileURL=[NSURL fileURLWithPath:filePath isDirectory:NO];

		NSBlockOperation *op=[NSBlockOperation blockOperationWithBlock:^
								{
									NSImage *icon=[THFinderFileIcon quickLookFileIconForFileAtURL:fileURL size:_iconSize bordered:NO];
									if (icon==nil)
									{
										//THLogError(@"icon==nil fileURL:%@",fileURL);
									}

									NSDictionary *infos=[NSDictionary dictionaryWithObjectsAndKeys:filePath,@"filePath",icon,@"icon",nil];
									[self performSelectorOnMainThread:@selector(mt_didUpdateIcon:) withObject:infos waitUntilDone:NO];
								  }];

		op.queuePriority=NSOperationQueuePriorityVeryLow;

		static NSOperationQueue *opQueue=nil;
		if (opQueue==nil)
		{
			opQueue=[[NSOperationQueue alloc] init];
			opQueue.maxConcurrentOperationCount=2;
		}
		[opQueue addOperation:op];
	}

	return [self iconForFileAtPath:filePath aliasMask:NO];
}

- (void)mt_didUpdateIcon:(NSDictionary*)infos
{
	NSString *filePath=infos[@"filePath"];
	NSImage *icon=infos[@"icon"];

	[_loadingPaths removeObject:filePath];

	if (icon!=nil)
		_previewIcons[filePath]=icon;
	else
		[_onErrorPaths addObject:filePath];	

	if (icon!=nil)
		self.updatedIconBk(filePath,icon);
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
