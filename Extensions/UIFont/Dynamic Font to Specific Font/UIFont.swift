//
//  UIFont.swift
//
//  Created by Arjan van der Laan on 02/02/16.
//

import UIKit

extension UIFont {
    static func IsKnownTextStyle(_ style: String?) -> Bool {
        guard style != nil else {
            return false
        }
        
        var knownTextStyles: [String] =
        [UIFontTextStyle.body.rawValue,
            UIFontTextStyle.headline.rawValue,
            UIFontTextStyle.subheadline.rawValue,
            UIFontTextStyle.caption1.rawValue,
            UIFontTextStyle.caption2.rawValue,
            UIFontTextStyle.footnote.rawValue]
        
        if #available(iOS 9.0, *) {
            let addition: [String] = [UIFontTextStyle.callout.rawValue,
                                      UIFontTextStyle.title1.rawValue,
                                      UIFontTextStyle.title2.rawValue,
                                      UIFontTextStyle.title3.rawValue]
            knownTextStyles += addition
        }
        
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
        static let Body = AppFont.FromTextStyle(UIFontTextStyle.body.rawValue)
        static let Headline = AppFont.FromTextStyle(UIFontTextStyle.headline.rawValue)
        static let SubHeadline = AppFont.FromTextStyle(UIFontTextStyle.subheadline.rawValue)
        static let Caption1 = AppFont.FromTextStyle(UIFontTextStyle.caption1.rawValue)
        static let Caption2 = AppFont.FromTextStyle(UIFontTextStyle.caption2.rawValue)
        static let Footnote = AppFont.FromTextStyle(UIFontTextStyle.footnote.rawValue)
        
        @available(iOS 9.0, *)static let Callout = AppFont.FromTextStyle(UIFontTextStyle.callout.rawValue)
        @available(iOS 9.0, *) static let Title1 = AppFont.FromTextStyle(UIFontTextStyle.title1.rawValue)
        @available(iOS 9.0, *) static let Title2 = AppFont.FromTextStyle(UIFontTextStyle.title2.rawValue)
        @available(iOS 9.0, *) static let Title3 = AppFont.FromTextStyle(UIFontTextStyle.title3.rawValue)
        
        
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
        static func FromTextStyle(_ style: String, fontSize: CGFloat? = nil) -> UIFont {
            let dynamicFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle(rawValue: style))
            let dynamicFontPointSize = dynamicFontDescriptor.pointSize
            let dynamicFontIsBold = (dynamicFontDescriptor.symbolicTraits.rawValue & UIFontDescriptorSymbolicTraits.traitBold.rawValue) > 0
            let dynamicFontIsItalic = (dynamicFontDescriptor.symbolicTraits.rawValue & UIFontDescriptorSymbolicTraits.traitItalic.rawValue) > 0
            
            var toFontDescriptor = UIFontDescriptor(name: name, size: dynamicFontPointSize)
            if dynamicFontIsBold { toFontDescriptor = toFontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)! }
            if dynamicFontIsItalic { toFontDescriptor = toFontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitItalic)! }
            
            let font = UIFont(descriptor: toFontDescriptor, size: fontSize ?? 0.0)
            
            return font
        }
    }
    
    var isBold: Bool {
        return (fontDescriptor.symbolicTraits.rawValue & UIFontDescriptorSymbolicTraits.traitBold.rawValue) > 0
    }
    
    var isItalic: Bool {
        return (fontDescriptor.symbolicTraits.rawValue & UIFontDescriptorSymbolicTraits.traitItalic.rawValue) > 0
    }
    
    var styleAttribute: String? {
        return fontDescriptor.fontAttributes[UIFontDescriptorTextStyleAttribute] as! String?
    }
}
