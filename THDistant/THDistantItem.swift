// THDistantObject.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
class THDistantObject: NSObject {

	var lastUpdate: Date?
	var isUpdating: Bool { task != nil }
	var lastError: (date: Date, error: String)?

	private var task: URLSessionTask?

	func updateRequest() -> URLRequest {
		THFatalError("not implemented by subclass")
	}
	
	private func concludeUpdate(withError error: String?) {
		self.task = nil
		self.lastError = error != nil ? (date: Date(), error: error!) : nil
	}

	func update(urlSession: URLSession, completion: @escaping (Bool, String?) -> Void) {
		if task != nil {
			return
		}

		let request = updateRequest()
	
		THLogInfo("request:\(request.url)")

		self.lastUpdate = Date()
#if DEBUG
		let t0 = CFAbsoluteTimeGetCurrent()
#endif

		task = urlSession.dataTask(with: request) {(data: Data?, response: URLResponse?, error: Error?) in
			if self.task == nil {
				THLogInfo("cancelled")
				return
			}

			let te = CFAbsoluteTimeGetCurrent() - t0
			THLogInfo("request:\(request.url), response time: \(Double(te).th_string()) sec")

			guard 	let rep = response as? HTTPURLResponse,
						let data = data
			else {
				THLogError("no data or response for request:\(request.url), error:\(error)")

				self.concludeUpdate(withError: error?.localizedDescription ?? THLocalizedString("no data or no response"))
				completion(false, error?.localizedDescription ?? THLocalizedString("no data or no response"))

				return
			}
			
			if rep.statusCode != 200 {
				let datarep = String(data: data, encoding: .utf8)
				THLogError("response:\(rep.th_displayStatus()) data:\(datarep)")

				self.concludeUpdate(withError: rep.th_displayStatus())
				completion(false, rep.th_displayStatus())

				return
			}

			if let error = self.parse(data: data) {
				THLogError("parse failed error:\(error)")

				self.concludeUpdate(withError: error)
				completion(false, error)

				return
			}
	
			self.concludeUpdate(withError: nil)
			completion(true, nil)
		}

		task!.resume()
	}

	func cancel() {
		task?.cancel()
		task = nil
	}

	func parse(data: Data) -> String? {
		THFatalError("not implemented by subclass")
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
