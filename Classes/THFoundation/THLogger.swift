// THLogger.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
class THLoggerConfig: NSObject {
	var dirPath: String?
	var retentionDays: TimeInterval = 30 * 24 * 3600
	var appName = ProcessInfo.processInfo.processName
	var rotationLogCount: Int = 100 * 1000
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THLogger: NSObject {

	@objc static let shared = THLogger()
	
	var config = THLoggerConfig()

	private var dirPath: String?
	private var lock = NSLock()
	private var dateFormatter = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss.SSS")
	private var fileHandler: FileHandle?
	private var nbLogs = 0

	private func prepateDirectory() {
		var dirPath = config.dirPath
		
		if dirPath == nil {
			let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
			var logDir = paths.first!.th_appendingPathComponent("Logs")

#if os(macOS)
			if THRunningApp.isSandboxedApp() == false {
				let bundleId = Bundle.main.bundleIdentifier!
				logDir = logDir.th_appendingPathComponent(bundleId)
			}
#elseif os(iOS)
//			dir = paths.first
#endif
			dirPath = logDir.th_appendingPathComponent("THLog")
		}

		guard let dirPath = dirPath
		else {
			return
		}
	
		if FileManager.th_checkCreatedDirectory(atPath: dirPath) == false {
			THLogError("th_checkCreatedDirectory == false dirPath:\(dirPath)")
			return
		}

		self.dirPath = dirPath
		purgeDirectory()

		guard let fileHandler = createFileHandler()
		else {
			THLogError("THLogger - init -fileHandler == nil")
			return
		}

		self.fileHandler = fileHandler
	}

	private func purgeDirectory() {
		guard let dirPath = dirPath
		else {
			return
		}

		guard let dirContents = try? FileManager.default.contentsOfDirectory(atPath: dirPath)
		else {
			THLogError("dirContents == nil dirPath:\(dirPath)")
			return
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
		
			if config.retentionDays > 0.0 && modDate.timeIntervalSinceNow > -config.retentionDays {
				continue
			}

			THLogInfo("deleting old log file at path:\(path)")

			if FileManager.default.th_removeItem(atPath: path) == false {
				THLogError("removeItemAtPath == false path:\(path)")
			}
		}
	}

	private func createFileHandler() -> FileHandle? {
		guard let dirPath = dirPath
		else {
			return nil
		}

		let m_pid = ProcessInfo.processInfo.processIdentifier
		let appName = config.appName
		var logPath: String? = nil

		while logPath == nil {
			let date = DateFormatter(dateFormat: "yyyy-MM-dd HH-mm-ss").string(from: Date())
			let filename = "\(appName) \(m_pid) \(date).log"
			let path = (dirPath as NSString).appendingPathComponent(filename)
	
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
		content.append("Date: " + DateFormatter(dateStyle: .medium, timeStyle: .medium).string(from: Date()))
		content.append("Process-pid: " + String(m_pid))
		content.append("Bundle-Id: " + Bundle.main.bundleIdentifier!)
		content.append("Session-Locale: " + NSLocale.current.identifier)
		content.append("App-Version: " + THRunningApp.appVersion)
		content.append("App-Build: " + THRunningApp.appBuild)
//		content.append("Build Date-Time: " + DateFormatter.th_string_YMD_HMS(fromDate: TH_AppDateCompiled()!)!)
		content.append("\n")

		fh.write(content.joined(separator: "\n").data(using: .utf8)!)

		return fh
	}

	@objc func write(_ log: String, for date: Date) {
		if dirPath == nil {
			prepateDirectory()
		}

		guard let fh = fileHandler
		else {
			return
		}

		lock.lock()

		nbLogs += 1
		fh.write((dateFormatter.string(from: date) + " " + log + "\n").data(using: .utf8)!)

		if nbLogs >= config.rotationLogCount {
			fh.write("\nCLOSED".data(using: .utf8)!)

#if os(macOS)
			if #available(macOS 10.15, *) {
				try! fh.close()
			} else {
				fh.closeFile()
			}
#elseif os(iOS)
			try! fh.close()
#endif

			fileHandler = nil
			nbLogs = 0

			purgeDirectory()
			fileHandler = createFileHandler()
		}

		lock.unlock()
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
