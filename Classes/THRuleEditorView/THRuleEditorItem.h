// THRuleEditorItem.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
enum // SERIALIZED
{
	THRuleItemKind_popMenu=1,
	THRuleItemKind_label=2,
	THRuleItemKind_textField=3,
	THRuleItemKind_datePicker=4,
	THRuleItemKind_fileSize=5,
	THRuleItemKind_combox=6,
	THRuleItemKind_dateWithin=7,
	THRuleItemKind_viewController=8
};

@protocol THRuleItem_ViewControllerProtocol <NSObject>
- (void)rulesEditorViewWillDisplayView;
@end

@interface THRuleItem : NSObject <NSCoding>

@property (nonatomic) NSInteger kind; // change interne lors de l'init uniquement
@property (nonatomic) CGFloat wSize; // change interne lors de l'init uniquement
@property (nonatomic) BOOL isInvisible;

@property (nonatomic,strong) NSMenu *menu;
@property (nonatomic) NSInteger menuSelectedTag;
@property (nonatomic,strong) id menuSelectedObject;
@property (nonatomic,strong) NSString *labelTitle;
@property (nonatomic,strong) NSString *stringValue;
@property (nonatomic,strong) NSDate *dateValue;
@property (nonatomic,strong) NSString *dateWithin;
@property (nonatomic) NSString *fileSizeValue;
@property (nonatomic,strong) NSArray *comboStrings;
@property (nonatomic,strong) NSViewController<THRuleItem_ViewControllerProtocol>*viewController;
@property (nonatomic,strong) id representedObject;

+ (THRuleItem*)rulePopMenuWithMenu:(NSMenu*)menu wSize:(CGFloat)wSize selectedTag:(NSInteger)selectedTag;
+ (THRuleItem*)rulePopMenuWithMenu:(NSMenu*)menu wSize:(CGFloat)wSize selectedObjet:(id)selectedObjet;
+ (THRuleItem*)ruleLabelWithText:(NSString*)text;
+ (THRuleItem*)ruleTextFieldWithString:(NSString*)string;
+ (THRuleItem*)ruleDatePickerWithDate:(NSDate*)date isInvisible:(BOOL)isInvisible;
+ (THRuleItem*)ruleDateWithinWithValue:(NSString*)value;
+ (THRuleItem*)ruleFileSizeWithValue:(NSString*)value;
+ (THRuleItem*)ruleComboxWithStrings:(NSArray*)strings string:(NSString*)string;
+ (THRuleItem*)ruleViewController:(NSViewController<THRuleItem_ViewControllerProtocol>*)viewController representedObject:(id)representedObject;

@end
//--------------------------------------------------------------------------------------------------------------------------------------------
