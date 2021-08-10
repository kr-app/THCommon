// THAsScriptEnlacement.m

#import "THAsScriptEnlacement.h"
#import "THFoundation.h"
#import "THUnixCommand.h"
#import "THLog.h"
#import "THStringEnlacement.h"
#import "TH_APP-Swift.h"

#ifdef DEBUG
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation THAsScriptEnlacement

+ (void)initialize
{
	static int once=0;
	if (once!=0)
		return;
	once=1;

	// garde fou pour ne pas copier les scripts dans le dossier resource de l'app
	NSString *rsrPath=[[NSBundle mainBundle] resourcePath];
	THException(rsrPath==nil,@"rsrPath==nil");

	NSError *error=nil;
	NSArray *dirContents=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:rsrPath error:&error];
	THException(dirContents==nil,@"dirContents==nil error:%@",error);

	for (NSString *file in dirContents)
	{
		THException([file.pathExtension isEqualToString:@"scpt"]==YES,@"app resource directory should not contains script (%@)",file);
	}
}

+ (NSArray*)linesFromString:(NSString*)string options:(NSInteger)options
{
	__block NSMutableArray *lines=[NSMutableArray array];
	[string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop)
	{
		NSString *s=line;
		if ((options&1)!=0)
		{
			s=[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if (s.length==0)
				return;
		}
		[lines addObject:s];
	}];

	return lines;
}

+ (NSString*)parsedAppleScriptSourceString:(NSString*)string removeTab:(BOOL)removeTab
{
	if (string.length==0)
		return nil;

	NSMutableString *nString=[NSMutableString stringWithString:string];
	[nString replaceOccurrencesOfString:@"{} -- a dynamique" withString:@"{%@}" options:NSCaseInsensitiveSearch range:NSMakeRange(0,nString.length)];
	[nString replaceOccurrencesOfString:@"0 -- %d dynamique" withString:@"%d" options:NSCaseInsensitiveSearch range:NSMakeRange(0,nString.length)];
	[nString replaceOccurrencesOfString:[NSString stringWithFormat:@"%C",8220] withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,nString.length)]; //  @"\“"
	string=nString;
	
	NSArray *lines=[self linesFromString:string options:removeTab==YES?1:0];
	
	nString=[NSMutableString string];
	for (NSString *the_line in lines)
	{
		if ([the_line hasPrefix:@"--"]==YES)
			continue;
		
		NSString *line=the_line;
		
		if (removeTab==YES)
		{
			while ([line hasPrefix:@"\t"]==YES)
				line=[line substringFromIndex:1];
		}
		
		NSString *nLine=nil;
		if ([line hasSuffix:@"-- a dynamique"]==YES)
		{
			NSRange r0=[line rangeOfString:@" to "];
			THException(r0.location==NSNotFound,@"r0.location==NSNotFound");
			
			NSString *v=[line substringFromIndex:r0.location+r0.length];
			
			if ([v hasPrefix:@"\""]==YES)
				nLine=[NSString stringWithFormat:@"%@\"%%@\"",[line substringToIndex:r0.location+r0.length]];
			else if ([v hasPrefix:@"{"]==YES)
				nLine=[NSString stringWithFormat:@"%@{%%@}",[line substringToIndex:r0.location+r0.length]];
			else if ([v characterAtIndex:0]>='0' && [v characterAtIndex:0]<='9')
				nLine=[NSString stringWithFormat:@"%@%%@",[line substringToIndex:r0.location+r0.length]];
			else if ([v hasPrefix:@"true"]==YES || [v hasPrefix:@"false"]==YES)
				nLine=[NSString stringWithFormat:@"%@%%@",[line substringToIndex:r0.location+r0.length]];
			else if ([v hasPrefix:@"null"]==YES)
				nLine=[NSString stringWithFormat:@"%@%%@",[line substringToIndex:r0.location+r0.length]];
			else
				THException(1,@"v:%@ line:%@",v,line);
		}
		
		if (nLine!=nil)
			THLogInfo(@"Replaced line:[%@] by [%@]\n",line,nLine);
		
		[nString appendFormat:@"%@\n",nLine!=nil?nLine:line];
	}
	
	return [NSString stringWithString:nString];
}

