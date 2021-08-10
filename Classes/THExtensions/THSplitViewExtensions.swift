// THExtensions.swift

import Cocoa

//-----------------------------------------------------------------------------------------------------------------------------------------
@objc extension NSSplitView {

	@objc func th_setSubViews(_ subViews: [NSView]) {
		THFatalError(subViews.count != 2, "subViews.count != 2")
		subViews.first!.frame = NSRect(0.0, 0.0, self.subviews.first!.frame.size.width,self.subviews.first!.frame.size.height)
		subViews.last!.frame = NSRect(0.0, 0.0, self.subviews.last!.frame.size.width,self.subviews.last!.frame.size.height)
		self.subviews = [subViews.first!, subViews.last!]
	}

	@objc func th_updateFixedDivided(atIndex index: Int) {
		let dividerThickness = self.dividerThickness
		let newFrame = self.frame
		
		let v1 = self.subviews[0]
		let v2 = self.subviews[1]
		
		let r1 = v1.frame
		let r2 = v2.frame
		
		var nR1 = r1
		var nR2 = r2
		
		if self.isVertical {
			/* 0 (gauche), 1 (droite) */
			
			if index == 0 {
				nR1.size.height = newFrame.size.height
				nR1.origin = NSZeroPoint
				
				nR2.size.width = newFrame.size.width - r1.size.width - dividerThickness
				nR2.size.height = newFrame.size.height
				nR2.origin.x = r1.size.width + dividerThickness
			}
			else if index == 1 {
				nR1.origin = NSPoint(0.0, 0.0)
				nR1.size=NSMakeSize(newFrame.size.width - r2.size.width - dividerThickness, newFrame.size.height)
				
				nR2.origin = NSPoint(newFrame.size.width - r2.size.width, 0.0)
				nR2.size.height = newFrame.size.height
			}
		}
		else {
			/* 0 (haut)
				1 (bas) */
			
			if index == 0 {
				nR1.size.width = newFrame.size.width
				nR1.origin = NSZeroPoint
				
				nR2.size.height = newFrame.size.height - r1.size.height - dividerThickness
				nR2.size.width = newFrame.size.width
				nR2.origin = NSPoint(0.0, r1.size.height + dividerThickness)
			}
			else if index == 1 {
				nR1.size = NSSize(newFrame.size.width, newFrame.size.height - r2.size.height - dividerThickness)
				nR1.origin = NSPoint(0.0, 0.0)

				nR2.size = NSSize(newFrame.size.width, r2.size.height)
				nR2.origin = NSPoint(0.0, newFrame.size.height - dividerThickness - r2.size.height)
			}
		}

		if NSEqualRects(nR1, r1) == false || NSEqualRects(nR2, r2) == false {
			v1.frame = nR1
			v2.frame = nR2
		}
	}

	@objc func th_assureMinimumSizes(_ min0: CGFloat, min1: CGFloat) {
	/*
		NSRect rect=self.frame;
		CGFloat dividerThickness=[self dividerThickness];
		
		NSView *v0=self.subviews[0];
		NSView *v1=self.subviews[1];
		
		NSRect r0=v0.frame;
		NSRect r1=v1.frame;
		
		if (self.isVertical==YES)
		{
			if (r0.size.width<min0)
			{
				r0.size.width=min0;
				r1.size.width=rect.size.width-dividerThickness-r0.size.width;
				[v0 setFrame:r0];
				[v1 setFrame:r1];
			}
			else if (r1.size.width<min1)
			{
				r1.size.width=min1;
				r0.size.width=rect.size.width-dividerThickness-r1.size.width;
				r1.origin.y=0.0;
				
				[v0 setFrame:r0];
				[v1 setFrame:r1];
			}
		}
		else
		{
			if (r0.size.height<min0)
			{
				r0.size.height=min0;
				r1.size.height=rect.size.height-dividerThickness-r0.size.height;
				[v0 setFrame:r0];
				[v1 setFrame:r1];
			}
			else if (r1.size.height<min1)
			{
				r1.size.height=min1;
				r0.size.height=rect.size.height-dividerThickness-r1.size.height;
				r1.origin.y=0.0;
				
				[v0 setFrame:r0];
				[v1 setFrame:r1];
			}
		}
	*/	}


}
//-----------------------------------------------------------------------------------------------------------------------------------------
