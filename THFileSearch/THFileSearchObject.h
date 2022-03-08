// THFileSearchObject.h

#import <Cocoa/Cocoa.h>
#import "THFileSearch.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
extern NSString *THFileSearchObjectUpdatedNotification;

enum
{
	THFileSearchObjectUpdatedKind_updated=1,
	THFileSearchObjectUpdatedKind_finished=2
};

@interface THFileSearchObject : NSObject
{
	NSInteger _fileSearchJeton;
	NSString *_scopeDir;
 	NSArray *_criteria;
	THFileSearch *_fileSearch;

	NSMutableArray *_results;
	NSDictionary *_statistics;
	CFAbsoluteTime _lastResultsUpdate;
}

+ (BOOL)canStartSearch:(NSString*)scopeDir message:(NSString**)pMessage;
+ (BOOL)hasUsableCriteria:(NSArray*)criteria;

- (id)initWithScopeDir:(NSString*)scopeDir criteria:(NSArray*)criteria;

@property (readonly,atomic,strong) NSString *scopeDir;
@property (readonly,atomic,strong) NSArray *criteria;

- (NSArray*)results;
- (NSDictionary*)statistics;
- (NSString*)displayStatistics;

- (NSArray*)criterionListWithKind:(NSInteger)kind;

- (BOOL)isSearching;
- (void)stopSearch;
- (void)startSearch:(NSOperationQueue*)operationQueue;

//- (void)cleanSearchResultsByDelay;
//- (void)updateStatusOfSearchResults;

@end

//--------------------------------------------------------------------------------------------------------------------------------------------
