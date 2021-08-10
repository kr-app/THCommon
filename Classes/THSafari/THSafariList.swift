// THSafariList.swift

import Foundation

//--------------------------------------------------------------------------------------------------------------------------------------------
protocol THSafariBookmark {
}

class THSafariSite: NSObject {
	private(set) var identifier: String!
	private(set) var title: String!
	private(set) var url: String!
	var asURL: URL? { get {
										return url.count > 0 ? URL(string: url): nil
									}
								}

	init(identifier: String, title: String?, url: String) {
		self.identifier = identifier
		self.title = title ?? URL(string: url)!.lastPathComponent
		self.url = url
	}

	override var description: String {
		th_description("id:\(identifier) title:\(title) url:\(url)")
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
class THSafariFolder: NSObject {

	private(set) var identifier: String!
	private(set) var title: String!
	private(set) var childs: [AnyObject]!

	init(identifier: String, title: String?, childs: [AnyObject]) {
		self.identifier = identifier
		self.title = title
		self.childs = childs
	}

	override var description: String {
		th_description("id:\(identifier) title:\(title) childs:\(childs.count)")
	}

	class func bookmark(withId id: String?, childs: [AnyObject]) -> THSafariSite? {
		guard let id = id else {
			return nil
		}
	
		for child in childs {
			if child is THSafariSite {
				let site = child as! THSafariSite
				if site.identifier == id {
					return site
				}
			}
			else if child is THSafariFolder {
				if let s = Self.bookmark(withId: id, childs: (child as! THSafariFolder).childs) {
					return s
				}
			}
		}

		return nil
	}

#if DEBUG
	class func printChilds(_ childs: [AnyObject], level: String = "") {

		for child in childs {
			if child is THSafariSite {
				let c = child as! THSafariSite
				print(level + "- " + c.title)
			}
			else if child is THSafariFolder {
				let f = child as! THSafariFolder
				print(level + "+ " + f.title)
				printChilds(f.childs, level: level + "\t")
			}
		}
	}
#endif

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
protocol THSafariListParserProtocol: AnyObject {
	func safariList(_ sender: THSafariList!, canIncludeSite siteUrl: String, siteTitle: String) -> Bool
	func safariList(_ sender: THSafariList!, canIncludeFolder folderId: String, folderPath: String) -> Bool
}

class THSafariList: NSObject {
	static let shared = THSafariList()
	private var bookmarksModDate: Date?

	func canBookmarksAccess() -> (canAccess: Bool, reason: String?) {

		let path = ("~/Library/Safari/Bookmarks.plist" as NSString).expandingTildeInPath

		if FileManager.default.fileExists(atPath: path) == false {
			return (false, THLocalizedString("Bookmarks file does not exist"))
		}

		if FileManager.default.isReadableFile(atPath: path) == false {
			return (false, THLocalizedString("Bookmarks file is not readable"))
		}

		return (true, nil)
	}
	
	/*+ (NSImage*)safariIcon16
	{
		static NSImage *icon=nil;
		if (icon==nil)
		{
			NSString *path=@"/Applications/Safari.app";
			if ([[NSFileManager defaultManager] fileExistsAtPath:path]==NO)
			{
				NSURL *appURL=[[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.apple.Safari"];
				path=(appURL!=nil && appURL.isFileURL==YES)?appURL.path:nil;
			}
			icon=[[[NSWorkspace sharedWorkspace] iconForFile:path] copy];
			icon.size=NSMakeSize(16.0,16.0);
		}
		return icon;
	}*/

	//- (BOOL)isRunningSafari
	//{
	//	NSArray *apps=[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.Safari"];
	//	return apps.count>0?YES:NO;
	//}

	/*- (NSArray*)currentSites
	{
		NSRunningApplication *safariApp=[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.Safari"].firstObject;
		if (safariApp==nil)
			return nil;

		NSDictionary *error=nil;
		NSURL *asURL=[[NSBundle mainBundle] URLForResource:@"THSafariList_CurrentSite" withExtension:@"scpt"];
		NSAppleScript *appleScript=[[NSAppleScript alloc] initWithContentsOfURL:asURL error:&error];
		THException(appleScript==nil,@"appleScript==nil");

		NSDictionary *errorInfo=nil;
		NSAppleEventDescriptor *aed=[appleScript executeAndReturnError:&errorInfo];
		if (aed==nil)
		{
			THLogError(@"aed==nil errorInfo:%@",errorInfo);
			return nil;
		}

		if ([aed numberOfItems]!=2)
			return nil;

		NSMutableArray *sites=[NSMutableArray array];

		NSString *title=[aed descriptorAtIndex:1].stringValue;
		NSString *url=[aed descriptorAtIndex:2].stringValue;
		[sites addObject:[THSafariSite siteWithIdentifier:nil title:title url:url]];

		return sites;
	}*/

	/*- (NSArray*)topSites
	{
		NSString *path=[@"~/Library/Safari/TopSites.plist" stringByExpandingTildeInPath];

		if ([[NSFileManager defaultManager] fileExistsAtPath:path]==NO)
			return nil;

		if ([[NSFileManager defaultManager] isReadableFileAtPath:path]==NO)
		{
			THLogError(@"isReadableFileAtPath==NO path:%@",path);
			return nil;
		}

		NSTimeInterval modDate=0.0;
		if ([THFunctions getModDate1970:&modDate ofPath:path]==NO)
			THLogError(@"getModDate1970==NO path:%@",path);
		else if (modDate==_topSitesModDate)
			return _topSites;
		_topSitesModDate=modDate;

		NSDictionary *dico=[NSDictionary dictionaryWithContentsOfFile:path];
		if (dico==nil)
		{
			THLogError(@"dico==nil path:%@",path);
			return nil;
		}

		NSArray *topSites=dico[@"TopSites"];
		NSMutableArray *result=[NSMutableArray array];

		for (NSDictionary *site in topSites)
			[result addObject:[THSafariSite siteWithIdentifier:nil title:site[@"TopSiteTitle"] urlString:site[@"TopSiteURLString"]]];

		_topSites=[NSArray arrayWithArray:result];
		return _topSites;
	}*/
	
	func bookmarksHasChanged() -> Bool? {

		guard let bookmarksModDate = bookmarksModDate
		else {
			return true
		}

		let path = ("~/Library/Safari/Bookmarks.plist" as NSString).expandingTildeInPath

		let modDate = FileManager.th_modDate1970(atPath: path)
		if modDate == nil {
			THLogError("modDate == nil path\(path)")
			return nil
		}

		if modDate == bookmarksModDate {
			return false
		}

		return true
	}

	func fetchBookmarks(parser: THSafariListParserProtocol?) -> (results: [AnyObject]?, error: String?) {

		let path = ("~/Library/Safari/Bookmarks.plist" as NSString).expandingTildeInPath

		if FileManager.default.fileExists(atPath: path) == false {
			THLogError("fileExistsAtPath == false path:\(path)")
			return (nil, THLocalizedString("Bookmarks file does not exist"))
		}
	
		if FileManager.default.isReadableFile(atPath: path) == false {
			THLogError("isReadableFileAtPath == false path:\(path)")
			return (nil, THLocalizedString("Bookmarks file is not readable"))
		}

		let modDate = FileManager.th_modDate1970(atPath: path)
		if modDate == nil {
			THLogError("modDate == nil path\(path)")
			return (nil, THLocalizedString("Can not get modificaion date of bookmarks file"))
		}

		var bookmarks: [AnyObject]?
		if let dico = NSDictionary(contentsOfFile: path) {
			if let children = dico["Children"] as? [AnyObject] {
				bookmarks = self.bookmarks(fromChilds: children, location: nil, parser: parser)
			}
			else {
				THLogError("dico == nil path:\(path)")
			}
		}
		else {
			THLogError("dico == nil path:\(path)")
		}

		bookmarksModDate = modDate

		return (bookmarks, nil)
	}

	private func bookmarks(fromChilds children: [AnyObject], location: String?, parser: THSafariListParserProtocol?) -> [AnyObject] {

		var results = [AnyObject]()
	
		for child in children {
			let type = child["WebBookmarkType"] as! String

			if type == "WebBookmarkTypeList" {
				
				if location == nil {
					if let omit = child["ShouldOmitFromUI"] as? NSNumber {
						if omit.boolValue == true {
							continue
						}
					}
				}

				guard let title = child["Title"] as? String
				else {
					THLogError("title == nil child:\(child)")
					continue
				}

				if location == nil {
					if ["com.apple.ReadingList", "History"].contains(title) == true {
						continue
					}
				}

				guard let uuid = child["WebBookmarkUUID"] as? String
				else {
					THLogError("uuid == nil || children == nil child:\(child)")
					continue
				}
	
				let children = child["Children"] as? [AnyObject]
				if children == nil {
					continue
				}

				let folderPath = (location ?? "") + "/" + title
				if parser?.safariList(self, canIncludeFolder: uuid, folderPath: folderPath) == false {
					continue
				}

				let childs = bookmarks(fromChilds: children!, location: folderPath, parser: parser)
				results.append(THSafariFolder(identifier: uuid, title: title, childs: childs))
			}
			else if type == "WebBookmarkTypeLeaf" {
				guard let d = child["URIDictionary"] as? [String: AnyObject]
				else {
					THLogError("d == nil child:\(child)")
					continue
				}

				guard 	let title = d["title"] as? String,
						  	let uuid = child["WebBookmarkUUID"] as? String,
							let url = child["URLString"] as? String
				else {
					THLogError("title == nil || uuid == nil || url == nil child:\(child)")
					continue
				}

				if parser?.safariList(self, canIncludeSite: url, siteTitle: title) == false {
					continue
				}

				results.append(THSafariSite(identifier: uuid, title: title, url: url))
			}
		}

		return results
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
