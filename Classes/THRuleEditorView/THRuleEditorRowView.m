// THRuleEditorRowView.m

#import "THRuleEditorRowView.h"
#import "TH_APP-Swift.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THRuleEditorRowView

static CGFloat marginLR=8.0;

//- (BOOL)acceptsFirstResponder { return YES; }
//
//- (BOOL)becomeFirstResponder { return YES; }
//
//- (BOOL)resignFirstResponder { return YES; }
//
//- (BOOL)canBecomeKeyView { return YES; }

- (void)setNextResponder:(NSResponder*)aResponder
{
	[super setNextResponder:aResponder];
}

- (void)setNextKeyView:(NSView*)next
{
	[super setNextKeyView:next];
}

- (id)initWithFrame:(NSRect)frameRect rowIndex:(NSInteger)rowIndex rulesEditor:(id)rulesEditor
{
	if (self=[super initWithFrame:frameRect])
	{
		self.autoresizingMask=NSViewMinYMargin|NSViewWidthSizable;
		self.rowIndex=rowIndex;

		_rulesEditor=(id<THRuleEditorRowViewDelegateProtocol>)rulesEditor;
		_isEnabled=YES;
	}
	return self;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<%@ %@ criterionViews:%@>",[self className],self,_criterionViews];
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//	[[NSColor colorWithCalibratedWhite:0.7 alpha:1.0] set];
//	[NSBezierPath fillRect:self.bounds];
//}

- (void)criterionPopMenuAction:(NSPopUpButton*)sender
{
	[_rulesEditor ruleEditorRowView:self popUpButtonDidChange:sender];
}

//- (void)criterionTextFieldAction:(NSTextField*)sender
//{
//}

- (void)criterionDatePickerAction:(NSDatePicker*)sender
{
	[_rulesEditor ruleEditorRowView:self datePickerDidChange:sender];
}

- (void)controlTextDidChange:(NSNotification*)notification
{
	id sender=notification.object;
	if ([sender isKindOfClass:[NSComboBox class]]==YES)
		[_rulesEditor ruleEditorRowView:self comboBoxDidChange:sender];
	else if ([sender isKindOfClass:[NSTextField class]]==YES)
		[_rulesEditor ruleEditorRowView:self textFieldDidChange:sender];
}

- (void)valueAndUnitViewDidChange:(THValueAndUnitView*)sender
{
	if ([sender isKindOfClass:[THDateWithinStepperView class]]==YES)
		[_rulesEditor ruleEditorRowView:self dateWithinStepperDidChange:(THDateWithinStepperView*)sender];
	else if ([sender isKindOfClass:[THFileSizeStepperView class]]==YES)
		[_rulesEditor ruleEditorRowView:self fileSizeStepperDidChange:(THFileSizeStepperView*)sender];
}

- (void)criterionComboBoxAction:(NSComboBox*)sender
{
	[_rulesEditor ruleEditorRowView:self comboBoxDidValidated:sender];
}

- (BOOL)hasViewController:(NSViewController*)viewController
{
	if (viewController!=nil && [_criterionViews containsObject:viewController.view]==YES)
		return YES;
	return NO;
}

- (void)updateWithCriterion:(NSDictionary*)criterion
{
	[_criterionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self updateUIButtons];

	NSSize frameSz=self.frame.size;
	NSInteger buttonsPosition=[_rulesEditor ruleEditorRowViewButtonsPosition:self];
	NSSize bSize=[self buttonsSize];

	NSRect cRect=NSMakeRect(buttonsPosition=='l'?(marginLR+bSize.width*2.0+8.0):marginLR,0.0,100.0,self.frame.size.height);
	NSMutableArray *nCriterionViews=[NSMutableArray array];
	NSView *pCriterionView=nil;

	for (THRuleItem *ruleItem in criterion[@"items"])
	{
		if (ruleItem.isInvisible==YES)
			continue;

		if (ruleItem.wSize==0.0)
			cRect.size.width=(frameSz.width-cRect.origin.x-40.0);
		else
			cRect.size.width=ruleItem.wSize;

		THRuleEditorControl *ruleEditorControl=[[THRuleEditorControl alloc] init];
		NSView *criterionView=nil;
		if (ruleItem.kind==THRuleItemKind_popMenu)
			criterionView=[ruleEditorControl popUpButtonWithFrame:cRect ruleItem:ruleItem controlView:self];
		else if (ruleItem.kind==THRuleItemKind_label)
			criterionView=[ruleEditorControl labelWithFrame:cRect ruleItem:ruleItem controlView:self];
		else if (ruleItem.kind==THRuleItemKind_textField)
			criterionView=[ruleEditorControl textFieldWithFrame:cRect ruleItem:ruleItem controlView:self];
		else if (ruleItem.kind==THRuleItemKind_datePicker)
			criterionView=[ruleEditorControl datePickerWithFrame:cRect ruleItem:ruleItem controlView:self];
		else if (ruleItem.kind==THRuleItemKind_dateWithin)
			criterionView=[ruleEditorControl dateWithinStepperViewWithFrame:cRect ruleItem:ruleItem controlView:self];
		else if (ruleItem.kind==THRuleItemKind_fileSize)
			criterionView=[ruleEditorControl fileSizeViewWithFrame:cRect ruleItem:ruleItem controlView:self];
		else if (ruleItem.kind==THRuleItemKind_combox)
			criterionView=[ruleEditorControl comboxWithFrame:cRect ruleItem:ruleItem controlView:self];
		else if (ruleItem.kind==THRuleItemKind_viewController)
		{
			[ruleItem.viewController rulesEditorViewWillDisplayView];
			criterionView=ruleItem.viewController.view;
			criterionView.frame=NSMakeRect(cRect.origin.x,cRect.origin.y,cRect.size.width,cRect.size.height);
		}
	
		if (ruleItem.kind==THRuleItemKind_textField || ruleItem.kind==THRuleItemKind_combox)
		{
			if (ruleItem==[criterion[@"items"] lastObject])
				criterionView.autoresizingMask=NSViewWidthSizable;
		}

		[self addSubview:criterionView];
		[nCriterionViews addObject:criterionView];

		if (pCriterionView==nil)
			self.nextKeyView=criterionView;
		else
			pCriterionView.nextKeyView=criterionView;
		pCriterionView=criterionView;

		cRect.origin.x+=cRect.size.width+8.0;
	}

	pCriterionView.nextResponder=self;

	_criterionViews=[NSArray arrayWithArray:nCriterionViews];
}

- (NSSize)buttonsSize { return NSMakeSize(16.0,16.0); }

- (void)updateUIButtons
{
	NSSize frameSz=self.frame.size;
	NSInteger buttonsPosition=[_rulesEditor ruleEditorRowViewButtonsPosition:self];
	NSSize bSize=[self buttonsSize];
	
	BOOL showAddButton=self.rowIndex<15?YES:NO;
	BOOL showRemoveButton=self.isFirstEmpty==YES?NO:[_rulesEditor ruleEditorRowViewCanRemove:self];

	if (showAddButton==YES && _addButtonView==nil)
	{
		NSRect rect=NSMakeRect(		(buttonsPosition=='l' || self.isFirstEmpty==YES)?marginLR:(frameSz.width-bSize.width-marginLR),
									  									CGFloatFloor((frameSz.height-bSize.height)/2.0)+1.0,
									  									bSize.width,bSize.height);
	
		_addButtonView=[[THOverView alloc] initWithFrame:rect];
		_addButtonView.delegator=self;
		_addButtonView.autoresizingMask=(buttonsPosition=='l' || self.isFirstEmpty==YES)?NSViewMaxXMargin:NSViewMinXMargin;
		[self addSubview:_addButtonView];
	}
	else if (showAddButton==NO && _addButtonView!=nil)
	{
		[_addButtonView removeFromSuperview];
		_addButtonView=nil;
	}

	if (showRemoveButton==YES && _removeButtonView==nil)
	{
		NSRect rect=NSMakeRect(0.0,CGFloatFloor((frameSz.height-bSize.height)/2.0)+1.0,bSize.width,bSize.height);
		if (buttonsPosition=='l')
			rect.origin.x=_addButtonView.frame.origin.x+_addButtonView.frame.size.width;
		else if (_addButtonView!=nil)
			rect.origin.x=_addButtonView.frame.origin.x-_addButtonView.frame.size.width;
		else
			rect.origin.x=frameSz.width-rect.size.width-marginLR;

		_removeButtonView=[[THOverView alloc] initWithFrame:rect];
		_removeButtonView.delegator=self;
		_removeButtonView.autoresizingMask=buttonsPosition=='l'?NSViewMaxXMargin:NSViewMinXMargin;
		[self addSubview:_removeButtonView];
	}
	else if (showRemoveButton==NO && _removeButtonView!=nil)
	{
		[_removeButtonView removeFromSuperview];
		_removeButtonView=nil;
	}
}

- (void)overView:(THOverView*)sender drawRect:(NSRect)rect withState:(THOverViewState)state
{
//	[[NSColor orangeColor] set];
//	[NSBezierPath fillRect:rect];

	static NSDictionary *attrs[4]={nil,nil,nil,nil};
	if (attrs[0]==nil)
	{
		NSFont *font=[NSFont boldSystemFontOfSize:14.0];
		attrs[0]=@{NSFontAttributeName:font,NSForegroundColorAttributeName:[NSColor colorWithCalibratedWhite:0.5 alpha:1.0]};
		attrs[1]=@{NSFontAttributeName:font,NSForegroundColorAttributeName:[NSColor colorWithCalibratedWhite:0.33 alpha:1.0]};
		attrs[2]=@{NSFontAttributeName:font,NSForegroundColorAttributeName:[NSColor colorWithCalibratedWhite:0.1 alpha:1.0]};
		attrs[3]=@{NSFontAttributeName:font,NSForegroundColorAttributeName:[NSColor colorWithCalibratedWhite:0.5 alpha:1.0]};
	}

	NSDictionary *a=attrs[state==THOverViewStateDisabled?3:state==THOverViewStateHighlighted?1:state==THOverViewStatePressed?2:0];
	NSAttributedString *as=[[NSAttributedString alloc] initWithString:sender==_addButtonView?@"+":@"-" attributes:a];

	NSSize sz=as.size;
	sz=NSMakeSize(CGFloatCeil(sz.width),CGFloatCeil(sz.height));

	[as drawAtPoint:NSMakePoint(CGFloatCeil((rect.size.width-sz.width)/2.0),CGFloatCeil((rect.size.height-sz.height)/2.0)+2.0)];
}

- (void)overView:(THOverView*)sender didPressed:(NSDictionary*)infos
{
	if (sender==_removeButtonView)
		[_rulesEditor ruleEditorRowViewWantsRemove:self infos:0];
	else if (sender==_addButtonView)
		[_rulesEditor ruleEditorRowViewWantsNewRow:self infos:0];
}

- (void)setIsEnabled:(BOOL)isEnabled
{
	if (_isEnabled==isEnabled)
		return;
	_isEnabled=isEnabled;

	for (id view in _criterionViews)
	{
		if ([view isKindOfClass:[NSPopUpButton class]]==YES)
			[(NSPopUpButton*)view setEnabled:isEnabled];
		else if ([view isKindOfClass:[NSTextField class]]==YES)
			[(NSTextField*)view setEnabled:isEnabled];
		else if ([view isKindOfClass:[NSDatePicker class]]==YES)
			[(NSDatePicker*)view setEnabled:isEnabled];
		else if ([view isKindOfClass:[THFileSizeStepperView class]]==YES)
			[(THFileSizeStepperView*)view setEnabled:isEnabled];
		else
			THException(1,@"view:%@",view);
	}

	[_removeButtonView setIsDisabled:isEnabled==YES?NO:YES];
	[_addButtonView setIsDisabled:isEnabled==YES?NO:YES];
}

- (void)makeNextKeyRowView:(THRuleEditorRowView*)rowView
{
	[_criterionViews.lastObject setNextKeyView:rowView];
}

- (BOOL)makeFirstKeyViewResponder
{
	if (_criterionViews.count==0)
		return NO;
	return [self.window makeFirstResponder:_criterionViews[0]];
}

//- (void)keyDown:(NSEvent*)theEvent
//{
//	[self peformKeyDownEvent:theEvent];
//	[super keyDown:theEvent];
//}

- (BOOL)peformKeyDownEvent:(NSEvent*)theEvent
{
	if (_isEnabled==NO || theEvent==nil || theEvent.type!=NSEventTypeKeyDown)
		return NO;

	NSString *characters=theEvent.charactersIgnoringModifiers;
	NSUInteger modifierFlags=theEvent.modifierFlags;
	if (characters.length==1)
	{
		if ([characters isEqualToString:@"+"]==YES && (modifierFlags&NSEventModifierFlagCommand)!=0 && _addButtonView!=nil)
		{
			[_rulesEditor ruleEditorRowViewWantsNewRow:self infos:1];
			return YES;
		}
		else if ([characters isEqualToString:@"-"]==YES && (modifierFlags&NSEventModifierFlagCommand)!=0 && _removeButtonView!=nil)
		{
			[_rulesEditor ruleEditorRowViewWantsRemove:self infos:1];
			return YES;
		}
	}
	return NO;
}

- (BOOL)performActionWithEvent:(NSEvent*)theEvent firstResponder:(id)firstResponder
{
	if (_isEnabled==NO || theEvent==nil || firstResponder==nil || [firstResponder isKindOfClass:[NSView class]]==NO || [firstResponder isDescendantOf:self]==NO)
		return NO;
	return [self peformKeyDownEvent:theEvent];
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
