// THRuleEditorItem.m

#import "THRuleEditorItem.h"
#import "TH_APP-Swift.h"

//--------------------------------------------------------------------------------------------------------------------------------------------
@implementation THRuleItem

+ (THRuleItem*)rulePopMenuWithMenu:(NSMenu*)menu wSize:(CGFloat)wSize selectedTag:(NSInteger)selectedTag
{
	THRuleItem *ruleItem=[[THRuleItem alloc] initWithKind:THRuleItemKind_popMenu wSize:wSize];
	ruleItem.menu=menu;
	ruleItem.menuSelectedTag=selectedTag;
	return ruleItem;
}

+ (THRuleItem*)rulePopMenuWithMenu:(NSMenu*)menu wSize:(CGFloat)wSize selectedObjet:(id)selectedObjet
{
	THRuleItem *ruleItem=[[THRuleItem alloc] initWithKind:THRuleItemKind_popMenu wSize:wSize];
	ruleItem.menu=menu;
	ruleItem.menuSelectedObject=selectedObjet;
	return ruleItem;
}

+ (THRuleItem*)ruleLabelWithText:(NSString*)text
{
	THRuleItem *ruleItem=[[THRuleItem alloc] initWithKind:THRuleItemKind_label wSize:0.0];
	ruleItem.stringValue=text;
	return ruleItem;
}

+ (THRuleItem*)ruleTextFieldWithString:(NSString*)string
{
	THRuleItem *ruleItem=[[THRuleItem alloc] initWithKind:THRuleItemKind_textField wSize:0.0];
	ruleItem.stringValue=string;
	return ruleItem;
}

+ (THRuleItem*)ruleDatePickerWithDate:(NSDate*)date isInvisible:(BOOL)isInvisible
{
	THRuleItem *ruleItem=[[THRuleItem alloc] initWithKind:THRuleItemKind_datePicker wSize:0.0];
	ruleItem.dateValue=date;
	ruleItem.isInvisible=isInvisible;
	return ruleItem;
}

+ (THRuleItem*)ruleDateWithinWithValue:(NSString*)value
{
	THRuleItem *ruleItem=[[THRuleItem alloc] initWithKind:THRuleItemKind_dateWithin wSize:0.0];
	ruleItem.dateWithin=value;
	return ruleItem;
}

+ (THRuleItem*)ruleFileSizeWithValue:(NSString*)value
{
	THRuleItem *ruleItem=[[THRuleItem alloc] initWithKind:THRuleItemKind_fileSize wSize:0.0];
	ruleItem.fileSizeValue=value;
	return ruleItem;
}

+ (THRuleItem*)ruleComboxWithStrings:(NSArray*)strings string:(NSString*)string
{
	THRuleItem *ruleItem=[[THRuleItem alloc] initWithKind:THRuleItemKind_combox wSize:0.0];
	ruleItem.comboStrings=strings;
	ruleItem.stringValue=string;
	return ruleItem;
}

+ (THRuleItem*)ruleViewController:(NSViewController<THRuleItem_ViewControllerProtocol>*)viewController representedObject:(id)representedObject
{
	THRuleItem *ruleItem=[[THRuleItem alloc] initWithKind:THRuleItemKind_viewController wSize:0.0];
	ruleItem.viewController=viewController;
	ruleItem.representedObject=representedObject;
	return ruleItem;
}

- (id)initWithKind:(NSInteger)kind wSize:(CGFloat)wSize
{
	if (self=[super init])
	{
		self.kind=kind;
		self.wSize=wSize;
	}
	return self;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<%@ %p kind:%d>",[self className],self,(int)self.kind];
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeInteger:self.kind forKey:@"kind"];
	[coder encodeInteger:(NSInteger)self.wSize forKey:@"wSize"];

	[coder encodeBool:self.isInvisible forKey:@"isInvisible"];

	// menu
	[coder encodeInteger:self.menuSelectedTag forKey:@"menuSelectedTag"];
	[coder encodeObject:self.menuSelectedObject forKey:@"menuSelectedObject"];
	[coder encodeObject:self.labelTitle forKey:@"labelTitle"];
	[coder encodeObject:self.stringValue forKey:@"stringValue"];
	[coder encodeObject:self.dateValue forKey:@"dateValue"];
	[coder encodeObject:self.dateWithin forKey:@"dateWithin"];
	[coder encodeObject:self.fileSizeValue forKey:@"fileSizeValue"];
	// comboStrings
	[coder encodeObject:self.representedObject forKey:@"representedObject"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if ((self=[super init])!=nil)
	{
		self.kind=[decoder decodeIntegerForKey:@"kind"];
		self.wSize=(CGFloat)[decoder decodeIntegerForKey:@"wSize"];

		self.isInvisible=[decoder decodeBoolForKey:@"isInvisible"];

		// menu
		self.menuSelectedTag=[decoder decodeIntegerForKey:@"menuSelectedTag"];
		self.menuSelectedObject=[decoder decodeObjectForKey:@"menuSelectedObject"];
		self.labelTitle=[decoder decodeObjectForKey:@"labelTitle"];
		self.stringValue=[decoder decodeObjectForKey:@"stringValue"];
		self.dateValue=[decoder decodeObjectForKey:@"dateValue"];
		self.dateWithin=[decoder decodeObjectForKey:@"dateWithin"];
		self.fileSizeValue=[decoder decodeObjectForKey:@"fileSizeValue"];
		// comboStrings
		self.representedObject=[decoder decodeObjectForKey:@"representedObject"];
	}
	return self;
}

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
