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
  private var dailyQueto: DailyQuetoStruct!
  
  enum CellIdentifier {
    static let weatherTableViewCell = "WeatherTableViewCell"
    static let dailyQuetoTableViewCell = "DailyQuetoTableViewCell"
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
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupTableView()
    tableView.reloadData()
  }

  // MARK: - TableView
  private func setupTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.allowsSelection = true
    tableView.separatorColor = UIColor.clear
  }

  // MARK: - UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Add 1
    return weatherResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = indexPath.row
    switch row {
    case 0: // Daily queto cell.
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.dailyQuetoTableViewCell, for: indexPath) as! DailyQuetoTableViewCell
      return cell
      guard let quote = dailyQueto else {
        assertionFailure()
        return cell
      }
      // TODO:
      cell.dailyQuetoLabel.text = "每日一句："
      cell.articleLabel.text = quote.article
      cell.authorLabel.text = quote.author
      return cell
    default:
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.weatherTableViewCell, for: indexPath) as! WeatherTableViewCell
      let weather = weatherResults[row]
      cell.dateLabel.text = weather.date.localTimeString(format: "MM/dd")
      cell.highestTemperatureLabel.text = String(weather.highestTemperature)
      cell.lowestTemperatureLabel.text = String(weather.lowestTemperature)
      cell.weatherLabel.text = weather.description.rawValue
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return view.frame.width * 75 / 375
  }
  
  // MARK: - UITableViewDelegate
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.backgroundColor = UIColor.clear
  }
}

