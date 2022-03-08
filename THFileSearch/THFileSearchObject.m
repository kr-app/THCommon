// THFileSearchObject.m

#import "THFileSearchObject.h"
#import "TH_APP-Swift.h"
#include <sys/stat.h> // stat
#include <sys/xattr.h> // xattr
#include <errno.h> // xattr

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THFileSearchObject

NSString *THFileSearchObjectUpdatedNotification=@"THFileSearchObjectUpdatedNotification";

+ (BOOL)canStartSearch:(NSString*)scopeDir message:(NSString**)pMessage
{
	if (scopeDir==nil)
		return TH_ReturnNoWithMessage(THLocalizedString(@"The directory is not specified."),pMessage);

	BOOL isDir=NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:scopeDir isDirectory:&isDir]==NO)
		return TH_ReturnNoWithMessage(THLocalizedString(@"Directory does not exist."),pMessage);
	if (isDir==NO)
		return TH_ReturnNoWithMessage(THLocalizedString(@"The target path is not a directory."),pMessage);

	if ([[NSFileManager defaultManager] isReadableFileAtPath:scopeDir]==NO)
		return TH_ReturnNoWithMessage(THLocalizedString(@"No directory access."),pMessage);

	return YES;
}

+ (BOOL)hasUsableCriteria:(NSArray*)criteria
{
	for (NSNumber *k in @[			@(THFileSearchCriterion_fileSize),
																@(THFileSearchCriterion_dateCreated),
																@(THFileSearchCriterion_dateModified),
																@(THFileSearchCriterion_fileName),
		  														@(THFileSearchCriterion_tagNames),
																@(THFileSearchCriterion_UTIType),
		  														@(THFileSearchCriterion_xAttrs)])
	{
		if ([THFileSearch criteriaWithKind:[k integerValue] criteria:criteria].count>0)
			return YES;
	}
	return NO;
}

- (id)initWithScopeDir:(NSString*)scopeDir criteria:(NSArray*)criteria
{
	if (self=[super init])
	{
		static NSInteger jeton=0;
		jeton+=1;

		_fileSearchJeton=jeton;
		_scopeDir=scopeDir;
		_criteria=criteria;
	}
	return self;
}

- (void)dealloc
{
	[self stopSearch];
}

- (NSArray*)results { return [NSArray arrayWithArray:_results]; }

- (NSDictionary*)statistics { return _statistics; }

- (NSString*)displayStatistics
{
	long long nbFiles=[_statistics[@"files"] longLongValue];
	long long nbDirs=[_statistics[@"dirs"] longLongValue];
	long long nbLinks=[_statistics[@"links"] longLongValue];

	if (nbFiles==0 && nbDirs==0 && nbLinks==0)
		return nil;

	NSMutableString *ms=[NSMutableString string];
	if (nbFiles>1)
		[ms appendString:THLocalizedStringFormat(@"%@ files",[NSNumberFormatter.th_decimal stringFromNumber:@(nbFiles)])];
	else if (nbFiles==1)
		[ms appendString:THLocalizedString(@"1 file")];

	if (nbDirs>1)
		[ms appendFormat:@"%@%@",ms.length>0?@", ":@"",THLocalizedStringFormat(@"%@ directories",[NSNumberFormatter.th_decimal stringFromNumber:@(nbDirs)])];
	else if (nbDirs==1)
		[ms appendFormat:@"%@%@",ms.length>0?@", ":@"",THLocalizedString(@"1 directoriy")];

	if (nbLinks>1)
		[ms appendFormat:@"%@%@",ms.length>0?@", ":@"",THLocalizedStringFormat(@"%@ links",[NSNumberFormatter.th_decimal stringFromNumber:@(nbLinks)])];
	else if (nbLinks==1)
		[ms appendFormat:@"%@%@",ms.length>0?@", ":@"",THLocalizedString(@"1 link")];

	return [NSString stringWithString:ms];
}

- (NSArray*)criterionListWithKind:(NSInteger)kind
{
	NSMutableArray *results=[NSMutableArray array];
	for (NSDictionary *criterion in _criteria)
		if ([criterion[@"kind"] integerValue]==kind)
			[results addObject:criterion];
	return results;
}

- (BOOL)isSearching { return _fileSearch!=nil?YES:NO; }

- (void)stopSearch
{
	[_fileSearch cancelSearch];
	_fileSearch=nil;
	_fileSearchJeton+=1;
}

