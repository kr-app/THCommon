// THHostFilter.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
fileprivate class HostDomain: NSObject, THDictionarySerializationProtocol {
	let host: String
	var subdomain = false
	var accepted = false

	init(host: String, subdomain: Bool, accepted: Bool) {
		self.host = host
		self.subdomain = subdomain
		self.accepted = accepted
	}
	
	init(rawHost: String, accepted: Bool) {
		var h = rawHost
		var subdomain = false
	
		if h.hasPrefix("*.") || h.hasSuffix(".*") {
			h = String(h.dropFirst("*".count))
			subdomain = true
		}
	
		self.host = h
		self.subdomain = subdomain
		self.accepted = accepted
	}

	override var description: String {
		th_description("host:\(host) subdomain:\(subdomain) accepted:\(accepted))")
	}

	func match(withHost host: String) -> Bool {
		if subdomain == true {
			if host.contains(self.host) == true {
				return true
			}
		}
		return self.host == host || self.host.contains("." + host)
	}

	func dictionaryRepresentation() -> THDictionaryRepresentation {
		let coder = THDictionaryRepresentation()
		
		coder.setString(host, forKey: "host")
		coder.setBool(subdomain, forKey: "subdomain")
		coder.setBool(accepted, forKey: "accepted")
		
		return coder
	}

	required init(withDictionaryRepresentation dictionaryRepresentation: THDictionaryRepresentation) {
		host = dictionaryRepresentation.string(forKey: "host")!
		subdomain = dictionaryRepresentation.bool(forKey: "subdomain") ?? (dictionaryRepresentation.int(forKey: "rules") == 1 ? true : false)
		accepted = dictionaryRepresentation.bool(forKey: "accepted")!
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension HostDomain {

	fileprivate class func defaultHosts() -> [HostDomain] {
		var hosts = [HostDomain]()
		hosts += hostDomains(from: Self.whiteList(), accepted: true)
		hosts += hostDomains(from: Self.blockedHostList(), accepted: false)
		return hosts
	}

	fileprivate class func blockedHostList() -> [String] {
		return [		"gum.criteo.com",
						"aax-eu.amazon-adsystem.com",
						"*.doubleclick.net",
						"acdn.adnxs.com",
						"ads.pubmatic.com",
						"acdn.adnxs.com",
						"eu-u.openx.net",
						"ssum-sec.casalemedia.com",
						"ap.lijit.com",
						"eu-u.openx.net",
						"sync-eu.connectad.io",
						"eb2.3lift.com",
						"ssum-sec.casalemedia.com",
						"cm.adform.net",
						"creativecdn.com",
						"ups.analytics.yahoo.com",
						"ssum.casalemedia.com",
						"sync.connectad.io",
						"x.bidswitch.net",
						"cdn.connectad.io",
						"js-sec.indexww.com",
						"onetag-sys.com",
						"eus.rubiconproject",
						"tpc.googlesyndication.com",
						"*.safeframe.googlesyndication.com",
						"google-analytics.com",
						"imasdk.googleapis.com",
						"*.rubiconproject.com",
						"*.openx.net",
						"sync-t1.taboola.com",
						"*.hubvisor.io"]
		}

	fileprivate class func whiteList() -> [String] {
		return [		"*.apple.com",
						"*.wikipedia.*"]
		}

	fileprivate class func hostDomains(from domains: [String], accepted: Bool) -> [HostDomain] {
//		let u = Bundle.main.url(forResource: "blackListedHosts", withExtension: "txt")
//		let text = try! String(contentsOf: u, encoding: .utf8)
//
//		var hosts = [AdHost]()
//		for host in text.components(separatedBy: CharacterSet.newlines) {
//			if host.isEmpty == true {
//				continue
//			}
//
//			var h = host
//			var rule = HostRule.none
//
//			if host.hasPrefix("*") == true {
//				h = String(host.dropFirst("*".count))
//				rule = .subdomain
//			}
//
//			hosts.append(AdHost(host: h, rule: rule, accepted: false))
//		}

		var hosts = [HostDomain]()
		for domain in domains {
			if domain.trimmingCharacters(in: .whitespaces).isEmpty == true {
				continue
			}
			hosts.append(HostDomain(rawHost: domain, accepted: accepted))
		}
	
		return hosts
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
enum THHostFilterStatus: Int {
	case unknown = 0
	case accepted = 1
	case refused = -1
}

class THHostFilter: NSObject, THDictionarySerializationProtocol {
	static let shared = THHostFilter.hostFilter(named: "shared")

	private var name: String!
	private var hosts: [HostDomain]!

	private init(name: String) {
		super.init()

		self.name = name
		self.hosts = HostDomain.defaultHosts()
	}
	
	fileprivate class func hostFilter(named name: String) -> THHostFilter {
		let dir = FileManager.th_appSupportPath()
		let path = dir.th_appendingPathComponent("THHostFilter-\(name).plist")

		guard let hostFilter = THHostFilter.th_unarchive(fromDictionaryRepresentationAtPath: path)
		else {
			return THHostFilter(name: name)
		}
	
		hostFilter.checkDefaultHosts()
		hostFilter.synchronize()

		return hostFilter
	}

	// MARK: -

	required init(withDictionaryRepresentation dictionaryRepresentation: THDictionaryRepresentation) {
		super.init()
		
		self.name = dictionaryRepresentation.string(forKey: "name")!
		self.hosts = HostDomain.th_objects(fromDictionaryRepresentation: dictionaryRepresentation, forKey: "hosts")
	}

	func dictionaryRepresentation() -> THDictionaryRepresentation {
		let coder = THDictionaryRepresentation()

		coder.setString(name!, forKey: "name")
		coder.setObjects(hosts, forKey: "hosts")

		return coder
	}

	// MARK: -

	private func checkDefaultHosts() {
		for defaultHost in HostDomain.defaultHosts() {

			if let host = hosts.first(where: { 	$0.host == defaultHost.host &&
																$0.accepted == defaultHost.accepted &&
																$0.subdomain == defaultHost.subdomain }) {
				THLogInfo("updated host domain:\(host)")
				hosts.removeAll(where: { $0.host == host.host })
				hosts.append(defaultHost)
				continue
			}

			THLogInfo("added default host:\(defaultHost)")
			hosts.append(defaultHost)
		}
	}

	// MARK: -

	func status(forHost host: String) -> THHostFilterStatus {
		if let h = hosts.first(where: { $0.match(withHost: host) }) {
			return h.accepted == true ? .accepted : .refused
		}
		return .unknown
	}

	func setHost(_ host: String, accepted: Bool) {
		if host.trimmingCharacters(in: .whitespaces).isEmpty == true {
			return
		}

		if let h = hosts.first(where: { $0.match(withHost: host) }) {
			h.accepted = accepted
		}
		else {
			hosts.append(HostDomain(rawHost: host, accepted: accepted))
		}
	
		if synchronize() == false {
			THLogError("synchronize == false")
		}
	}

	func synchronize() -> Bool {
		let path = FileManager.th_appSupportPath().th_appendingPathComponent("THHostFilter-\(self.name!).plist")

		if dictionaryRepresentation().write(toFile: path) == false {
			THLogError("dictionaryRepresentation().write == false path:\(path)")
			return false
		}

		return true
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------
