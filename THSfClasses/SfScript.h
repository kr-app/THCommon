// SfScript.h

#import <Cocoa/Cocoa.h>

//typedef struct THAsBoundsRect
//{
//	int left_x;
//	int top_y;
//	int right_x;
//	int bottom_y;
//} THAsBoundsRect;
//
//NSString *THAsBoundsRectToString(THAsBoundsRect bounds);
//THAsBoundsRect THAsBoundsRectFromString(NSString *string);

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface SfScript : NSObject

#ifdef DEBUG
+ (void)autoEnlaceScripts;
#endif

+ (nonnull NSString*)source_TakeSnapshot;
+ (nonnull NSString*)source_RestoreSwitch;
+ (nonnull NSString*)source_DeleteWindows;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
