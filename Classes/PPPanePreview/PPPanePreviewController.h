// PPPanePreviewController.h

#import <Cocoa/Cocoa.h>

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@class PPPanePreviewWindow;

@interface PPPanePreviewController : NSViewController <NSWindowDelegate>
{
	PPPanePreviewWindow *_myWindow;
}

- (BOOL)isVisiblePane;

- (void)showWindowAtPoint:(NSPoint)point onScreen:(NSScreen*)screen;
- (void)hideWindowAnimated:(BOOL)animated;

- (void)panePreviewControllerWillShow;
- (void)panePreviewControllerWillHide;
- (void)panePreviewControllerDidHide;

@end
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
