// THLogger.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THLogger: NSObject {

	@objc static let shared = THLogger()

	private var dirPath: String?
	private var lock = NSLock()
	private var dateFormatter = DateFormatter(withDateFormat: "yyyy-MM-dd HH:mm:ss.SSS")
	private var fileHandler: FileHandle?

	private var nbLogs = 0

	override init() {
		super.init()
 
#if os(macOS)
#if DEBUG
		let old_dir = FileManager.th_appSupportPath("THLog")
		if FileManager.default.fileExists(atPath: old_dir) == true {
			if FileManager.default.th_removeItem(atPath: old_dir) == false {
				fatalError("th_removeItem == false")
			}
		}
#endif
#endif
	}
	
	private func prepate() {
		let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
		var logDir = paths.first!.th_appendingPathComponent("Logs")

#if os(macOS)
		if THRunningApp.isSandboxedApp() == false {
			let bundleId = Bundle.main.bundleIdentifier!
			logDir = logDir.th_appendingPathComponent(bundleId)
		}
#elseif os(iOS)
		//	dir = paths.first
#endif

		logDir = logDir.th_appendingPathComponent("THLog")
		dirPath = logDir

		THFatalError(FileManager.th_checkHasCreatedDirectory(atPath: logDir) == false, "th_checkHasCreatedDirectory == false logdir:\(logDir)")

		guard let fileHandler = createFile(dirPath: logDir)
		else {
			THLogError("THLogger - init -_file == nil")
			exit(0);
		}

		self.fileHandler = fileHandler
	}

	private func createFile(dirPath: String) -> FileHandle? {

		guard let dirContents = try? FileManager.default.contentsOfDirectory(atPath: dirPath)
		else {
			THLogError("dirContents == nil dirPath:\(dirPath)")
			return nil
		}

		for filename in dirContents {
			if filename.hasSuffix(".log") == false {
				continue
			}

			let path = dirPath.th_appendingPathComponent(filename)
			guard let modDate = FileManager.th_modDate1970(atPath: path)
			else {
				THLogError("deleting old log file at path:\(path)")
				continue
			}
		
			if modDate.timeIntervalSinceNow > (-30.0.th_day) {
				continue
			}

			THLogInfo("deleting old log file at path:\(path)")

			if FileManager.default.th_removeItem(atPath: path) == false {
				THLogError("removeItemAtPath == false path:\(path)")
			}
		}

		let m_pid = ProcessInfo.processInfo.processIdentifier
		let appName = Bundle.main.executablePath!.th_lastPathComponent()
		var logPath: String?

		while logPath == nil {
			let date = DateFormatter(withDateFormat: "yyyy-MM-dd HH-mm-ss").string(from: Date())
			let filename = appName + " " + date + ".log"

			let path = dirPath.th_appendingPathComponent(filename)
			if FileManager.default.fileExists(atPath: path) == true {
				THLogError("another file exists at path:\(path)")
				Thread.sleep(forTimeInterval: 1.0)
				continue
			}

			logPath = path
		}

		if FileManager.default.createFile(atPath: logPath!, contents: nil, attributes: nil) == false {
			THLogError("can not create new log file, logPath:\(logPath)")
			return nil
		}

		guard let fh = FileHandle(forWritingAtPath: logPath!)
		else {
			THLogError("can not fileHandler, logPath:\(logPath)")
			return nil
		}

		THLogInfo("created log file at path:\(logPath)")

		var content = [String]()
		content.append("Date: " + DateFormatter(withDateStyle: .medium, timeStyle: .medium).string(from: Date()))
		content.append("Bundle-Id: " + Bundle.main.bundleIdentifier!)
		content.append("Process-pid: " + String(m_pid))
//		content.append("Build Date-Time: " + DateFormatter.th_string_YMD_HMS(fromDate: TH_AppDateCompiled()!)!)
		content.append("")
		content.append("Session-Locale: " + NSLocale.current.identifier)
		content.append("\n")

		fh.write(content.joined(separator: "\n").data(using: .utf8)!)

		return fh
	}

	@objc func write(_ log: String, for date: Date) {
		if dirPath == nil {
			prepate()
		}

		guard let fh = fileHandler
		else {
			return
		}

		lock.lock()

		if nbLogs >= 100*1000 {
			fh.write("\nCLOSED".data(using: .utf8)!)

			if #available(macOS 10.15, *) {
				try! fh.close()
			} else {
				fh.closeFile()
			}
			self.fileHandler = nil

			self.fileHandler = createFile(dirPath: dirPath!)!
			nbLogs = 0
		}

		nbLogs += 1
		self.fileHandler!.write((dateFormatter.string(from: date) + " " + log + "\n").data(using: .utf8)!)

		lock.unlock()
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
