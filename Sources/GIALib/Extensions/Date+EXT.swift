//
//  File.swift
//  
//
//  Created by admin on 13.03.2024.
//

import Foundation

extension Date {
    public var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    public init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    public var selectedDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self)
    }
    
    public var selectedTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    
    public var tfHour: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter.string(from: self)
    }
    public var tfMinute: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter.string(from: self)
    }
    
    public var selectedDateTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm dd.MM.yyyy"
        return formatter.string(from: self)
    }
    
    public var datePickerFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = String(localized: "HH:mm, MMM d")
        return formatter.string(from: self)
    }
}
