

import UIKit
import QuartzCore

// hit-testing on the non-transparent portion of a drawing
// (here, it's the black ellipse)

class MyView : UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let lay = CALayer()
        lay.frame = self.layer.bounds
        self.layer.addSublayer(lay)
        let t = UITapGestureRecognizer(target: self, action: "tap")
        self.addGestureRecognizer(t)
    }
    
    func tap() {
        println("tap")
    }
    
    override func drawRect(rect: CGRect) {
        let subs = self.layer.sublayers
        let lay = subs[subs.count-1] as CALayer
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        let con = UIGraphicsGetCurrentContext()
        let r = self.bounds.rectByInsetting(dx: 30, dy: 30)
        CGContextSaveGState(con)
        CGContextTranslateCTM(con, self.bounds.width/2.0, self.bounds.height/2.0)
        CGContextRotateCTM(con, CGFloat(M_PI)/10.0)
        CGContextTranslateCTM(con, -self.bounds.size.width/2.0, -self.bounds.size.height/2.0)
        CGContextFillEllipseInRect(con, r)
        CGContextRestoreGState(con)
        let im = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        lay.contents = im.CGImage
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent!) -> UIView! {
        let inside = self.pointInside(point, withEvent:event)
        if (!inside) { return nil }
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        let subs = self.layer.sublayers
        let lay = subs[subs.count-1] as CALayer
        lay.renderInContext(UIGraphicsGetCurrentContext())
        let im = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let info = CGBitmapInfo.fromRaw(CGImageAlphaInfo.Only.toRaw())!
        let pixel = UnsafeMutablePointer<CUnsignedChar>.alloc(1)
        pixel[0] = 0
        let context = CGBitmapContextCreate(pixel,
            1, 1, 8, 1, nil, info)
        UIGraphicsPushContext(context)
        im.drawAtPoint(CGPointMake(-point.x, -point.y))
        UIGraphicsPopContext()
        let p = pixel[0]
        let alpha = Double(p)/255.0
        let transparent = alpha < 0.01
        return transparent ? nil : self
    }
    
}