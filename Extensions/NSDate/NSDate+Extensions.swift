//
//  NSDate+Extensions.swift
//  Jeeves
//
//  Created by Arjan on 20/05/16.
//  Copyright © 2016 Auxilium. All rights reserved.
//

import Foundation

extension NSDate {
    var isToday: Bool {
        return (NSCalendar.currentCalendar().compareDate(self, toDate: NSDate(), toUnitGranularity: NSCalendarUnit.Day) == .OrderedSame)
    }
}