//
//  String+Extensions.swift
//  Jeeves
//
//  Created by Arjan on 03/05/16.
//  Copyright © 2016 Auxilium. All rights reserved.
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