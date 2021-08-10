//  THQLPreviewItemCoquille.swift

import Cocoa
import Quartz

//--------------------------------------------------------------------------------------------------------------------------------------------
@objc class THQLPreviewItemCoquille: NSObject, QLPreviewItem {
	private var mPreviewItemUrl: URL!

	var previewItemURL: URL! { get { mPreviewItemUrl } }
	
	@objc init(url: URL) {
		super.init()
		mPreviewItemUrl = url
	}

	@objc init(filePath: String) {
		mPreviewItemUrl = URL(fileURLWithPath: filePath)
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
