// RssChannelManager.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
class RssChannelManager: NSObject, RssChannelDelegate {

	static let shared = RssChannelManager()
	static let channelUpdatedNotification = Notification.Name("RssChannelManager-channelUpdatedNotification")
	static let channelItemUpdatedNotification = Notification.Name("RssChannelManager-channelItemUpdatedNotification")
	
	var channels = [RssChannel]()

	private let dirPath = FileManager.th_appSupportPath("RssChannels")
	private var urlSession: URLSession!
	private var synchronizeTimer: Timer?
	
	// MARK: -
	
	override init() {
		super.init()

		loadChannels()
		urlSession = URLSession(configuration: URLSessionConfiguration.th_ephemeral())
	}

	private func loadChannels() {

		let files = try! FileManager.default.contentsOfDirectory(	at: URL(fileURLWithPath: dirPath),
																								includingPropertiesForKeys:nil,
																								options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
		for file in files {
			if file.pathExtension != "plist" {
				continue
			}
			if let channel = RssChannel.channel(fromFile: file.path) {
				channels.append(channel)
			}
			else {
				THLogError("channel == nil file:\(file)")
			}
		}
		
		channels.sort(by: { $0.creationDate < $1.creationDate })
		
		var nbItems = 0
		channels.forEach({ nbItems += $0.items.count })

		var nbUnreaded = 0
		channels.forEach({ nbUnreaded += $0.unreaded() })

		THLogInfo("\(channels.count) channels, nbItems:\(nbItems), nbUnreaded:\(nbUnreaded)")
	}
	
	// MARK: -

	@discardableResult func addChannel(url: URL, startUpdate: Bool = true) -> RssChannel? {
		if channel(withUrl: url) != nil {
			return nil
		}

		let channel = RssChannel(url: url)
		channels.append(channel)

		if channel.save(toDir: dirPath) == false {
			THLogError("can not save channel:\(channel)")
		}

		if startUpdate == true {
			startUpdateOfNextChannel()
		}

		return channel
	}

	func removeChannel(_ channelId: String) {
		if let channel = channel(withId: channelId) {
			channel.cancel()
			if channel.remove(fromDir: dirPath) == false {
				THLogError("can not remove channel:\(channel)")
			}
			channels.removeAll(where: {$0.identifier == channelId })
		}
	}

	func refresh(force: Bool = false) {
		if force == true {
			for channel in channels {
				channel.lastUpdate = nil
			}
		}
		startUpdateOfNextChannel()
	}
	
	// MARK: -
	
	func recentRefDate() -> TimeInterval {
		return Date().timeIntervalSinceReferenceDate - 0.5.th_day
	}

	func channelsOnError() -> [RssChannel] {
		return channels.filter( { $0.lastError != nil } )
	}

	func channel(withUrl url: URL) -> RssChannel? {
		return channels.first(where: { $0.url == url } )
	}
	
	private func channel(withId identifier: String) -> RssChannel? {
		return channels.first(where: { $0.identifier == identifier } )
	}

//	func unreadedChannels() -> [RssChannel] {
//		let r = channels.filter( { $0.unreaded() > 0 } )
//		return r.sorted(by: {
//			if let p0 = $0.items.first?.pubDate, let p1 = $1.items.first?.pubDate {
//				return p0 > p1
//			}
//			return false
//		})
//	}

//	func unreadedItems() -> Int {
//		var r = 0
//		for c in channels {
//			r += c.unreaded()
//		}
//		return r
//	}

	func hasWallChannels(withDateRef dateRef: TimeInterval, atLeast: Int) -> Bool {
		var nb = 0
		for channel in channels {
			nb += channel.items.filter( {$0.checkedDate == nil && $0.isRecent(refDate: dateRef) }).count
			if nb >= atLeast {
				return true
			}
		}
		return false
			//return channels.contains(where: { $0.hasUnreaded() && $0.hasRecent(refDate: dateRef) } )
	}

//	func wallChannels(withDateRef dateRef: TimeInterval) -> [RssChannel] {
//		let r = channels.filter( { $0.hasUnreaded() || $0.hasRecent(refDate: dateRef) } )
//		return r.sorted(by: {
//			if let p0 = $0.items.first?.wallDate, let p1 = $1.items.first?.wallDate {
//				return p0 > p1
//			}
//			return false
//		})
//	}

	func wallChannels() -> [RssChannel] {
		return channels.sorted(by: {
			if let p0 = $0.items.first?.wallDate, let p1 = $1.items.first?.wallDate {
				return p0 > p1
			}
			return false
		})
	}

	func removeItem(_ item: RssChannelItem, ofChannel channelId: String) {
		guard let channel = channel(withId: channelId)
		else {
			return
		}
		
		channel.items.removeAll(where: {$0.identifier == item.identifier! })
		channel.pendingSave = true

		synchronise_delayed()
		NotificationCenter.default.post(name: Self.channelUpdatedNotification, object: self, userInfo: ["channel": channel])
	}

	private func synchronise_delayed() {
		synchronizeTimer?.invalidate()
		synchronizeTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: {(timer: Timer) in
			self.synchronise()
		})
	}

