//
//  WeatherListViewController.swift
//  TaiChungWeather
//
//  Created by JEROME on 2018/2/1.
//  Copyright © 2018年 jerome. All rights reserved.
//

import UIKit

class WeatherListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  private var weatherResults = [Weather]()
  private var dailyQuote: DailyQuote!
  
  enum CellIdentifier {
    static let weatherTableViewCell = "WeatherTableViewCell"
    static let dailyQuoteTableViewCell = "DailyQuoteTableViewCell"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let coreDataConnect = CoreDataConnect(context: myContext)
    
    // Fetch the lastest weather forecast.
    if let results = coreDataConnect.retrieveWeekWeatherResults(predicate: nil, sort: [[Constant.timeKey: false]], limit: 1) {
      guard results.count == 1 else {
        assertionFailure()
        return
      }
      guard let tempWeatherResults = results[0].covertToWeatherResults() else {
        assertionFailure()
        return
      }
      weatherResults = tempWeatherResults
    }
    
    if let results = coreDataConnect.retrieveDailyQuoteResults(predicate: nil, sort: [[Constant.timeKey: false]], limit: 1) {
      guard results.count == 1 else {
        assertionFailure()
        return
      }
      dailyQuote = results[0]
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupTableView()
    tableView.reloadData()
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
    tableView.dataSource = self
    tableView.delegate = self
  }

  // MARK: - UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Add 1
    return weatherResults.count
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
      return cell
    default:
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.weatherTableViewCell, for: indexPath) as! WeatherTableViewCell
      let weather = weatherResults[row]
      cell.dateLabel.text = weather.date.localTimeString(format: "MM/dd") + " \(weather.weatherTime.getString())"
      cell.highestTemperatureLabel.text = String(weather.highestTemperature)
      cell.lowestTemperatureLabel.text = String(weather.lowestTemperature)
      cell.weatherLabel.text = weather.description.rawValue
      return cell
    }
  }
  
  // MARK: - UITableViewDelegate
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.backgroundColor = UIColor.clear
  }
}

