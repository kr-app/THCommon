// THSharedLoginItems.m

#import "THSharedLoginItems.h"
#import "THFoundation.h"
#import "THLog.h"
//#import "THCocoaExtensions.h"
#import "TH_APP-Swift.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface SharedFileList: NSObject
@end

@implementation SharedFileList

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (CFStringRef)sessionLoginItems { return kLSSharedFileListSessionLoginItems; }

+ (CFStringRef)favoriteItems { return kLSSharedFileListFavoriteItems; }

+ (LSSharedFileListItemRef)itemLast { return kLSSharedFileListItemLast; }

+ (CFStringRef)loginItemHidden { return kLSSharedFileListLoginItemHidden; }

static LSSharedFileListRef SharedFileListCreate(CFStringRef inListType, CFTypeRef listOptions)
{
	return LSSharedFileListCreate(NULL,inListType,listOptions);
}

static CFArrayRef SharedFileListCopySnapshot(LSSharedFileListRef inList, UInt32 *outSnapshotSeed)
{
	return LSSharedFileListCopySnapshot(inList,outSnapshotSeed);
}

static OSStatus SharedFileListItemResolve(	LSSharedFileListItemRef inItem,
																		LSSharedFileListResolutionFlags inFlags,
																		CFURLRef *outURL,
  																		FSRef *outRef)
{
	return LSSharedFileListItemResolve(inItem,inFlags,outURL,outRef);
}

static OSStatus SharedFileListItemRemove(LSSharedFileListRef inList, LSSharedFileListItemRef inItem)
{
	return LSSharedFileListItemRemove(inList,inItem);
}

static LSSharedFileListItemRef SharedFileListInsertItemURL(	LSSharedFileListRef inList,
																									LSSharedFileListItemRef insertAfterThisItem,
																									CFStringRef inDisplayName,
																									IconRef inIconRef,
																									CFURLRef inURL,
																									CFDictionaryRef inPropertiesToSet,
																									CFArrayRef inPropertiesToClear)
{
	return LSSharedFileListInsertItemURL(		inList,
																		insertAfterThisItem,
																		inDisplayName,
																		inIconRef,
																		inURL,
																	  	inPropertiesToSet,
																		inPropertiesToClear);
}

static CFStringRef SharedFileListItemCopyDisplayName(LSSharedFileListItemRef inItem)
{
	return LSSharedFileListItemCopyDisplayName(inItem);
}
#pragma clang diagnostic pop

@end
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THSharedLoginItems

+ (BOOL)addLoginItem:(NSURL*)loginItem
{
	if (loginItem==nil)
		return NO;
	
	LSSharedFileListRef loginItemList=SharedFileListCreate([SharedFileList sessionLoginItems],NULL);
	
	CFArrayRef snapshot=loginItemList==NULL?NULL:SharedFileListCopySnapshot(loginItemList,NULL);
	if (snapshot==NULL)
	{
		THLogError(@"snapshot==NULL");
		return NO;
	}
	
	BOOL hasCorrect=NO;
	NSString *loginItemName=[loginItem.path lastPathComponent];
	
	for (id anItem in (__bridge NSArray*)snapshot)
	{
		LSSharedFileListItemRef itemRef=(__bridge LSSharedFileListItemRef)anItem;
		CFURLRef urlRef=NULL;
		OSStatus status=SharedFileListItemResolve(itemRef,kLSSharedFileListNoUserInteraction|kLSSharedFileListDoNotMountVolumes,&urlRef,NULL);

		NSString *itemName=(__bridge NSString*)SharedFileListItemCopyDisplayName(itemRef);

		if (status==noErr)
		{
			NSString *itemPath=[(__bridge NSURL*)urlRef path];
			if ([itemPath isEqualToString:loginItem.path]==YES)
				hasCorrect=YES;
			else if ([itemName isEqualToString:loginItemName]==YES || [itemName isEqualToString:[loginItemName stringByDeletingPathExtension]]==YES)
			{
				OSStatus status=SharedFileListItemRemove(loginItemList,itemRef);
				if (status!=noErr)
					THLogError(@"SharedFileListItemRemove:%d urlRef:%@",status,(__bridge NSURL*)urlRef);
			}
		}
		else if (status==fnfErr)
		{
			if ([itemName isEqualToString:loginItemName]==YES || [itemName isEqualToString:[loginItemName stringByDeletingPathExtension]]==YES)
			{
				OSStatus status=SharedFileListItemRemove(loginItemList,itemRef);
				if (status!=noErr)
					THLogError(@"SharedFileListItemRemove:%d urlRef:%@",status,(__bridge NSURL*)urlRef);
			}
		}

		if (urlRef!=NULL)
			CFRelease(urlRef);
	}
	
	CFRelease(snapshot);
	
	if (hasCorrect==YES)
		return YES;

	NSDictionary *properties=[NSDictionary dictionaryWithObjectsAndKeys:@(NO),[SharedFileList loginItemHidden],nil];
	LSSharedFileListItemRef itemRef=SharedFileListInsertItemURL(	loginItemList,
																											[SharedFileList itemLast],
																											NULL,
																											NULL,
																											(__bridge CFURLRef)loginItem,
																											(__bridge CFDictionaryRef)properties,
																											NULL);
	if (itemRef!=NULL)
	{
		CFRelease(itemRef);
		return YES;
	}
	
	return NO;
}

