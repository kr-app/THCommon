// THUnixCommand.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THUnixCommand : NSObject
+ (BOOL)executeCommand:(NSString*)command args:(NSArray*)args status:(NSInteger*)pStatus stdOut:(NSString**)pStdOut stdErr:(NSString**)pStdErr;
+ (BOOL)executeCommand:(NSString*)command args:(NSArray*)args environment:(NSDictionary*)environment currentDir:(NSString*)currentDir status:(NSInteger*)pStatus stdOut:(NSString**)pStdOut stdErr:(NSString**)pStdErr;
@end
//--------------------------------------------------------------------------------------------------------------------------------------------
