// THNetworkActivity.swift

#if os(macOS)
	import Foundation
#elseif os(iOS)
	import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THNetworkActivity: NSObject {
	static let shared = THNetworkActivity()

	private var clientsCount: Int = 0
	private var currentStatus: Int = 0

	private func updateStatus() {
		let status = clientsCount > 0 ? 1 : -1
		if currentStatus == 0 || currentStatus != status {
			currentStatus = status
			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = status == 1
			}
		}
	}

	private func containsClient(_ client: Any) -> Bool {
//		for (NSUInteger i=0;i<THNetworkActivityNbClientsMax;i++)
//			if (_clients[i]==client)
//				return YES;
		return false
	}

	func addClient(_ client: Any) {
//		if ([self hasClient:client]==YES)
//			return;
//
//		NSAssert(_clientsCount+1<THNetworkActivityNbClientsMax,@"_ITHNetworkActivitManagerClientMax");
//
//		for (NSUInteger i=0;i<THNetworkActivityNbClientsMax;i++)
//		{
//			if (_clients[i]==nil)
//			{
//				_clients[i]=client;
				clientsCount += 1
//				break;
//			}
//		}
//
		updateStatus()
	}

	func removeClient(_ client: Any) {
//		for (NSUInteger i=0;i<THNetworkActivityNbClientsMax;i++)
//		{
//			if (_clients[i]==client)
//			{
//				_clients[i]=nil;
				clientsCount -= 1
//			}
//		}
		updateStatus()
	}

	@objc class func addClient(_ client: Any) {
		Self.shared.addClient(client)
	}

	@objc class func removeClient(_ client: Any) {
		Self.shared.removeClient(client)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
