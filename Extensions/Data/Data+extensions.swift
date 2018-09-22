//
//  Data+extenstions.swift
//  SiteDish
//
//  Created by Arjan van der Laan on 13/12/16.
//  Copyright © 2016 Arjan developing. All rights reserved.
//

import Foundation

extension Data {
    var hexString: String {
        return map { String(format: "%02.2hhx", arguments: [$0]) }.joined()
    }
}
