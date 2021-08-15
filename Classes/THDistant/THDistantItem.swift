// THDistantItem.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
class THDistantItem: NSObject {

	var lastUpdate: Date?
	var isUpdating: Bool { task != nil }
	var lastError: String?

	private var task: URLSessionTask?

	func updateRequest() -> URLRequest {
		fatalError("not implemented by subclass")
	}
	
	func concludeUpdate(withError error: String?) {
		self.task = nil
		self.lastError = error
	}

	func update(withDelegate delegate: Any? = nil, urlSession: URLSession, completion: @escaping (Bool, String?) -> Void) {
		if task != nil {
			return
		}

		let request = updateRequest()
	
		THLogInfo("update requested with url:\(request.url)")

		self.lastUpdate = Date()
		let t0 = CFAbsoluteTimeGetCurrent()

		task = urlSession.dataTask(with: request) {(data: Data?, response: URLResponse?, error: Error?) in
			if self.task == nil {
				THLogInfo("cancelled")
				return
			}

			let te = CFAbsoluteTimeGetCurrent() - t0
			THLogInfo("updated in \(Double(te).th_string()) sec")

			guard 	let rep = response as? HTTPURLResponse,
						let data = data
			else {
				DispatchQueue.main.async {
					THLogError("no data or response for request:\(request.url), error:\(error)")

					self.concludeUpdate(withError: error?.localizedDescription ?? THLocalizedString("no data or no response"))
					completion(false, error?.localizedDescription ?? THLocalizedString("no data or no response"))
				}
				return
			}
			
			if rep.statusCode != 200 {
				DispatchQueue.main.async {
					let datarep = String(data: data, encoding: .utf8)
					THLogError("response:\(rep.th_displayStatus()) data:\(datarep)")

					self.concludeUpdate(withError: rep.th_displayStatus())
					completion(false, rep.th_displayStatus())
				}
				return
			}

			if let error = (delegate != nil ? self.parse(data: data, withDelegate: delegate!) : self.parse(data: data)) {
				DispatchQueue.main.async {
					THLogError("parse failed error:\(error)")

					self.concludeUpdate(withError: error)
					completion(false, error)
				}
				return
			}
	
			DispatchQueue.main.async {
				self.concludeUpdate(withError: nil)
				completion(true, nil)
			}
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

	func parse(data: Data, withDelegate delegate: Any) -> String? {
		THFatalError("not implemented by subclass")
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------

