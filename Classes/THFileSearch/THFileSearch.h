// THFileSearch.h

#import <Cocoa/Cocoa.h>
#import "THFileSearchResult.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
enum // SERIALIZED
{
	THFileSearchCriterion_fileName=1,
	THFileSearchCriterion_fileSize=2,
	THFileSearchCriterion_UTIType=3,
	THFileSearchCriterion_dateCreated=4,
	THFileSearchCriterion_dateModified=5,
	THFileSearchCriterion_tagNames=6,
	//THFileSearchCriterion_statType=7,
	THFileSearchCriterion_xAttrs=8,
	THFileSearchCriterion_mdAttribute=9,
	THFileSearchCriterion_dirPaths=10,
	THFileSearchCriterion_options=11
};

enum // SERIALIZED
{
	THFileSearchOperator_contains=1,
	THFileSearchOperator_doesNotContain=20,
	THFileSearchOperator_beginsWith=2,
	THFileSearchOperator_endsWith=3,

	THFileSearchOperator_is=4,
	THFileSearchOperator_isNot=5,

	THFileSearchOperator_lessThan=6,
	THFileSearchOperator_greaterThan=7,

	THFileSearchOperator_dateExactlyDay=8,
	THFileSearchOperator_dateBefore=9,
	THFileSearchOperator_dateAfter=10,
	THFileSearchOperator_dateToday=11,
	THFileSearchOperator_dateLastHour=18,
	THFileSearchOperator_dateLast6Hours=19,
	THFileSearchOperator_dateYesterday=12,
//	THFileSearchOperator_thisWeek=16,
//	THFileSearchOperator_thisMonth=17,
	THFileSearchOperator_dateWithinLast=15,

	THFileSearchOperator_isDefined=13,
	THFileSearchOperator_isNotDefined=14
};

enum // SERIALIZED
{
	THFileSearchUnit_day=1,
	THFileSearchUnit_week=2,
	THFileSearchUnit_month=3,
	THFileSearchUnit_year=4,
	THFileSearchUnit_hour=5,
	THFileSearchUnit_min=6
};

enum // SERIALIZED
{
	THFileSearchInclude_TrashDir=1,
};

extern NSString *THFileSearchUTIType_RegFile;
extern NSString *THFileSearchUTIType_Directorty;
extern NSString *THFileSearchUTIType_SymLink;
extern NSString *THFileSearchUTIType_DSStore;

typedef void(^THFileSearch_didPerformBk)(int action, NSString *directoryPath, NSArray *results, long long statistics[3]);

@interface THFileSearch : NSObject
{
	BOOL _isCancelled;
}

+ (NSArray*)criteriaWithKind:(NSInteger)kind criteria:(NSArray*)criteria;

- (void)performSearchInDirectory:(NSString*)scopeDir criteria:(NSArray*)criteria didPerformBk:(THFileSearch_didPerformBk)didPerformBk;
- (void)cancelSearch;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
