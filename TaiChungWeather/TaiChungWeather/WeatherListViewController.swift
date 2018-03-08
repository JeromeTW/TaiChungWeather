//
//  WeatherListViewController.swift
//  TaiChungWeather
//
//  Created by JEROME on 2018/2/1.
//  Copyright © 2018年 jerome. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh
import CoreData
import KRProgressHUD


class WeatherListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NetworkControllerDelegate, NSFetchedResultsControllerDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  private var weatherResults = [Weather]()
  private var dailyQuote: DailyQuote!
  private let networkController = NetworkController.shared
    private var weatherFRC: NSFetchedResultsController<NSFetchRequestResult>!
  enum CellIdentifier {
    static let weatherTableViewCell = "WeatherTableViewCell"
    static let dailyQuoteTableViewCell = "DailyQuoteTableViewCell"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    networkController.didQueryDailyQuoteHandler = {
      [weak self] error in
        self?.fetchDataDailyQuote()
        self?.tableView.reloadData()
    }
    NetworkController.shared.addDelegate(self)
    let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let coreDataConnect = CoreDataConnect(context: myContext)
    weatherFRC = coreDataConnect.getFRC(Constant.weatherEntityName, predicate: nil, sort: [[Constant.timeKey: false]], limit: 1)
    weatherFRC.delegate = self
    setupNavigationBar()
    fetchDataDailyQuote()
    setupTableView()
  }

  deinit {
    if let _ = tableView {
      tableView.dg_removePullToRefresh()
    }
    NetworkController.shared.removeDelegate(self)
  }
  
  private func queryNewDataFromInternet() {
    guard currentReachabilityStatus != .notReachable else {
      tableView.dg_stopLoading()
      // Show alert.
      showOKAlert(LocStr(.internetNotReachable), message: nil, okTitle: LocStr(.ok))
      return
    }
    guard networkController.isQueryDailyQuoteFinished && networkController.isQueryWeatherFinished else {
      return
    }
    networkController.requestDailyQuoteData()
    NetworkController.shared.addDelegate(self)
    networkController.requestWeatherData()
  }
  
  // MARK: - Navigation Bar
  private func setupNavigationBar() {
    let dateString = Date().weekDay.getString()
    title = LocStr(.today) + " \(dateString)"
    navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Color.darkBlue]
  }
  
  private func fetchDataDailyQuote() {
    let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let coreDataConnect = CoreDataConnect(context: myContext)
    
    if let results = coreDataConnect.retrieveDailyQuoteResults(predicate: nil, sort: [[Constant.timeKey: false]], limit: 1) {
      guard results.count == 1 else {
        // First time launch the app without history record.
        KRProgressHUD.appearance().style = .black
        KRProgressHUD.set(deadlineTime: 999999.9)
        KRProgressHUD.showInfo(withMessage: LocStr(.loading))
        return
      }
      dailyQuote = results[0]
    }
  }
  
  // MARK: - TableView
  private func setupTableView() {
    guard let backgroundImage = GetImage(name: .background) else {
      assertionFailure()
      return
    }
    
    let tempImageView = UIImageView(image: backgroundImage)
    tempImageView.frame = tableView.frame
    tableView.backgroundView = tempImageView
    tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = view.frame.width * 60 / 375
    tableView.delegate = self
    
    let loadingView = DGElasticPullToRefreshLoadingViewCircle()
    loadingView.tintColor = UIColor.white
    tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
      self?.queryNewDataFromInternet()
      }, loadingView: loadingView)
    tableView.dg_setPullToRefreshFillColor(Color.orange)
    tableView.dg_setPullToRefreshBackgroundColor(Color.lightTiffanyBlue)
    tableView.dataSource = self
  }

  // MARK: - UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard dailyQuote != nil else {
        return 0
    }
    // Add 1 for daily quote.
    guard weatherFRC.sections?.first?.objects?.count != 0 else {
        return 1
    }
    KRProgressHUD.dismiss()
    tableView.dg_stopLoading()
    let newIndexPath = IndexPath(row: 0, section: 0)
    // only get one result.
    let weathers = ((weatherFRC.object(at: newIndexPath) as! WeekWeather).covertToWeatherResults())!
    return weathers.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = indexPath.row
    switch row {
    case 0: // Daily quote cell.
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.dailyQuoteTableViewCell, for: indexPath) as! DailyQuoteTableViewCell
      guard let quote = dailyQuote else {
        assertionFailure()
        return cell
      }
      cell.dailyQuoteLabel.text = LocStr(.dailyQuote)
      cell.articleLabel.text = quote.article
      cell.authorLabel.text = quote.author
      
      cell.dailyQuoteLabel.textColor = Color.darkBlue
      cell.articleLabel.textColor = Color.darkOrange
      cell.authorLabel.textColor = Color.darkBlue
  
      return cell
    default:
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.weatherTableViewCell, for: indexPath) as! WeatherTableViewCell
        let newIndexPath = IndexPath(row: 0, section: 0)
        // only get one result.
        let weathers = ((weatherFRC.object(at: newIndexPath) as! WeekWeather).covertToWeatherResults())!
        let weather = weathers[row - 1] // minus 1 for daily quote.
        cell.dateLabel.text = weather.date.weekDay.getString() + " \(weather.weatherTime.getString())"
        cell.highestTemperatureLabel.text = String(weather.highestTemperature)
        cell.lowestTemperatureLabel.text = String(weather.lowestTemperature)
        cell.weatherLabel.text = weather.description.rawValue
        
        cell.dateLabel.textColor = Color.darkBlue
        cell.highestTemperatureLabel.textColor = Color.darkBlue
        cell.lowestTemperatureLabel.textColor = Color.darkBlue
        cell.weatherLabel.textColor = Color.darkBlue
        return cell
    }
  }
  
  // MARK: - UITableViewDelegate
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.backgroundColor = UIColor.clear
  }
    
  // MARK: - NetworkControllerDelegate
    func completedNetworkRequest(_ requestClassName: String, response: Data?, error: NSError?) {
        NetworkController.shared.removeDelegate(self)
        if requestClassName == "WeatherNetworkRequest" {
            if error != nil {
                // TODO: Show Network Error.
                return
            }
            // Write Data in coredata.
            guard let data = response else {
                assertionFailure()  // Should not be here.
                return
            }
            guard let string = String(data: data, encoding: .utf8) else {
                // TODO: Show invalidDecoding Error.
                return
            }
            DispatchQueue.main.async {
                let parserManager = ParserManager.shared
                let success = parserManager.parseWeatherXML(xmlString: string)
                DLog("success:\(success)")
                if !success {
                    // TODO: Show parse Error.
                }
            }
        }
    }
    
    // Mark: NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == weatherFRC {
            tableView.reloadData()
        }
    }
}

