// THRuleEditorView.m

#import "THRuleEditorView.h"
#import "TH_APP-Swift.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THRuleEditorView

//- (BOOL)acceptsFirstResponder { return YES; }
//
//- (BOOL)canBecomeKeyView { return YES; }

- (BOOL)isFlipped { return self.enclosingScrollView!=nil?YES:NO; }

- (NSArray*)criteria { return _criteria; }

- (void)reloadDataWithCriteria:(NSArray*)criteria
{
	_criteria=[NSArray arrayWithArray:criteria];
	//[self.delegate rulesEditorView:self didChangeCriteria:_criteria];
	[_rowViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

	NSSize frameSz=self.frame.size;
	NSSize nSize=NSMakeSize(frameSz.width,self.marginTop);
	CGFloat rowHeight=self.rowHeight==0.0?27.0:self.rowHeight;

	CGFloat ptY=frameSz.height-self.marginTop;
	NSInteger rowIndex=0;
	NSMutableArray *nRowViews=[NSMutableArray array];
	THRuleEditorRowView *prevRowView=nil;

	for (NSDictionary *criterion in _criteria)
	{
		ptY-=rowHeight;

		NSRect rect=NSMakeRect(0.0,ptY,frameSz.width,rowHeight);
		THRuleEditorRowView *rowView=[[THRuleEditorRowView alloc] initWithFrame:rect rowIndex:rowIndex rulesEditor:self];
		[rowView updateWithCriterion:criterion];

		[self addSubview:rowView];
		[nRowViews addObject:rowView];

		nSize.height+=rowView.frame.size.height;
		rowIndex+=1;
	
		if (prevRowView==nil)
			self.nextKeyView=rowView;
		else
		{
			prevRowView.nextKeyView=rowView;
			prevRowView=rowView;
		}
	}

	if (_criteria.count==0)
	{
		ptY-=rowHeight;

		NSDictionary *criterion=@{@"items":@[]};

		NSRect rect=NSMakeRect(0.0,ptY,frameSz.width,rowHeight);
		THRuleEditorRowView *rowView=[[THRuleEditorRowView alloc] initWithFrame:rect rowIndex:rowIndex rulesEditor:self];
		rowView.isFirstEmpty=YES;
		[rowView updateWithCriterion:criterion];

		[self addSubview:rowView];
		[nRowViews addObject:rowView];
	
		nSize.height+=rowView.frame.size.height;
	}

	_rowViews=[NSArray arrayWithArray:nRowViews];

	prevRowView.nextKeyView=self;

	nSize.height+=self.marginBottom;
	NSRect frameRect=self.frame;
	self.frame=NSMakeRect(		frameRect.origin.x,
																frameRect.origin.y+(frameRect.size.height-nSize.height),
								 								frameRect.size.width,
																nSize.height);
}

- (NSDictionary*)criterionForRowViewController:(NSViewController*)viewController
{
	for (THRuleEditorRowView *rowView in _rowViews)
		if ([rowView hasViewController:viewController]==YES)
			return _criteria[rowView.rowIndex];
	return nil;
}

#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
//	[[NSColor orangeColor] set]; [NSBezierPath fillRect:self.bounds]; return;

//	NSSize frameSz=self.frame.size;

	if (self.bgColor!=nil)
	{
		[self.bgColor set];
		[NSBezierPath fillRect:self.bounds];
	}

//	[[NSColor colorWithCalibratedWhite:0.7 alpha:1.0] set];
//	[NSBezierPath fillRect:self.bounds];

//	[[NSColor colorWithCalibratedWhite:0.7 alpha:1.0] set];
//	[NSBezierPath fillRect:NSMakeRect(0.0,0.0,frameSz.width,1.0)];
}

- (void)setIsEnabled:(BOOL)isEnabled
{
	for (THRuleEditorRowView *rowView in _rowViews)
		[rowView setIsEnabled:isEnabled];
}

- (BOOL)performActionWithEvent:(NSEvent*)theEvent firstResponder:(id)firstResponder
{
	for (THRuleEditorRowView *rowView in _rowViews)
		if ([rowView performActionWithEvent:theEvent firstResponder:firstResponder]==YES)
			return YES;
	return NO;
}

- (BOOL)makeDefaultFirstResponder
{
	return [self.window makeFirstResponder:self];
}

#pragma mark -

- (NSInteger)ruleEditorRowViewButtonsPosition:(id)sender
{
	return self.buttonsPosition;
}

- (BOOL)ruleEditorRowViewCanRemove:(id)sender
{
	if (self.canBeEmpty==YES)
		return YES;
	return _criteria.count>1?YES:NO;
}

