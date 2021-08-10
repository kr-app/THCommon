// THLog.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
@objc class THLogConsole: NSObject {
	static let s_dateFormatter = DateFormatter(withDateFormat: "HH:mm:ss.SSS")
	static let s_homeDir = NSHomeDirectory()

	class func write(_ log: String, at date: Date) {
		var r_log = log
		if log.contains(s_homeDir) == true {
			r_log = log.replacingOccurrences(of: s_homeDir, with: "/Users/XXX")
		}
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
	
#if os(macOS)
	if Thread.isMainThread == true {
		let alert = NSAlert(withTitle: "Fatal Error", message: "\(alert)\n\n\(msg)" , buttons: ["Ok"])
		alert.runModal()
	}
#elseif os(iOS)
	if Thread.isMainThread == true {
		var firstWin = UIApplication.shared.keyWindow
		if firstWin == nil {
			firstWin = UIApplication.shared.windows.first(where: { $0.rootViewController != nil })
		}

		var mainVc = firstWin?.rootViewController
		if mainVc == nil {
			mainVc = UIViewController()

			let w = UIWindow(frame: UIScreen.main.bounds)
			w.makeKeyAndVisible()
			w.rootViewController = mainVc
		}
	
		mainVc!.th_showAlert("Fatal Error", "\(alert)\n\n\(msg)")
	}
#endif

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
		log = "📕 \(filename) \(line) \(function) \(msg)"
#else
		log = "ERROR [\(filename):\(line)] [\(function)] \(msg)"
#endif
	case .warning:
#if DEBUG
		log = "📙 \(filename) \(line) \(function) \(msg)"
#else
		log = "WARNING [\(filename):\(line)] [\(function)] \(msg)"
#endif
	case .info:
#if DEBUG
		log = "📒 \(filename) \(line) \(function) \(msg)"
#else
		log = "INFO [\(filename) \(line)] [\(function)] \(msg)"
#endif
#if DEBUG
	case .debug:
		log = "📘 \(function) \(msg)"
#endif
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
