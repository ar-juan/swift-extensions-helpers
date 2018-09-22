//
//  File.swift
//
//  Created by Arjan on 07/03/16.
//

import UIKit

extension Array where Element : ExpressibleByStringLiteral {
    func stringWithLineBreaksFromArray() -> String {
        var localSelf = self
        var result = "\(localSelf.removeFirst())"
        
        for item in self {
            result += "\r\n\(item)"
        }
        
        return result
    }
}
