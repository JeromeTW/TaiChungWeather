//
//  AppDelegate.swift
//  TaiChungWeather
//
//  Created by JEROME on 2018/2/1.
//  Copyright © 2018年 jerome. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  private let clearAllRecord = false  // For developing.

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    #if DEBUG // Develop
      if clearAllRecord {
        // Delete all records.
        // Create Fetch Request
        let weatherFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constant.weatherEntityName)
        // Create Batch Delete Request
        let weatherBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: weatherFetchRequest)
        
        // Create Fetch Request
        let dailyQuoteFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constant.dailyQuoteEntityName)
        // Create Batch Delete Request
        let dailyQuoteBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: dailyQuoteFetchRequest)
        
        do {
          try persistentContainer.viewContext.execute(weatherBatchDeleteRequest)
          try persistentContainer.viewContext.execute(dailyQuoteBatchDeleteRequest)
        } catch {
          DLog(error)
        }
      }
    #endif
    // Start to fetch data.
    return true
  }
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    persistentContainer.saveContext()
  }

  // MARK: - Core Data stack
  
  lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: Constant.perisistentContainerName)
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
}