+ (nullable NSString*)encodeScript:(nonnull NSString*)sourcePath outFilePath:(nullable NSString*)outFilePath
{
	NSInteger status=0;
	NSString *stdOut=nil;
	NSString *stdErr=nil;
	
	NSArray *args=@[sourcePath];
	BOOL isOk=[THUnixCommand executeCommand:@"/usr/bin/osadecompile" args:args status:&status stdOut:&stdOut stdErr:&stdErr];
	if (isOk==NO || status!=0)
	{
		THLogError(@"executeCommand==NO status:%@ stdOut:%@ stdErr:%@",@(status),stdOut,stdErr);
		return nil;
	}
	
	NSString *parsedSource=[self parsedAppleScriptSourceString:stdOut removeTab:YES];
	if (parsedSource.length==0)
	{
		THLogError(@"parsedSource.length==0");
		return nil;
	}
	
	THLogDebug(@"parsedSource:\n%@",[self parsedAppleScriptSourceString:stdOut removeTab:NO]);
	
	NSString *encodedString=TH_StringEnlacement(parsedSource,0);
	if (encodedString.length==0)
	{
		THLogError(@"encodedString==nil");
		return nil;
	}
	
	if (outFilePath!=nil)
	{
		NSString *fileName=[outFilePath.lastPathComponent stringByDeletingPathExtension];
		
		NSMutableString *file=[NSMutableString stringWithFormat:@"// %@\n",fileName];
		[file appendFormat:@"#ifndef %@_scpt\n",fileName.stringByDeletingPathExtension];
		[file appendFormat:@"#define %@_scpt\\\n",fileName.stringByDeletingPathExtension];
		NSArray *lines=[self linesFromString:encodedString options:0];
		for (NSString *line in lines)
			[file appendFormat:@"%@%@\n",line,line!=lines.lastObject?@"\\":@""];
		[file appendFormat:@"#endif\n"];
		
		NSError *error=nil;
		if ([file writeToFile:outFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error]==NO)
		{
			THLogError(@"writeToFile==NO outFilePath:%@ error:%@",outFilePath,error);
			return nil;
		}
	}
	
	return encodedString;
}

+ (void)autoEnlaceScripts:(nullable NSString*)dirPath
{
	NSString *cachesDir=[NSFileManager th_appCachesDir:nil];
	NSString *file=[NSString stringWithFormat:@"%@-%@.cache.plist",[self className],dirPath.lastPathComponent];

	NSString *cf_infos=[cachesDir stringByAppendingPathComponent:file];
	NSMutableDictionary *c_infos=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:cf_infos]];

	NSString *osVersion=[NSProcessInfo processInfo].operatingSystemVersionString;
	THException(osVersion==nil,@"osVersion==nil");

	if (c_infos[@"os_version"]==nil || [(NSString*)c_infos[@"os_version"] isEqualToString:osVersion]==NO)
	{
		[c_infos removeAllObjects];
		c_infos[@"os_version"]=osVersion;
	}
	
	NSError *error=nil;
	NSArray *dirContents=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:&error];
	THException(dirContents==nil,@"dirContents==nil dirPath:%@ error:%@",dirPath,error);

	NSInteger changes=0;

	for (NSString *fileName in dirContents)
	{
		if ([fileName.pathExtension isEqualToString:@"scpt"]==NO)
			continue;
		
		NSString *p=[dirPath stringByAppendingPathComponent:fileName];
	
		NSDate *modDate=[NSFileManager th_modDate1970AtPath:p];
		THException(modDate==nil,@"modDate==nil p:%@",p)

		NSString *date=[modDate description];
		if ([date isEqualToString:c_infos[fileName]]==YES)
		{
			THLogInfo(@"No Change for \"%@\"",p.lastPathComponent);
			continue;
		}

		NSString *h=[dirPath stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"h"]];

		THLogInfo(@"Encoding... \"%@\"",p.lastPathComponent);
		NSString *source=[self encodeScript:p outFilePath:h];
		if (source==nil)
			continue;
	
		changes+=1;
		[c_infos setObject:date forKey:fileName];
	}

	if (changes>0)
	{
		if ([[NSDictionary dictionaryWithDictionary:c_infos] writeToFile:cf_infos atomically:YES]==NO)
			THLogError(@"writeToFile==NO... cf_infos:%@",cf_infos);
	}

}

@end
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#endif
