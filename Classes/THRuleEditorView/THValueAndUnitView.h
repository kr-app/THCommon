// THValueAndUnitView.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
@protocol THValueAndUnitViewDelegateProtocol;

@interface THValueAndUnitView : NSView <NSTextFieldDelegate>
{
	NSTextField *_textField;
	NSStepper *_stepper;
	NSPopUpButton *_popUpButton;

	__weak id<THValueAndUnitViewDelegateProtocol>_controlView;
}

- (id)initWithFrame:(NSRect)frame popBezelStyle:(NSBezelStyle)popBezelStyle controlView:(id<THValueAndUnitViewDelegateProtocol>)controlView;

- (NSInteger)value;
- (NSInteger)poids;
- (void)setValue:(NSInteger)value poids:(NSInteger)poids;

- (NSString*)valueComps;
- (void)setValueComps:(NSString*)comps;

- (void)setEnabled:(BOOL)isEnabled;

@end

@protocol THValueAndUnitViewDelegateProtocol <NSObject>
- (void)valueAndUnitViewDidChange:(THValueAndUnitView*)sender;
@end
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THFileSizeStepperView : THValueAndUnitView
@end

@interface THDateWithinStepperView : THValueAndUnitView
@end
//--------------------------------------------------------------------------------------------------------------------------------------------
