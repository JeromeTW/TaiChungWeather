/*
	String+Path.swift

	Copyright © 2017 SoftArts Inc. All rights reserved.

	* Description: Extend String path function.

	* Creation Date: 2017/7/13
	* Author: Jerome Hsieh
	* Language: Swift 3/4
	* OS: iOS/watchOS/macOS
	* Source: n/a
	* Reference: n/a
	* Note: n/a

*/

import Foundation

extension String {
	
	/// Get Last Path Component.
	var lastPathComponent: String {
		get {
			return (self as NSString).lastPathComponent
		}
	}
	
	/// Get Path Extension.
	var pathExtension: String {
		get {
			return (self as NSString).pathExtension
		}
	}
	
	/// Delete Last Path Component.
	var stringByDeletingLastPathComponent: String {
		get {
			return (self as NSString).deletingLastPathComponent
		}
	}
	
	/// Delete Path Extension.
	var stringByDeletingPathExtension: String {
		get {
			return (self as NSString).deletingPathExtension
		}
	}
	
	/// Get Path Components.
	var pathComponents: [String] {
		get {
			return (self as NSString).pathComponents
		}
	}
	
	
	/// String by Appending Path Component.
	///
	/// - Parameter path: path.
	/// - Returns: result path.
	func stringByAppendingPathComponent(_ path: String) -> String {
		let nsSt = self as NSString
		return nsSt.appendingPathComponent(path)
	}
	
	/// String by Appending Path Extension.
	///
	/// - Parameter ext: path.
	/// - Returns: result path.
	func stringByAppendingPathExtension(_ ext: String) -> String? {
		let nsSt = self as NSString
		return nsSt.appendingPathExtension(ext)
	}
}
