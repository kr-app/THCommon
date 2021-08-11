// THValueAndUnitView.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate class THValueAndUnitView_PopUpButton : NSPopUpButton {
	override var canBecomeKeyView: Bool { get { true } }
}

fileprivate class THValueAndUnitView_Stepper : NSStepper {
	override var canBecomeKeyView: Bool { get { true } }
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@objc protocol THValueAndUnitViewDelegateProtocol {
	@objc func valueAndUnitViewDidChange(_ sender: THValueAndUnitView)
}

@objc class THValueAndUnitView : NSView, NSTextFieldDelegate {
	private var textField: NSTextField!
	private var stepper: NSStepper!
	private var popUpButton: NSPopUpButton!

	weak var controlView: THValueAndUnitViewDelegateProtocol!
	
	@objc init(frame: NSRect, popBezelStyle: NSButton.BezelStyle, controlSize: NSControl.ControlSize, controlView: THValueAndUnitViewDelegateProtocol) {
		super.init(frame: frame)

		self.controlView = controlView

		// faire height en control controlSize != small

		let fieldRect = NSRect(0.0, CGFloatFloor((frame.size.height - 19.0) / 2.0), 50.0, 19.0)
		let stepperRect = NSRect(fieldRect.size.width + 4.0 ,CGFloatFloor((frame.size.height - 22.0) / 2.0), 16.0, 22.0)
		var menuRect = NSRect(stepperRect.origin.x + stepperRect.size.width + 4.0, CGFloatFloor((frame.size.height - 22.0) / 2.0), 60.0, 22.0)

		if self is THDateWithinStepperView {
			menuRect.size.width = 90.0
		}

		let font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: controlSize))

		if true {
			textField = NSTextField(frame: fieldRect)

			textField.font = font
			//	result.target=self
			//	result.action=@selector(criterionTextFieldAction:)
			textField.delegate = self
			textField.isEditable = true
			textField.isSelectable = true
			textField.drawsBackground = true

			let nbFormatter = NumberFormatter()
			nbFormatter.numberStyle = .decimal
			nbFormatter.usesGroupingSeparator = false
			textField.formatter = nbFormatter

			let cell = textField.cell as! NSTextFieldCell
			cell.controlSize = controlSize
			cell.alignment = .right

			addSubview(textField)
		}

		if true {
			let stepInfos = self.valueStepperInfos()!

			stepper = THValueAndUnitView_Stepper(frame: stepperRect)
			stepper.target = self
			stepper.action = #selector(fileSizeStepperAction)
			stepper.minValue = 1.0
			stepper.integerValue = 1
			stepper.maxValue = Double(stepInfos["maxValue"] as! Int)
			
			let cell = stepper.cell as! NSStepperCell
			cell.controlSize = controlSize

			addSubview(stepper)
		}

		if true {
			let  menu  = self.unitMenu()!

			popUpButton = THValueAndUnitView_PopUpButton(frame: menuRect)
			popUpButton.alignment = .left
			popUpButton.bezelStyle = popBezelStyle
			popUpButton.target = self
			popUpButton.action = #selector(fileSizePoidsMenuAction)
			popUpButton.menu = menu
			popUpButton.autoresizingMask = [.maxXMargin]

			let cell = popUpButton.cell as! NSPopUpButtonCell
			cell.controlSize = controlSize
			cell.font = font

			addSubview(popUpButton)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		controlView = nil
	}

	// MARK: -

	func valueStepperInfos() -> [String: Any]? {
		return nil
	}

	func unitMenu() -> NSMenu? {
		return nil
	}

	// MARK: -

	@objc func value() -> Int {
		return textField.integerValue
	}

	@objc func poids() -> Int {
		return popUpButton.selectedTag()
	}

	@objc func setValue(_ value: Int, poids: Int) {
		textField.integerValue = value
		stepper.integerValue = value
		popUpButton.selectItem(withTag: poids)
	}

	@objc func valueComps() -> String {
		return String(self.value()) + "|" + String(self.poids())
	}

	@objc func setValueComps(_ comps: String) {
		let c = comps.components(separatedBy: "|")
		if c.count == 2 {
			setValue(Int(c.first!)!, poids: Int(c.last!)!)
			return
		}
		setValue(1, poids: 1)
	}
	
	@objc func controlTextDidChange(_ notification: Notification) {
		let sender = notification.object as? NSTextField

		if sender == textField {
			if textField.integerValue >= Int(stepper.minValue) {
				stepper.integerValue = textField.integerValue
				controlView.valueAndUnitViewDidChange(self)
			}
		}
	}

	@objc func fileSizeStepperAction(_ sender: NSStepper) {
		textField.integerValue = sender.integerValue
		controlView.valueAndUnitViewDidChange(self)
	}

	@objc func fileSizePoidsMenuAction(_ sender: NSPopUpButton) {
		controlView.valueAndUnitViewDidChange(self)
	}

	@objc func setEnabled(_ enabled: Bool) {
		textField.isEnabled = enabled
		stepper.isEnabled = enabled
		popUpButton.isEnabled = enabled
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THFileSizeStepperView : THValueAndUnitView {
	
	override func  valueStepperInfos() -> [String: Any] {
		return ["maxValue": 1000 * 1000]
	}

	override func unitMenu() -> NSMenu {
		let menu = NSMenu()
		menu.addItem(NSMenuItem(withTitle: THLocalizedString("FileSizePoids_KB"), tag: 1))
		menu.addItem(NSMenuItem(withTitle: THLocalizedString("FileSizePoids_MB"), tag: 2))
		menu.addItem(NSMenuItem(withTitle: THLocalizedString("FileSizePoids_GB"), tag: 3))
		menu.addItem(NSMenuItem(withTitle: THLocalizedString("FileSizePoids_TB"), tag: 4))
		return menu
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THDateWithinStepperView : THValueAndUnitView {

	override func  valueStepperInfos() -> [String: Any] {
		return ["maxValue": 1000]
	}

	override func unitMenu() -> NSMenu {
		let menu = NSMenu()
		menu.addItem(NSMenuItem(withTitle: THLocalizedString("Minute(s)"), tag: THFileSearchUnit_min))
		menu.addItem(NSMenuItem(withTitle: THLocalizedString("Hour(s)"), tag: THFileSearchUnit_hour))
		menu.addItem(NSMenuItem.separator())
		menu.addItem(NSMenuItem(withTitle: THLocalizedString("Day(s)"), tag: THFileSearchUnit_day))
		menu.addItem(NSMenuItem(withTitle: THLocalizedString("Yeek(s)"), tag: THFileSearchUnit_week))
		menu.addItem(NSMenuItem(withTitle: THLocalizedString("Month(s)"), tag: THFileSearchUnit_month))
		menu.addItem(NSMenuItem(withTitle: THLocalizedString("Year(s)"), tag: THFileSearchUnit_year))
		return menu
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