	func synchronise() {
		for channel in channels.filter({ $0.pendingSave == true }) {
			if channel.save(toDir: dirPath) == false {
				THLogError("can not save channel:\(channel)")
			}
		}
	}

	// MARK: -

	@discardableResult private func startUpdateOfNextChannel() -> Bool {
		if channels.contains(where: { $0.isUpdating == true }) == true {
			return false
		}

		let refreshInterval = UserPreferences.shared.refreshInterval
		let refreshTI = (refreshInterval != nil && refreshInterval! > 0) ? TimeInterval(refreshInterval!).th_min : 5.0.th_min
		
		let now = Date().timeIntervalSinceReferenceDate
		let now_time = now - refreshTI
		let now_time_onerror = now - 30.0

		let channels = self.channels.sorted(by: {
					if $0.lastUpdate == nil || $1.lastUpdate == nil {
						return true
					}
					return $0.lastUpdate! < $1.lastUpdate!
				})

		for channel in channels {

			if let lu = channel.lastUpdate {
				if lu.timeIntervalSinceReferenceDate > (channel.lastError != nil ? now_time_onerror : now_time) {
					continue
				}
			}
			
			channel.update(withDelegate: self, urlSession: urlSession, completion: {(ok: Bool, error: String?) in
				if ok == false {
					THLogError("ok == false error:\(error)")
				}

				if channel.save(toDir: self.dirPath) == false {
					THLogError("can not save channel:\(channel)")
				}

				NotificationCenter.default.post(name: Self.channelUpdatedNotification, object: self, userInfo: ["channel": channel])
				self.startUpdateOfNextChannel()
			})

			return true
		}
	
		return false
	}

	func updateChannel(_ channelId: String, completion: @escaping () -> Void) {
		guard let channel = channel(withId: channelId)
		else {
			return
		}

		channel.update(withDelegate: self, urlSession: urlSession, completion: {(ok: Bool, error: String?) in
			if ok == false {
				THLogError("ok == false error:\(error)")
			}

			if channel.save(toDir: self.dirPath) == false {
				THLogError("can not save channel:\(channel)")
			}

			completion()
			NotificationCenter.default.post(name: Self.channelUpdatedNotification, object: self, userInfo: ["channel": channel])
		})
	}
	
	// MARK: -
	
	func channel(_ channel: RssChannel, canIncludeItem item: RssChannelItem) -> Bool {
		return true
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension RssChannelManager {

	private func markChecked(channel: RssChannel) {
		if channel.items.contains(where: { $0.checkedDate == nil }) == false {
			return
		}

		let now = Date()
		for item in channel.items {
			item.checkedDate = now
		}

		channel.pendingSave = true
		synchronise_delayed()
		NotificationCenter.default.post(name: Self.channelUpdatedNotification, object: self, userInfo: ["channel": channel])
	}

	func markAllAsReaded() {
		for channel in channels {
			markChecked(channel: channel)
		}
	}

	func setUrl(_ url: URL, ofChannel channelId: String) {
		guard let channel = channel(withId: channelId)
		else {
			return
		}

		channel.url = url

		channel.pendingSave = true
		synchronise_delayed()
		NotificationCenter.default.post(name: Self.channelUpdatedNotification, object: self, userInfo: ["channel": channel])
	}

	func markChecked(_ checked: Bool = true, item: RssChannelItem, ofChannel channelId: String) {
		guard let channel = channel(withId: channelId)
		else {
		   return
		}

		guard let r_item = channel.items.first(where: {$0.identifier == item.identifier! })
		else {
		   return
		}

		let now = Date()
		item.checkedDate = checked ? now : nil
		r_item.checkedDate = checked ? now : nil

		channel.pendingSave = true
		synchronise_delayed()
		NotificationCenter.default.post(name: Self.channelItemUpdatedNotification, object: self, userInfo: ["channel": channel, "item": item.identifier!])
	}
   
	func markPinned(pinned: Bool, item: RssChannelItem, ofChannel channelId: String) {
		guard let channel = channel(withId: channelId)
		else {
			return
		}

		guard let r_item = channel.items.first(where: {$0.identifier == item.identifier! })
		else {
			return
		}

		item.pinned = pinned
		r_item.pinned = pinned

		channel.pendingSave = true
		synchronise()
		NotificationCenter.default.post(name: Self.channelItemUpdatedNotification, object: self, userInfo: ["channel": channel, "item": item.identifier!])
   }

}
//--------------------------------------------------------------------------------------------------------------------------------------------
