//
//  String+Extensions.swift
//
//  Created by Arjan on 03/05/16.
//

import Foundation

extension String {
    static func isNilOrEmpty(string: String?) -> Bool {
        if let string = string {
            return string.isEmpty
        } else {
            return true
        }
    }
}