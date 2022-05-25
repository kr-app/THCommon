// THJsonEncoder.swift

import UIKit

//--------------------------------------------------------------------------------------------------------------------------------------------
class THJsonEncoder {
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension THJsonEncoder {
	
	class func encoded<T: Encodable>(_ object: T, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil, pError: inout String?) -> Data? {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted

		if let dateEncodingStrategy = dateEncodingStrategy {
			encoder.dateEncodingStrategy = dateEncodingStrategy
		}

		do {
			return try encoder.encode(object)
		}
		catch {
			THLogError("Error occured while serializating data, error:\(error)")
			pError = "Error occured while serializating data, error:\(error)"
		}
		
		return nil
	}
	
	class func encode<T: Encodable>(_ object: T, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil, to url: URL, pError: inout String?) -> Bool {
		
		var error: String?
		guard let data = encoded(object, dateEncodingStrategy: dateEncodingStrategy, pError: &error)
		else {
			pError = "Error occured while encoding object, error:\(error)"
			return false
		}
		
		if data.th_write(to: url) == false {
			THLogError("ec_write == false url:\(url)")
			pError = "Error occured while writing data"
			return false
		}
		
		return true
	}
	
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension THJsonEncoder {
	
	class func encoded(jsonObject: Any, pError: inout String?) -> Data? {
		do {
			return try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
		}
		catch {
			THLogError("Error occured while serializating data, error:\(error)")
			pError = "Error occured while serializating data, error:\(error)"
		}
		return nil
	}

	class func encode(jsonObject: Any, toFile url: URL, pError: inout String?) -> Bool {

		var error: String?
		guard let data = encoded(jsonObject: jsonObject, pError: &error)
		else {
			THLogError("Error occured while encoding json object, error:\(error)")
			pError = "Error occured while encoding json object, error:\(error)"
			return false
		}
		
		do {
			try data.write(to: url)
			return true
		}
		catch {
			THLogError("Error occured while writing data file, error:\(error)")
			pError = "Error occured while writing data file, error:\(error)"
		}
		
		return false
	}
}
//--------------------------------------------------------------------------------------------------------------------------------------------