+ (BOOL)removeLoginItem:(NSURL*)loginItem
{
	if (loginItem==nil)
		return NO;
	
	LSSharedFileListRef loginItemList=SharedFileListCreate([SharedFileList sessionLoginItems],NULL);
	CFArrayRef snapshot=loginItemList==NULL?NULL:SharedFileListCopySnapshot(loginItemList,NULL);
	if (snapshot==NULL)
	{
		THLogError(@"snapshot==NULL");
		return NO;
	}
	
	BOOL founds=NO;
	NSString *loginItemName=[loginItem.path lastPathComponent];
	
	for (id anItem in (__bridge NSArray*)snapshot)
	{
		LSSharedFileListItemRef itemRef=(__bridge LSSharedFileListItemRef)anItem;
		CFURLRef urlRef=NULL;
		OSStatus status=SharedFileListItemResolve(itemRef,kLSSharedFileListNoUserInteraction|kLSSharedFileListDoNotMountVolumes,&urlRef,NULL);
		
		NSString *itemName=(__bridge NSString*)SharedFileListItemCopyDisplayName(itemRef);
		
		if (status==noErr)
		{
			NSString *itemPath=[(__bridge NSURL*)urlRef path];
			if ([itemPath isEqualToString:loginItem.path]==YES || [itemName isEqualToString:loginItemName]==YES || [itemName isEqualToString:[loginItemName stringByDeletingPathExtension]]==YES)
			{
				founds=YES;
				OSStatus status=SharedFileListItemRemove(loginItemList,itemRef);
				if (status!=noErr)
					THLogError(@"SharedFileListItemRemove:%d urlRef:%@",status,(__bridge NSURL*)urlRef);
			}
		}
		else if (status==fnfErr)
		{
			if ([itemName isEqualToString:loginItemName]==YES || [itemName isEqualToString:[loginItemName stringByDeletingPathExtension]]==YES)
			{
				founds=YES;
				OSStatus status=SharedFileListItemRemove(loginItemList,itemRef);
				if (status!=noErr)
					THLogError(@"SharedFileListItemRemove:%d urlRef:%@",status,(__bridge NSURL*)urlRef);
			}
		}
		
		if (urlRef!=NULL)
			CFRelease(urlRef);
	}
	
	CFRelease(snapshot);
	
	return founds;
}

+ (NSString*)statusForLoginItem:(NSURL*)loginItem
{
	if (loginItem==nil)
		return nil;
	
	LSSharedFileListRef loginItemList=SharedFileListCreate([SharedFileList sessionLoginItems],NULL);
	CFArrayRef snapshot=loginItemList==NULL?NULL:SharedFileListCopySnapshot(loginItemList,NULL);
	if (snapshot==NULL)
	{
		THLogError(@"snapshot==NULL");
		return nil;
	}
	
	NSString *validStatus=nil;
	NSString *loginItemName=loginItem.path.lastPathComponent;
	
	for (id anItem in (__bridge NSArray*)snapshot)
	{
		LSSharedFileListItemRef itemRef=(__bridge LSSharedFileListItemRef)anItem;
		CFURLRef urlRef=NULL;
		OSStatus status=SharedFileListItemResolve(itemRef,kLSSharedFileListNoUserInteraction|kLSSharedFileListDoNotMountVolumes,&urlRef,NULL);
		
		NSString *itemName=CFBridgingRelease(SharedFileListItemCopyDisplayName(itemRef));
		
		if (status==noErr)
		{
			NSString *itemPath=[(__bridge NSURL*)urlRef path];
			if ([itemPath isEqualToString:loginItem.path]==YES)
				validStatus=@"valid";
			else if ([itemName isEqualToString:loginItemName]==YES || [itemName isEqualToString:[loginItemName stringByDeletingPathExtension]]==YES)
				validStatus=@"invalid";
		}
		else if (status==fnfErr)
		{
			if ([itemName isEqualToString:loginItemName]==YES || [itemName isEqualToString:[loginItemName stringByDeletingPathExtension]]==YES)
				validStatus=@"invalid";
		}
		
		if (urlRef!=NULL)
			CFRelease(urlRef);
	}

	CFRelease(snapshot);

	return validStatus;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
