//
//  NSAttributedString+FromHtml.swift
//
//  Created by Arjan on 17/05/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    class func fromHtml(_ html: String, font: UIFont) -> NSMutableAttributedString? {
        var html = html
        html += "<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize);}</style>"
        let encodedData = html.data(using: String.Encoding.utf8)!
        let attributedOptions : [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        var attributedString: NSMutableAttributedString? = nil
        do {
            attributedString = try NSMutableAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        } catch let error as NSError {
            logthis("\(error.localizedDescription) (\(String(describing: error.localizedFailureReason)))")
        }
        return attributedString
    }
}
