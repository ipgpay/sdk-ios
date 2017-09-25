//
//  Date.swift
//  IPG
//
//  Created by AirS CC on 06/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation

extension Date {
  static func from(_ year: Int, _ month: Int, _ day: Int) -> Date
  {
    let calendar = Calendar.current
    
    var dateComponents = DateComponents( )
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.hour = 0
    dateComponents.minute = 0

    let date = calendar.date(from: dateComponents)!
    return date
  }
  
  static func addMonth(_ value: Int, to date: Date) -> Date {
    let calendar = Calendar.current
    
    let date = calendar.date(byAdding: .month, value: value, to: date)!
    return date
  }
  
  static func parse(_ string: String, format: String = "yyyy-MM-dd") -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    
    let date = dateFormatter.date(from: string)
    return date
  }
  
  static func current() -> Date {
    let date = Date()
    
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    
    return from(year, month, day)
    
  }
  
  static func currentDay() -> Int {
    let date = Date()
    let calendar = Calendar.current
    
    let day = calendar.component(.day, from: date)
    return day
  }
  
  static func timezoneOffset() -> Int {
    return -TimeZone.current.secondsFromGMT() / 60
  }
  
}
