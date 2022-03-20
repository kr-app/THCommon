// PPPaneRequester.swift

import Cocoa

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
struct PPPaneRequesterKey {
	static let action = "action"
	static let point = "point"
	static let data = "data"
	static let animated = "animated"
	static let parentPid = "parent_pid"
}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@objc class PPPaneRequester: NSObject {
	@objc static let shared = PPPaneRequester()
	@objc static let requestNotificationName = Notification.Name("PPPaneRequester-requestNotification")
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
																	 userInfo: [	PPPaneRequesterKey.parentPid: myPid,
																						PPPaneRequesterKey.action: "show",
																						PPPaneRequesterKey.point: NSStringFromPoint(point),
																						PPPaneRequesterKey.data: data],
																	 deliverImmediately: true)
	}

	@objc func requestHide(withAnimation animated: Bool) {
		THLogInfo("")
		
		DistributedNotificationCenter.default().postNotificationName(Self.requestNotificationName,
																	 object: "PPPaneRequester",
																	 userInfo: [	PPPaneRequesterKey.action: "hide",
																						PPPaneRequesterKey.animated: NSNumber(booleanLiteral: animated)],
																	 deliverImmediately: true)
	}

	@objc func requestClose(withAnimation animated: Bool) {
		THLogInfo("")
	
		DistributedNotificationCenter.default().postNotificationName(Self.requestNotificationName,
																	 object: "PPPaneRequester",
																	 userInfo: [	PPPaneRequesterKey.action: "close",
																						PPPaneRequesterKey.animated: NSNumber(booleanLiteral: animated)],
																	 deliverImmediately: true)
	}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
