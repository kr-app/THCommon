// THSpecialFilename.h

#import <Foundation/Foundation.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
enum
{
	THIsExcludedMode_none=0,
	THIsExcludedMode_user=1
};

bool THIsFilenameHiddenExcluded(const char *filename, size_t filenameLen, int mode);
bool THIsVolumeHiddenFilename(const char *filename, size_t len);
bool THIsVolumeSystemHiddenFilename(const char *filename, size_t len, int mode);
//--------------------------------------------------------------------------------------------------------------------------------------------
