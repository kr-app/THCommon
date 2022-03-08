// THFinderMdItem.m

#import "THFinderMdItem.h"
#import "THLog.h"
#include <sys/xattr.h> // xattr

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THFinderMdItem

+ (BOOL)setMdPropertyListObject:(id)anObject withKey:(const char*)key toFileAtPath:(const char*)path
{
	CFErrorRef error=NULL;
	CFDataRef data=CFPropertyListCreateData(NULL, (__bridge CFPropertyListRef)anObject, kCFPropertyListBinaryFormat_v1_0,0,&error);
	if (data==NULL)
	{
		THLogError(@"data==NULL");
		return NO;
	}

	const void *bytes=CFDataGetBytePtr(data);
	size_t bytesCount=CFDataGetLength(data);

	if (setxattr(path,key,bytes,bytesCount,0,XATTR_NOFOLLOW)!=0)
	{
		THLogError(@"setxattr!=0 path:%s errno:%d (%s)",path,errno,strerror(errno));
		return NO;
	}

	CFRelease(data);

	return YES;
}

+ (BOOL)setMdItemComment:(NSString*)comment atPath:(NSString*)path
{
	const char *c_path=[path fileSystemRepresentation];
	//const char *cmt=comment==nil?NULL:[comment UTF8String];
	const char *key="com.apple.metadata:kMDItemFinderComment";

	if ([self setMdPropertyListObject:comment withKey:key toFileAtPath:c_path]==NO)
	{
		THLogError(@"setMdPropertyListObject==NO comment:%@ path:%@",comment,path);
		return NO;
	}

	return YES;//THSetExtendedAttribute(cmt,comment==nil?0:strlen(cmt),key,path.fileSystemRepresentation)==true?YES:NO;
}

+ (BOOL)setMdItemWhereFroms:(NSArray*)whereFroms atPath:(NSString*)path
{
	const char *c_path=[path fileSystemRepresentation];
	const char *key="com.apple.metadata:kMDItemWhereFroms";

	if (whereFroms.count==0)
	{
		if (removexattr(c_path,key,XATTR_NOFOLLOW)!=0)
		{
			THLogError(@"removexattr!=0 path:%@ errno:%d (%s)",path,errno,strerror(errno));
			return NO;
		}
		return YES;
	}

	for (id whereFrom in whereFroms)
	{
		if ([whereFrom isKindOfClass:[NSString class]]==NO)
		{
			THLogError(@"all items of whereFroms should be NSString object. whereFroms:%@ path:%@",whereFroms,path);
			return NO;
		}
	}

//	NSData *data=nil;
//	NS_DURING
//		data=[NSArchiver archivedDataWithRootObject:whereFroms];
//	NS_HANDLER
//		THLogError(@"data==nil whereFroms:%@ localException:%@",whereFroms,localException);
//		return NO;
//	NS_ENDHANDLER

	if ([self setMdPropertyListObject:whereFroms withKey:key toFileAtPath:c_path]==NO)
	{
		THLogError(@"setMdPropertyListObject==NO whereFroms:%@ path:%@",whereFroms,path);
		return NO;
	}

	return YES;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
