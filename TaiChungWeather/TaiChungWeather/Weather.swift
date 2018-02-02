//
//  WeekWeather.swift
//  TaiChungWeather
//
//  Created by JEROME on 2018/2/2.
//  Copyright © 2018年 jerome. All rights reserved.
//
//  Managed object class for the WeekWeather entity.

import CoreData

class Weather: NSManagedObject {
  // MARK: Properties
  //
  @NSManaged var content: String
  @NSManaged var time: Date
  
  // MARK: Convenience Methods
  //
  func update(with weatherDictionary: [String: AnyObject]) throws {
    /*
    // Only update the quake if all the relevant properties can be accessed.
    //
    guard let properties = weatherDictionary["properties"] as? [String: AnyObject],
      let newCode = properties["code"] as? String,
      let newMagnitude = properties["mag"] as? Float,
      let newPlaceName = properties["place"] as? String,
      let newDetailURL = properties["detail"] as? String,
      let newTime = properties["time"] as? Double,
      let geometry = weatherDictionary["geometry"] as? [String: AnyObject],
      let coordinates = geometry["coordinates"] as? [Float] else {
        
        let localizedDescription = NSLocalizedString("Could not interpret data from the earthquakes server.", comment: "")
        
        throw NSError(domain: EarthQuakesErrorDomain, code: 999, userInfo: [
          NSLocalizedDescriptionKey: localizedDescription])
    }
    
    code = newCode
    magnitude = newMagnitude
    placeName = newPlaceName
    detailURL = newDetailURL
    time = Date(timeIntervalSince1970: newTime / 1000.0)
    
    longitude = coordinates[0]
    latitude = coordinates[1]
    depth = coordinates[2]
 */
  }
}
