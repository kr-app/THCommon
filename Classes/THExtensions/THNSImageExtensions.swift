// THNSImageExtensions.swift

import Cocoa

//--------------------------------------------------------------------------------------------------------------------------------------------
fileprivate class Caches {
	static var wsIcons = [String: NSImage]()
}

extension NSImage {

	@objc func th_copyAndResize(_ size: NSSize) -> Self? {
		if let img = self.copy() as? Self{
			img.size = size
			return img
		}
		return nil
	}

	@objc func th_PNGRepresentation() -> Data? {
		if let data = self.tiffRepresentation {
			let imageRep = NSBitmapImageRep(data: data)
			return imageRep?.representation(using: .png, properties: [:])
		}
		return nil
	}
	
/*	@objc class func th_imageFromPasteboard(_ pasteboard: NSPasteboard? = nil) -> Self? {
		let pb = pasteboard ?? NSPasteboard.general

		let images = pb.readObjects(forClasses: [NSImage.self], options: [.urlReadingContentsConformToTypes: [NSPasteboard.PasteboardType.URL]])
		if let img = images?.first as? NSImage {
			return img as? Self
		}

		let urls = pb.readObjects(forClasses: [NSURL.self], options: nil)
		if let url = urls?.first as? URL {
			if let img = NSImage(contentsOf: url) {
				return img as? Self
			}
		}

		let strings = pb.readObjects(forClasses: [NSString.self], options: nil)
		if let string = strings?.first as? String {
			if let url = URL(string: string) {
				if let img = NSImage(contentsOf: url) {
					return img as? Self
				}
			}
		}

		THLogError("unsupported pb:\(pb)")
		return nil
	}*/

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension NSImage {

	@objc func th_rotated(by angle: CGFloat) -> NSImage {
		let img = NSImage(size: self.size)
		img.isTemplate = self.isTemplate

		img.lockFocus()
			//, flipped: false, drawingHandler: { (rect) -> Bool in
			let iSz = self.size
			let transform = NSAffineTransform()
			transform.translateX(by: iSz.width / 2.0, yBy: iSz.height / 2.0)
			transform.rotate(byDegrees: angle)
			transform.translateX(by: -iSz.width / 2.0, yBy: -iSz.height / 2.0)
			transform.concat()
			self.draw(in: NSRect(0.0, 0.0, iSz.width, iSz.height))
		img.unlockFocus()

		return img
	}

	@objc func th_scaledSize(withMaxSize maxSize: CGFloat) -> NSSize {
		let size = self.size
		if size.height > size.width {
			return NSSize((size.width / (size.height / maxSize)).rounded(.down), maxSize)
		}
		if size.height < size.width {
			return NSSize(maxSize, (size.height / (size.width / maxSize)).rounded(.down))
		}
		return NSSize(maxSize, maxSize)
	}

	@objc func th_resizedImage(withMaxSize maxSize: CGFloat, crop: Bool = false) -> Self {

		let size = self.size
		if size.width < maxSize && size.height < maxSize {
			//THLogError("not yet implemented")
			return self
		}

		if crop == true {

			var r: NSRect?
			if size.width > size.height {
				r = NSRect(((size.width - size.height) / 2.0).rounded(.down), 0.0, size.height, size.height)
			}
			else {
				r = NSRect(0.0, ((size.height - size.width) / 2.0).rounded(.down), size.height, size.height)
			}

			let img = Self(size: NSSize(maxSize, maxSize))

			img.lockFocus()
			self.draw(	in: NSRect(0.0, 0.0, maxSize, maxSize), from: r!, operation: .sourceOver, fraction: 1.0)
			img.unlockFocus()

			return img
		}
	
		let scSize = self.th_scaledSize(withMaxSize: maxSize)
		let img = Self(size: scSize)

		img.lockFocus()
			self.draw(in: NSRect(0.0, 0.0, scSize.width, scSize.height),
				from: NSRect(0.0, 0.0, size.width, size.height),
				operation: .sourceOver,
				fraction: 1.0)
		img.unlockFocus()

		return img
	}

	@objc func th_imageGray() -> Self {
		guard let cgRef = self.cgImage(forProposedRect: nil, context: nil, hints: nil)
		else {
			return self
		}

		let representation = NSBitmapImageRep(cgImage: cgRef)
		let rep = representation.converting(to: .genericGray, renderingIntent: .default)
		return Self(cgImage: rep!.cgImage!, size: self.size)
	}
	
	@objc func th_tinted(withColor color: NSColor) -> Self {
		
		guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)
		else {
			return self
		}

		let r = Self(size: size)

		r.lockFocus()
			let context = NSGraphicsContext.current?.cgContext
			color.set()
			context?.clip(to: NSRect(0.0, 0.0, r.size.width, r.size.height), mask: cgImage)
			context?.fill(NSRect(0.0, 0.0, r.size.width, r.size.height))
		r.unlockFocus()
	
		return r
	}
	
	@objc func th_imageOval() -> Self {
		let sz = self.size
		let minSz = sz.width < sz.height ? sz.width : sz.height
		let img = Self(size: NSSize(width: minSz, height: minSz))

		img.lockFocus()
			NSBezierPath(ovalIn: NSRect(0.0, 0.0, minSz, minSz)).addClip()
			self.draw(		at: NSPoint(((minSz - sz.width) / 2.0).rounded(.down), ((minSz - sz.height) / 2.0).rounded(.down)),
								from: NSRect(0.0,0.0,sz.width,sz.height),
								operation: .sourceOver, fraction: 1.0)
		img.unlockFocus()

		return img
	}

	@objc func th_image(withCorner radius: CGFloat) -> Self {
		let img = Self(size: self.size)
		let iRect = NSRect(0.0, 0.0, self.size.width, self.size.height)
		
		img.lockFocus()
			NSGraphicsContext.current?.imageInterpolation = .high
			NSBezierPath(roundedRect: iRect, xRadius: radius, yRadius: radius).addClip()
			self.draw(at: NSZeroPoint, from: iRect, operation: .sourceOver, fraction: 1.0)
		img.unlockFocus()

		return img
	}

	@objc class func th_wsIcon(forFileHFSType hfsType: OSType, size: CGFloat) -> NSImage? {

		guard let type = NSFileTypeForHFSTypeCode(hfsType)
		else {
			THLogError("can not get icon for hfsType:\(hfsType)")
			return nil
		}

		let key = type + "-" + String(Int(size))

		if let icon = Caches.wsIcons[key] {
			return icon
		}

		if let icon = NSWorkspace.shared.icon(forFileType: type).th_copyAndResize(NSSize(size, size)) {
			Caches.wsIcons[key] = icon
			return icon
		}

		THLogError("can not get icon for type:\(type)")
		return nil
	}

	@objc class func th_computerIcon(withSize size: CGFloat) -> NSImage? {
		return th_wsIcon(forFileHFSType: OSType(kComputerIcon), size: size)
	}

	@objc class func th_genericFolderIcon(withSize size: CGFloat) -> NSImage? {
		return th_wsIcon(forFileHFSType: OSType(kGenericFolderIcon), size: size)
	}
	
}
//-----------------------------------------------------------------------------------------------------------------------------------------
