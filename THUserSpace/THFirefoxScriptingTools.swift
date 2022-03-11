// THFirefoxScriptingTools.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
class THFirefoxScriptingTools {

	static func createWindowIfNecessary() -> Bool {
		
		var script = THAsScriptManager.shared.script(named: "CreateWindowIfNecessary")
		
		if script == nil {
			let s = 	"tell application \"Firefox\"\n"
							+ "try\n"
								+ "set w to front window\n"
								+ "if w is visible and w is not miniaturized then\n"
									+ "return \"has window\"\n"
								+ "end if\n"
							+ "end try\n"
							+ "open \"about:\"\n"
							+ "return \"new win\"\n"
						+ "end tell\n"
			script = THAsScriptManager.shared.addScript(withSource: s, forName : "CreateWindowIfNecessary")
		}

		guard let script = script
		else {
			THLogError("script == nil")
			return false
		}

		if script.execute(forRunner: self) == nil {
			THLogError("script.execute() == nil")
			return false
		}

		THLogInfo("scrupt result:\(script.resultAed)")
		return true
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
