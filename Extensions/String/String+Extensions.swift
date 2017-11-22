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
    
    /**
     Concatenates `self` with `path`, ensuring it has one `/` character in between.
     If '/' is missing, '/' is added
     If `self` ends with '/' and `path` starts with '/', only one '/' will be present in the return value.
     */
    func stringByAppendingUrlPath(path: String) -> String {
        var firstPart: String
        var secondPart: String
        
        if self.last == "/" {
            if path.first == "/" {
                firstPart = self
                secondPart = String(path[path.index(after: startIndex)...]) // 1?
                //secondPart = path.substring(from: path.index(after: startIndex)) // path.substring(from: path.startIndex.advancedBy(1))
            } else {
                firstPart = self
                secondPart = path
            }
        } else {
            if path.first == "/" {
                firstPart = self
                secondPart = path
            } else {
                firstPart = self.appending("/")// stringByAppendingString("/")
                secondPart = path
            }
        }
        
        return firstPart.appending(secondPart) //stringByAppendingString(secondPart)
    }
}
