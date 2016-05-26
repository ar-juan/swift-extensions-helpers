//
//  LogHelper.swift
//
//  Created by Arjan van der Laan on 02/02/16.
//

import Foundation

/*global*/ func logthis(msg:String = "", function: String = #function, file: String = #file, line: Int = #line){
    let str = "\(LogHelper.sharedInstance.makeTag(function, file: file, line: line)) \(msg)"
    
    print(str)
    LogHelper.sharedInstance.delegate?.LogHelperLogsString(str)
}

protocol LogHelperDelegate {
    func LogHelperLogsString(string: String)
}

struct LogHelper {
    static var sharedInstance: LogHelper = LogHelper()
    private init() {}
    
    var delegate: LogHelperDelegate?
    
    private func makeTag(function: String, file: String, line: Int) -> String{
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
            difference -= 1
        }
        
        difference = minLineNumberLength - lineStr.characters.count
        while difference > 0 {
            lineStr.append(" " as Character)
            difference -= 1
        }
        
        return "\(lineStr) \(shortClassName) \(function)"
    }
}
