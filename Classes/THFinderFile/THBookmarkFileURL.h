// THBookmarkFileURL.h

#ifdef TH_TARGET_OSX
#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
typedef enum
{
	THBookmarkFileURLStatus_error=0,
	THBookmarkFileURLStatus_ok=1
} THBookmarkFileURLStatus;

typedef struct THBookmarkFileURLStatInfo
{
	dev_t st_dev;
	ino_t st_ino;
	mode_t st_mode;
	struct timespec st_mtimespec;
	off_t st_size;
} THBookmarkFileURLStatInfo;

@interface THBookmarkFileURL : NSObject
{
	NSURL *_URL;
	NSString *_path;

	THBookmarkFileURLStatus _status;
	THBookmarkFileURLStatInfo _statInfo;
	NSData *_bookmarkData;
	NSString *_serializedPath;

	NSString *_displayName;
	NSImage *_icon;
}

- (NSURL*)URL;
- (NSString*)path;
- (THBookmarkFileURLStatus)status;

- (id)initWithURL:(NSURL*)URL path:(NSString*)path updateStatus:(BOOL)updateStatus;

- (NSDictionary*)dictionaryRepresentation;
- (id)initWithDictionaryRepresentation:(NSDictionary*)dictionaryRepresentation;

- (void)updateStatus;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THBookmarkFileURL (Extensions)

- (NSString*)displayName;
- (NSImage*)displayIcon;
- (NSImage*)updatedDisplayIcon;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
#endif
