// THLikeComparison.swift

import Foundation

//--------------------------------------------------------------------------------------------------------------------------------------------
protocol THLikeComparisonProtocol: NSObject {
	func isLike(_ other: Any?) -> Bool
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension Array {

	func isLike(_ other: Array<THLikeComparisonProtocol>?) -> Bool {

		guard let array = other
		else {
			return false
		}
		
		if array.count != self.count {
			return false
		}

		for i in 0 ..< self.count {
			if (self[i] as! THLikeComparisonProtocol).isLike(array[i]) == false {
				return false
			}
		}
		
		return true
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------
