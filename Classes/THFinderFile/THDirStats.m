// THDirStats.m

#import "THDirStats.h"
#import "THLog.h"
#include <sys/xattr.h> // xattr
#import <dirent.h> // readdir
#import <sys/stat.h> // readdir

#define IsDirEntrySystemName(_name_,_nameL_) ((_nameL_==1 && _name_[0]=='.') || (_nameL_==2 && _name_[0]=='.' && _name_[1]=='.'))

//--------------------------------------------------------------------------------------------------------------------------------------------
static int GetDirectoryStatistics(const char *dirPath, int options, THDirectoryStatistics *pStatistics)
{
	size_t dirPathL=dirPath==NULL?0:strlen(dirPath);
	if (dirPathL==0)
	{
		THLogErrorFc(@"dirPathL==0 dirPath:%s",dirPath);
		return -1;
	}

	DIR *dir=opendir(dirPath);
	if (dir==NULL)
	{
		THLogErrorFc(@"dir==NULL dirPath:%s errno:%d (%s)",dirPath,errno,strerror(errno));
		return -2;
	}

	char *entryPath=malloc(MAXPATHLEN);
	if (entryPath==NULL)
		return -3;

	while (1)
	{
		struct dirent *dirEntry=readdir(dir);
		if (dirEntry==NULL)
			break;

		char *name=dirEntry->d_name;
		__uint16_t nameL=dirEntry->d_namlen;
		__uint8_t dirType=dirEntry->d_type;

		if (name==NULL || nameL==0 || IsDirEntrySystemName(name,nameL))
			continue;

		size_t entryPathL=dirPathL;
		if (dirPath[dirPathL-1]!='/')
			entryPathL+=1;
		entryPathL+=nameL;

		if (entryPathL>=MAXPATHLEN-1)
		{
			THLogErrorFc(@"entryPathL>=MAXPATHLEN entryPathL:%d",(int)entryPathL);
			return -4;
		}

		strcpy(entryPath,dirPath);
		if (dirPath[dirPathL-1]!='/')
			strcat(entryPath,"/");
		strcat(entryPath,name);

		if (dirType==DT_REG)
		{
			pStatistics->nbFiles++;

			struct stat s;
			bzero(&s,sizeof(s));

			if (stat(entryPath,&s)!=0)
				THLogErrorFc(@"stat==-1 entryPath:%s errno:%d (%s)",entryPath,errno,strerror(errno));
			else
				pStatistics->totalSize+=(unsigned long long)s.st_size;
		}
		else if (dirType==DT_DIR)
		{
			pStatistics->nbDirs++;

			int err=GetDirectoryStatistics(entryPath,options,pStatistics);
			if (err!=0)
				THLogErrorFc(@"GetDirectoryStatistics:%d entryPath:%s",err,entryPath);
		}
		else if (dirType==DT_LNK)
		{
			pStatistics->nbLinks++;
		}
//		else
//			THLogErrorFc(@"dirType:%ld entryPath:%s",(NSInteger)dirType,entryPath);
	}

	free(entryPath);

	if (closedir(dir)!=0)
		THLogErrorFc(@"closeDir!=0 dirPath:%s errno:%d",dirPath,errno);

	return 0;
}

bool THGetDirectoryStatistics(THDirectoryStatistics *pStatistics, int options, NSString *dirPath)
{
	if (dirPath==nil || [dirPath isEqualToString:@"/"]==YES || [dirPath isEqualToString:@"/Volumes"]==YES)
		return false;
	return GetDirectoryStatistics(dirPath==nil?NULL:[dirPath fileSystemRepresentation],(int)options,pStatistics)==0?true:false;
}
//--------------------------------------------------------------------------------------------------------------------------------------------
