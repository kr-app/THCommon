// THCBufferContainer.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
typedef struct THCBufferContainer
{
	size_t capacity;
	size_t allocated;
	size_t size;
	size_t used;
	void *ptr;
} THCBufferContainer;

THCBufferContainer THCBufferContainerNew(size_t capa, bool preallocate);
bool THCBufferContainerSetSize(THCBufferContainer *bufferContainer, size_t newSize);
void THCBufferContainerFree(THCBufferContainer *bufferContainer);
//--------------------------------------------------------------------------------------------------------------------------------------------
