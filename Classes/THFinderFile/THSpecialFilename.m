// THSpecialFilename.m

#import "THSpecialFilename.h"
#import "THLog.h"
#include <sys/xattr.h> // xattr
#import <dirent.h> // readdir
#import <sys/stat.h> // readdir

//--------------------------------------------------------------------------------------------------------------------------------------------
bool THIsFilenameHiddenExcluded(const char *filename, size_t filenameLen, int mode)
{
	if (filename==NULL || filenameLen==0 || filenameLen>22)
		return false;

	if (filename[0]=='.')
	{
		if (filenameLen==10 && strcmp(filename,".localized")==0)
			return true;
		if (filenameLen==5 && strcmp(filename,".file")==0)
			return true;
		if (filenameLen==6 && strcmp(filename,".Trash")==0)
			return true;

		if ((mode&THIsExcludedMode_user)==0)
		{
			if (filenameLen==9 && strcmp(filename,".DS_Store")==0)
				return true;
		}

		return false;
	}

	if (filenameLen==5)
	{
		if ((mode&THIsExcludedMode_user)==0)
		{
			static char iconName[]={'I','c','o','n',13,0};
			if (strcmp(filename,iconName)==0)
				return true;
		}
	}
	else if (filenameLen==22)
	{
		static char *n=NULL;
		if (n==NULL)
			n=strdup([@"File Transfer Folder" stringByAppendingFormat:@"%c%c",3,13].UTF8String);
		if (strcmp(filename,n)==0)
			return true;
	}

	return false;
}

bool THIsVolumeHiddenFilename(const char *filename, size_t len)
{
	if (filename==NULL || len==0 || len>40)
		return false;
	if (filename[0]=='.')
	{
		if (len==23 && strcmp(filename,".DocumentRevisions-V100")==0)
			return true;
		if (len==29 && strcmp(filename,".HFS+ Private Directory Data\r")==0)
			return true;
		if (len==39 && strcmp(filename,".PKInstallSandboxManager-SystemSoftware")==0)
			return true;
		if (len==15 && strcmp(filename,".Spotlight-V100")==0)
			return true;
		if (len==15 && strcmp(filename,".hotfiles.btree")==0)
			return true;
		if (len==8 && strcmp(filename,".Trashes")==0)
			return true;
		if (len==10 && strcmp(filename,".fseventsd")==0)
			return true;
		if (len==5 && strcmp(filename,".file")==0)
			return true;
		if (len==4 && strcmp(filename,".vol")==0)
			return true;
		return false;
	}
	return false;
}

bool THIsVolumeSystemHiddenFilename(const char *filename, size_t len, int mode)
{
	if (filename==NULL || len==0 || len>50)
		return false;

	if (THIsVolumeHiddenFilename(filename,len)==true)
		return true;

	if (len==3 && strcmp(filename,"dev")==0)
		return true;
	if (len==3 && strcmp(filename,"net")==0)
		return true;
	if (len==4 && strcmp(filename,"home")==0)
		return true;
	if (strcmp(filename,"cores")==0)
		return true;
	if (strcmp(filename,"mach_kernel")==0)
		return true;
	if (strcmp(filename,"mach.sym")==0)
		return true;
	if (strcmp(filename,"mach")==0)
		return true;
	if (strcmp(filename,"Network")==0)
		return true;
	if (strcmp(filename,"Volumes")==0)
		return true;

	if (mode==0)
	{
		if (len==3 && strcmp(filename,"etc")==0)
			return true;
		if (len==3 && strcmp(filename,"var")==0)
			return true;
		if (len==3 && strcmp(filename,"tmp")==0)
			return true;
		if (len==3 && strcmp(filename,"bin")==0)
			return true;
		if (len==4 && strcmp(filename,"sbin")==0)
			return true;
		if (len==3 && strcmp(filename,"usr")==0)
			return true;
		if (strcmp(filename,"private")==0)
			return true;
	}
	
	return false;
}
//--------------------------------------------------------------------------------------------------------------------------------------------
