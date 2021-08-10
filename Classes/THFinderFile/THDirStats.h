// THDirStats.h

#import <Foundation/Foundation.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
typedef struct THDirectoryStatistics
{
	unsigned long long totalSize;
	unsigned long long nbFiles;
	unsigned long long nbDirs;
	unsigned long long nbLinks;
} THDirectoryStatistics;

bool THGetDirectoryStatistics(THDirectoryStatistics *pStatistics, int options, NSString *dirPath);
//--------------------------------------------------------------------------------------------------------------------------------------------
