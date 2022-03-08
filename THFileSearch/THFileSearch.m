// THFileSearch.m

#import "THFileSearch.h"
#import "TH_APP-Swift.h"
#include <sys/stat.h> // stat
#include <sys/xattr.h> // xattr
#include <errno.h> // xattr

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THFileSearch

#define IsDirEntrySystemName(_name_,_nameL_) 			((_nameL_==1 && _name_[0]=='.') || (_nameL_==2 && _name_[0]=='.' && _name_[1]=='.'))
#define IsDirEntryDSStoreName(_name_,_nameL_) 			(_nameL_==9 && strcmp(_name_,".DS_Store")==0)
#define IsDirEntryTrashDirName(_name_,_nameL_) 			(_nameL_==6 && strcmp(_name_,".Trash")==0)

//ajouter kind ds_store? exclusion par default ?

NSString *THFileSearchUTIType_RegFile=@"THFileSearchUTIType_RegFile";
NSString *THFileSearchUTIType_Directorty=@"THFileSearchUTIType_Directorty";
NSString *THFileSearchUTIType_SymLink=@"THFileSearchUTIType_SymLink";
NSString *THFileSearchUTIType_DSStore=@"THFileSearchUTIType_DSStore";

typedef struct THFileSearchFilterExcludedPath
{
	const char *path;
	size_t pathLen;
	const void *next;
} THFileSearchFilterExcludedPath;

typedef struct THFileSearchFilterStruct
{
	NSInteger kind;
	NSInteger op;

	const char *fileName;
	size_t fileNameLen;
	off_t fileSize;
	__darwin_time_t fileDate;
	int entType;
	CFStringRef valueStrRef;
} THFileSearchFilterStruct;

+ (NSArray*)criteriaWithKind:(NSInteger)kind criteria:(NSArray*)criteria
{
	NSMutableArray *r=[NSMutableArray array];
	for (NSDictionary *c in criteria)
		if ([c[@"kind"] integerValue]==kind)
			[r addObject:c];
	return r;
}

