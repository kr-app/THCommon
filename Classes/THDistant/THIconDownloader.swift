// THIconDownloader.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate class Icon : NSObject {

	var repObject: AnyHashable!
	var content: TH_NSUI_Image?
	var task: URLSessionTask?
	var error: String?

	init(repObject: AnyHashable) {
		self.repObject = repObject
	}

	override var description: String {
		th_description("repObject:\(repObject) content.size:\(content?.size)")
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
class IconDownloader: NSObject {
	var identifier: String!

	// configuration
	var validity: TimeInterval = 7.0.th_day
	var storeProcessed = false
	var maxSize: CGFloat = 0.0
	var cropIcon = false
	var roundedIcon = false
	var cornerRadius: CGFloat = 0.0
	var excludedHosts: [String]?
	var inMemory = 0

	private var icons = [Icon]()
	private var cacheDir: String?
	private let urlSession = URLSession(configuration: URLSessionConfiguration.th_ephemeral())

	init(identifier: String, cacheDir: String?) {

		super.init()

		if let cacheDir = cacheDir {
			if FileManager.th_checkCreatedDirectory(atPath: cacheDir) == false {
				fatalError("th_checkCreatedDirectory == false cacheDir:\(cacheDir)")
			}
		}

		self.identifier = identifier
		self.cacheDir = cacheDir

		let cookies = urlSession.configuration.httpCookieStorage
		THLogInfo("cookies:\(cookies?.cookies)")
	}
	
	override var description: String {
		th_description("identifier:\(identifier)")
	}

	func setDiskRetention(_ retention: TimeInterval) {

		THFatalError(retention < 0.0, "retention:\(retention)")

		guard let cacheDir = cacheDir
		else {
			THFatalError("cacheDir == nil")
		}

		guard let files = FileManager.default.enumerator(atPath: cacheDir)
		else {
			THFatalError("files == nil cacheDir:\(cacheDir)")
		}

		let now = Date().timeIntervalSince1970

		while let file = files.nextObject() as? String {

			if file.hasPrefix(".") == true {
				continue
			}

			let path = cacheDir.th_appendingPathComponent(file)

			var isDir = ObjCBool(true)
			if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) == false || isDir.boolValue == true {
				THLogError("fileExists == false || isDir == true path:\(path)")
				continue
			}
	
			if retention > 0.0 {
				guard let creationDate = FileManager.th_modDate1970(atPath: path)
				else {
					THLogError("creationDate == nil path:\(path)")
					continue;
				}

				if (now - creationDate.timeIntervalSince1970) < retention {
					continue
				}
			}

			if FileManager.default.th_removeItem(atPath: path) == false {
				THLogError("th_removeItem == false path:\(path)")
			}
		}
	}

	// MARK: -
	
	fileprivate func proposedFilename(forRepObject repObject: AnyHashable) -> String? {
		fatalError("subclass implementation")
	}

	fileprivate func startConnection(ofIcon icon: Icon) {
		fatalError("subclass implementation")
	}

	fileprivate func processReceivedIcon(icon: TH_NSUI_Image) -> TH_NSUI_Image {
		var img = icon

#if os(macOS)
		if maxSize > 0.0 {
			img = img.th_resizedImage(withMaxSize: maxSize, crop: cropIcon)
		}
		if roundedIcon == true {
			img = img.th_imageOval()
		}
		else if cornerRadius > 0.0 {
			img = img.th_image(withCorner: cornerRadius)
		}
#endif

		return img
	}

	private func data(fromImage img: TH_NSUI_Image) -> Data? {
	#if os(macOS)
			return img.th_PNGRepresentation()
	#elseif os(iOS)
			return img.pngData()
	#endif
	}

	fileprivate func didFinishUpdate(ofIcon icon: Icon) {
		fatalError("subclass implementation")
	}

	// MARK: -
	
	fileprivate func hasData(forRepObject repObject: AnyHashable) -> Bool {
		let icon = icons.first(where: { $0.repObject == repObject })
		if icon != nil && icon!.content != nil {
			return true
		}

		guard let file = proposedFilename(forRepObject: repObject)
		else {
			return false
		}

		let path = cacheDir!.th_appendingPathComponent(file)
		return FileManager.default.fileExists(atPath: path)
	}

	fileprivate func error(forRepObject repObject: AnyHashable) -> String? {
		if let icon = icons.first(where:  { $0.repObject == repObject }) {
			return icon.error
		}
		return nil
	}
	
	private func addIcon(with repObject: AnyHashable) -> Icon? {
		if repObject is URL || repObject is String {
			let icon = Icon(repObject: repObject)
			icons.append(icon)
			if inMemory > 0 && icons.count > inMemory {
				icons.remove(at: 0)
			}
			return icon
		}
		return nil
	}
	
	fileprivate func icon(withRepObject repObject: AnyHashable, startUpdate: Bool) -> Icon? {

		var icon = icons.first(where:  { $0.repObject == repObject })
		if icon == nil {
			icon = addIcon(with: repObject)
		}
		
		guard let icon = icon
		else {
			return nil
		}

		var needsUpdate = false

		if icon.content == nil && cacheDir != nil {
			if let file = proposedFilename(forRepObject: repObject) {
				let path = cacheDir!.th_appendingPathComponent(file)

				if FileManager.default.fileExists(atPath: path) == true {

					let data = try? (NSData(contentsOfFile: path) as Data)
					let img = data == nil ? nil : TH_NSUI_Image(data: data!)

					if img == nil {
						THLogError("can not create image from data at path:\(path)")
						if FileManager.default.th_removeItem(atPath: path) == false {
							THLogError("can not remove invalid image file at path:\(path)")
						}
						else {
							needsUpdate = true
						}
					}
					else {
						icon.content = processReceivedIcon(icon: img!)

						if validity > 0.0 {
							let modDate = FileManager.th_modDate1970(atPath: path)
							if modDate == nil {
								THLogError("modDate == nil path:\(path)")
							}
							else {
								if modDate!.timeIntervalSinceNow < -validity {
									needsUpdate = true
								}
							}
						}
					}
				}
			}
		}
	
		if startUpdate == true && (icon.content == nil || needsUpdate == true) {
			if icon.error == nil {
				startConnection(ofIcon: icon)
			}
		}

		return icon
	}

	fileprivate func loadIcon(forRepObject repObject: AnyHashable) {
		
		var icon = icons.first(where:  { $0.repObject == repObject })
		if icon == nil {
			icon = addIcon(with: repObject)
		}
		
		guard let icon = icon
		else {
			return
		}

		startConnection(ofIcon: icon)
	}

	fileprivate func removeIcon(atURL url: URL?) {
		THFatalError("not yet implemented")
	}

	fileprivate func removeIcons() {
		THFatalError("not yet implemented")
	}

	// MARK: -

	private func saveToDisk(data: Data, ofIcon icon: Icon, receivedData: Bool = false) -> Bool {
		guard let file = proposedFilename(forRepObject: icon.repObject)
		else {
			return false
		}

		let path = cacheDir!.th_appendingPathComponent(file + (receivedData ? ".receivedData" :""))

		if data.th_write(to: URL(fileURLWithPath: path)) == false {
			THLogError("can not write data to path:\(path)")
			return false
		}

#if DEBUG
//		if let url = icon.repObject as? URL {
//			let w = "url: " + url.absoluteString
//
//// 			ca marche pas !
//			if THFinderMdItem.setMdItemWhereFroms([w], atPath: path) == false {
//				THLogError("setMdItemComment == false path:\(path)")
//			}
//		}
#endif

		return true
	}
	
	// MARK: -

	fileprivate func startConnection(withRequest request: URLRequest, ofIcon icon: Icon) {
		if icon.task != nil {
			return
		}
	
		THLogInfo("request load of icon:\(icon)")

		let task = urlSession.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
			if icon.task == nil {
				THLogError("icon.task == nil icon:\(icon)")
				return
			}

			let rep = response as? HTTPURLResponse
			if data == nil || rep == nil {
				DispatchQueue.main.async {
					THLogError("data == nil || rep == nil icon:\(icon) error:\(error)")

					icon.task = nil
					icon.error = error?.localizedDescription ?? THLocalizedString("no data or no response url")
				}
				return
			}
			else if rep!.statusCode != 200 {
				DispatchQueue.main.async {
					THLogError("response:\(rep!.th_displayStatus()) icon:\(icon)")

					icon.task = nil
					icon.error = rep!.th_displayStatus()
				}
				return
			}

			if data!.count > 1.th_Mio {
				THLogError("expensive data length: (\(ByteCountFormatter.th_bin1024.string(fromByteCount: Int64(data!.count))) for icon:\(icon)")
			}

			guard let d_img = TH_NSUI_Image(data: data!)
			else {
				if self.saveToDisk(data: data!, ofIcon: icon, receivedData: true) == false {
					THLogError("saveToDisk(data:ofIco:receivedData:) == false icon:\(icon)")
				}

				DispatchQueue.main.async {
					THLogError("can not create img from data icon:\(icon)")

					icon.task = nil
					icon.error = THLocalizedString("can not create img from data (\(request.url))")
				}
				return
			}

			let p_img = self.processReceivedIcon(icon: d_img)

			if self.cacheDir != nil {
				let data = self.storeProcessed == true ? self.data(fromImage: p_img)! : data!

				if self.saveToDisk(data: data, ofIcon: icon) == false {
					THLogError("saveToDisk == false icon:\(icon)")
				}
			}
	
			DispatchQueue.main.async {
				icon.task = nil
				icon.error = nil
				icon.content = p_img
				self.didFinishUpdate(ofIcon: icon)
			}
		})

		icon.task = task
		task.resume()
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
protocol THIconDownloaderDelegateProtocol: AnyObject {
	func iconDownloadder(_ sender: THIconDownloader, processReceivedIcon icon: TH_NSUI_Image) -> TH_NSUI_Image
}

