// THValueAndUnitView.m

#import "THValueAndUnitView.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@interface THValueAndUnitView_PopUpButton : NSPopUpButton
@end

@implementation THValueAndUnitView_PopUpButton
- (BOOL)canBecomeKeyView { return YES; }
@end

@interface THValueAndUnitView_Stepper : NSStepper
@end

@implementation THValueAndUnitView_Stepper
- (BOOL)canBecomeKeyView { return YES; }
@end
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THValueAndUnitView

- (id)initWithFrame:(NSRect)frame popBezelStyle:(NSBezelStyle)popBezelStyle controlView:(id<THValueAndUnitViewDelegateProtocol>)controlView
{
	if (self=[super initWithFrame:frame])
	{
		_controlView=controlView;

		NSRect fieldRect=NSMakeRect(0.0,CGFloatFloor((frame.size.height-19.0)/2.0),50.0,19.0);
		
		NSRect stepperRect=NSMakeRect(fieldRect.size.width+4.0,CGFloatFloor((frame.size.height-22.0)/2.0),16.0,22.0);

		NSRect menuRect=NSMakeRect(stepperRect.origin.x+stepperRect.size.width+4.0,CGFloatFloor((frame.size.height-22.0)/2.0),60.0,22.0);
		if ([self isKindOfClass:[THDateWithinStepperView class]]==YES)
			menuRect.size.width=90.0;
	
		NSFont *font=[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeSmall]];

		{
			_textField=[[NSTextField alloc] initWithFrame:fieldRect];

			_textField.font=font;
			//	result.target=self;
			//	result.action=@selector(criterionTextFieldAction:);
			_textField.delegate=self;
			[_textField setEditable:YES];
			[_textField setSelectable:YES];
			[_textField setDrawsBackground:YES];

			NSNumberFormatter *nbFormatter=[[NSNumberFormatter alloc] init];
			nbFormatter.numberStyle=NSNumberFormatterDecimalStyle;
			nbFormatter.usesGroupingSeparator=NO;
			_textField.formatter=nbFormatter;

			[(NSTextFieldCell*)_textField.cell setControlSize:NSControlSizeSmall];
			[(NSTextFieldCell*)_textField.cell setAlignment:NSTextAlignmentRight];

			[self addSubview:_textField];
		}

		{
			NSDictionary *stepInfos=[self valueStepperInfos];
			_stepper=[[THValueAndUnitView_Stepper alloc] initWithFrame:stepperRect];
			_stepper.target=self;
			_stepper.action=@selector(fileSizeStepperAction:);
			_stepper.minValue=1.0;
			_stepper.integerValue=1;
			_stepper.maxValue=[stepInfos[@"maxValue"] integerValue];
			[(NSStepperCell*)_stepper.cell setControlSize:NSControlSizeSmall];
			
			[self addSubview:_stepper];
		}

		{
			NSMenu *menu=[self unitMenu];
			_popUpButton=[[THValueAndUnitView_PopUpButton alloc] initWithFrame:menuRect];
			_popUpButton.alignment=NSTextAlignmentLeft;
			_popUpButton.bezelStyle=popBezelStyle;
			_popUpButton.target=self;
			_popUpButton.action=@selector(fileSizePoidsMenuAction:);
			_popUpButton.menu=menu;
			_popUpButton.autoresizingMask=NSViewMaxXMargin;

			[(NSPopUpButtonCell*)_popUpButton.cell setControlSize:NSControlSizeSmall];
			[(NSPopUpButtonCell*)_popUpButton.cell setFont:font];

			[self addSubview:_popUpButton];
		}
	}
	return self;
}

- (void)dealloc
{
    _controlView=nil;
}

#pragma mark -

- (NSDictionary*)valueStepperInfos { return nil; }

- (NSMenu*)unitMenu { return nil; }

#pragma mark -

- (NSInteger)value { return _textField.integerValue; }

- (NSInteger)poids { return _popUpButton.selectedTag; }

- (void)setValue:(NSInteger)value poids:(NSInteger)poids
{
	_textField.integerValue=value;
	_stepper.integerValue=value;
	[_popUpButton selectItemWithTag:poids];
}

- (NSString*)valueComps
{
	return [NSString stringWithFormat:@"%d|%d",(int)[self value],(int)[self poids]];
}

- (void)setValueComps:(NSString*)comps
{
	NSArray *c=[comps componentsSeparatedByString:@"|"];
	[self setValue:c.count==2?[c[0] integerValue]:1 poids:c.count==2?[c[1] integerValue]:1];
}

- (void)controlTextDidChange:(NSNotification*)notification
{
	if (notification.object!=_textField)
		return;
	if (_textField.integerValue>=(NSInteger)_stepper.minValue)
		_stepper.integerValue=_textField.integerValue;
	[_controlView valueAndUnitViewDidChange:self];
}

- (void)fileSizeStepperAction:(NSStepper*)sender
{
	_textField.integerValue=sender.integerValue;
	[_controlView valueAndUnitViewDidChange:self];
}

- (void)fileSizePoidsMenuAction:(NSPopUpButton*)sender
{
	[_controlView valueAndUnitViewDidChange:self];
}

- (void)setEnabled:(BOOL)isEnabled
{
	[_textField setEnabled:isEnabled];
	[_stepper setEnabled:isEnabled];
	[_popUpButton setEnabled:isEnabled];
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THFileSizeStepperView : THValueAndUnitView

- (NSDictionary*)valueStepperInfos
{
	return @{@"maxValue":@(1000*1000)};
}

- (NSMenu*)unitMenu
{
	NSMenu *menu=[[NSMenu alloc] init];
	[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"FileSizePoids_KB") tag:1]];
	[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"FileSizePoids_MB") tag:2]];
	[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"FileSizePoids_GB") tag:3]];
	[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"FileSizePoids_TB") tag:4]];
	return menu;
}

@end

@implementation THDateWithinStepperView : THValueAndUnitView

- (NSDictionary*)valueStepperInfos
{
	return @{@"maxValue":@(1000)};
}

- (NSMenu*)unitMenu
{
	NSMenu *menu=[[NSMenu alloc] init];
	[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"Minute(s)") tag:THFileSearchUnit_min]];
	[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"Hour(s)") tag:THFileSearchUnit_hour]];
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"Day(s)") tag:THFileSearchUnit_day]];
	[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"Yeek(s)") tag:THFileSearchUnit_week]];
	[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"Month(s)") tag:THFileSearchUnit_month]];
	[menu addItem:[NSMenuItem th_menuItemWithTitle:THLocalizedString(@"Year(s)") tag:THFileSearchUnit_year]];
	return menu;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
