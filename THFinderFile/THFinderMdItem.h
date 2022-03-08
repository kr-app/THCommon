// THFinderMdItem.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THFinderMdItem : NSObject

+ (BOOL)setMdItemComment:(NSString*)comment atPath:(NSString*)path;
+ (BOOL)setMdItemWhereFroms:(NSArray*)whereFroms atPath:(NSString*)path;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
