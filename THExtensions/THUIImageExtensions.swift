// THUIImageExtensions.swift

import UIKit

//#if os(iOS)
//extension UIImage {
//	class func th_copyAndResize(_ size: CGSize) -> Self {
////		if let img = self.copy() {
////			img.size = size
////			return img
////		}
//	}
//}
//#endif
//--------------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension UIImage {

	@objc func th_scaledSize(withMaxSize maxSize: CGFloat) -> CGSize {
		let size = self.size
		if size.height > size.width {
			return CGSize((size.width / (size.height / maxSize)).rounded(.down), maxSize)
		}
		if size.height < size.width {
			return CGSize(maxSize, (size.height / (size.width / maxSize)).rounded(.down))
		}
		return CGSize(maxSize, maxSize)
	}

	@objc func th_resized(withFactor factor: CGFloat) -> UIImage {
		let size = self.size

		let nSize = CGSize((size.width * factor).rounded(.down), (size.height * factor).rounded(.down))

		UIGraphicsBeginImageContext(nSize)
		UIGraphicsGetCurrentContext()!.interpolationQuality = .high
			draw(in: CGRect(0.0, 0.0, nSize.width, nSize.height))
			let result = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return result!
	}

	@objc func th_resized(withMaxSize maxSize: CGFloat) -> UIImage {

		let rSize = th_scaledSize(withMaxSize: maxSize)

		UIGraphicsBeginImageContextWithOptions(rSize, false, self.scale)
			draw(in: CGRect(0.0, 0.0, rSize.width, rSize.height))
			let result = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return result!
	}

	@objc func th_tinted(withColor color: UIColor) -> UIImage {
		let image = withRenderingMode(.alwaysTemplate)

		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
			color.set()
			image.draw(in: CGRect(origin: .zero, size: self.size))
			let result = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return result!
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------
