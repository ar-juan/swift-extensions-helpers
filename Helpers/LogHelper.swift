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
        shortClassName = shortClassName.replacingOccurrences(of: "Manager", with: "Mgr")
        let minLineNumberLength = 6
        let desiredClassNameLength = 25
        
        let ellipsis = "..."
        if shortClassName.count > (desiredClassNameLength) {
            let beg = shortClassName[..<shortClassName.index(shortClassName.startIndex, offsetBy: desiredClassNameLength / 2 - ellipsis.count)]; // swift 4
            //let beg = shortClassName.substring(to: shortClassName.index(shortClassName.startIndex, offsetBy: desiredClassNameLength / 2 - ellipsis.count)) // < swift 4
            //let end = shortClassName.substring(from: shortClassName.index(shortClassName.endIndex, offsetBy: -desiredClassNameLength / 2)) // < swift 4
            let end = shortClassName[shortClassName.index(shortClassName.endIndex, offsetBy: -desiredClassNameLength / 2)...]; // swift 4
            shortClassName = "\(beg)\(ellipsis)\(end)"
        }
        
        var difference = desiredClassNameLength - shortClassName.count
        while difference > 0 {
            shortClassName.append(" " as Character)
            difference -= 1
        }
        
        difference = minLineNumberLength - lineStr.count
        while difference > 0 {
            lineStr.append(" " as Character)
            difference -= 1
        }
        
        return "\(lineStr) \(shortClassName) \(function)"
    }
}
