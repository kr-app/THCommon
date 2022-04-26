// THError.h

#ifdef TH_TARGET_OSX
	#import <Cocoa/Cocoa.h>
#elif defined TH_TARGET_IOS
	#import <UIKit/UIKit.h>
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
#define THErrorReason(log,...) _THLogReason(log,##__VA_ARGS__)
#define THErrorReasonFc(log,...) _THLogReasonFc(log,##__VA_ARGS__)

@interface THError : NSObject
{
	NSMutableArray *_infos;
}

+ (instancetype)errorWithMessage:(NSString*)message reason:(NSString*)reason;
+ (instancetype)errorWithMessage:(NSString*)message reason:(NSString*)reason depends:(id)depends;

@property (nonatomic) NSUInteger errorCount;
@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) NSString *reason;
@property (nonatomic,strong) id depends; // THError-NSError-NSString
@property (nonatomic) BOOL isNotified;

- (NSArray*)infos;
- (void)addInfo:(id)info forKey:(NSString*)key;

- (NSString*)initialErrorMessage;
- (NSArray*)errorsStack;

- (void)presentWIthTitle:(NSString*)title asSheetForWIndow:(NSWindow*)parentWindow;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
