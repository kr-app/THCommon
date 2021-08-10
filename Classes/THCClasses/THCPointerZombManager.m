// THCPointerZombManager.c

#import "THCPointerZombManager.h"

#ifdef THCPointerZombManagerMalloc_ON

THCPointerZombManagerContext *THCPointerZombManagerContextNew(int mode)
{
	NSCAssert(sizeof(SInt64)==sizeof(void*),@"sizeof(SInt64)==sizeof(void*)");

	THCPointerZombManagerContext *result=malloc(sizeof(THCPointerZombManagerContext));
	bzero(result,sizeof(THCPointerZombManagerContext));

	result->capacity=8*1000*1000;
	result->tableau=malloc(sizeof(void*)*result->capacity);
	bzero(result->tableau,result->capacity);

	return result;
}

void THCPointerZombManagerContextFree(THCPointerZombManagerContext *context)
{
	free(context->tableau);
	free(context);
}

bool THCPointerZombManagerAddPointer(THCPointerZombManagerContext *context, void *ptr)
{
	NSCAssert(context->nbCount<context->capacity,@"context->nbCount<context->capacity");
	
	if (context->nbCount>0 && context->maxIndex==context->nbCount-1)
	{
		NSCAssert(context->tableau[context->maxIndex+1]==0,@"context->tableau[context->maxIndex+1]==0");
		context->tableau[context->maxIndex+1]=(SInt64)ptr;
	
		context->maxIndex+=1;
		context->nbCount+=1;
		context->nbAdd+=1;
		return true;
	}

	for (int i=context->maxIndex;i>=0;i--)
	{
		if (context->tableau[i]==0)
		{
			context->tableau[i]=(SInt64)ptr;

			if (i>context->maxIndex)
				context->maxIndex=i;
			context->nbCount+=1;
			context->nbAdd+=1;
			return true;
		}
	}
	
	return false;
}

bool THCPointerZombManagerRemovePointer(THCPointerZombManagerContext *context, void *ptr)
{
	for (int i=context->maxIndex;i>=0;i--)
	{
		if (context->tableau[i]==(SInt64)ptr)
		{
			context->tableau[i]=0;
			context->nbCount-=1;
			context->nbRemove+=1;
			return true;
		}
	}
	return false;
}

bool THCPointerZombManagerContainsPointer(THCPointerZombManagerContext *context, void *ptr)
{
	for (int i=context->maxIndex;i>=0;i--)
	{
		if (context->tableau[i]==(SInt64)ptr)
			return true;
	}
	return false;
}

void* THCPointerZombManagerMalloc(THCPointerZombManagerContext *context, size_t mSize)
{
	void *buff=malloc(mSize);
	NSCAssert(THCPointerZombManagerAddPointer(context,buff)==true,@"THCPointerZombManagerAddPointer");
	return buff;
}

char* THCPointerZombManagerStrdup(THCPointerZombManagerContext *context, const char *ptr)
{
	void *buff=strdup(ptr);
	NSCAssert(THCPointerZombManagerAddPointer(context,buff)==true,@"THCPointerZombManagerAddPointer");
	return buff;
}

void THCPointerZombManagerFree(THCPointerZombManagerContext *context, void *ptr)
{
	NSCAssert(ptr!=NULL,@"ptr==NULL");
	NSCAssert(THCPointerZombManagerRemovePointer(context,ptr)==true,@"THCPointerZombManagerRemovePointer");
	free(ptr);
}

void THCPointerZombManagerFreeLike(THCPointerZombManagerContext *context, void *ptr)
{
	NSCAssert(ptr!=NULL,@"ptr==NULL");
	NSCAssert(THCPointerZombManagerRemovePointer(context,ptr)==true,@"THCPointerZombManagerRemovePointer==true");
}

#endif
