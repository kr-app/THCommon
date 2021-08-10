// THHighlightedTableView.h

#import <Cocoa/Cocoa.h>

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@class THHighlightedTableView;

@interface THHighlightedTableViewScrollView : NSScrollView
{
	THHighlightedTableView *_enclosedTableView;
}

//@property (nonatomic,weak) id delegatePageController;

@end

//@protocol THHighlightedTableViewScrollViewDelegateProtocol <NSObject>
//- (void)highlightedTableViewScrollViewDidScroll:(THHighlightedTableViewScrollView*)sender;
//@end
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@interface THHighlightedTableView : NSTableView
{
	NSTrackingArea *_highlightedTrackingArea;
	NSPoint _firstHighlightedPoint;
	NSInteger _highlightedRow;
	BOOL _highlightedRowIsChanging;
}

- (void)startHighlightedTracking;
- (void)stopHighlightedTracking;

- (void)updateHighLightedRowFromSelectionDidChange;
- (void)updateHighLightedCellAfterScroll;
- (void)updateHighLightedCellAfterDeletion;
- (void)unhighlightRow;

- (NSPoint)convertWindowPointOfRow:(NSInteger)row;

@end

@protocol THHighlightedTableViewDelegateProtocol <NSTableViewDelegate>
@required
- (void)highlightedTableView:(THHighlightedTableView*)tableView didHighlightRow:(NSInteger)highlightedRow previousHighlightedRow:(NSInteger)previousHighlightedRow;
@end
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
