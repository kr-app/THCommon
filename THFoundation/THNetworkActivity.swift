// THNetworkActivity.swift

#if os(iOS)
import UIKit

//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate struct NetworkClient {
	weak var object: AnyObject?
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
class THNetworkActivity {
	static let shared = THNetworkActivity()

	private var clients = [NetworkClient]()
	private var currentStatus: Int = 0

	private func updateStatus() {
		let status = clients.count > 0 ? 1 : -1

		if currentStatus == 0 || currentStatus != status {
			currentStatus = status

			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = status == 1
			}
		}
	}

	func addClient(_ client: AnyObject) {
		clients.removeAll(where: { $0.object == nil })

		if clients.contains(where: { $0.object === client }) == false {
			clients.append(NetworkClient(object: client))
		}

		updateStatus()
	}

	func removeClient(_ client: AnyObject) {
		clients.removeAll(where: { $0.object === client })
		updateStatus()
	}

	class func addClient(_ client: AnyObject) {
		Self.shared.addClient(client)
	}

	class func removeClient(_ client: AnyObject) {
		Self.shared.removeClient(client)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
#endif
