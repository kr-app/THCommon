// THFileSearchResult.m

#import "THFileSearchResult.h"
#import "TH_APP-Swift.h"
#include <sys/stat.h> // stat
#include <sys/xattr.h> // xattr
#include <errno.h> // xattr

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THFileSearchResult

- (NSString*)path { return _path; }
- (NSString*)fileName { return _fileName; }
- (BOOL)isRegularFile { return _type=='F'?YES:NO; }
- (BOOL)isDirectory { return _type=='D'?YES:NO; }
- (BOOL)isSymLink { return _type=='L'?YES:NO; }
- (unsigned long long)fileSize { return _type=='F'?(unsigned long long)_statInfos.st_size:0; }
- (NSTimeInterval)modificationDate { return (NSTimeInterval)_statInfos.st_mtimespec.tv_sec; }
- (NSTimeInterval)creationDate { return (NSTimeInterval)_statInfos.st_birthtimespec.tv_sec; }

- (id)initWithPath:(const char*)cPath type:(int)type stat:(struct stat*)stat
{
	NSString *path=cPath==NULL?nil:[NSString stringWithUTF8String:cPath];
	if (path==nil)
		return nil;
	
	if (self=[super init])
	{
		_path=path;
		_cPath=strdup(cPath);
		_fileName=[_path lastPathComponent];
		_type=type;
		_isValid=YES;
		
		_statInfos.st_mode=stat->st_mode;
		_statInfos.st_mtimespec=stat->st_mtimespec;
		_statInfos.st_birthtimespec=stat->st_birthtimespec;
		_statInfos.st_size=stat->st_size;
	}
	return self;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<%@ %p path:%@ isValid:%d>",[self className],self,_path,_isValid];
}

- (BOOL)isValid { return _isValid; }

- (NSInteger)updateStatus
{
	struct stat s;
	bzero(&s,sizeof(s));
	
	if (_cPath==NULL || lstat(_cPath,&s)!=0)
	{
		_isValid=NO;
		return -1;
	}
	
	THFileSearchResultStatInfo statInfos;
	statInfos.st_mode=s.st_mode;
	statInfos.st_mtimespec=s.st_mtimespec;
	statInfos.st_birthtimespec=s.st_birthtimespec;
	statInfos.st_size=s.st_size;
	
	if (memcmp(&statInfos,&_statInfos,sizeof(THFileSearchResultStatInfo))==0)
	{
		_isValid=YES;
		return 0;
	}
	
	int type=((s.st_mode&S_IFMT)==S_IFREG)?'F':((s.st_mode&S_IFMT)==S_IFDIR)?'D':((s.st_mode&S_IFMT)==S_IFLNK)?'L':0;
	if (type==0)
	{
		_isValid=NO;
		return -1;
	}
	
	_type=type;
	_isValid=YES;
	_statInfos=statInfos;
	
	_fileURL=nil;
	[self attributesChanged];
	
	return 1;
}

- (void)attributesChanged
{
	self.fileIcon=nil;
	self.displayDirPath=nil;
	_dirPath=nil;
	_dateModified=nil;
	_dateCreated=nil;
}

- (NSURL*)fileURL
{
	if (_fileURL==nil && _path!=nil)
		_fileURL=[NSURL fileURLWithPath:_path];
	return _fileURL;
}

- (NSString*)dirPath
{
	if (_dirPath==nil)
		_dirPath=_path.stringByDeletingLastPathComponent;
	return _dirPath;
}

- (NSDate*)dateModified
{
	if (_dateModified==nil)
		_dateModified=[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)_statInfos.st_mtimespec.tv_sec];
	return _dateModified;
}

- (NSDate*)dateCreated
{
	if (_dateCreated==nil)
		_dateCreated=[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)_statInfos.st_birthtimespec.tv_sec];
	return _dateCreated;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
