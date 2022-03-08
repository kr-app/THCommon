// THExtensions.swift

#if os(macOS)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

//-----------------------------------------------------------------------------------------------------------------------------------------
extension String {
	
	var th_lastPathComponent: String { (self as NSString).lastPathComponent }
	var th_pathExtension: String { (self as NSString).pathExtension }

	func th_appendingPathComponent(_ pathCompoment: String) -> String { (self as NSString).appendingPathComponent(pathCompoment) }
	func th_deletingLastPathComponent() -> String { (self as NSString).deletingLastPathComponent }
	func th_appendingPathExtension(_ pathExtension: String) -> String { (self as NSString).appendingPathExtension(pathExtension)! }
	func th_deletingPathExtension() -> String { (self as NSString).deletingPathExtension }
	func th_expandingTildeInPath() -> String { (self as NSString).expandingTildeInPath }
}
//-----------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension String {

	private func th_trimedFirstSpace() -> String {
		if self.hasPrefix(" ") == true {
			return String(self.dropFirst(1))
		}
		return self
	}

	private func th_trimedLastSpace() -> String {
		if self.hasSuffix(" ") == true {
			return String(self.dropLast(1))
		}
		return self
	}

	func th_truncate(maxChars: Int, by byTruncate: NSLineBreakMode) -> String {
		if self.count < maxChars {
			return self
		}

		if byTruncate == .byTruncatingMiddle {
			let offset: Int = maxChars / 2
			return String(self.prefix(offset)).th_trimedFirstSpace() + "…" + String(self.suffix(offset)).th_trimedFirstSpace()
		}
	
		return String(self.prefix(maxChars)).th_trimedLastSpace() + "…"
	}

	func th_truncate(	maxLength: CGFloat,
								withAttrs attrs: [NSAttributedString.Key: Any],
								by byTruncate: NSLineBreakMode = .byTruncatingMiddle,
								substitutor: String = "…") -> String {

		if self.count < 40 {
			return self
		}
		
		let sz = self.size(withAttributes: attrs)
		if sz.width <= maxLength {
			return self
		}
		
		if byTruncate == .byTruncatingMiddle {
			var offset: Int = self.count / 2
			while offset > 0 {
				for i in 0...1 {
					let s = String(self.prefix(offset)).th_trimedLastSpace() + "…" + String(self.suffix(offset - i)).th_trimedFirstSpace()
					if s.size(withAttributes: attrs).width <= maxLength {
						return s
					}
				}
				offset -= 1
			}
		}
		else {
			var offset = 0
			while true {
				let s = String(self.prefix(offset + 1)).th_trimedLastSpace() + substitutor
				if s.size(withAttributes: attrs).width <= maxLength {
					offset += 1
					continue
				}
				return s
			}
		}

		return self
	}
}
//--------------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------------------------
extension String {

	func th_write(toFile file: String, atomically: Bool, encoding: Encoding) -> Bool {
		do {
			try write(toFile: file, atomically: atomically, encoding: encoding)
			return true
		}
		catch {
			THLogError("writeTo file:\(file) error: \(error)")
		}
		return false
	}

}
//--------------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension NSString {

//	- (BOOL)th_isEmailValid
//	{
//		NSUInteger L=self.length;
//		if (L<3 || L>128)
//			return NO;
//
//		NSString *expression=@"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
//
//		NSError *error=nil;
//		NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
//		NSTextCheckingResult *match=[regex firstMatchInString:self options:0 range:NSMakeRange(0,L)];
//
//		return match!=nil?YES:NO;
//	}

	@objc func th_isEqual(string: String?, to anotherString: String?) -> Bool {
		if string == anotherString {
			return true
		}
		return (string != nil && anotherString != nil && string == anotherString) ? true : false
	}
	
	@objc func th_terminating(by suffix: String) -> String {
		if self.length == 0 || hasSuffix(suffix) == true {
			return self as String
		}
	
		for s in [".", "?", ":", "!", "?", "…"] {
			if hasSuffix(s) == true {
				return self as String
			}
		}

		return appending(suffix)
	}

//	- (NSString*)th_stringTruncatedWithAttributes:(NSDictionary*)attributes maxWidth:(CGFloat)maxWidth
//	{
//		NSString *s=self;
//		while ([s sizeWithAttributes:attributes].width>maxWidth)
//			s=[s substringToIndex:s.length-1];
//		if (s==self)
//			return s;
//		while (s.length>0 && [s hasSuffix:@" "])
//			s=[s substringToIndex:s.length-1];
//		return [s stringByAppendingString:@"…"];
//	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------------------------
extension String {

	func th_hasPrefixInsensitive(_ prefix: String) -> Bool {
		(self as NSString).range(of: prefix, options: .caseInsensitive).location == 0
	}

	func th_containsInsensitive(_ string: String) -> Bool {
		(self as NSString).range(of: string, options: .caseInsensitive).location != NSNotFound
	}

	func th_search(firstRangeOf begin: String, endRange end: String) -> String? {

		let fr = (self as NSString).range(of: begin)
		if fr.location == NSNotFound {
			return nil
		}
		let fre = fr.location + fr.length

		let er = (self as NSString).range(of: end, range: NSRange(fre, self.count - fre))
		if er.location == NSNotFound {
			return nil
		}

		let r = (self as NSString).substring(with: NSRange(fre, er.location - fre))
		return r.isEmpty == false ? r : nil
	}

}
//-----------------------------------------------------------------------------------------------------------------------------------------
