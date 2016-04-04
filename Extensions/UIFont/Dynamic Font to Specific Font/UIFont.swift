//
//  UIFont.swift
//  PwcReportingApp
//
//  Created by Arjan van der Laan on 02/02/16.
//  Copyright © 2016 Auxilium. All rights reserved.
//

import UIKit

extension UIFont {
    static func IsKnownTextStyle(style: String?) -> Bool {
        guard style != nil else {
            return false
        }
        
        let knownTextStyles: [String] =
        [UIFontTextStyleBody,
            UIFontTextStyleHeadline,
            UIFontTextStyleSubheadline,
            UIFontTextStyleCallout,
            UIFontTextStyleCaption1,
            UIFontTextStyleCaption2,
            UIFontTextStyleFootnote,
            UIFontTextStyleTitle1,
            UIFontTextStyleTitle2,
            UIFontTextStyleTitle3]
        
        return knownTextStyles.contains(style!)
    }
    
    func appFontOfSameStyleAndSize() -> UIFont {
        if self.styleAttribute == nil {
            print("appFontOfSameStyleAndSize(): shouldnt come here")
        }
        if UIFont.IsKnownTextStyle(self.styleAttribute) {
            return UIFont.AppFont.FromTextStyle(self.styleAttribute!, fontSize: nil)
        } else {
            return UIFont.AppFont.FromTextStyle(self.styleAttribute ?? "CTFontRegularUsage", fontSize: pointSize)
        }
    }
    
    
    internal struct AppFont {
        // developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/CustomTextProcessing/CustomTextProcessing.html#//apple_ref/doc/uid/TP40009542-CH4-SW65
        static let name = Globals.AppFontFamily /* e.g. "Georgia" */
        static let Body = AppFont.FromTextStyle(UIFontTextStyleBody)
        static let Headline = AppFont.FromTextStyle(UIFontTextStyleHeadline)
        static let SubHeadline = AppFont.FromTextStyle(UIFontTextStyleSubheadline)
        static let Callout = AppFont.FromTextStyle(UIFontTextStyleCallout)
        static let Caption1 = AppFont.FromTextStyle(UIFontTextStyleCaption1)
        static let Caption2 = AppFont.FromTextStyle(UIFontTextStyleCaption2)
        static let Footnote = AppFont.FromTextStyle(UIFontTextStyleFootnote)
        static let Title1 = AppFont.FromTextStyle(UIFontTextStyleTitle1)
        static let Title2 = AppFont.FromTextStyle(UIFontTextStyleTitle2)
        static let Title3 = AppFont.FromTextStyle(UIFontTextStyleTitle3)
        
        
        /**
         iOS gives the opportunity to use dynamic font sizes, based on the current preferred font size the user
         has set in the Settings app of iOS. However, this also includes the preferred font (San Francisco in
         iOS 9).
         This function grabs the size and other traits (bold, italic or not) from a given `UIFontTextStyle`,
         and applies them to predefined `UIFont` of choice (defined in `AppFont.name`)
         
         - Parameter style: a font text style such as `UIFontTextStyleFootnote`.
         - Parameter fontSize: a CGFloat which will be set if not nil, otherwise the standard font size of `style` will be used.
         
         - Returns: a predefined `UIFont` which has the size (or not, see `fontSize`) and other characteristics of the dynamic font style defined in `style`
         */
        static func FromTextStyle(style: String, fontSize: CGFloat? = nil) -> UIFont {
            let dynamicFontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(style)
            let dynamicFontPointSize = dynamicFontDescriptor.pointSize
            let dynamicFontIsBold = (dynamicFontDescriptor.symbolicTraits.rawValue & UIFontDescriptorSymbolicTraits.TraitBold.rawValue) > 0
            let dynamicFontIsItalic = (dynamicFontDescriptor.symbolicTraits.rawValue & UIFontDescriptorSymbolicTraits.TraitItalic.rawValue) > 0
            
            var toFontDescriptor = UIFontDescriptor(name: name, size: dynamicFontPointSize)
            if dynamicFontIsBold { toFontDescriptor = toFontDescriptor.fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitBold) }
            if dynamicFontIsItalic { toFontDescriptor = toFontDescriptor.fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitItalic) }
            
            let font = UIFont(descriptor: toFontDescriptor, size: fontSize ?? 0.0)
            
            return font
        }
    }
    
    var isBold: Bool {
        return (fontDescriptor().symbolicTraits.rawValue & UIFontDescriptorSymbolicTraits.TraitBold.rawValue) > 0
    }
    
    var isItalic: Bool {
        return (fontDescriptor().symbolicTraits.rawValue & UIFontDescriptorSymbolicTraits.TraitItalic.rawValue) > 0
    }
    
    var styleAttribute: String? {
        return fontDescriptor().fontAttributes()[UIFontDescriptorTextStyleAttribute] as! String?
    }
}