- (void)ruleEditorRowViewWantsNewRow:(THRuleEditorRowView*)sender infos:(NSInteger)infos
{
	if (_isSomeAnimating==YES || _criteria.count>=15)
		return;

	BOOL isFirstEmpty=sender.isFirstEmpty;
	NSInteger rowIndex=sender.rowIndex;

	if ([self.delegate rulesEditorView:self canAddRowAtIndex:rowIndex]==NO)
		return;

	NSRect fRect=self.frame;
	CGFloat rowOffset=isFirstEmpty==NO?sender.frame.size.height:0.0;
	if (isFirstEmpty==NO)
		self.frame=NSMakeRect(fRect.origin.x,fRect.origin.y-rowOffset,fRect.size.width,fRect.size.height+rowOffset);

	NSDictionary *criterion=[self.delegate rulesEditorView:self addRow:rowIndex+1 rowOffset:rowOffset];
	THException(criterion==nil,@"criterion==nil");

	NSMutableArray *nCriteria=[NSMutableArray arrayWithArray:_criteria];
	if (rowIndex+1>=nCriteria.count)
		[nCriteria addObject:criterion];
	else
		[nCriteria insertObject:criterion atIndex:rowIndex+1];
	_criteria=[NSArray arrayWithArray:nCriteria];
	[self.delegate rulesEditorView:self didChangeCriteria:_criteria];

	NSMutableArray *rowViews=[NSMutableArray array];
	NSRect nextRowRect=NSZeroRect;
	THRuleEditorRowView *nRuleEditorRowView=nil;
	BOOL needsNextKV=NO;

	for (THRuleEditorRowView *rowView in _rowViews)
	{
		if (isFirstEmpty==NO)
		{
			nextRowRect=rowView.frame;
			[rowViews addObject:rowView];
			[rowView updateUIButtons];
		}

		if (rowView==sender)
		{
			NSRect rect=isFirstEmpty==YES?sender.frame:NSMakeRect(nextRowRect.origin.x,nextRowRect.origin.y-nextRowRect.size.height,fRect.size.width,nextRowRect.size.height);
			nRuleEditorRowView=[[THRuleEditorRowView alloc] initWithFrame:rect rowIndex:isFirstEmpty==YES?0:rowIndex+1 rulesEditor:self];
			nRuleEditorRowView.alphaValue=0.0;

			[self addSubview:nRuleEditorRowView positioned:NSWindowAbove relativeTo:sender];
			[rowViews addObject:nRuleEditorRowView];
			[nRuleEditorRowView updateWithCriterion:criterion];

			[rowView makeNextKeyRowView:nRuleEditorRowView];
			needsNextKV=YES;

			continue;
		}
		else if (nRuleEditorRowView!=nil)
		{
			if (needsNextKV==YES)
			{
				[nRuleEditorRowView makeNextKeyRowView:rowView];
				needsNextKV=NO;
			}

			rowView.rowIndex+=1;
			rowView.frame=NSMakeRect(rowView.frame.origin.x,rowView.frame.origin.y-rowView.frame.size.height,rowView.frame.size.width,rowView.frame.size.height);
		}
	}
	_rowViews=[NSArray arrayWithArray:rowViews];

	_isSomeAnimating=YES;
	THRuleEditorRowView *rowViewToRemove=isFirstEmpty==YES?sender:nil;

	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
	{
		context.duration=0.25;
		[(NSView*)rowViewToRemove.animator setAlphaValue:0.0];
		[(NSView*)nRuleEditorRowView.animator setAlphaValue:1.0];
	}
	completionHandler:^
	{
		_isSomeAnimating=NO;
		[rowViewToRemove removeFromSuperview];
		if ((infos&1)!=0)
			[nRuleEditorRowView makeFirstKeyViewResponder];
	}];
}

- (void)ruleEditorRowViewWantsRemove:(THRuleEditorRowView*)sender infos:(NSInteger)infos
{
	if (_isSomeAnimating==YES || (self.canBeEmpty==NO && _criteria.count<=1))
		return;

	CGFloat rowOffset=sender.frame.size.height;
	NSInteger rowIndex=sender.rowIndex;

	NSMutableArray *nCriteria=[NSMutableArray arrayWithArray:_criteria];
	[nCriteria removeObjectAtIndex:rowIndex];
	_criteria=[NSArray arrayWithArray:nCriteria];
	[self.delegate rulesEditorView:self didChangeCriteria:_criteria];

	THRuleEditorRowView *nRowView=nil;
	if (_criteria.count==0 && self.canBeEmpty==YES)
	{
		NSDictionary *criterion=@{@"items":@[]};

		NSRect rect=sender.frame;
		nRowView=[[THRuleEditorRowView alloc] initWithFrame:rect rowIndex:sender.rowIndex rulesEditor:self];
		nRowView.isFirstEmpty=YES;
		[nRowView updateWithCriterion:criterion];
		nRowView.alphaValue=0.0;

		[self addSubview:nRowView];
		_rowViews=[_rowViews arrayByAddingObject:nRowView];

		rowOffset=0.0;
	}

	_isSomeAnimating=YES;

	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
	{
		context.duration=0.25;
		[(NSView*)sender.animator setAlphaValue:0.0];
		[(NSView*)nRowView setAlphaValue:1.0];
	}
	completionHandler:^
	{
		_isSomeAnimating=NO;
		[sender removeFromSuperview];

		NSMutableArray *nRowViews=[NSMutableArray array];
		NSRect nextRowRect=NSZeroRect;
		THRuleEditorRowView *rowViewToBeKey=nil;

		for (THRuleEditorRowView *rowView in _rowViews)
		{
			if (rowView==sender)
			{
				if (rowView.rowIndex==0)
					rowViewToBeKey=_rowViews.count>1?_rowViews[1]:nil;
				else
					rowViewToBeKey=_rowViews.count>1?_rowViews[rowView.rowIndex-1]:nil;
				continue;
			}

			nextRowRect=rowView.frame;
			[nRowViews addObject:rowView];
			[rowView updateUIButtons];

			if (rowView.rowIndex>rowIndex)
			{
				rowView.rowIndex-=1;
				rowView.frame=NSMakeRect(rowView.frame.origin.x,rowView.frame.origin.y+rowView.frame.size.height,rowView.frame.size.width,rowView.frame.size.height);
			}
		}
		_rowViews=[NSArray arrayWithArray:nRowViews];

		THRuleEditorRowView *pRowView=nil;
		for (THRuleEditorRowView *rowView in nRowViews)
		{
			if (pRowView==nil)
				self.nextKeyView=rowView;
			else
				[pRowView makeNextKeyRowView:rowView];
			pRowView=rowView;
		}

		if ((infos&1)!=0)
			[rowViewToBeKey makeFirstKeyViewResponder];

		NSRect fRect=self.frame;
		self.frame=NSMakeRect(fRect.origin.x,fRect.origin.y+rowOffset,fRect.size.width,fRect.size.height-rowOffset);

		[self.delegate rulesEditorView:self removeRow:rowIndex rowOffset:-rowOffset];
	}];
}

