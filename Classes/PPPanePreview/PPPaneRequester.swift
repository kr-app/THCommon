// PPPaneRequester.swift

import Cocoa

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@objc class PPPaneRequester: NSObject {
	@objc static let shared = PPPaneRequester()

	@objc static let requestNotificationName = Notification.Name("PPPaneRequester-requestNotification")
	
	@objc static let keyAction = "action"
	@objc static let keyPoint = "point"
	@objc static let keyData = "data"
	@objc static let keyAnimated = "animated"
	@objc static let keyParentPid = "parent_pid"
	
	private let myPid = NSRunningApplication.current.processIdentifier

	@objc func requestShowAtPoint(_ point: NSPoint, withData data: Any) {
		THLogInfo("")

		guard let data: Any = (data as? Data) ?? (data as? NSDictionary) ?? (data as? String)
		else {
			THLogError("inconsistant data")
			return
		}

		DistributedNotificationCenter.default().postNotificationName(Self.requestNotificationName,
																	 object: "PPPaneRequester",
																	 userInfo: [	Self.keyParentPid: myPid,
																						Self.keyAction: "show",
																						Self.keyPoint: NSStringFromPoint(point),
																						Self.keyData: data],
																	 deliverImmediately: true)
	}

	@objc func requestHide(withAnimation animated: Bool) {
		THLogInfo("")
		
		DistributedNotificationCenter.default().postNotificationName(Self.requestNotificationName,
																	 object: "PPPaneRequester",
																	 userInfo: [	Self.keyAction: "hide",
																						Self.keyAnimated: NSNumber(booleanLiteral: animated)],
																	 deliverImmediately: true)
	}

	@objc func requestClose(withAnimation animated: Bool) {
		THLogInfo("")
	
		DistributedNotificationCenter.default().postNotificationName(Self.requestNotificationName,
																	 object: "PPPaneRequester",
																	 userInfo: [	Self.keyAction: "close",
																						Self.keyAnimated: NSNumber(booleanLiteral: animated)],
																	 deliverImmediately: true)
	}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
