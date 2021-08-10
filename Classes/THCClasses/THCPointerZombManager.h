// THCPointerZombManager.h

#import <Foundation/Foundation.h>

#ifdef DEBUG
	//#define THCPointerZombManagerMalloc_ON
#endif

#ifdef THCPointerZombManagerMalloc_ON

typedef struct THCPointerZombManagerContext
{
	SInt64 *tableau;
	size_t capacity;
	int maxIndex;
	
	unsigned nbCount;
	unsigned nbAdd;
	unsigned nbRemove;
} THCPointerZombManagerContext;

THCPointerZombManagerContext *THCPointerZombManagerContextNew(int mode);
void THCPointerZombManagerContextFree(THCPointerZombManagerContext *context);

void* THCPointerZombManagerMalloc(THCPointerZombManagerContext *context, size_t mSize);
char* THCPointerZombManagerStrdup(THCPointerZombManagerContext *context, const char *ptr);
void THCPointerZombManagerFree(THCPointerZombManagerContext *context, void *ptr);
void THCPointerZombManagerFreeLike(THCPointerZombManagerContext *context, void *ptr);

#define THCPointerZombManager_malloc(mSize) 			THCPointerZombManagerMalloc(pointerManagerContext,mSize)
#define THCPointerZombManager_strdup(ptr) 				THCPointerZombManagerStrdup(pointerManagerContext,ptr)
#define THCPointerZombManager_free(ptr) 					THCPointerZombManagerFree(pointerManagerContext,ptr)
#define THCPointerZombManager_freeLike(ptr)				THCPointerZombManagerFreeLike(pointerManagerContext,ptr)

#else

#define THCPointerZombManager_malloc(mSize) 			malloc(mSize)
#define THCPointerZombManager_strdup(ptr) 				strdup(ptr)
#define THCPointerZombManager_free(ptr) 					free(ptr)
#define THCPointerZombManager_freeLike(ptr)				free(ptr)

#endif
