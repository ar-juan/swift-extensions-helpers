//
//  NSAttributedString+FromHtml.swift
//  Jeeves
//
//  Created by Arjan on 17/05/16.
//  Copyright © 2016 Auxilium. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    class func fromHtml(html: String, font: UIFont) -> NSMutableAttributedString? {
        var html = html
        html += "<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize);}</style>"
        let encodedData = html.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        var attributedString: NSMutableAttributedString? = nil
        do {
            attributedString = try NSMutableAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        } catch let error as NSError {
            logthis("\(error.localizedDescription) (\(error.localizedFailureReason))")
        }
        return attributedString
    }
}