/*
 Date+LocalTime.swift
 
 Copyright © 2017 SoftArts Inc. All rights reserved.
 
 * Description: Generate localtime string from Date.
 
 * Creation Date: 2017/6/18
 * Author: Kent Liu
 * Language: Swift 3/4
 * OS: iOS/watchOS/macOS
 * Source: n/a
 * Reference: n/a
 * Note: n/a
 
*/


import Foundation

extension Date {
    
    func localTimeString() -> String
    {
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
    func localTimeString(format:String) -> String
    {
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
}