- (void)canonisateCriterionKind:(NSInteger)kind criteria:(NSArray*)criteria
						 			searchFilter:(THFileSearchFilterStruct*)filters filtersCount:(int*)filtersCount
									calendar:(NSCalendar*)calendar now:(NSDate*)now todayMidnight:(NSDate*)todayMidnight
{
	for (NSDictionary *criterion in criteria)
	{
		if ([criterion[@"kind"] integerValue]!=kind)
			continue;

		NSInteger op=[criterion[@"operator"] integerValue];

		THFileSearchFilterStruct *filter=&filters[(*filtersCount)];
		BOOL isCorrect=NO;

		if (kind==THFileSearchCriterion_fileName)
		{
			if (		op==THFileSearchOperator_contains ||
				 	op==THFileSearchOperator_doesNotContain ||
					op==THFileSearchOperator_beginsWith ||
					op==THFileSearchOperator_endsWith||
					op==THFileSearchOperator_is ||
					op==THFileSearchOperator_isNot)
			{
				NSString *value=[criterion[@"value"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				const char *c_value=value.decomposedStringWithCanonicalMapping.UTF8String;
				c_value=c_value!=NULL?strdup(c_value):NULL;

				if (value.length>0 && c_value!=NULL)
				{
					filter->fileName=c_value;
					filter->fileNameLen=strlen(c_value);
					isCorrect=YES;
				}
			}
		}
		else if (kind==THFileSearchCriterion_fileSize)
		{
			if (op==THFileSearchOperator_lessThan || op==THFileSearchOperator_greaterThan)
			{
				NSNumber *value=criterion[@"value"];
				if (value!=nil)
				{
					filter->fileSize=(off_t)[value longLongValue];
					isCorrect=YES;
				}
			}
		}
		else if (kind==THFileSearchCriterion_UTIType)
		{
			if (op==THFileSearchOperator_is || op==THFileSearchOperator_isNot)
			{
				NSString *value=criterion[@"value"];
				if (value!=nil && value.length>0)
				{
					if ([value isEqualToString:THFileSearchUTIType_RegFile]==YES)
						filter->entType=DT_REG;
					else if ([value isEqualToString:THFileSearchUTIType_Directorty]==YES)
						filter->entType=DT_DIR;
					else if ([value isEqualToString:THFileSearchUTIType_SymLink]==YES)
						filter->entType=DT_LNK;
					else if ([value isEqualToString:THFileSearchUTIType_DSStore]==YES)
					{
						filter->fileName=".DS_Store";
						filter->fileNameLen=strlen(filter->fileName);
					}
					else
						filter->valueStrRef=CFStringCreateCopy(NULL,(__bridge CFStringRef)value);
					isCorrect=YES;
				}
			}
		}
		else if (kind==THFileSearchCriterion_dateCreated || kind==THFileSearchCriterion_dateModified)
		{
			NSDate *date=nil;
			if (op==THFileSearchOperator_dateExactlyDay || op==THFileSearchOperator_dateBefore || op==THFileSearchOperator_dateAfter)
			{
				NSDate *value=criterion[@"value"];
				NSDateComponents *comps=value==nil?nil:[calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:value];
				date=comps==nil?nil:[calendar dateFromComponents:comps];
			}
			else if (op==THFileSearchOperator_dateToday)
				date=todayMidnight;
			else if (op==THFileSearchOperator_dateLastHour)
				date=[now dateByAddingTimeInterval:-3600.0];
			else if (op==THFileSearchOperator_dateLast6Hours)
				date=[now dateByAddingTimeInterval:-3600.0*6.0];
			else if (op==THFileSearchOperator_dateYesterday)
				date=[calendar dateByAddingComponents:[[NSDateComponents alloc] initWithYear:0 month:0 day:-1] toDate:todayMidnight options:0];
			else if (op==THFileSearchOperator_dateWithinLast)
			{
				NSArray *comps=[(NSString*)criterion[@"value"] componentsSeparatedByString:@"|"];
				NSInteger value=[(NSString*)comps[0] integerValue];
				NSInteger unit=[(NSString*)comps[1] integerValue];

				if (unit==THFileSearchUnit_day)
					date=[calendar dateByAddingComponents:[[NSDateComponents alloc] initWithYear:0 month:0 day:-value] toDate:todayMidnight options:0];
				else if (unit==THFileSearchUnit_week)
					date=[calendar dateByAddingComponents:[[NSDateComponents alloc] initWithYear:0 month:0 day:-value*7] toDate:todayMidnight options:0];
				else if (unit==THFileSearchUnit_month)
					date=[calendar dateByAddingComponents:[[NSDateComponents alloc] initWithYear:0 month:-value day:0] toDate:todayMidnight options:0];
				else if (unit==THFileSearchUnit_year)
					date=[calendar dateByAddingComponents:[[NSDateComponents alloc] initWithYear:-value month:0 day:0] toDate:todayMidnight options:0];
				else if (unit==THFileSearchUnit_hour)
					date=[calendar dateByAddingComponents:[[NSDateComponents alloc] initWithHour:-value min:0 sec:0] toDate:now options:0];
				else if (unit==THFileSearchUnit_min)
					date=[calendar dateByAddingComponents:[[NSDateComponents alloc] initWithHour:0 min:-value sec:0] toDate:now options:0];
			}

			if (date!=nil)
			{
				filter->fileDate=(__darwin_time_t)[date timeIntervalSince1970];
				isCorrect=YES;
			}
		}
		else if (kind==THFileSearchCriterion_tagNames)
		{
			NSString *value=[criterion[@"value"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			if (value.length>0)
			{
				filter->valueStrRef=CFStringCreateCopy(NULL,(__bridge CFStringRef)value);
				isCorrect=YES;
			}
		}
		else if (kind==THFileSearchCriterion_xAttrs)
		{
			if (op==THFileSearchOperator_isDefined || op==THFileSearchOperator_isNotDefined)
			{
				NSString *value=[criterion[@"value"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				const char *c_value=value.decomposedStringWithCanonicalMapping.UTF8String;
				c_value=c_value!=NULL?strdup(c_value):NULL;

				if (value.length>0 && c_value!=NULL)
				{
					filter->fileName=c_value;
					filter->fileNameLen=strlen(c_value);
					isCorrect=YES;
				}
			}
		}

		if (isCorrect==NO)
		{
			THLogErrorFc(@"isCorrect==NO criterion:%@",criterion);
			continue;
		}

		filter->kind=kind;
		filter->op=op;

		(*filtersCount)+=1;
	}
}

- (void)performSearchInDirectory:(NSString*)scopeDir criteria:(NSArray*)criteria didPerformBk:(THFileSearch_didPerformBk)didPerformBk
{
	THException(scopeDir==nil,@"scopeDir==nil");
	THException(criteria.count==0,@"_criteria.count==0");

	_isCancelled=NO;

	NSMutableArray *scopeDirs=[NSMutableArray array];
	THFileSearchFilterExcludedPath *excludedPaths=NULL;
	THFileSearchFilterExcludedPath *excludedPathLast=NULL;

	for (NSDictionary *criterion in [THFileSearch criteriaWithKind:THFileSearchCriterion_dirPaths criteria:criteria])
	{
		NSInteger op=[criterion[@"operator"] integerValue];
		for (NSString *path in criterion[@"value"])
		{
			if (path==nil || [path hasPrefix:scopeDir]==NO)
				continue;
			if (op==THFileSearchOperator_is)
			{
				[scopeDirs addObject:path];
			}
			else if (op==THFileSearchOperator_isNot)
			{
				const char *c_path=path.fileSystemRepresentation;
				if (c_path==NULL)
					continue;
				THFileSearchFilterExcludedPath *ep=malloc(sizeof(THFileSearchFilterExcludedPath));
				bzero(ep,sizeof(THFileSearchFilterExcludedPath));
				if (excludedPaths==NULL)
					excludedPaths=ep;
				else
					excludedPathLast->next=ep;
				ep->path=strdup(c_path);
				ep->pathLen=strlen(ep->path);
				excludedPathLast=ep;
			}
		}
	}

	int exclude_DS_Store=1;
	for (NSDictionary *criterion in [THFileSearch criteriaWithKind:THFileSearchCriterion_UTIType criteria:criteria])
	{
		NSInteger op=[criterion[@"operator"] integerValue];
		if (op==THFileSearchOperator_is || op==THFileSearchOperator_isNot)
		{
			NSString *value=criterion[@"value"];
			if ([value isKindOfClass:[NSString class]]==YES && [value isEqualToString:THFileSearchUTIType_DSStore]==YES)
				exclude_DS_Store=0;
		}
	}
	
	int includeTraskDir=0;
	for (NSDictionary *criterion in [THFileSearch criteriaWithKind:THFileSearchCriterion_options criteria:criteria])
	{
		NSInteger op=[criterion[@"operator"] integerValue];
		if (op==THFileSearchOperator_is)
		{
			NSNumber *options=criterion[@"value"];
			if (options!=nil && [options isKindOfClass:[NSNumber class]]==YES)
			{
				if ((options.integerValue&THFileSearchInclude_TrashDir)!=0)
					includeTraskDir=1;
			}
		}
	}

	if (scopeDirs.count==0)
		[scopeDirs addObject:scopeDir];

	THFileSearchFilterStruct *filters=malloc(sizeof(THFileSearchFilterStruct)*criteria.count);
	bzero(filters,sizeof(THFileSearchFilterStruct)*criteria.count);

	int filtersCount=0;
	NSCalendar *calendar=[NSCalendar currentCalendar];
	NSDate *now=[NSDate date];
	NSDate *todayMidnight=[now th_dateAtMidnight];

	[self canonisateCriterionKind:THFileSearchCriterion_fileSize criteria:criteria searchFilter:filters filtersCount:&filtersCount calendar:nil now:nil todayMidnight:nil];
	[self canonisateCriterionKind:THFileSearchCriterion_dateCreated criteria:criteria searchFilter:filters filtersCount:&filtersCount calendar:calendar now:now todayMidnight:todayMidnight];
	[self canonisateCriterionKind:THFileSearchCriterion_dateModified criteria:criteria searchFilter:filters filtersCount:&filtersCount calendar:calendar now:now todayMidnight:todayMidnight];
	[self canonisateCriterionKind:THFileSearchCriterion_fileName criteria:criteria searchFilter:filters filtersCount:&filtersCount calendar:nil now:nil todayMidnight:nil];
	[self canonisateCriterionKind:THFileSearchCriterion_tagNames criteria:criteria searchFilter:filters filtersCount:&filtersCount calendar:nil now:nil todayMidnight:nil];
	[self canonisateCriterionKind:THFileSearchCriterion_UTIType criteria:criteria searchFilter:filters filtersCount:&filtersCount calendar:nil now:nil todayMidnight:nil];
	[self canonisateCriterionKind:THFileSearchCriterion_xAttrs criteria:criteria searchFilter:filters filtersCount:&filtersCount calendar:nil now:nil todayMidnight:nil];

	long long statistics[3]={0,0,0}; // nbFiles, nbDirs, nbLinks

	if (filtersCount==0)
		THLogError(@"filtersCount==0 criteria:%@",criteria);
	else
	{
		THCBufferContainer bufferContainer=THCBufferContainerNew(128*TH_Mio,false);
		for (NSString *scopeDir in scopeDirs)
		{
			int r=PerformSearchInDirectory(			[scopeDir fileSystemRepresentation],
																		exclude_DS_Store,
										   								includeTraskDir,
																		excludedPaths,
																		filters,filtersCount,
																		&bufferContainer,
																		&_isCancelled,
																		statistics,
																		didPerformBk);
			if (r==1)
				;//[self pushEndResult];
			else if (r==0)
				THLogInfo(@"PerformSearchInDirectory cancelled scopeDir:%@",scopeDir);
			else
				THLogError(@"PerformSearchInDirectory:%d scopeDir:%@",(int)r,scopeDir);
		}
		THCBufferContainerFree(&bufferContainer);
	}

	didPerformBk(2,NULL,NULL,statistics);
}

- (void)cancelSearch
{
	_isCancelled=YES;
}

static CFStringRef UTI_TypeOfFilePath_needCFRelease(const  char *filePath)
{
	FSRef fileRef;
	OSStatus status=FSPathMakeRef((const UInt8*)filePath,&fileRef,NULL);
	if (status!=noErr)
	{
		THLogErrorFc(@"FSPathMakeRef:%d filePath:%s",status,filePath);
		return NULL;
	}

	static CFArrayRef attrNames=NULL;
	if (attrNames==NULL)
	{
		CFStringRef attrs[1]={kLSItemContentType};
		attrNames=CFArrayCreate(NULL,(const void **)attrs,1,NULL);
	}

	CFDictionaryRef values=NULL;
	status=LSCopyItemAttributes(&fileRef,kLSRolesViewer,attrNames,&values);
	if (status!=noErr || values==NULL)
	{
		THLogErrorFc(@"LSCopyItemAttributes:%d || values==NULL filePath:%s",status,filePath);
		return NULL;
	}

	CFTypeRef uti=CFDictionaryGetValue(values,kLSItemContentType);
	CFRetain(uti);

	CFRelease(values);

	return (CFStringRef)uti;
}

static CFArrayRef MD_TagNamesOfFilePath(const  char *filePath, THCBufferContainer *bufferContainer)
{
	ssize_t avSize=getxattr(filePath,"com.apple.metadata:_kMDItemUserTags",NULL,0,0,XATTR_NOFOLLOW);
	if (avSize<=0)
		return NULL;

	if (THCBufferContainerSetSize(bufferContainer,avSize)==false)
	{
		THLogErrorFc(@"THCBufferContainerSetSize==false filePath:%s",filePath);
		return NULL;
	}
	
	ssize_t sz=getxattr(filePath,"com.apple.metadata:_kMDItemUserTags",bufferContainer->ptr,avSize,0,XATTR_NOFOLLOW);
	if (sz!=avSize)
	{
		THLogErrorFc(@"sz!=avSize (%ld/%ld) filePath:%s",sz,avSize,filePath);
		return NULL;
	}

	CFDataRef dataRef=CFDataCreateWithBytesNoCopy(kCFAllocatorDefault,(const UInt8*)bufferContainer->ptr,(CFIndex)sz,kCFAllocatorNull);
	if (dataRef==NULL)
	{
		THLogErrorFc(@"dataRef==NULL filePath:%s",filePath);
		return NULL;
	}

	CFErrorRef errorRef=NULL;
	CFPropertyListRef propertyListRef=CFPropertyListCreateWithData(kCFAllocatorDefault,dataRef,kCFPropertyListImmutable,NULL,&errorRef);
	CFRelease(dataRef);

	if (propertyListRef==NULL)
	{
		THLogErrorFc(@"propertyListRef==NULL filePath:%s",filePath);
		return NULL;
	}

	if (CFGetTypeID(propertyListRef)!=CFArrayGetTypeID())
	{
		THLogErrorFc(@"propertyListRef!=CFArrayGetTypeID filePath:%s",filePath);
		return NULL;
	}

	return propertyListRef;
}
	
static bool EntryFileNameMatchWithFilters(	const char *name, size_t nameL,
																								const THFileSearchFilterStruct *filters, int filtersCount)
{
	for (int i=0;i<filtersCount;i++)
	{
		const THFileSearchFilterStruct *filter=&filters[i];

		if (filter->kind==THFileSearchCriterion_fileName)
		{
			if (filter->op==THFileSearchOperator_contains)
			{
				if (filter->fileNameLen>nameL)
					return false;

//				const char *c0=[NSString stringWithUTF8String:name].precomposedStringWithCanonicalMapping.UTF8String;
//				const char *c1=[NSString stringWithUTF8String:name].precomposedStringWithCompatibilityMapping.UTF8String;
//				const char *c2=[NSString stringWithUTF8String:name].decomposedStringWithCanonicalMapping.UTF8String;
//				const char *c3=[NSString stringWithUTF8String:name].decomposedStringWithCompatibilityMapping.UTF8String;

//				name,filter->fileName

				char *ptr=strcasestr(name,filter->fileName);
				if (ptr==NULL)
					return false;
			}
			else if (filter->op==THFileSearchOperator_doesNotContain)
			{
				if (filter->fileNameLen<=nameL)
				{
					char *ptr=strcasestr(name,filter->fileName);
					if (ptr!=NULL)
						return false;
				}
			}
			else if (filter->op==THFileSearchOperator_beginsWith)
			{
				if (filter->fileNameLen>nameL)
					return false;
				char *ptr=strcasestr(name,filter->fileName);
				if (ptr==NULL || ptr!=name)
					return false;
			}
			else if (filter->op==THFileSearchOperator_endsWith)
			{
				if (filter->fileNameLen>nameL)
					return false;
				char *ptr=strcasestr(name,filter->fileName);
				if (ptr==NULL || (ptr+filter->fileNameLen)!=(name+nameL))
					return false;
			}
			else if (filter->op==THFileSearchOperator_is)
			{
				if (filter->fileNameLen!=nameL)
					return false;
				if (strcasecmp(filter->fileName,name)!=0)
					return false;
			}
			else if (filter->op==THFileSearchOperator_isNot)
			{
				if (filter->fileNameLen>nameL)
					return false;
				if (strcasecmp(filter->fileName,name)==0)
					return false;
			}
		}
		else if (filter->kind==THFileSearchCriterion_UTIType)
		{
			if (filter->fileName!=NULL)
			{
				// strcmp pour .DS_Store
				if (filter->op==THFileSearchOperator_is && (nameL!=filter->fileNameLen || strcmp(filter->fileName,name)!=0))
					return false;
				else if (filter->op==THFileSearchOperator_isNot && nameL==filter->fileNameLen && strcmp(filter->fileName,name)==0)
					return false;
			}
		}
	}

	return true;
}

static bool EntryMatchWithFilters(			const char *path, int entType, const struct stat *st,
											 										const THFileSearchFilterStruct *filters, int filtersCount,
											 										THCBufferContainer *bufferContainer)
{
	for (int i=0;i<filtersCount;i++)
	{
		const THFileSearchFilterStruct *filter=&filters[i];
		if (filter->kind==THFileSearchCriterion_fileSize)
		{
			if (entType!=DT_REG)
				return false;
			if (filter->op==THFileSearchOperator_lessThan)
			{
				if (st->st_size>filter->fileSize)
					return false;
			}
			else if (filter->op==THFileSearchOperator_greaterThan)
			{
				if (st->st_size<filter->fileSize)
					return false;
			}
		}
		else if (filter->kind==THFileSearchCriterion_UTIType)
		{
			if (filter->entType!=0)
			{
				if (filter->op==THFileSearchOperator_is && filter->entType!=entType)
					return false;
				else if (filter->op==THFileSearchOperator_isNot && filter->entType==entType)
					return false;
			}
			else if (filter->fileName!=NULL)
			{
			}
			else
			{
				if (entType!=DT_REG && entType!=DT_DIR)
					return false;
				if (filter->op==THFileSearchOperator_is)
				{
					CFStringRef pathUtiTipe=UTI_TypeOfFilePath_needCFRelease(path);
					if (pathUtiTipe==NULL)
						return false;
					Boolean isConform=UTTypeConformsTo(pathUtiTipe,filter->valueStrRef);
					CFRelease(pathUtiTipe);
					if (isConform==false)
						return false;
				}
				else if (filter->op==THFileSearchOperator_isNot)
				{
					CFStringRef pathUtiTipe=UTI_TypeOfFilePath_needCFRelease(path);
					if (pathUtiTipe!=NULL)
					{
						Boolean isConform=UTTypeConformsTo(pathUtiTipe,filter->valueStrRef);
						CFRelease(pathUtiTipe);
						if (isConform==true)
							return false;
					}
				}
			}
		}
		else if (filter->kind==THFileSearchCriterion_dateCreated || filter->kind==THFileSearchCriterion_dateModified)
		{
			__darwin_time_t date=0;

			if (filter->kind==THFileSearchCriterion_dateCreated)
				date=st->st_birthtimespec.tv_sec;
			else if (filter->kind==THFileSearchCriterion_dateModified)
				date=st->st_mtimespec.tv_sec;

			__darwin_time_t daySec=3600*24;

			if (filter->op==THFileSearchOperator_dateExactlyDay)
			{
				if ((date<filter->fileDate) || (date>(filter->fileDate+daySec)))
					return false;
			}
			else if (filter->op==THFileSearchOperator_dateBefore)
			{
				if (date>=filter->fileDate)
					return false;
			}
			else if (filter->op==THFileSearchOperator_dateAfter)
			{
				if (date<=(filter->fileDate+daySec))
					return false;
			}
			else if (filter->op==THFileSearchOperator_dateLastHour || filter->op==THFileSearchOperator_dateLast6Hours)
			{
				if (date<filter->fileDate)
					return false;
			}
			else if (filter->op==THFileSearchOperator_dateToday || filter->op==THFileSearchOperator_dateYesterday)
			{
				if ((date<filter->fileDate) || (date>(filter->fileDate+daySec)))
					return false;
			}
			else if (filter->op==THFileSearchOperator_dateWithinLast)
			{
				if (date<filter->fileDate)
					return false;
			}
		}
		else if (filter->kind==THFileSearchCriterion_tagNames)
		{
			if (entType!=DT_REG && entType!=DT_DIR)
				return false;

			CFArrayRef tagNames=MD_TagNamesOfFilePath(path,bufferContainer);
			if (tagNames==NULL)
				return false;

			CFIndex namesCount=CFArrayGetCount(tagNames);
			bool isFound=false;

			for (CFIndex i=0;i<namesCount;i++)
			{
				CFTypeRef valueRef=CFArrayGetValueAtIndex(tagNames,i);
				if (valueRef!=NULL && CFGetTypeID(valueRef)==CFStringGetTypeID())
				{
					CFRange range=CFRangeMake(0,CFStringGetLength(valueRef));
					if (CFStringFindWithOptions(valueRef,filter->valueStrRef,range,kCFCompareCaseInsensitive,NULL)==true)
					{
						isFound=true;
						break;
					}
				}
			}

			CFRelease(tagNames);

			if (isFound==false)
				return false;
		}
		else if (filter->kind==THFileSearchCriterion_xAttrs)
		{
			if (entType!=DT_REG && entType!=DT_DIR)
				return false;

			ssize_t namesSz=listxattr(path,NULL,0,XATTR_NOFOLLOW);
			bool isFound=false;

			if (namesSz>0)
			{
				if (THCBufferContainerSetSize(bufferContainer,(size_t)namesSz)==false)
				{
					THLogErrorFc(@"THCBufferContainerSetSize==false");
					return false;
				}

				if (listxattr(path,bufferContainer->ptr,namesSz,XATTR_NOFOLLOW)!=namesSz)
				{
					int errNo=errno;
					THLogErrorFc(@"listxattr!=namesSz errno:%d (%s)",errNo,strerror(errNo));
					return false;
				}

				size_t namesOffset=0;
				while (namesOffset<namesSz)
				{
					const char *name=bufferContainer->ptr+namesOffset;
					size_t nameLen=strlen(name);
					namesOffset+=nameLen+1;

					if (filter->fileNameLen!=nameLen || strcmp(name,filter->fileName)!=0)
						continue;

					isFound=true;
					break;
				}
			}

			if (filter->op==THFileSearchOperator_isDefined && isFound==false)
				return false;
			if (filter->op==THFileSearchOperator_isNotDefined && isFound==true)
				return false;
		}

//		//MDItemCreate(<#CFAllocatorRef allocator#>, <#CFStringRef path#>)
//		CFArrayRef arr = MDItemCopyAttributeNames(mdItem);

//		CFDictionaryRef dic = MDItemCopyAttributes(mdItem, arr);
//		NSLog(@"%@", dic);

		
	}
	
	return true;
}

static bool IsExcludedVolumeFileName(const char *name, size_t len)
{
	if (len>10)
		return false;
	if (len==3 && strcmp(name,"dev")==0)
		return true;
	if (len==4 && strcmp(name,"home")==0)
		return true;
	if (len==3 && strcmp(name,"net")==0)
		return true;
	if (len==7 && strcmp(name,"Network")==0)
		return true;
	if (len==7 && strcmp(name,"Volumes")==0)
		return true;
	if (len==29 && strcmp(name,".HFS+ Private Directory Data\r")==0)
		return true;
	return false;
}

/*static bool IsFileNameExcludedHidden(const char *name, size_t len)
{
	if (len<3 || len>40)
		return false;

	if (name[0]!='.')
		return false;

//	if (len==5 && strcmp(name,".file")==0)
//		return true;
//	if (strcmp(name,".DocumentRevisions-V100")==0)
//		return true;
//	if (len==39 && strcmp(name,".PKInstallSandboxManager-SystemSoftware")==0)
//		return true;
//	if (strcmp(name,".Spotlight-V100")==0)
//		return true;
//	if (strcmp(name,".fseventsd")==0)
//		return true;
//	if (strcmp(name,".hotfiles.btree")==0)
//		return true;
//	if (strcmp(name,".vol")==0)
//		return true;

	return false;
}*/

static bool IsDirectoryExcludedPath(		const char *dirPath, size_t dirPathL,
																					const THFileSearchFilterExcludedPath *excludedPaths)
{
	const THFileSearchFilterExcludedPath *ep=excludedPaths;
	while (ep!=NULL)
	{
		if (dirPathL>=ep->pathLen && strcasecmp(dirPath,ep->path)==0)
			return true;
		ep=ep->next;
	}
	return false;
}

static int PerformSearchInDirectory(				const char *dirPath,
																		int exclude_DS_Store, int includeTrashDir,
																		const THFileSearchFilterExcludedPath *excludedPaths,
																		const THFileSearchFilterStruct *filters, int filtersCount,
																		THCBufferContainer *bufferContainer,
																		BOOL *pIsCancelled,
																		long long statistics[3],
																		THFileSearch_didPerformBk didPerformBk)
{
	if ((*pIsCancelled)==YES)
		return 0;

	size_t dirPathL=dirPath==NULL?0:strlen(dirPath);
	//printf("dirPath:%s\n",dirPath);

	if (dirPathL==0)
	{
		THLogErrorFc(@"dirPathL==0 dirPath:%s",dirPath);
		return -1;
	}

	DIR *dir=opendir(dirPath);
	if (dir==NULL)
	{
		int e=errno;
		if (e==EACCES)
			THLogInfoFc(@"dir==NULL dirPath:%s errno:%d (%s)",dirPath,e,strerror(e));
		else
			THLogErrorFc(@"dir==NULL dirPath:%s errno:%d (%s)",dirPath,e,strerror(e));
		return -2;
	}

	char *entryPath=malloc(MAXPATHLEN);
	if (entryPath==NULL)
		return -3;

	BOOL isCancelled=NO;
	NSMutableArray *results=nil;
	int rCode=1;

	while (1)
	{
		if ((*pIsCancelled)==YES)
		{
			isCancelled=YES;
			rCode=0;
			break;
		}

		struct dirent *dirEntry=readdir(dir); // getdirentriesattr
		if (dirEntry==NULL)
			break;

		char *name=dirEntry->d_name;
		__uint16_t nameL=dirEntry->d_namlen;
		__uint8_t entType=dirEntry->d_type;

		if (name==NULL || nameL==0 || IsDirEntrySystemName(name,nameL))
			continue;
		if (exclude_DS_Store==1 && IsDirEntryDSStoreName(name,nameL))
			continue;
		if (dirPathL==1 && strcmp(dirPath,"/")==0 && IsExcludedVolumeFileName(name,nameL)==true)
			continue;
//		if (IsFileNameExcludedHidden(name,nameL)==true)
//			continue;

		size_t entryPathL=dirPathL;
		if (dirPath[dirPathL-1]!='/')
			entryPathL+=1;
		entryPathL+=nameL;

		if (entryPathL>=MAXPATHLEN-1)
		{
			THLogErrorFc(@"entryPathL>=MAXPATHLEN entryPathL:%d",(int)entryPathL);
			rCode=-4;
			break;
		}

		strcpy(entryPath,dirPath);
		if (dirPath[dirPathL-1]!='/')
			strcat(entryPath,"/");
		strcat(entryPath,name);

		if (entType==DT_REG || entType==DT_DIR || entType==DT_LNK)
		{
			bool isDirectory=entType==DT_DIR?true:false;

			if (isDirectory==true)
			{
				if (includeTrashDir==0 && IsDirEntryTrashDirName(name,nameL))
					continue;
				if (IsDirectoryExcludedPath(entryPath,entryPathL,excludedPaths)==true)
					continue;
			}

			if (EntryFileNameMatchWithFilters(name,nameL,filters,filtersCount)==true)
			{
				struct stat s;
				bzero(&s,sizeof(s));

				if (lstat(entryPath,&s)!=0)
				{
					THLogErrorFc(@"lstat!=0 entryPath:%s errno:%d (%s)",entryPath,errno,strerror(errno));
					continue;
				}

				if (EntryMatchWithFilters(entryPath,entType,&s,filters,filtersCount,bufferContainer)==true)
				{
					THFileSearchResult *result=[[THFileSearchResult alloc] initWithPath:entryPath type:entType==DT_REG?'F':entType==DT_DIR?'D':'L' stat:&s];
					if (result==nil)
						THLogErrorFc(@"result==nil entryPath:%s",entryPath);
					else
					{
						if (results==nil)
							results=[NSMutableArray array];//CFArrayCreateMutable(kCFAllocatorDefault,10,NULL);
						//NSMutableArray *mResults=(__bridge NSMutableArray*)results;
						[results addObject:result];
						statistics[(entType==DT_REG)?0:(entType==DT_DIR)?1:2]+=1;
					}
				}
			}

			if (isDirectory==true)
			{
				int r=PerformSearchInDirectory(			entryPath,
																			exclude_DS_Store,
																			includeTrashDir,
																			excludedPaths,
																			filters,filtersCount,
																			bufferContainer,
																			pIsCancelled,
																			statistics,
																			didPerformBk);
				if (r==0)
				{
					rCode=0;
					break;
				}
				else if (r==-2)
					THLogWarningFc(@"PerformSearchInDirectory:%d entryPath:%s",r,entryPath);
				else if (r!=1)
					THLogErrorFc(@"PerformSearchInDirectory:%d entryPath:%s",r,entryPath);
			}
		}
		else
			THLogWarningFc(@"dirType:%d entryPath:%s",(int)entType,entryPath);
	}

	if (closedir(dir)!=0)
		THLogErrorFc(@"closeDir!=0 errno:%d dirPath:%s",errno,dirPath);

	if (results!=nil && (*pIsCancelled)==NO)
	{
		NSString *dirPath=[NSString stringWithUTF8String:entryPath];
		didPerformBk(1,dirPath,results,statistics);
		//CFRelease(results);
	}

	free(entryPath);

	return rCode;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
