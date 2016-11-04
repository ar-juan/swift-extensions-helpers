//
//  LogHelper.swift
//
//  Created by Arjan van der Laan on 02/02/16.
//

import Foundation

/*global*/ func logthis(_ msg:String = "", function: String = #function, file: String = #file, line: Int = #line){
    let str = "\(LogHelper.sharedInstance.makeTag(function, file: file, line: line)) \(msg)"
    
    print(str)
    LogHelper.sharedInstance.delegate?.LogHelperLogsString(str)
}

protocol LogHelperDelegate {
    func LogHelperLogsString(_ string: String)
}

struct LogHelper {
    static var sharedInstance: LogHelper = LogHelper()
    fileprivate init() {}
    
    var delegate: LogHelperDelegate?
    
    fileprivate func makeTag(_ function: String, file: String, line: Int) -> String{
        var lineStr = "[\(line)]"
        let url = URL(fileURLWithPath: file)
        let fileName:String! = url.lastPathComponent.isEmpty ? file : url.lastPathComponent
        let toArray = fileName.components(separatedBy: ".")
        let className = toArray.first ?? ""
        var shortClassName = className.replacingOccurrences(of: "ViewController", with: "VC")
       
        let minLineNumberLength = 6
        let desiredClassNameLength = 25
        
        let ellipsis = "..."
        if shortClassName.characters.count > (desiredClassNameLength) {
            let beg = shortClassName.substring(to: shortClassName.characters.index(shortClassName.startIndex, offsetBy: desiredClassNameLength / 2 - ellipsis.characters.count))
            let end = shortClassName.substring(from: shortClassName.characters.index(shortClassName.endIndex, offsetBy: -desiredClassNameLength / 2))
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
