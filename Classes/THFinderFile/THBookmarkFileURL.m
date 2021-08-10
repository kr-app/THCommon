// THBookmarkFileURL.m

#ifdef TH_TARGET_OSX
#import "THBookmarkFileURL.h"
#include <sys/stat.h>
#include <strings.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THBookmarkFileURL

- (NSURL*)URL { return _URL; }
- (NSString*)path { return _path; }
- (THBookmarkFileURLStatus)status { return _status; }

#pragma mark -

- (id)initWithURL:(NSURL*)URL path:(NSString*)path updateStatus:(BOOL)updateStatus
{
	if (URL==nil && path!=nil)
		URL=[NSURL fileURLWithPath:path];
	else if (path==nil && URL!=nil)
		path=URL.path;

	if (URL==nil || path==nil)
	{
		THLogError(@"URL==nil || path==nil");
		return nil;
	}

	if (self=[super init])
	{
		_URL=URL;
		_path=path;
		
		if (updateStatus==YES)
		{
			bzero(&_statInfo,sizeof(THBookmarkFileURLStatInfo));
			_status=[self getStatInfo:&_statInfo]==YES?THBookmarkFileURLStatus_ok:THBookmarkFileURLStatus_error;
		}

		_bookmarkData=[self bookmarkDataFromURL:URL];
	}
	return self;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<%@ %p URL:%@ path:%@>",[self className],self,_URL,_path];
}

#pragma mark -

- (NSDictionary*)dictionaryRepresentation
{
	if (_bookmarkData==nil)
		_bookmarkData=[self bookmarkDataFromURL:_URL];
	
	NSMutableDictionary *rep=[NSMutableDictionary dictionary];
	
	[rep setValue:_serializedPath forKey:@"serializedPath"];
	[rep setValue:_bookmarkData forKey:@"bookmarkData"];
	
	return [NSDictionary dictionaryWithDictionary:rep];
}

- (id)initWithDictionaryRepresentation:(NSDictionary*)dictionaryRepresentation
{
	if (dictionaryRepresentation==nil)
		return nil;
	if (self=[super init])
	{
		_serializedPath=[dictionaryRepresentation objectForKey:@"serializedPath"];
		_bookmarkData=[dictionaryRepresentation objectForKey:@"bookmarkData"];
	}
	return self;
}

#pragma mark -

- (BOOL)getStatInfo:(THBookmarkFileURLStatInfo*)statInfo
{
	if (_path==nil)
		return NO;

	const char *cFilePath=[_path fileSystemRepresentation];
	if (cFilePath==NULL)
		return NO;

	struct stat sb;
	bzero(&sb,sizeof(sb));

	if (lstat(cFilePath,&sb)!=0)
	{
		int errNo=errno;
#ifdef DEBUG
		THLogError(@"lstat!=0 cFilePath:%s errno:%d (%s)",cFilePath,errNo,strerror(errNo));
#else
		if (errNo!=EPERM && errNo!=ENOENT && errNo!=EACCES)
			THLogError(@"lstat!=0 cFilePath:%s errno:%d (%s)",cFilePath,errNo,strerror(errNo));
#endif
		return NO;
	}

	statInfo->st_dev=sb.st_dev;
	statInfo->st_ino=sb.st_ino;
	statInfo->st_mode=sb.st_mode;
	statInfo->st_mtimespec=sb.st_mtimespec;
	statInfo->st_size=sb.st_size;

	return YES;
}

- (NSData*)bookmarkDataFromURL:(NSURL*)fileURL
{
#ifdef TH_MAS
	NSURLBookmarkCreationOptions options=NSURLBookmarkCreationWithSecurityScope|NSURLBookmarkCreationSecurityScopeAllowOnlyReadAccess;
#else
	NSURLBookmarkCreationOptions options=NSURLBookmarkCreationMinimalBookmark;
#endif

	NSError *error=nil;
	NSData *bookmarkData=[fileURL bookmarkDataWithOptions:options includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
	if (bookmarkData==nil)
		THLogError(@"bookmarkData==nil fileURL:%@ error:%@",fileURL,error);

	return bookmarkData;
}

- (void)updateFromBookmarkData:(NSData*)bookmarkData path:(NSString*)path
{
	if (bookmarkData==nil && path==nil)
	{
		_status=THBookmarkFileURLStatus_error;
		return;
	}

	NSURL *fileURL=nil;
	if (bookmarkData!=nil)
	{
#ifdef TH_MAS
		NSURLBookmarkResolutionOptions options=NSURLBookmarkResolutionWithoutUI|NSURLBookmarkResolutionWithoutMounting|NSURLBookmarkResolutionWithSecurityScope;
#else
		NSURLBookmarkResolutionOptions options=NSURLBookmarkResolutionWithoutUI|NSURLBookmarkResolutionWithoutMounting;
#endif

		NSError *error=nil;
		BOOL isStale=NO;
		fileURL=[NSURL URLByResolvingBookmarkData:bookmarkData options:options relativeToURL:nil bookmarkDataIsStale:&isStale error:&error];
		if (fileURL==nil)
			THLogError(@"fileURL==nil fileURL:%@ error:%@",_URL,error);
	}

	if (fileURL==nil && path!=nil)
		fileURL=[NSURL fileURLWithPath:path];
	else if (fileURL!=nil)
		path=fileURL.path;

	[_URL stopAccessingSecurityScopedResource];
	[fileURL startAccessingSecurityScopedResource];

	_URL=fileURL;
	_path=path;

	_status=[self getStatInfo:&_statInfo]==YES?THBookmarkFileURLStatus_ok:THBookmarkFileURLStatus_error;

	_displayName=nil;
	_icon=nil;
}

- (void)updateStatus
{
	if (_URL==nil)
	{
		[self updateFromBookmarkData:_bookmarkData path:_serializedPath];
		return;
	}

	THBookmarkFileURLStatInfo statInfo;
	bzero(&statInfo,sizeof(THBookmarkFileURLStatInfo));

	if ([self getStatInfo:&statInfo]==YES && memcmp(&statInfo,&_statInfo,sizeof(THBookmarkFileURLStatInfo))==0)
	{
		_status=THBookmarkFileURLStatus_ok;
		return;
	}

	[self updateFromBookmarkData:_bookmarkData path:_path];
}

#pragma mark -

- (NSUInteger)hash { return (NSUInteger)_URL.hash; }

- (BOOL)isEqual:(THBookmarkFileURL*)anObject
{
	if (anObject==nil)
		return NO;
	if (anObject==self)
		return YES;
	if (_URL==nil || anObject->_URL==nil || [_URL isEqualTo:anObject->_URL]==NO)
		return NO;
	return YES;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THBookmarkFileURL (Extensions)

- (NSString*)displayName
{
	if (_displayName==nil)
	{
		if (_status==THBookmarkFileURLStatus_ok)
		{
			_displayName=[[NSFileManager defaultManager] displayNameAtPath:_path];
			if (_displayName==nil)
				_displayName=_path.lastPathComponent;
		}
		else
			return _serializedPath.lastPathComponent;
	}
	return _displayName;
}

- (NSImage*)displayIcon
{
	if (_icon==nil && _status==THBookmarkFileURLStatus_ok)
		_icon=[self updatedDisplayIcon];
	return _icon;
}

- (NSImage*)updatedDisplayIcon
{
	NSImage *icon=[[[NSWorkspace sharedWorkspace] iconForFile:_path] copy];
	icon.size=NSMakeSize(16.0,16.0);
	return icon;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
#endif
