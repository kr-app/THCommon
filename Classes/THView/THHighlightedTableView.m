// THHighlightedTableView.m

#import "THHighlightedTableView.h"
#import "THFoundation.h"
#import "THLog.h"
#import "TH_APP-Swift.h"

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation THHighlightedTableViewScrollView

- (void)scrollWheel:(NSEvent *)event
{
	[super scrollWheel:event];
//	[self updateHighLightedCellAfterScroll];
}

- (void)reflectScrolledClipView:(NSClipView *)aClipView
{
	[super reflectScrolledClipView:aClipView];
	[self updateHighLightedCellAfterScroll];
}

- (void)updateHighLightedCellAfterScroll
{
	if (_enclosedTableView==nil)
	{
		_enclosedTableView=(THHighlightedTableView*)self.documentView;
		THException([_enclosedTableView isKindOfClass:[THHighlightedTableView class]]==NO,@"documen view is not THHighlightedTableView class");
	}
	[_enclosedTableView updateHighLightedCellAfterScroll];

//	[(id<THHighlightedTableViewScrollViewDelegateProtocol>)self.delegatePageController highlightedTableViewScrollViewDidScroll:self];
}

@end
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@implementation THHighlightedTableView

- (void)awakeFromNib
{
	[super awakeFromNib];

	THHighlightedTableViewScrollView *sv=(THHighlightedTableViewScrollView*)self.enclosingScrollView;
	THException([sv isKindOfClass:[THHighlightedTableViewScrollView class]]==NO,@"enclosingScrollView is not THHighlightedTableViewScrollView sv:%@",sv);
}

- (void)dealloc
{
	[self removeTrackingArea:_highlightedTrackingArea];
}

- (id<THHighlightedTableViewDelegateProtocol>)highlightedDelegate
{
	return (id<THHighlightedTableViewDelegateProtocol>)self.delegate;
}

#pragma mark -

- (void)reloadData
{
	_highlightedRow=-1;
	[super reloadData];
}

#pragma mark -

- (void)startHighlightedTracking
{
	if (_highlightedTrackingArea!=nil)
		return;
	_highlightedRow=-1;
	[self refreshHighlightedTracking];
}

- (void)stopHighlightedTracking
{
	_highlightedRow=-1;
	[self removeTrackingArea:_highlightedTrackingArea];
}

- (void)refreshHighlightedTracking
{
	[self removeTrackingArea:_highlightedTrackingArea];
	NSTrackingAreaOptions options=		NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved|
																NSTrackingActiveAlways|
																NSTrackingInVisibleRect;
	_highlightedTrackingArea=[[NSTrackingArea alloc] initWithRect:NSMakeRect(0.0,0.0,self.frame.size.width,self.frame.size.height) options:options owner:self userInfo:nil];
	[self addTrackingArea:_highlightedTrackingArea];
}

- (void)updateTrackingAreas
{
	[super updateTrackingAreas];
	[self refreshHighlightedTracking];
}

#pragma mark -

- (void)updateHighLightedCellWithPoint:(NSPoint)point
{
	if (_firstHighlightedPoint.x==0.0 && _firstHighlightedPoint.y==0.0 && _highlightedRow==0)
		_highlightedRow=-1;

	if (_highlightedRow>=self.numberOfRows)
		_highlightedRow=-1;		

	_firstHighlightedPoint=point;
	NSInteger row=[self rowAtPoint:point];
	if (row==_highlightedRow)
		return;

	_highlightedRowIsChanging=YES;

//	if (self.selectedRow!=-1)
//		[self deselectRow:self.selectedRow];

	[[self highlightedDelegate] highlightedTableView:self didHighlightRow:row previousHighlightedRow:_highlightedRow];
	_highlightedRow=row;

	_highlightedRowIsChanging=NO;
}

#pragma mark -

- (BOOL)canHightlight
{
	if (self.window.isKeyWindow==YES || [[NSApplication sharedApplication] isActive]==NO)
		return YES;
	if ([[NSApplication sharedApplication] keyWindow]==self.window)
		return YES;
	return NO;
}

- (void)mouseEntered:(NSEvent*)event
{
	if ([[NSApplication sharedApplication] isActive]==NO)
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

	[self.window makeFirstResponder:self];

	if ([self canHightlight]==NO)
		return;
	
	NSPoint pt=[self convertPoint:[event locationInWindow] fromView:nil];
	[self updateHighLightedCellWithPoint:pt];
}

- (void)mouseExited:(NSEvent*)event
{
	if ([self canHightlight]==NO)
		return;

	[[self highlightedDelegate] highlightedTableView:self didHighlightRow:-1 previousHighlightedRow:_highlightedRow];
	_highlightedRow=-1;
}

- (void)mouseMoved:(NSEvent*)event
{
	if ([self canHightlight]==NO)
		return;

	NSPoint pt=[self convertPoint:[event locationInWindow] fromView:nil];
	[self updateHighLightedCellWithPoint:pt];
}

#pragma mark -

- (void)updateHighLightedRowFromSelectionDidChange
{
	if (_highlightedRowIsChanging==YES)
		return;

	NSInteger pRow=_highlightedRow;
	_highlightedRow=self.selectedRow;
	[[self highlightedDelegate] highlightedTableView:self didHighlightRow:_highlightedRow previousHighlightedRow:pRow];
}

- (void)updateHighLightedCellAfterScroll
{
	NSPoint location=[self.window mouseLocationOutsideOfEventStream];
	NSPoint pt=[self convertPoint:location fromView:nil];
	[self updateHighLightedCellWithPoint:pt];
}

- (void)updateHighLightedCellAfterDeletion
{
	_highlightedRow=-1;
	[self updateHighLightedCellAfterScroll];
}

- (void)unhighlightRow
{
	NSInteger pRow=_highlightedRow;
	_highlightedRow=-1;
	[[self highlightedDelegate] highlightedTableView:self didHighlightRow:_highlightedRow previousHighlightedRow:pRow];
}

#pragma mark -

- (NSPoint)convertWindowPointOfRow:(NSInteger)row
{
	NSRect rowRect=[self rectOfRow:row];

	NSPoint pt=NSMakePoint(rowRect.origin.x,rowRect.origin.y+CGFloatFloor(rowRect.size.height/2.0));
	pt=[self convertPointToBase:pt];
	//NSPoint p=[self.view.window.contentView convertPoint:rowPoint toView:self.tableView];
	pt=[self.window convertRectToScreen:NSMakeRect(pt.x,pt.y,0.0,0.0)].origin;

	return pt;
}

@end
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
