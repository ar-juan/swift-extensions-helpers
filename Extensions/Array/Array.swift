//
//  File.swift
//  PwcReportingApp
//
//  Created by Arjan on 07/03/16.
//  Copyright © 2016 Auxilium. All rights reserved.
//

import UIKit

extension Array where Element : StringLiteralConvertible {
    func stringWithLineBreaksFromArray() -> String {
        var localSelf = self
        var result = "\(localSelf.removeFirst())"
        
        for item in self {
            result += "\r\n\(item)"
        }
        
        return result
    }
}
