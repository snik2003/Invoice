//
//  CustomPrintPageRenderer.swift
//  Invoice
//
//  Created by Сергей Никитин on 05.12.2022.
//

import UIKit

class CustomPrintPageRenderer: UIPrintPageRenderer {

    let A4PageWidth: CGFloat = 595.2
    let A4PageHeight: CGFloat = 841.8
    
    override init() {
        super.init()
        
        let pageFrame = CGRect(x: 0.0, y: 0.0, width: A4PageWidth, height: A4PageHeight)
        self.setValue(NSValue(cgRect: pageFrame), forKey: "paperRect")
        self.setValue(NSValue(cgRect: pageFrame.insetBy(dx: 10.0, dy: 10.0)), forKey: "printableRect")
    
        self.headerHeight = 30.0
        self.footerHeight = 30.0
    }
    
    override func drawHeaderForPage(at pageIndex: Int, in headerRect: CGRect) {
        let headerText: NSString = "Invoice Mobile App for iOS"
        
        let font = UIFont(name: "SFProDisplay-Semibold", size: 20.0)
        let color = UIColor.appPrimaryColor
        
        let textAttributes = [NSAttributedString.Key.font: font!,
                              NSAttributedString.Key.foregroundColor: color,
                              NSAttributedString.Key.kern: 5] as [NSAttributedString.Key : Any]
        
        let textSize = getTextSize(text: headerText as String, font: nil, textAttributes: textAttributes)
        
        let offsetX: CGFloat = 5.0
        
        let pointX = headerRect.size.width - textSize.width - offsetX
        let pointY = headerRect.size.height/2 - textSize.height/2
        
        headerText.draw(at: CGPoint(x: pointX, y: pointY), withAttributes: textAttributes)
    }

    override func drawFooterForPage(at pageIndex: Int, in footerRect: CGRect) {
        let footerText: NSString = "Thank you!"
        
        let font = UIFont(name: "SFProDisplay-Semibold", size: 14.0)
        let textSize = getTextSize(text: footerText as String, font: font!)
        
        let centerX = footerRect.size.width/2 - textSize.width/2
        let centerY = footerRect.origin.y + self.footerHeight/2 - textSize.height/2
        let attributes = [NSAttributedString.Key.font: font!,
                          NSAttributedString.Key.foregroundColor: UIColor.appPrimaryColor]
        
        footerText.draw(at: CGPoint(x: centerX, y: centerY), withAttributes: attributes)
        
        
        let lineOffsetX: CGFloat = 20.0
        let context = UIGraphicsGetCurrentContext()
        context!.setStrokeColor(red: 205.0/255.0, green: 205.0/255.0, blue: 205.0/255, alpha: 1.0)
        context!.move(to: CGPoint(x: lineOffsetX, y: footerRect.origin.y))
        context!.addLine(to: CGPoint(x: footerRect.size.width - lineOffsetX, y: footerRect.origin.y))
        context!.strokePath()
    }
    
    
    
    func getTextSize(text: String, font: UIFont!, textAttributes: [NSAttributedString.Key: Any]! = nil) -> CGSize {
        let testLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.paperRect.size.width, height: footerHeight))
        if let attributes = textAttributes {
            testLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
        else {
            testLabel.text = text
            testLabel.font = font!
        }
        
        testLabel.sizeToFit()
        
        return testLabel.frame.size
    }
    
}