- (void)startSearch:(NSOperationQueue*)operationQueue
{
	NSString *scopeDir=_scopeDir;
	NSArray *criteria=_criteria;
	
	THException(scopeDir==nil,@"self.scopeDir==nil");
	THException(criteria==nil,@"self.criteria==nil");
	THException(operationQueue==nil,@"operationQueue==nil");

	THLogInfo(@"scopeDir:%@ criteria:%@",scopeDir,criteria);

	[_fileSearch cancelSearch];
	_fileSearchJeton+=1;

	THFileSearch *fileSearch=[[THFileSearch alloc] init];
	_fileSearch=fileSearch;
	NSInteger fileSearchJeton=_fileSearchJeton;

	_results=[NSMutableArray array];
	_statistics=nil;
	_lastResultsUpdate=0.0;

	[operationQueue addOperationWithBlock:^
						 {
							 [fileSearch performSearchInDirectory:scopeDir criteria:criteria
															  didPerformBk:^(int action, NSString *directoryPath, NSArray *results, long long statistics[3])
											{
												if (fileSearchJeton!=_fileSearchJeton)
													return;

												NSDictionary *stats=@{		@"files":@(statistics[0]),
																							@"dirs":@(statistics[1]),
																							@"links":@(statistics[2]),
																							@"total":@(statistics[0]+statistics[1]+statistics[2])};
												NSDictionary *object=nil;

												if (action==1)
												{
													object=@{		@"jeton":@(fileSearchJeton),
																			@"change":@(THFileSearchObjectUpdatedKind_updated),
																			@"directoryPath":directoryPath,
																			@"results":results,
																			@"stats":stats};
												}
												else if (action==2)
													object=@{	@"jeton":@(fileSearchJeton),
																		@"change":@(THFileSearchObjectUpdatedKind_finished),
																		@"stats":stats};

												[self performSelectorOnMainThread:@selector(mt_searchUpdated:) withObject:object waitUntilDone:YES];
											}];
						  }];
}

- (void)mt_searchUpdated:(NSDictionary*)infos
{
	if (_fileSearch==nil || _fileSearchJeton!=[infos[@"jeton"] integerValue])
		return;

	_statistics=infos[@"stats"];

	NSInteger change=[infos[@"change"] integerValue];
	if (change==THFileSearchObjectUpdatedKind_updated)
	{
		NSArray *results=infos[@"results"];
		[_results addObjectsFromArray:results];
		[[NSNotificationCenter defaultCenter] postNotificationName:THFileSearchObjectUpdatedNotification
																			 	object:self userInfo:@{@"kind":@(change),@"results":results}];
	}
	else if (change==THFileSearchObjectUpdatedKind_finished)
	{
		_fileSearch=nil;
		_lastResultsUpdate=CFAbsoluteTimeGetCurrent();
		[[NSNotificationCenter defaultCenter] postNotificationName:THFileSearchObjectUpdatedNotification
																			object:self userInfo:@{@"kind":@(change)}];
	}
}

//- (void)cleanSearchResultsByDelay
//{
//	if (_results==nil || _results.count==0)
//		return;
//	if (self.isSearching==YES)
//		return;
//	CFAbsoluteTime t=CFAbsoluteTimeGetCurrent();
//	if ((t-_lastResultsUpdate)<60.0)
//		return;
//	_results=nil;
//	_lastResultsUpdate=0;
//}

- (void)updateStatusOfSearchResults
{
//	if (_results==nil || _results.count==0 || self.isSearching==YES)
//		return;
//
//	CFAbsoluteTime t=CFAbsoluteTimeGetCurrent();
//	if ((t-_lastResultsUpdate)<5.0)
//		return;
//	_lastResultsUpdate=t;
//
//	THFileSearch *fileSearch=_fileSearch;
//	NSArray *results=[NSArray arrayWithArray:_results];
//
//	[[THFileSearchObject sharedSearchOpQueue] addOperationWithBlock:^
//						  {
//							  NSMutableArray *changes=[NSMutableArray array];
//							  for (THFileSearchResult *result in results)
//							  {
//								  if (fileSearch!=_fileSearch)
//									  return;
//								  if ([result updateStatus]!=0)
//									  [changes addObject:result];
//							  }
//							  if (changes.count>0)
//								  [self performSelectorOnMainThread:@selector(mt_searchResultsDidChanged:) withObject:@{@"sender":fileSearch,@"results":changes} waitUntilDone:NO];
//						  }];
//}
//
//- (void)mt_searchResultsDidChanged:(NSDictionary*)infos
//{
//	if (infos[@"sender"]!=_fileSearch)
//		return;
//	[[NSNotificationCenter defaultCenter] postNotificationName:THFileSearchObjectUpdatedNotification object:self userInfo:@{@"kind":@(3),@"results":infos[@"results"]}];
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
