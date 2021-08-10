// THSharedLoginItems.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THSharedLoginItems : NSObject

+ (BOOL)addLoginItem:(NSURL*)loginItem;
+ (BOOL)removeLoginItem:(NSURL*)loginItem;
+ (NSString*)statusForLoginItem:(NSURL*)loginItem;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
