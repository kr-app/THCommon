// THAsScript.swift

import Cocoa

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@objc class THAsScript: NSObject {

	static var runningScript: [String: Any]?
	static var cachesDir: String!
	
	@objc var name: String!
	@objc var source: String!

	@objc var resultAed: NSAppleEventDescriptor?
	@objc var resultErrorInfo: NSDictionary?

	@objc class func hasRunningScript() -> Bool {
		return Self.runningScript != nil ? true : false
	}

	@objc init(name: String, source: String) {
		self.name = name
		self.source = source
	}

	override var description: String {
		th_description("name: \(self.name)")
	}

	@objc func execute(forRunner runner: Any) -> NSAppleEventDescriptor? {

		THFatalError(Thread.isMainThread == false, "should be executed on main thread")

		if Self.runningScript != nil {
			THLogError("script execution requested while another script is running, runningScript:\(Self.runningScript)")
			return nil
		}

		resultAed = nil
		resultErrorInfo = nil

		let startTime = CFAbsoluteTimeGetCurrent()

#if DEBUG
		let path = writeSourceToCachesDir()
#endif

//	NSError *error=nil;

/*	NSArray *apps=[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.mail"];
	pid_t pid = [(NSRunningApplication*)apps.lastObject processIdentifier];

	NSAppleEventDescriptor *target=[NSAppleEventDescriptor descriptorWithProcessIdentifier:pid];
//	typeApplicationBundleID
// 	NSAppleEventDescriptor *target=[[NSAppleEventDescriptor alloc] initWithDescriptorType:typeKernelProcessID bytes:&pid length:sizeof(pid)];
//	target=[NSAppleEventDescriptor currentProcessDescriptor];

	// AEBuildAppleEvent(....
	
	NSAppleEventDescriptor *event = [NSAppleEventDescriptor
																				appleEventWithEventClass:kAECoreSuite
																				eventID:kAEDoScript
																				targetDescriptor:target
																				returnID:kAutoGenerateReturnID
																				transactionID:kAnyTransactionID];
	if (event == nil) {
		return nil;
	}
	
	//NSAppleEventDescriptor *scriptParam=[NSAppleEventDescriptor descriptorWithString:self.appleScript.source];
	//NSAppleEventDescriptor *scriptParam=[NSAppleEventDescriptor descriptorWithFileURL:[NSURL fileURLWithPath:path]];
	
//	NSString *path_c=[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"out"];
//	NSTask *task=[NSTask launchedTaskWithLaunchPath:@"/usr/bin/osascript"
//													  arguments:@[@"-d",@"-o",path,path_c]];

	NSAppleEventDescriptor *scriptParam=[NSAppleEventDescriptor descriptorWithFileURL:[NSURL fileURLWithPath:@"ss/Desktop/AM_AccountList.scptd"]];
	
	if(scriptParam == nil) {
		return nil;
	}

	[event setParamDescriptor:scriptParam forKeyword:keyDirectObject];
	
	
	NSAppleEventDescriptor *_aed=[event sendEventWithOptions:NSAppleEventSendDefaultOptions timeout:1000 error:&error];
	NSLog(@"_aed:%@ error:%@",_aed,error);
//	return _aed;

	AppleEvent replyEvent;
	OSStatus err = AESendMessage(	[event aeDesc],
														&replyEvent,
														NSAppleEventSendWaitForReply|NSAppleEventSendNeverInteract,
														kNoTimeOut);
	if(err != noErr) {
		return nil;
	}
	
	NSAppleEventDescriptor *replyDesc=[[NSAppleEventDescriptor alloc] initWithAEDescNoCopy:&replyEvent];

//	NSAppleEventDescriptor *errorDesc = [replyDesc descriptorForKeyword:keyErrorNumber];
*/

		guard let appleScript = NSAppleScript(source: self.source)
		else {
			fatalError("appleScript == nil")
		}

		var runningScript = [String: Any]()
		runningScript["runner"] = runner
		runningScript["name"] = self.name
		Self.runningScript = runningScript

		var errorInfo: NSDictionary?
		//NSAppleEventDescriptor *aed=[(AS*)self.appleScript _executeWithMode:1 andReturnError:&errorInfo];
		let aed = appleScript.executeAndReturnError(&errorInfo)
		Self.runningScript = nil

		let runningTime = CFAbsoluteTimeGetCurrent() - startTime

		if runningTime > 5.0 {
			THLogError("runningTime:\(runningTime.th_string())")
		}
		else {
			THLogInfo("runningTime:\(runningTime.th_string())")
		}

		if aed == nil {
			THLogError("aed == nil errorInfo:\(errorInfo)")
		}

		self.resultAed = aed
		self.resultErrorInfo = errorInfo

#if DEBUG
		if let path = path {
			if writeExecuteFinished(withRunningTime: runningTime, atPath: path) == false {
				THLogError("writeExecuteFinished == false path:\(path)")
			}
		}
#endif

		return aed
	}

	private func writeSourceToCachesDir() -> String? {

		let name = self.name!
		let source = self.source!

		if Self.cachesDir == nil {
			let dirPath = FileManager.th_appCachesDir().th_appendingPathComponent(self.th_className)

			if FileManager.default.fileExists(atPath: dirPath) == true {
				if FileManager.default.th_removeItem(atPath: dirPath) == false {
					THLogError("can not remove previous script caches at path:\(dirPath)")
				}
			}

			if FileManager.default.th_createDirectory(atPath: dirPath, withIntermediateDirectories: true) == false {
				THLogError("can not create scrip cache directory at path:\(dirPath)")
			}

			Self.cachesDir = dirPath
		}

		let dirPath = Self.cachesDir

		let filename = name.th_appendingPathExtension("txt")
		let path = dirPath!.th_appendingPathComponent(filename)

		if source.th_write(toFile: path, atomically: true, encoding: .utf8) == false {
			THLogError("failed to write source at path:\(path)")
			return nil
		}

		return path
	}

	private func writeExecuteFinished(withRunningTime runningTime: TimeInterval, atPath path: String) -> Bool {
		let file = path.th_lastPathComponent().th_deletingPathExtension()
		let path = path.th_deletingLastPathComponent().th_appendingPathComponent(file + "-result.txt")

		let aed = self.resultAed
		let errorInfo = self.resultErrorInfo
		
		var results = [String]()
		results.append("aed:\n\(aed)")
		results.append("runningTime:\n\(runningTime.th_string()) sec")
		results.append("errorInfo:\n\(errorInfo)")

		if results.joined(separator: "\n\n").th_write(toFile: path, atomically: true, encoding: .utf8) == false {
			THLogError("can not write execution result file at path:\(path)")
			return false
		}

		return true
	}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@objc class THAsScriptManager: NSObject {
	@objc static let shared = THAsScriptManager()

	private var scripts = [THAsScript]()

	@objc func removeAllScripts() {
		scripts.removeAll()
	}

	@objc func script(named name: String) -> THAsScript? {
		return scripts.first(where: {$0.name == name })
	}

	@objc func addScript(withSource source: String, forName name: String) -> THAsScript {
		let script = THAsScript(name: name, source:source)
		scripts.append(script)
		return script
	}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
