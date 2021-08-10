// THCBufferContainer.m

#import "THCBufferContainer.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
THCBufferContainer THCBufferContainerNew(size_t capa, bool preallocate)
{
	THCBufferContainer bufferContainer={capa,0,0,0,NULL};
	if (preallocate==true)
		THCBufferContainerSetSize(&bufferContainer,capa);
	return bufferContainer;
}

bool THCBufferContainerSetSize(THCBufferContainer *bufferContainer, size_t newSize)
{
	if (newSize>0 && newSize>bufferContainer->allocated)
	{
		if (newSize>bufferContainer->capacity)
		{
			THLogErrorFc(@"newSize>bufferContainer->capacity newSize:%lld capacity:%lld",(long long)newSize,(long long)bufferContainer->capacity);
			return false;
		}

		if (bufferContainer->ptr!=NULL)
			free(bufferContainer->ptr);

		if ((bufferContainer->ptr=malloc(newSize))==NULL)
		{
			THLogErrorFc(@"bufferContainer->ptr=malloc(newSize))==NULL newSize:%lld",(long long)newSize);
			return false;
		}

		bufferContainer->allocated=newSize;
	}

	bufferContainer->size=newSize;

	return true;
}

void THCBufferContainerFree(THCBufferContainer *bufferContainer)
{
	if (bufferContainer->ptr!=NULL)
	{
		free(bufferContainer->ptr);
		bufferContainer->ptr=NULL;
	}
}

//Boolean THCBufferCompare(const THCBuffer *buffer, const THCBuffer *otherBuffer)
//{
//	if (buffer==otherBuffer)
//		return true;
//	if (buffer==NULL || otherBuffer==NULL)
//		return false;
//	if (buffer->size==0 && otherBuffer->size==0)
//		return true;
//	if (buffer->size==otherBuffer->size && memcmp(buffer->ptr,otherBuffer->ptr,buffer->size)==0)
//		return true;
//	return false;
//}
//
//char* THCBufferDump(const THCBuffer *buffer, size_t maxSize, int options)
//{
//	if (buffer==NULL)
//		return NULL;
//
//	size_t rSize=buffer->size;
//	Boolean isTruncated=false;
//	if (maxSize!=-1 && rSize>maxSize)
//	{
//		rSize=maxSize;
//		isTruncated=true;
//	}
//
//	char *result=malloc(rSize*2+1);
//	memset(result,0,rSize*2+1);
//
//	size_t i;
//	for (i=0;i<buffer->size;i++)
//	{
//		if (isTruncated==true && i+3>=rSize)
//		{
//			strcat(&result[i*2],"…");
//			break;
//		}
//		snprintf(result+i*2,3,"%02X",*((char*)buffer->ptr+i));
//[buf appendFormat:@"%02hhX",bytes[i]];

//	}
//
//	return result;
//}
//--------------------------------------------------------------------------------------------------------------------------------------------
