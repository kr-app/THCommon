// THFinderTools.h

#import <Cocoa/Cocoa.h>
#import "THFileXattr.h"
#import "THSpecialFilename.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THFinderTools : NSObject

+ (BOOL)displayFinderGetInfoOfPath:(NSString*)path;

+ (BOOL)isSystemFileNameInFolder:(NSString*)fileName mode:(NSInteger)mode;
+ (BOOL)isVolumeHiddenFilename:(NSString*)filename;
+ (BOOL)isVolumeSystemHiddenFilename:(NSString*)filename mode:(NSInteger)mode;

+ (NSArray*)finderLabels;
+ (NSImage*)iconWithAliasMaskForType:(NSString*)type;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
