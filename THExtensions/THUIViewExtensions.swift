// THUIViewExtensions.swift

import UIKit

//-----------------------------------------------------------------------------------------------------------------------------------------
extension UIView {

	var th_enclosingTbV: UITableView? {
		var v = self.superview
		while (v != nil) {
			if (v is UITableView) {
				return v as? UITableView
			}
			v = v?.superview
		}
		return nil
	}

	var th_enclosingCollectionView: UICollectionView? {
		var v = self.superview
		while (v != nil) {
			if (v is UICollectionView) {
				return v as? UICollectionView
			}
			v = v?.superview
		}
		return nil
	}

	func th_removeAllSubview() {
		for v in self.subviews {
			v.removeFromSuperview()
		}
	}

	func th_sizeToFit_withOnly_leftAligned(_ margin: CGFloat = 0) {
		let f = self.frame
		self.sizeToFit()
		self.frame = CGRect(f.origin.x, f.origin.y, (self.frame.width).rounded() + margin, f.size.height)
	}
}
//-----------------------------------------------------------------------------------------------------------------------------------------
#endif
