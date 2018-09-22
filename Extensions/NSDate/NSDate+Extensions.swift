//
//  NSDate+Extensions.swift
//
//  Created by Arjan on 20/05/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension Date {
    var isToday: Bool {
        return ((Calendar.current as NSCalendar).compare(self, to: Date(), toUnitGranularity: NSCalendar.Unit.day) == .orderedSame)
    }
}

extension NSDate {
    var isToday: Bool {
        return ((Calendar.current as NSCalendar).compare(self as Date, to: Date(), toUnitGranularity: NSCalendar.Unit.day) == .orderedSame)
    }
}

