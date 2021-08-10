// THFinderFileIcon.h

#import <Cocoa/Cocoa.h>
#import <QuickLook/QuickLook.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
typedef void(^THFinderFileIcon_updatedIconBk)(NSString *filePath, NSImage *icon);

@interface THFinderFileIcon : NSObject
{
	NSMutableDictionary *_fileIcons;
	NSMutableDictionary *_fileIconAliasMask;
	NSMutableDictionary *_previewIcons;
	NSMutableArray *_loadingPaths;
	NSMutableArray *_onErrorPaths;
}

+ (NSImage*)iconForFileAtPath:(NSString*)path size:(CGFloat)size;
+ (NSImage*)quickLookFileIconForFileAtURL:(NSURL*)fileURL size:(CGFloat)size bordered:(BOOL)bordered;

@property (nonatomic) CGFloat iconSize;
@property (nonatomic,copy) THFinderFileIcon_updatedIconBk updatedIconBk;

- (NSImage*)iconForFileAtPath:(NSString*)path aliasMask:(BOOL)aliasMask;
- (NSImage*)iconPreviewForFileAtPath:(NSString*)filePath fileURL:(NSURL*)fileURL canStartLoad:(BOOL)canStartLoad;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
