// THLog.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
enum
{
	THLogSeverity_debug,
	THLogSeverity_info,
	THLogSeverity_warning,
	THLogSeverity_error,
	THLogSeverity_critical
};

@interface THLog : NSObject

#ifdef DEBUG
+ (void)logDebug:(nonnull NSString*)string;
#endif
+ (void)logInfo:(nonnull NSString*)string;
+ (void)logWarning:(nonnull NSString*)string;
+ (void)logError:(nonnull NSString*)string;
+ (void)logCriticalException:(nonnull NSString*)string;
+ (void)logWithSeverity:(NSInteger)severity string:(nonnull NSString*)string error:(nullable id)error;

+ (void)raiseCritialException:(nonnull NSString*)msg function:(nonnull NSString*)function file:(nonnull const char*)file line:(NSInteger)line;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
#define _THLogReason(_msg_,...)		[	NSString stringWithFormat:@"%s:%d %@ %@",sel_getName(_cmd),__LINE__,self,[NSString stringWithFormat:_msg_,##__VA_ARGS__]]
#define _THLogReasonFc(_msg_,...)		[NSString stringWithFormat:@"%s:%d %@",__FUNCTION__,__LINE__,[NSString stringWithFormat:_msg_,##__VA_ARGS__]]

// obj-c
#ifdef DEBUG
	#define THLogDebug(_log_,...)			[THLog logDebug:_THLogReason(_log_,##__VA_ARGS__)]
#else
	#define THLogDebug(_log_,...)
#endif
#define THLogInfo(_log_,...)					[THLog logInfo:_THLogReason(_log_,##__VA_ARGS__)]
#define THLogWarning(_log_,...)			[THLog logWarning:_THLogReason(_log_,##__VA_ARGS__)]
#define THLogError(_log_,...)					[THLog logError:_THLogReason(_log_,##__VA_ARGS__)]

// c
#ifdef DEBUG
	#define THLogDebugFc(_log_,...)		[THLog logDebug:_THLogReasonFc(_log_,##__VA_ARGS__)]
#else
	#define THLogDebugFc(_log_,...)
#endif
#define THLogInfoFc(_log_,...)				[THLog logInfo:_THLogReasonFc(_log_,##__VA_ARGS__)]
#define THLogWarningFc(_log_,...)		[THLog logWarning:_THLogReasonFc(_log_,##__VA_ARGS__)]
#define THLogErrorFc(_log_,...)				[THLog logError:_THLogReasonFc(_log_,##__VA_ARGS__)]

#define THException(_condition_,_msg_,...)		{ if (_condition_)\
																			{\
																				[THLog logCriticalException:_THLogReason(_msg_,##__VA_ARGS__)];\
																				[THLog raiseCritialException:[NSString stringWithFormat:_msg_,##__VA_ARGS__] function:[NSString stringWithFormat:@"%@ - %s",NSStringFromClass([self class]),sel_getName(_cmd)] file:__FILE__ line:__LINE__];\
																			}}
#define THExceptionFc(_condition_,_msg_,...)	{ if (_condition_)\
																			{\
																				[THLog logCriticalException:_THLogReasonFc(_msg_,##__VA_ARGS__)];\
																				[THLog raiseCritialException:[NSString stringWithFormat:_msg_,##__VA_ARGS__] function:[NSString stringWithFormat:@"%s",__FUNCTION__] file:__FILE__ line:__LINE__];\
																			}}
//--------------------------------------------------------------------------------------------------------------------------------------------
