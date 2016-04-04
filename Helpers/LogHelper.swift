//
//  LogHelper.swift
//  App
//
//  Created by Arjan van der Laan on 02/02/16.
//  Copyright © 2016 Auxilium. All rights reserved.
//

import Foundation

/*global*/ func logthis(msg:String = "", function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__){
    print("\(LogHelper.makeTag(function, file: file, line: line)) \(msg)")
}

struct LogHelper {
    private static func makeTag(function: String, file: String, line: Int) -> String{
        var lineStr = "[\(line)]"
        let url = NSURL(fileURLWithPath: file)
        let fileName:String! = url.lastPathComponent == nil ? file : url.lastPathComponent!
        let toArray = fileName.componentsSeparatedByString(".")
        let className = toArray.first ?? ""
        var shortClassName = className.stringByReplacingOccurrencesOfString("ViewController", withString: "VC")
       
        let minLineNumberLength = 6
        let desiredClassNameLength = 25
        
        let ellipsis = "..."
        if shortClassName.characters.count > (desiredClassNameLength) {
            let beg = shortClassName.substringToIndex(shortClassName.startIndex.advancedBy(desiredClassNameLength / 2 - ellipsis.characters.count))
            let end = shortClassName.substringFromIndex(shortClassName.endIndex.advancedBy(-desiredClassNameLength / 2))
            shortClassName = "\(beg)\(ellipsis)\(end)"
        }
        
        var difference = desiredClassNameLength - shortClassName.characters.count
        while difference > 0 {
            shortClassName.append(" " as Character)
            difference--
        }
        
        difference = minLineNumberLength - lineStr.characters.count
        while difference > 0 {
            lineStr.append(" " as Character)
            difference--
        }
        
        return "\(lineStr) \(shortClassName) \(function)"
    }
}