class THIconDownloader: IconDownloader {
	static let shared = THIconDownloader(identifier: "shared", cacheDir: FileManager.th_appCachesDir("THIconDownloader-shared"))
	static let didLoadNotification = Notification.Name("THIconDownloaderDidLoadNotification")

	var delegate: THIconDownloaderDelegateProtocol?

	override func proposedFilename(forRepObject repObject: AnyHashable) -> String? {
		var fn = (repObject as! URL).path
		if fn.hasPrefix("/") {
			fn = String(fn.dropFirst(1))
		}
		if fn.isEmpty == true {
			return nil
		}
		if fn.count > 200 {
			fn = String(fn.dropFirst(fn.count - 200))
		}
		return FileManager.th_secureFilename(fn, subsitution: "_")!
	}
	
	fileprivate override func startConnection(ofIcon icon: Icon) {
		let url = icon.repObject as! URL
		let req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
		startConnection(withRequest: req, ofIcon: icon)
	}

	fileprivate override func processReceivedIcon(icon: TH_NSUI_Image) -> TH_NSUI_Image {
		if let delegate = self.delegate {
			return delegate.iconDownloadder(self, processReceivedIcon: icon)
		}
		return super.processReceivedIcon(icon: icon)
	}

	fileprivate override func didFinishUpdate(ofIcon icon: Icon) {
		NotificationCenter.default.post(	name: Self.didLoadNotification,
															object: self,
															userInfo: ["url": icon.repObject as! URL, "icon": icon.content!])

	}

