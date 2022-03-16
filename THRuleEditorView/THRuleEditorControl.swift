// THRuleEditorControl.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate class THRuleEditorRow_PopUpButton : NSPopUpButton {
	override var canBecomeKeyView: Bool { get { true } }
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THRuleEditorControl: NSObject {

	let controlFont = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small))

	@objc func popUpButton(withFrame frame: NSRect, ruleItem: THRuleItem, controlView: NSView) -> NSPopUpButton {
		/*
		 NSTexturedRoundedBezelStyle		19
		 NSRoundRectBezelStyle 				17
		 */
		
		var frame = frame
		frame.origin.y += CGFloatFloor((frame.size.height - 19.0) / 2.0)
		frame.size.height = 19.0 // ou 17
		
		let result = THRuleEditorRow_PopUpButton(frame: frame)
		result.alignment = .left
		//result.bezelStyle=NSRoundedBezelStyle;
		result.bezelStyle = .rounded
		result.target = controlView
		result.action = Selector("criterionPopMenuAction:")
		result.menu = ruleItem.menu
		result.autoresizingMask = [.maxXMargin]
		result.focusRingType = .exterior
		//	if (isBordered!=nil)
		//		[result setBordered:YES];
		//	[result setImagePosition:imagePosition==nil?NSNoImage:[imagePosition intValue]];
		
		let cell = result.cell as! NSPopUpButtonCell
		cell.controlSize = .small
		cell.font = controlFont
		cell.lineBreakMode = .byTruncatingMiddle
		//	[(NSPopUpButtonCell*)[result cell] setArrowPosition:[arrowPosition integerValue]];
		
		if ruleItem.menuSelectedTag != 0 {
			result.selectItem(withTag: ruleItem.menuSelectedTag)
		}
		else {
			for item in ruleItem.menu!.items {
				if item.isSeparatorItem == true {
					continue
				}

				let itemRo = item.representedObject as? NSObject
				let ruleRo = ruleItem.menuSelectedObject as? NSObject

				if (itemRo == nil && ruleRo == nil) || (itemRo != nil && ruleRo != nil && itemRo! == ruleRo!) {
					result.select(item)
					break
				}
			}
		}

		return result
	}

	@objc func label(withFrame frame: NSRect, ruleItem: THRuleItem, controlView: NSView) -> NSTextField {
		var frame = frame
		
		frame.origin.y += CGFloatFloor((frame.size.height - 14.0) / 2.0)
		frame.size.height = 14.0

		let result = NSTextField(frame: frame)

		result.font = controlFont
		result.isBordered = false
		result.isEditable = false
		result.isSelectable = false
		result.drawsBackground = false
		result.objectValue = ruleItem.stringValue

		let cell = result.cell as! NSTextFieldCell
		cell.controlSize = .small
		cell.alignment = .left

		return result
	}

	@objc func textField(withFrame frame: NSRect, ruleItem: THRuleItem, controlView: NSTextFieldDelegate) -> NSTextField {
		var frame = frame

		frame.origin.y += CGFloatFloor((frame.size.height - 19.0) / 2.0)
		frame.size.height = 19.0
		
		let result = NSTextField(frame: frame)

		result.font = controlFont
		//	result.target=controlView;
		//	result.action=@selector(criterionTextFieldAction:);
		result.delegate = controlView
		result.isEditable = true
		result.isSelectable = true
		result.drawsBackground = true
		result.focusRingType = .exterior
		result.objectValue = ruleItem.stringValue

		let cell = result.cell as! NSTextFieldCell
		cell.controlSize = .small
		cell.alignment = .left

		return result;
	}

	@objc func datePicker(withFrame frame: NSRect,  ruleItem: THRuleItem, controlView: NSView) -> NSDatePicker {
		var frame = frame

		let date = ruleItem.dateValue ?? Calendar.current.th_midnight(of: Date())

		frame.origin.y += CGFloatFloor((frame.size.height - 22.0) / 2.0) + 1.0
		frame.size.width = 88.0
		frame.size.height = 22.0

		let min = Calendar.current.date(from: DateComponents(withYear: 1970, month: 1, day: 1))
		let max = Calendar.current.date(from: DateComponents(withYear: 2050, month: 1, day: 1))

		let result = NSDatePicker(frame: frame)
		result.datePickerStyle = .textFieldAndStepper
		result.font = controlFont
		result.datePickerElements = [.yearMonth, .yearMonthDay, .era]
		result.target = controlView
		result.action = Selector("criterionDatePickerAction:")
		result.minDate = min
		result.maxDate = max
		result.focusRingType = .default
		result.drawsBackground = true
		result.isBordered = true
		result.isBezeled = true
	
		//	[result setDelegate:self];
		//	[result.cell setDelegate:self];
		result.dateValue = date

		let cell = result.cell as! NSDatePickerCell
		cell.controlSize = .small
		//	[result.cell setEditable:YES];
		
		return result
	}

	@objc func dateWithinStepperView(withFrame frame: NSRect, ruleItem: THRuleItem, controlView: THValueAndUnitViewDelegateProtocol) -> THDateWithinStepperView {
		let result = THDateWithinStepperView(frame: frame, popBezelStyle: .texturedRounded, controlSize: .small, controlView: controlView)
		result.setValueComps(ruleItem.dateWithin!)
		return result
	}

	@objc func fileSizeView(withFrame frame: NSRect, ruleItem: THRuleItem, controlView: THValueAndUnitViewDelegateProtocol) -> THFileSizeStepperView {
		let result = THFileSizeStepperView(frame: frame, popBezelStyle: .texturedRounded,  controlSize: .small, controlView: controlView)
		result.setValueComps(ruleItem.fileSizeValue!)
		return result
	}

	@objc func combox(withFrame frame: NSRect, ruleItem: THRuleItem, controlView: NSComboBoxDelegate) -> NSComboBox {
		var frame = frame

		frame.origin.y += CGFloatFloor((frame.size.height - 22.0) / 2.0)
		frame.size.height = 22.0
		
		let result = NSComboBox(frame: frame)
		result.font = controlFont
		result.target = controlView
		result.action = Selector("criterionComboBoxAction:")
		result.delegate = controlView
		result.isEditable = true
		//result. setSelectable:YES];
		result.drawsBackground = true
		result.focusRingType = .exterior
		result.stringValue = ruleItem.stringValue ?? ""
		result.addItems(withObjectValues: ruleItem.comboStrings!)
		//result.numberOfItems=10;

		let cell = result.cell as! NSComboBoxCell
		cell.controlSize = .small

		//	[result.cell setAlignment:NSLeftTextAlignment];
		
		return result
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
