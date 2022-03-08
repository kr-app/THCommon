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
class PPPaneRequester: NSObject {
	static let shared = PPPaneRequester()

	static let requestNotificationName = Notification.Name("PPPaneRequester-requestNotification")

	private let myPid = NSRunningApplication.current.processIdentifier

	func requestShowAtPoint(_ point: NSPoint, withData data: Any) {
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

	func requestHide(withAnimation animated: Bool) {
		THLogInfo("")
		
		DistributedNotificationCenter.default().postNotificationName(Self.requestNotificationName,
																	 object: "PPPaneRequester",
																	 userInfo: [	PPPaneRequesterKey.action: "hide",
																						PPPaneRequesterKey.animated: NSNumber(booleanLiteral: animated)],
																	 deliverImmediately: true)
	}

	func requestClose(withAnimation animated: Bool) {
		THLogInfo("")
	
		DistributedNotificationCenter.default().postNotificationName(Self.requestNotificationName,
																	 object: "PPPaneRequester",
																	 userInfo: [	PPPaneRequesterKey.action: "close",
																						PPPaneRequesterKey.animated: NSNumber(booleanLiteral: animated)],
																	 deliverImmediately: true)
	}

}
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
