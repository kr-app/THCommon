// THLog.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
@objc class THLogConsole: NSObject {
	static private let s_dateFormatter = DateFormatter(dateFormat: "HH:mm:ss.SSS")
	static private let s_homeDir = NSHomeDirectory()

	class func write(_ log: String, at date: Date) {
		
		func trimPersonal(_ log: String) -> String {
#if os(macOS)
			if log.contains(s_homeDir) {
				return log.replacingOccurrences(of: s_homeDir, with: "/Users/XXX")
			}
			return log
#elseif os(iOS)
			return log
#endif
		}

		let r_log = trimPersonal(log)
		print(s_dateFormatter.string(from: date) + " " + r_log)
	}
}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
@objc class THLogFunctions: NSObject {
	@objc class func raiseFatal(msg: String, function: String, file: String, line: Int) {
		THFatalError(msg, function: function, file: file, line: line)
	}
}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
func THFatalError(_ msg: String, function: String = #function, file: String = #file, line: Int = #line) -> Never {
	let date = Date()
	let filename = (file as NSString).lastPathComponent
	
#if DEBUG
	let alert = "💣 \(filename) \(line) \(function)"
#else
	let alert = "💣 [\(filename):\(line)] \(function)"
#endif

	let log = "\(alert) \(msg)"

	THLogConsole.write(log, at: date)
	THLogger.shared.write(log, for: date)

	let csAddresses = Thread.callStackReturnAddresses.map ({ $0.stringValue }).joined(separator: "\n")
	THLogConsole.write("\(alert) callStackReturnAddresses:\n" + csAddresses, at: date)
	THLogger.shared.write("\(alert) callStackReturnAddresses:\n" + csAddresses, for: date)

	let csSymbols = Thread.callStackSymbols.joined(separator: "\n")
	THLogConsole.write("\(alert) callStackSymbols:\n" + csSymbols, at: date)
	THLogger.shared.write("\(alert) callStackSymbols:\n" + csSymbols, for: date)

	THLogConsole.write("\(alert) END / FATAL ERROR", at: date)
	THLogger.shared.write("\(alert) END / FATAL ERROR", for: date)

	//return Never.Body
	
	if Thread.isMainThread {
#if os(macOS)
		let alert = NSAlert(withTitle: "Fatal Error", message: "\(alert)\n\n\(msg)" , buttons: ["Ok"])
		alert.runModal()
#elseif os(iOS)
		let windows = UIApplication.shared.windows
		let keyWin = windows.first( where: { $0.isKeyWindow }) ?? windows.first(where: { $0.rootViewController != nil })

		var mainVc = keyWin?.rootViewController

		if mainVc == nil {
			mainVc = UIViewController()

			let w = UIWindow(frame: UIScreen.main.bounds)
			w.makeKeyAndVisible()
			w.rootViewController = mainVc
		}
	
		mainVc?.th_showAlert("Fatal Error", "\(alert)\n\n\(msg)")
#endif
	}

	return fatalError(msg)
}

func THFatalError(_ conditionToFail: Bool, _ msg: String, function: String = #function, file: String = #file, line: Int = #line) {
	if conditionToFail == false {
		return
	}
	THFatalError(msg, function: function, file: file, line: line)
}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
enum THLogLevel: Int {
	case error = 1
	case warning = 2
	case info = 3
#if DEBUG
	case debug = 4
#endif
}

fileprivate func push_log(_ level: THLogLevel, msg: String, /*sender: String,*/ function: String, file: String, line: Int) {
	let date = Date()
	let filename = (file as NSString).lastPathComponent

	var log: String!
	switch level {
	case .error:
#if DEBUG
		log = "📕 \(filename) \(line) \(function)"
#else
		log = "ERROR [\(filename):\(line)] [\(function)]"
#endif
	case .warning:
#if DEBUG
		log = "📙 \(filename) \(line) \(function)"
#else
		log = "WARNING [\(filename):\(line)] [\(function)]"
#endif
	case .info:
#if DEBUG
		log = "📒 \(filename) \(line) \(function)"
#else
		log = "INFO [\(filename) \(line)] [\(function)]"
#endif
#if DEBUG
	case .debug:
		log = "📘 \(filename) \(line) \(function)"
#endif
	}

	if msg.isEmpty == false {
		log += " \(msg)"
	}

	THLogConsole.write(log, at: date)
	THLogger.shared.write(log, for: date)
}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
func THLogError(_ msg: String, function: String = #function, file: String = #file, line: Int = #line) {
	push_log(.error, msg: msg, function: function, file: file, line: line)
}

func THLogWarning(_ msg: String, function: String = #function, file: String = #file, line: Int = #line) {
	push_log(.warning, msg: msg, function: function, file: file, line: line)
}

func THLogInfo(_ msg: String, function: String = #function, file: String = #file, line: Int = #line) {
	push_log(.info, msg: msg, function: function, file: file, line: line)
}

#if DEBUG
func THLogDebug(_ msg: String, function: String = #function, file: String = #file, line: Int = #line) {
	push_log(.debug, msg: msg, function: function, file: file, line: line)
}
#endif
//-----------------------------------------------------------------------------------------------------------------------------------------
