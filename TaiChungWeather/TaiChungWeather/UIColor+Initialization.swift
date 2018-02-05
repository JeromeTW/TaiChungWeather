/*
 UIColor+Initialization.swift
 
 Copyright © 2017 SoftArts Inc. All rights reserved.
 
 * Description: Check String's format.
 
 * Creation Date: 2017/7/13
 * Author: Jerome Hsieh
 * Language: Swift 3/4
 * OS: iOS/watchOS/macOS
 * Source: n/a
 * Reference: n/a
 * Note: n/a
 
 */

import UIKit

extension UIColor {
  
  /// Init Color by UInt. e.g. UIColor(0x209624)
  ///
  /// - Parameter rgbValue: rgbValue
  convenience init(_ rgbValue: UInt) {
    self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255, blue: CGFloat(rgbValue & 0x0000FF) / 255, alpha: 1.0)
  }
  
  
  /// Init Color by Red Int, Green Int And Blue Int. e.g. (123, 255, 0)
  ///
  /// - Parameters:
  ///   - redInt: red int.
  ///   - greenInt: green int.
  ///   - blueInt: blue int.
  ///   - alpha: default value is 1.
  convenience init(redInt: Int, greenInt: Int, blueInt: Int, alpha: CGFloat = 1) {
    self.init(red: CGFloat(redInt) / 255, green: CGFloat(greenInt) / 255, blue: CGFloat(blueInt) / 255, alpha: alpha)
  }
  
  
  /// Init Color by hexString.
  ///
  /// - Parameter hexString: hex string.
  convenience init(hexString:String) {
    let hexString:NSString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
    let scanner            = Scanner(string: hexString as String)
    
    if (hexString.hasPrefix("#")) {
      scanner.scanLocation = 1
    }
    
    var color:UInt32 = 0
    scanner.scanHexInt32(&color)
    
    let mask = 0x000000FF
    let r = Int(color >> 16) & mask
    let g = Int(color >> 8) & mask
    let b = Int(color) & mask
    
    let red   = CGFloat(r) / 255.0
    let green = CGFloat(g) / 255.0
    let blue  = CGFloat(b) / 255.0
    
    self.init(red:red, green:green, blue:blue, alpha:1)
  }
  
  /// Get UIColor's RGB.
  ///
  /// - Returns: tuple (red, green, blue, alpha)
  private func rgb() -> (red:Int, green:Int, blue:Int, alpha:Int)? {
    var fRed : CGFloat = 0
    var fGreen : CGFloat = 0
    var fBlue : CGFloat = 0
    var fAlpha: CGFloat = 0
    if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
      let iRed = Int(fRed * 255.0)
      let iGreen = Int(fGreen * 255.0)
      let iBlue = Int(fBlue * 255.0)
      let iAlpha = Int(fAlpha * 255.0)
      
      return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
    } else {
      // Could not extract RGBA components:
      return nil
    }
  }
  
  /// Get UIColor's Hex String.
  ///
  /// - Returns: hex string.
  private func toHexString() -> String {
    var r:CGFloat = 0
    var g:CGFloat = 0
    var b:CGFloat = 0
    var a:CGFloat = 0
    
    getRed(&r, green: &g, blue: &b, alpha: &a)
    
    let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
    
    return NSString(format:"#%06x", rgb) as String
  }
}

