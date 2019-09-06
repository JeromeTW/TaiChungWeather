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
  private let clearAllRecord = true  // For developing.
  lazy var logTextView: LogTextView = {
    let logTextView = LogTextView(frame: .zero)
    logTextView.layer.zPosition = .greatestFiniteMagnitude
    return logTextView
  }()

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
          printLog(error.localizedDescription, level: .error)
        }
      }
    #endif
    setupLogConfigure()
    setupLogTextView()
    return true
  }
  
  private func setupLogConfigure() {
    LogLevelConfigurator.shared.configure([.error, .warning, .debug, .info], shouldShow: true, shouldCache: true)
  }
  
  private func setupLogTextView() {
    #if DEBUG
    guard let window = window else { return }
    
    if #available(iOS 11.0, *) {
      window.addSubview(logTextView, constraints: [
        UIView.anchorConstraintEqual(from: \UIView.topAnchor, to: \UIView.safeAreaLayoutGuide.topAnchor, constant: .defaultMargin),
        UIView.anchorConstraintEqual(from: \UIView.leadingAnchor, to: \UIView.safeAreaLayoutGuide.leadingAnchor, constant: .defaultMargin),
        UIView.anchorConstraintEqual(from: \UIView.bottomAnchor, to: \UIView.safeAreaLayoutGuide.bottomAnchor, constant: CGFloat.defaultMargin.negativeValue),
        UIView.anchorConstraintEqual(from: \UIView.trailingAnchor, to: \UIView.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat.defaultMargin.negativeValue)
        ])
    } else {
      window.addSubview(logTextView, constraints: [
        UIView.anchorConstraintEqual(with: \UIView.topAnchor, constant: .defaultMargin),
        UIView.anchorConstraintEqual(with: \UIView.leadingAnchor, constant: .defaultMargin),
        UIView.anchorConstraintEqual(with: \UIView.bottomAnchor, constant: CGFloat.defaultMargin.negativeValue),
        UIView.anchorConstraintEqual(with: \UIView.trailingAnchor, constant: CGFloat.defaultMargin.negativeValue)
        ])
    }
    #endif
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
  
  lazy var viewContext: NSManagedObjectContext = {
    return persistentContainer.viewContext
  }()
}

