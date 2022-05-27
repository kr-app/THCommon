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
	var rotationLogCount = 50_000
	var fileCompression = false
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate extension FileHandle {

	@discardableResult func log_write(_ data: Data) -> Bool {
#if os(macOS)
		if #available(macOS 10.15.4, *) {
			do {
				try self.write(contentsOf: data)
				return true
			}
			catch {
				print("error while log_write, error:\(error)")
			}
		} else {
			self.write(data)
			return true
		}
#elseif os(iOS)
		do {
			try self.write(contentsOf: data)
			return true
		}
		catch {
			print("error while log_write, error:\(error)")
		}
#endif

		return false
	}

	@discardableResult func log_write(_ string: String) -> Bool {
		if let data = string.data(using: .utf8) {
			return log_write(data)
		}
		return false
	}

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

		func defaultLogDir() -> String {
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

			return logDir.th_appendingPathComponent("THLog")
		}

		let dirPath = config.dirPath ?? defaultLogDir()
		self.dirPath = dirPath

		if FileManager.th_checkCreatedDirectory(atPath: dirPath) == false {
			THLogError("th_checkCreatedDirectory == false dirPath:\(dirPath)")
			return
		}

		runDirectoryMaintenance()

		guard let fileHandler = createFileHandler()
		else {
			THLogError("THLogger - init -fileHandler == nil")
			return
		}

		self.fileHandler = fileHandler
	}

	private func compressLog(_ file: String) -> Bool {
		guard let data = NSData(contentsOfFile: file)
		else {
			THLogError("data == nil file:\(file)")
			return false
		}

		guard let compressed = try? data.compressed(using: .zlib)
		else {
			THLogError("compressed == nil file:\(file)")
			return false
		}

		let path = (file as NSString).appendingPathExtension("zlib")!
		if compressed.th_write(to: path) == false {
			THLogError("th_write == false path:\(path)")
			return false
		}

		if FileManager.default.th_removeItem(atPath: file) == false {
			THLogError("removeItemAtPath == false file:\(file)")
			return false
		}

		return true
	}
	
	private func runDirectoryMaintenance() {
		guard let dirPath = dirPath
		else {
			return
		}

		guard let dirContents = try? FileManager.default.contentsOfDirectory(atPath: dirPath)
		else {
			THLogError("dirContents == nil dirPath:\(dirPath)")
			return
		}

		for filename in dirContents.filter({ $0.hasPrefix(".") == false }) {
			let path = dirPath.th_appendingPathComponent(filename)

			if filename.hasSuffix(".log") || filename.hasSuffix(".zlib") {

				func deleteObsoleteFile(path: String) -> Bool {
					guard let modDate = FileManager.th_modDate1970(atPath: path)
					else {
						THLogError("modDate == nil path:\(path)")
						return false
					}
				
					if config.retentionDays > 0.0 && modDate.timeIntervalSinceNow > -config.retentionDays {
						return false
					}

					THLogInfo("deleting old log file at path:\(path)")

					if FileManager.default.th_removeItem(atPath: path) == false {
						THLogError("removeItemAtPath == false path:\(path)")
					}

					return true
				}
				
				if deleteObsoleteFile(path: path) {
					continue
				}
			}

			if config.fileCompression && filename.hasSuffix(".log") {
				if compressLog(path) == false {
					THLogError("compressLog == false path:\(path)")
				}
			}

		}
	}

	private func createFileHandler() -> FileHandle? {
		guard let dirPath = dirPath
		else {
			return nil
		}

		let m_pid = ProcessInfo.processInfo.processIdentifier
		
		func getLogPath(dirPath: String, m_pid: pid_t) -> String {
			let appName = ProcessInfo.processInfo.processName

			while true {
				let date = DateFormatter(dateFormat: "yyyy-MM-dd HH-mm-ss").string(from: Date())
				let filename = "\(appName) \(date).log"
				let path = (dirPath as NSString).appendingPathComponent(filename)
	
				if FileManager.default.fileExists(atPath: path) == false {
					return path
				}
		
				THLogError("another file exists at path:\(path)")
				Thread.sleep(forTimeInterval: 1.0)
			}
		}
		
		let logPath = getLogPath(dirPath: dirPath, m_pid: m_pid)

		if FileManager.default.createFile(atPath: logPath, contents: nil, attributes: nil) == false {
			THLogError("can not create new log file, logPath:\(logPath)")
			return nil
		}

		guard let fh = FileHandle(forWritingAtPath: logPath)
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

		fh.log_write(content.joined(separator: "\n"))

		return fh
	}

	@objc func write(_ log: String, for date: Date) {

		if dirPath == nil {
			lock.lock()
			if dirPath == nil {
				prepateDirectory()
			}
			lock.unlock()
		}

		guard let fh = fileHandler
		else {
			return
		}

		lock.lock()

		nbLogs += 1
		fh.log_write((dateFormatter.string(from: date) + " " + log + "\n"))

		if nbLogs >= config.rotationLogCount {
			fh.log_write("\nCLOSED")

#if os(macOS)
			if #available(macOS 10.15, *) {
				try? fh.close()
			} else {
				fh.closeFile()
			}
#elseif os(iOS)
			try? fh.close()
#endif

			fileHandler = nil
			nbLogs = 0

			runDirectoryMaintenance()
			fileHandler = createFileHandler()
		}

		lock.unlock()
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
