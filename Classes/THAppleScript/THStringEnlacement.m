// THStringEnlacement.m

#import "THStringEnlacement.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
#ifdef DEBUG
NSString* TH_StringEnlacement(NSString *string, int mode)
{
	if (string.length==0)
		return nil;

	NSData *data=[[string dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];

	NSMutableString *ms=[NSMutableString string];
	const char *c_data=data.bytes;
	int c_dataLen=(int)data.length;

	[ms appendFormat:@" \tint L=%d;",c_dataLen];
	if (mode==0)
		[ms appendFormat:@" char *b=malloc(sizeof(char)*(L+1));"];
	else if (mode==1)
		[ms appendFormat:@" char b[L+1];"];
	[ms appendFormat:@" int i=0;\n"];
	[ms appendFormat:@"\t"];

	int buffIdx=0;
	int cLIndex=0;
	for (int strIdx=c_dataLen-1;strIdx>=0;strIdx--)
	{
		const char c=c_data[strIdx];
		if (c>' ')
			[ms appendFormat:@"b[i++]=\'%c\';",c];
		else
			[ms appendFormat:@"b[i++]=%d;",c];
		buffIdx++;
		cLIndex++;
		if (cLIndex==12)
		{
			cLIndex=0;
			[ms appendFormat:@"\n\t"];
		}
	}

	[ms appendFormat:@"\n"];
	if (mode==0)
		[ms appendFormat:@"\tstring=TH_StringDelacement(L,b,1);\n"];

	return [NSString stringWithString:ms];
}
#endif

NSString* TH_StringDelacement(int l, const char *b, int options)
{
	if (l==0 || b==NULL)
		return nil;

	char *rb=malloc(sizeof(char)*(l+1));
	int rbIdx=0;
	for (int i=l-1;i>=0;i--)
		rb[rbIdx++]=b[i];

	if ((options&1)!=0)
		free((void*)b);

	NSData *data=[[NSData alloc] initWithBase64EncodedData:[NSData dataWithBytes:rb length:l] options:0];
	NSString *string=data==nil?nil:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	free(rb);

	return string;
}
//--------------------------------------------------------------------------------------------------------------------------------------------
