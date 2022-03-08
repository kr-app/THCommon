// THRuleEditorItem.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc enum THRuleItemKind: Int { // SERIALIZED
	case none = 0
	case popMenu = 1
	case label = 2
	case textField = 3
	case datePicker = 4
	case fileSize = 5
	case combox = 6
	case dateWithin = 7
	case viewController = 8
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@objc protocol THRuleItem_ViewControllerProtocol: AnyObject {
	@objc func rulesEditorViewWillDisplayView()
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THRuleItem : NSObject {

	@objc private(set) var kind: THRuleItemKind = .none
	@objc private(set) var wSize: CGFloat = 0.0

	@objc var isInvisible = false

	@objc var menu: NSMenu?
	@objc var menuSelectedTag = 0
	@objc var menuSelectedObject: Any?
	@objc var labelTitle: String?
	@objc var stringValue: String?
	@objc var dateValue: Date?
	@objc var dateWithin: String?
	@objc var fileSizeValue: String?
	@objc var comboStrings: [String]?

	@objc var viewController: THRuleItem_ViewControllerProtocol?
	@objc var representedObject: Any?

	@objc class func rulePopMenu(_ menu: NSMenu, wSize: CGFloat, selectedTag: Int) -> THRuleItem {
		let ruleItem = THRuleItem(kind: .popMenu, wSize: wSize)
		ruleItem.menu = menu
		ruleItem.menuSelectedTag = selectedTag
		return ruleItem
	}

	@objc class func rulePopMenu(_ menu: NSMenu, wSize: CGFloat, selectedObjet: Any?) -> THRuleItem {
		let ruleItem = THRuleItem(kind: .popMenu, wSize: wSize)
		ruleItem.menu = menu
		ruleItem.menuSelectedObject = selectedObjet
		return ruleItem
	}

	@objc class func ruleLabel(_ text: String) -> THRuleItem {
		let ruleItem = THRuleItem(kind: .label)
		ruleItem.stringValue = text
		return ruleItem
	}

	@objc class func ruleTextField(_ string: String?) -> THRuleItem {
		let ruleItem = THRuleItem(kind: .textField)
		ruleItem.stringValue = string
		return ruleItem
	}

	@objc class func ruleDatePicker(_ date: Date, isInvisible: Bool) -> THRuleItem {
		let ruleItem = THRuleItem(kind: .datePicker)
		ruleItem.dateValue = date
		ruleItem.isInvisible = isInvisible
		return ruleItem
	}

	@objc class func ruleDateWithin(_ value: String) -> THRuleItem {
		let ruleItem = THRuleItem(kind: .dateWithin)
		ruleItem.dateWithin = value
		return ruleItem
	}

	@objc class func ruleFileSize(_ value: String) -> THRuleItem {
		let ruleItem = THRuleItem(kind: .fileSize)
		ruleItem.fileSizeValue = value
		return ruleItem
	}

	@objc class func ruleCombox(_ strings: [String], string: String?) -> THRuleItem {
		let ruleItem = THRuleItem(kind: .combox)
		ruleItem.comboStrings = strings
		ruleItem.stringValue = string
		return ruleItem
	}

	@objc class func ruleViewController(_ viewController: THRuleItem_ViewControllerProtocol, representedObject: Any) -> THRuleItem {
		let ruleItem = THRuleItem(kind: .viewController)
		ruleItem.viewController = viewController
		ruleItem.representedObject = representedObject
		return ruleItem
	}

	@objc init(kind: THRuleItemKind, wSize: CGFloat = 0.0) {
		super.init()

		self.kind = kind
		self.wSize = wSize
	}

	override var description: String {
		th_description("kind: \(kind)")
	}

//	- (void)encodeWithCoder:(NSCoder*)coder
//	{
//		[coder encodeInteger:self.kind forKey:@"kind"];
//		[coder encodeInteger:(NSInteger)self.wSize forKey:@"wSize"];
//
//		[coder encodeBool:self.isInvisible forKey:@"isInvisible"];
//
//		// menu
//		[coder encodeInteger:self.menuSelectedTag forKey:@"menuSelectedTag"];
//		[coder encodeObject:self.menuSelectedObject forKey:@"menuSelectedObject"];
//		[coder encodeObject:self.labelTitle forKey:@"labelTitle"];
//		[coder encodeObject:self.stringValue forKey:@"stringValue"];
//		[coder encodeObject:self.dateValue forKey:@"dateValue"];
//		[coder encodeObject:self.dateWithin forKey:@"dateWithin"];
//		[coder encodeObject:self.fileSizeValue forKey:@"fileSizeValue"];
//		// comboStrings
//		[coder encodeObject:self.representedObject forKey:@"representedObject"];
//	}
//
//	- (id)initWithCoder:(NSCoder*)decoder
//	{
//		if ((self=[super init])!=nil)
//		{
//			self.kind=[decoder decodeIntegerForKey:@"kind"];
//			self.wSize=(CGFloat)[decoder decodeIntegerForKey:@"wSize"];
//
//			self.isInvisible=[decoder decodeBoolForKey:@"isInvisible"];
//
//			// menu
//			self.menuSelectedTag=[decoder decodeIntegerForKey:@"menuSelectedTag"];
//			self.menuSelectedObject=[decoder decodeObjectForKey:@"menuSelectedObject"];
//			self.labelTitle=[decoder decodeObjectForKey:@"labelTitle"];
//			self.stringValue=[decoder decodeObjectForKey:@"stringValue"];
//			self.dateValue=[decoder decodeObjectForKey:@"dateValue"];
//			self.dateWithin=[decoder decodeObjectForKey:@"dateWithin"];
//			self.fileSizeValue=[decoder decodeObjectForKey:@"fileSizeValue"];
//			// comboStrings
//			self.representedObject=[decoder decodeObjectForKey:@"representedObject"];
//		}
//		return self;
//	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
