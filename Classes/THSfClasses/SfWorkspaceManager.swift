// SfWorkspaceManager.swift

import Foundation

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class SfWorkspaceManager : NSObject {

	@objc static let shared = SfWorkspaceManager()
	
	@objc var workspaces = [SfWorkspace]()
	@objc var selectedWorkspace: SfWorkspace? { get { workspaces.first(where: { $0.isSelected == true }) }}
	@objc var defaultWorkspace: SfWorkspace { get { return workspaces.first! }}

	private let dirPath = FileManager.th_appSupportPath("workspaces")
	private var timer: Timer?

	class func safariRef() -> Int? {
		let apps = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.Safari")
		guard let app = apps.last
		else {
			THLogError("apps:\(apps)")
			return nil
		}
		return Int(app.processIdentifier)
	}

	override init() {
		super.init()

		if loadWorkspaces() == false {
			THLogError("workspaces == nil")
			return
		}

		if workspaces.count == 0 {
			let workspace = SfWorkspace(identifier: 1, name: THLocalizedString("Default Workspace"))
			workspace.isSelected = true
			workspaces = [workspace]
		}
	}
	
	private func loadWorkspaces() -> Bool {

		guard let files = try? FileManager.default.contentsOfDirectory(	at: URL(fileURLWithPath: dirPath),
																								includingPropertiesForKeys:nil,
																								options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
		else {
			THLogError("files == nil dir:\(dirPath)")
			return false
		}

		for file in files {
			if file.pathExtension != "plist" {
				continue
			}
			if let workspace = SfWorkspace.workspace(fromFile: file.path) {
				workspaces.append(workspace)
			}
			else {
				THLogError("workspace == nil file:\(file)")
			}
		}

		THLogInfo("\(workspaces.count) workspaces")

		return true
	}

	// MARK: -
	
	@objc func startAndCaptureNow(_ captureNow: Bool = false) {
		if timer != nil {
			return
		}

		let refreshInterval = SfUserPref.shared.refreshInterval ?? SfUserPref.defaultRefreshInterval
		timer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector:#selector(timer_action), userInfo:nil, repeats: true)

		if captureNow == true {
			timer_action(timer!)
		}
	}

	@objc func stop() {
		if timer == nil {
			return
		}
		timer?.invalidate()
		timer = nil
	}

	@objc func timer_action(_ sender: Timer) {
		let safari = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.Safari").last
		if safari == nil || safari!.isHidden == true || safari!.isActive == true {
			return
		}

		let currentWs = self.selectedWorkspace ?? self.defaultWorkspace

		if takeCapture(ofWorkspace: currentWs) == false {
			THLogError("takeCapture == false currentWs:\(currentWs)")
		}
	}

	@objc func setCurrentWorkspace(_ workspace: SfWorkspace?) {
		for ws in workspaces {
			ws.isSelected = ws.identifier == workspace?.identifier
			if ws.save(toDir: dirPath) == false {
				THLogError("save == false ws:\(ws)")
			}
		}
	}

	@objc func workspaceNamed(_ name: String) -> SfWorkspace? {
		return workspaces.first(where: { $0.name == name })
	}

	@objc func addWorkspace(withName name: String) -> SfWorkspace? {
		if workspaces.contains(where: { $0.name == name }) {
			THLogError("found another workspace with the same name:\(name)")
			return nil
		}

		var maxId = 0
		for ws in workspaces {
			if ws.identifier > maxId {
				maxId = ws.identifier
			}
		}

		maxId += 1

		let workspace = SfWorkspace(identifier: maxId, name: name)
		workspaces.append(workspace)
		
		if workspace.save(toDir: dirPath) == false {
			THLogError("save == false workspace:\(workspace)")
		}

		return workspace
	}

	@objc func renameWorkspace(_ workspace: SfWorkspace, withName name: String) -> Bool {
		if name.trimmingCharacters(in: .whitespaces).isEmpty == true {
			return false
		}
	
		guard let ws = workspaces.first(where: { $0.identifier == workspace.identifier })
		else {
			return false
		}

		ws.name = name
		if ws.save(toDir: dirPath) == false {
			THLogError("save == false ws:\(ws)")
		}

		return true
	}
	
	
	fileprivate func deleteWorkspace(_ workspace: SfWorkspace) -> Bool {
		if workspace.identifier == defaultWorkspace.identifier {
			THLogError("can not remve default workspace")
			return false
		}

		guard let ws = workspaces.first(where: { $0.identifier == workspace.identifier })
		else {
			THLogError("ws == nil")
			return false
		}

		if ws.remove(fromDir: dirPath) == false {
			THLogError("remove == false")
		}

		workspaces.removeAll(where: {$0.identifier == ws.identifier })
	
		return true
	}
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension SfWorkspaceManager {

	@objc func takeCapture(ofWorkspace workspace: SfWorkspace) -> Bool {
		let currentWs = selectedWorkspace ?? defaultWorkspace

		if workspace != currentWs {
			THLogError("workspace != currentWs")
			return false
		}

		guard let safariRef = Self.safariRef()
		else {
			THLogError("safariRef == nil")
			return false
		}

		if workspace.takeCapture(safariRef) == false {
			THLogError("takeCapture == false")
			return false
		}

		if workspace.save(toDir: dirPath) == false {
			THLogError("save == false workspace:\(workspace)")
		}

		return true
	}

	@objc func restoreCapture(_ capture: SfCapture, ofWorkspace workspace: SfWorkspace) -> Bool {
		let currentWs = selectedWorkspace ?? defaultWorkspace

		if workspace.identifier != currentWs.identifier {
			return false
		}

		guard let safariRef = Self.safariRef()
		else {
			THLogError("safariRef == nil")
			return false
		}

		if currentWs.takeCapture(safariRef) == false {
			THLogError("takeCapture == false")
			return false
		}

		if workspace.restoreCapture(capture, safariRef: safariRef) == false {
			THLogError("restoreCapture == false")
			return false
		}

		if workspace.save(toDir: dirPath) == false {
			THLogError("save == false workspace:\(workspace)")
		}

		return true
	}
	
	@objc func deleteCapture(_ capture: SfCapture, ofWorkspace workspace: SfWorkspace) -> Bool {
		if workspace.deleteCapture(capture) == false {
			THLogError("deleteCapture == false")
			return false
		}
		if workspace.save(toDir: dirPath) == false {
			THLogError("save == false workspace:\(workspace)")
		}
		return true
	}

	@objc func switchToWorkspace(_ workspace: SfWorkspace) -> Bool {
		let currentWs = selectedWorkspace ?? defaultWorkspace

		if workspace.identifier == currentWs.identifier {
			return false
		}

		guard let safariRef = Self.safariRef()
		else {
			THLogError("safariRef == nil")
			return false
		}

		if currentWs.takeCapture(safariRef) == false {
			THLogError("takeCapture == false")
			return false
		}

		if workspace.restoreCapture(nil, safariRef: safariRef) == false {
			THLogError("restoreCapture == false")
			//return false
		}

		setCurrentWorkspace(workspace)
		return true
	}

	@objc func closeWorkspace(_ workspace: SfWorkspace, closeWindows: Bool) -> Bool {
		if workspace.identifier == defaultWorkspace.identifier {
			THLogError("can not remve default workspace")
			return false
		}

		guard let ws = workspaces.first(where: { $0.identifier == workspace.identifier })
		else {
			THLogError("ws == nil")
			return false
		}

		if closeWindows == true {
			guard let safariRef = Self.safariRef()
			else {
				THLogError("safariRef == nil")
				return false
			}

			if ws.closeWindows(ofCapture: nil, safariRef: safariRef) == false {
				THLogError("closeWindows == false")
			}
		}
		
		if deleteWorkspace(ws) == false {
			THLogError("deleteWorkspace == false")
			return false
		}

		return true
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
