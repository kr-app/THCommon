// THRuleEditorView.h

#import <Cocoa/Cocoa.h>
#import "THRuleEditorItem.h"
#import "THRuleEditorRowView.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@protocol THRuleEditorViewDelegateSourceProtocol;

@interface THRuleEditorView : NSView
{
	NSArray *_criteria;
	NSArray *_rowViews;
	BOOL _isSomeAnimating;
}

@property (nonatomic,weak) id <THRuleEditorViewDelegateSourceProtocol> delegate;
@property (nonatomic,strong) NSColor *bgColor;
@property (nonatomic) CGFloat marginTop;
@property (nonatomic) CGFloat marginBottom;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) BOOL canBeEmpty;
@property (nonatomic) NSInteger buttonsPosition;

- (NSArray*)criteria;
- (void)reloadDataWithCriteria:(NSArray*)criteria;
- (NSDictionary*)criterionForRowViewController:(NSViewController*)viewController;

- (void)setIsEnabled:(BOOL)isEnabled;
- (BOOL)performActionWithEvent:(NSEvent*)theEvent firstResponder:(id)firstResponder;
- (BOOL)makeDefaultFirstResponder;

@end

@protocol THRuleEditorViewDelegateSourceProtocol <NSObject>
@required

- (BOOL)rulesEditorView:(THRuleEditorView*)sender canAddRowAtIndex:(NSInteger)rowIndex;
- (NSDictionary*)rulesEditorView:(THRuleEditorView*)sender addRow:(NSInteger)rowIndex rowOffset:(CGFloat)rowOffset;
- (void)rulesEditorView:(THRuleEditorView*)sender removeRow:(NSInteger)rowIndex rowOffset:(CGFloat)rowOffset;

- (NSDictionary*)rulesEditorView:(THRuleEditorView*)sender didChangeMenu:(NSMenu*)menu selectedItem:(NSMenuItem*)selectedItem criterion:(NSDictionary*)criterion;
- (void)rulesEditorView:(THRuleEditorView*)sender didChangeTextField:(NSString*)stringValue criterion:(NSDictionary*)criterion;
- (void)rulesEditorView:(THRuleEditorView*)sender didChangeDate:(NSDate*)dateValue criterion:(NSDictionary*)criterion;
- (void)rulesEditorView:(THRuleEditorView*)sender didChangeDateWithinValue:(NSString*)dateValue criterion:(NSDictionary*)criterion;
- (void)rulesEditorView:(THRuleEditorView*)sender didChangeFileSizeValue:(NSString*)fileSizeValue criterion:(NSDictionary*)criterion;
- (void)rulesEditorView:(THRuleEditorView*)sender didChangeCombox:(NSString*)string strings:(NSArray*)strings criterion:(NSDictionary*)criterion;
- (NSArray*)rulesEditorView:(THRuleEditorView*)sender didValidatedCombox:(NSString*)string strings:(NSArray*)strings criterion:(NSDictionary*)criterion;

- (void)rulesEditorView:(THRuleEditorView*)sender didChangeCriteria:(NSArray*)criteria;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
