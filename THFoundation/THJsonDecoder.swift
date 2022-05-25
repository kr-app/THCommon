// THJsonDecoder.swift

import UIKit

//--------------------------------------------------------------------------------------------------------------------------------------------
class THJsonDecoder {
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension THJsonDecoder {

	class func decoded<T: Decodable>(_ type: T.Type, from data: Data?, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil, pError: inout String?) -> T? {
        guard let data = data
		else {
			THLogError("Error occured while decoding data, data == nil")
			pError = "no data / empty data"
			return nil
		}

        let decoder = JSONDecoder()

        if let dateDecodingStrategy = dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrategy
		}
    
        do {
            return try decoder.decode(type, from: data)
        }
        catch {
			THLogError("Error occured while decoding data, error:\(error)")
			pError = "Error occured while decoding data, error:\(error)"
        }

        return nil
    }

	class func decode<T: Decodable>(_ type: T.Type, fromFile url: URL, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil, pError: inout String?) -> T? {
		guard let data = try? Data(contentsOf: url)
		else {
			THLogError("Error occured while reading data file, url:\(url.path)")
			pError = "Error occured while reading data file, url:\(url.path)"
			return nil
		}
		
		var error: String?
		guard let result = decoded(type, from: data, dateDecodingStrategy: dateDecodingStrategy, pError: &error)
		else {
			pError = error
			return nil
		}
		
		return result
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension THJsonDecoder {

	class func decodeJsonObject(fromData data: Data, pError: inout String?) -> Any? {
		do {
			return try JSONSerialization.jsonObject(with:data)
		}
		catch {
			THLogError("Error occured while decoding json object, error:\(error)")
			pError = "Error occured while decoding json object, error:\(error)"
		}
		return nil
	}
	
	class func decodeJsonObject(fromFile url: URL, pError: inout String?) -> Any? {
        do {
            let data = try Data(contentsOf: url)
			return decodeJsonObject(fromData: data, pError: &pError)
        }
        catch {
			THLogError("Error occured while decoding data file, error:\(error)")
			pError = "Error occured while decoding data file, error:\(error)"
            return nil
        }
    }

}
//--------------------------------------------------------------------------------------------------------------------------------------------
