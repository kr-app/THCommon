// THAsScriptEnlacement.h

#import <Cocoa/Cocoa.h>

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#ifdef DEBUG
@interface THAsScriptEnlacement : NSObject

+ (nullable NSString*)encodeScript:(nonnull NSString*)sourcePath outFilePath:(nullable NSString*)outFilePath;
+ (void)autoEnlaceScripts:(nullable NSString*)dirPath;

@end
#endif
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
