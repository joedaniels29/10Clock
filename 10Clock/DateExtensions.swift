//
// Created by Joseph Daniels on 04/09/16.
// Copyright (c) 2016 Joseph Daniels. All rights reserved.
//

import Foundation
extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return (Calendar.current as NSCalendar).date(byAdding: components, to: startOfDay, options: NSCalendar.Options())
    }
}
