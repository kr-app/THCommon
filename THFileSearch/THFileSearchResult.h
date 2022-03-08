// THFileSearchResult.h

#import <Cocoa/Cocoa.h>
#import <dirent.h>
#include <sys/stat.h> // stat

//--------------------------------------------------------------------------------------------------------------------------------------------
typedef struct THFileSearchResultStatInfo
{
	mode_t st_mode;
	struct timespec st_mtimespec;
	struct timespec st_birthtimespec;
	off_t st_size;
} THFileSearchResultStatInfo;

@interface THFileSearchResult : NSObject
{
	NSString *_path;
	const char *_cPath;
	NSString *_fileName;
	int _type;
	THFileSearchResultStatInfo _statInfos;
	BOOL _isValid;

	NSURL *_fileURL;

	NSString *_dirPath;
	NSDate *_dateModified;
	NSDate *_dateCreated;
}

- (NSString*)path;
- (NSString*)fileName;
- (BOOL)isRegularFile;
- (BOOL)isSymLink;
- (BOOL)isDirectory;
- (unsigned long long)fileSize;
- (NSTimeInterval)modificationDate;
- (NSTimeInterval)creationDate;

- (id)initWithPath:(const char*)cPath type:(int)type stat:(struct stat*)stat;

- (BOOL)isValid;
- (NSInteger)updateStatus;

//- (void)attributesChanged;
- (NSURL*)fileURL;

@property (nonatomic,strong) NSAttributedString *displayFilename;
@property (nonatomic,strong) NSImage *fileIcon;
@property (nonatomic,strong) NSString *displayDirPath;

- (NSString*)dirPath;
- (NSDate*)dateModified;
- (NSDate*)dateCreated;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