- (void)ruleEditorRowView:(THRuleEditorRowView*)sender popUpButtonDidChange:(NSPopUpButton*)popUpButton
{
	NSDictionary *criterion=_criteria[sender.rowIndex];
	NSDictionary *nCriterion=[self.delegate rulesEditorView:self didChangeMenu:popUpButton.menu selectedItem:popUpButton.selectedItem criterion:criterion];

	if (nCriterion!=nil && nCriterion!=criterion)
	{
		NSMutableArray *nCriteria=[NSMutableArray array];
		for (NSDictionary *object in _criteria)
			[nCriteria addObject:object==criterion?nCriterion:object];
		_criteria=[NSArray arrayWithArray:nCriteria];
		[sender updateWithCriterion:nCriterion];
	}

	[self.delegate rulesEditorView:self didChangeCriteria:_criteria];
}

- (void)ruleEditorRowView:(THRuleEditorRowView*)sender textFieldDidChange:(NSTextField*)textField
{
	NSDictionary *criterion=_criteria[sender.rowIndex];
	[self.delegate rulesEditorView:self didChangeTextField:textField.stringValue criterion:criterion];
	[self.delegate rulesEditorView:self didChangeCriteria:_criteria];
}

- (void)ruleEditorRowView:(THRuleEditorRowView*)sender datePickerDidChange:(NSDatePicker*)datePicker
{
	NSDictionary *criterion=_criteria[sender.rowIndex];
	[self.delegate rulesEditorView:self didChangeDate:datePicker.dateValue criterion:criterion];
	[self.delegate rulesEditorView:self didChangeCriteria:_criteria];
}

- (void)ruleEditorRowView:(THRuleEditorRowView*)sender dateWithinStepperDidChange:(THDateWithinStepperView*)dateStepper
{
	NSDictionary *criterion=_criteria[sender.rowIndex];
	[self.delegate rulesEditorView:self didChangeDateWithinValue:dateStepper.valueComps criterion:criterion];
	[self.delegate rulesEditorView:self didChangeCriteria:_criteria];
}

- (void)ruleEditorRowView:(THRuleEditorRowView*)sender fileSizeStepperDidChange:(THFileSizeStepperView*)fileSizeStepper
{
	NSDictionary *criterion=_criteria[sender.rowIndex];
	[self.delegate rulesEditorView:self didChangeFileSizeValue:fileSizeStepper.valueComps criterion:criterion];
	[self.delegate rulesEditorView:self didChangeCriteria:_criteria];
}

- (void)ruleEditorRowView:(THRuleEditorRowView*)sender comboBoxDidChange:(NSComboBox*)comboBox
{
	NSDictionary *criterion=_criteria[sender.rowIndex];
	[self.delegate rulesEditorView:self didChangeCombox:comboBox.stringValue strings:comboBox.objectValues criterion:criterion];
	[self.delegate rulesEditorView:self didChangeCriteria:_criteria];
}

- (void)ruleEditorRowView:(THRuleEditorRowView*)sender comboBoxDidValidated:(NSComboBox*)comboBox
{
	NSDictionary *criterion=_criteria[sender.rowIndex];
	NSArray *strings=[self.delegate rulesEditorView:self didValidatedCombox:comboBox.stringValue strings:comboBox.objectValues criterion:criterion];
	[comboBox removeAllItems];
	[comboBox addItemsWithObjectValues:[NSArray arrayWithArray:strings]];
	[self.delegate rulesEditorView:self didChangeCriteria:_criteria];
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
