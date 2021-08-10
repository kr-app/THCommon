// THRuleEditorRowView.h

#import <Cocoa/Cocoa.h>
#import "TH_APP-Swift.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@protocol THRuleEditorRowViewDelegateProtocol <NSObject>
@required

- (void)criterionPopMenuAction:(NSPopUpButton*)sender;
//- (void)criterionTextFieldAction:(NSTextField*)sender;
- (void)criterionDatePickerAction:(NSDatePicker*)sender;
- (void)criterionComboBoxAction:(NSComboBox*)sender;

- (NSInteger)ruleEditorRowViewButtonsPosition:(id)sender;
- (BOOL)ruleEditorRowViewCanRemove:(id)sender;
- (void)ruleEditorRowViewWantsRemove:(id)sender infos:(NSInteger)infos;
- (void)ruleEditorRowViewWantsNewRow:(id)sender infos:(NSInteger)infos;

- (void)ruleEditorRowView:(id)sender popUpButtonDidChange:(NSPopUpButton*)popUpButton;
- (void)ruleEditorRowView:(id)sender textFieldDidChange:(NSTextField*)textField;
- (void)ruleEditorRowView:(id)sender datePickerDidChange:(NSDatePicker*)datePicker;
- (void)ruleEditorRowView:(id)sender dateWithinStepperDidChange:(THDateWithinStepperView*)dateStepper;
- (void)ruleEditorRowView:(id)sender fileSizeStepperDidChange:(THFileSizeStepperView*)fileSizeStepper;
- (void)ruleEditorRowView:(id)sender comboBoxDidChange:(NSComboBox*)comboBox;
- (void)ruleEditorRowView:(id)sender comboBoxDidValidated:(NSComboBox*)comboBox;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THRuleEditorRowView : NSView <NSTextFieldDelegate,THOverViewDelegateProtocol>
{
	__weak id<THRuleEditorRowViewDelegateProtocol> _rulesEditor;

	NSArray *_criterionViews;
	THOverView *_removeButtonView;
	THOverView *_addButtonView;

	BOOL _isEnabled;
}

@property (nonatomic) NSInteger rowIndex;
@property (nonatomic) BOOL isFirstEmpty;

- (id)initWithFrame:(NSRect)frameRect rowIndex:(NSInteger)rowIndex rulesEditor:(id)rulesEditor;

- (void)setIsEnabled:(BOOL)isEnabled;

- (BOOL)hasViewController:(NSViewController*)viewController;
- (void)updateWithCriterion:(NSDictionary*)criterion;

- (void)updateUIButtons;

- (void)makeNextKeyRowView:(THRuleEditorRowView*)rowView;
- (BOOL)makeFirstKeyViewResponder;
- (BOOL)performActionWithEvent:(NSEvent*)theEvent firstResponder:(id)firstResponder;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