	func icon(atURL url: URL?, startUpdate: Bool) -> TH_NSUI_Image? {
		if let excludedHosts = excludedHosts, let host = url?.host {
			if excludedHosts.contains(host) == true {
				return nil
			}
		}
	
		let icon = url == nil ? nil : super.icon(withRepObject: url! as AnyHashable, startUpdate: startUpdate)
		return icon?.content
	}

	func hasData(forIconUrl url: URL?) -> Bool {
		guard let url = url
		else {
			return false
		}
	
		if let excludedHosts = excludedHosts, let host = url.host {
			if excludedHosts.contains(host) == true {
				return false
			}
		}

		return super.hasData(forRepObject: url as AnyHashable)
	}

	func error(forIconUrl url: URL?) -> String? {
		return url == nil ? nil : super.error(forRepObject: url! as AnyHashable)
	}

	func loadIcon(atURL url: URL?) {
		guard let url = url
		else {
			return
		}
	
		if let excludedHosts = excludedHosts, let host = url.host {
			if excludedHosts.contains(host) == true {
				return
			}
		}
		
		super.loadIcon(forRepObject: url as AnyHashable)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
#if os(macOS)
@objc class THWebIconLoader: IconDownloader {
	@objc static let shared = THWebIconLoader(		identifier: "shared",
																				cacheDir: FileManager.th_appCachesDir("THWebIconLoader-shared"))
	@objc static let didLoadNotification = Notification.Name("THWebIconLoader-didLoadNotification")

	@objc let genericIcon16 = TH_NSUI_Image(named: "BookmarkURL")!.th_copyAndResize(NSSize(16.0, 16.0))

	override init(identifier: String, cacheDir: String?) {

		if identifier == "shared" {
			let old = cacheDir!.th_deletingLastPathComponent().th_appendingPathComponent("THWebIconLoader")

			if FileManager.default.fileExists(atPath: old) == true {
				try! FileManager.default.removeItem(atPath: old)
			}
		}

		super.init(identifier: identifier, cacheDir: cacheDir)
	}

	override func proposedFilename(forRepObject repObject: AnyHashable) -> String? {
		return (repObject as! NSString).appendingPathExtension("png")
	}

	fileprivate override func startConnection(ofIcon icon: Icon) {
		let host = icon.repObject as! String

		let url = "https://www.google.com/s2/favicons?domain=" + host
		let req = URLRequest(url: URL(string: url)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
		
		startConnection(withRequest: req, ofIcon: icon)
	}

	fileprivate override func didFinishUpdate(ofIcon icon: Icon) {
		NotificationCenter.default.post(	name: Self.didLoadNotification,
															object: self,
															userInfo: ["host": icon.repObject as! String, "icon": icon.content!])

	}

	@objc func icon(forHost host: String?, startUpdate: Bool, allowsGeneric: Bool) -> TH_NSUI_Image? {
		guard let host = host
		else {
			return allowsGeneric == true ? genericIcon16 : nil
		}
		
		if host.isEmpty == true || host.contains("/") == true {
			THLogError("incorrect host name host:\(host)")
			return allowsGeneric == true ? genericIcon16 : nil
		}
		if excludedHosts != nil && excludedHosts!.contains(host) == true {
			return allowsGeneric == true ? genericIcon16 : nil
		}
		
		let icon = super.icon(withRepObject: host as AnyHashable, startUpdate: startUpdate)
		return icon?.content ?? (allowsGeneric == true ? genericIcon16 : nil)
	}

}
#endif
//--------------------------------------------------------------------------------------------------------------------------------------------
