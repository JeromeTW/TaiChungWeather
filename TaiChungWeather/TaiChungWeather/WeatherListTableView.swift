//
//  WeatherListTableView.swift
//  TaiChungWeather
//
//  Created by JEROME on 2019/9/1.
//  Copyright © 2019 jerome. All rights reserved.
//

import UIKit

class WeatherListTableView: UITableView {
  private var weatherLoader: WeatherLoader!
  private let dailyQuoteLoader = DailyQuoteLoader()
  private var weatherResults = [Weather]()
  private var dailyQuote: DailyQuote!
  
  enum CellIdentifier {
    static let weatherTableViewCell = "WeatherTableViewCell"
    static let dailyQuoteTableViewCell = "DailyQuoteTableViewCell"
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    print("init?(coder aDecoder: NSCoder)")
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    dataSource = self
    delegate = self
    print("awakeFromNib()")
    weatherLoader = WeatherLoader(completionHandler: {
      [weak self] in
      self?.reloadData()
    })
  }
  
  public func fetchWeatherFromInternet() {
    weatherLoader.fetchWeatherFromInternet { [weak self] (_) in
      self?.reloadData()
    }
  }
}

// MARK: - UITableViewDataSource
extension WeatherListTableView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard weatherLoader.isWeatherDataEmpty() == false else {
      return 0
    }
    let newIndexPath = IndexPath(row: 0, section: 0)
    // only get one result.
    let weathers = ((weatherLoader.weatherFRC.object(at: newIndexPath) as! WeekWeather).covertToWeatherResults())!
    return weathers.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = dequeueReusableCell(withIdentifier: CellIdentifier.weatherTableViewCell, for: indexPath) as! WeatherTableViewCell
    return cell
//    let row = indexPath.row
//    switch row {
//    case 0: // Daily quote cell.
//      let cell = dequeueReusableCell(withIdentifier: CellIdentifier.dailyQuoteTableViewCell, for: indexPath) as! DailyQuoteTableViewCell
//      return cell
//    default:
//      let cell = dequeueReusableCell(withIdentifier: CellIdentifier.weatherTableViewCell, for: indexPath) as! WeatherTableViewCell
//      return cell
//    }
  }
}

// MARK: - UITableViewDelegate
extension WeatherListTableView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.backgroundColor = UIColor.clear
    let row = indexPath.row
    if let dailyQuoteTableViewCell = cell as? DailyQuoteTableViewCell {
      guard let quote = dailyQuote else {
        assertionFailure()
        return
      }
      dailyQuoteTableViewCell.dailyQuoteLabel.text = R.string.localizable.dailyQuote()
      dailyQuoteTableViewCell.articleLabel.text = quote.article
      dailyQuoteTableViewCell.authorLabel.text = quote.author
      
      dailyQuoteTableViewCell.dailyQuoteLabel.textColor = Color.darkBlue
      dailyQuoteTableViewCell.articleLabel.textColor = Color.darkOrange
      dailyQuoteTableViewCell.authorLabel.textColor = Color.darkBlue
    } else if let weatherTableViewCell = cell as? WeatherTableViewCell {
      let newIndexPath = IndexPath(row: 0, section: 0)
      // only get one result.
      let weathers = ((weatherLoader.weatherFRC.object(at: newIndexPath) as! WeekWeather).covertToWeatherResults())!
      let weather = weathers[row] // minus 1 for daily quote.
      weatherTableViewCell.dateLabel.text = weather.date.weekDay.getString() + " \(weather.weatherTime.getString())"
      weatherTableViewCell.highestTemperatureLabel.text = String(weather.highestTemperature)
      weatherTableViewCell.lowestTemperatureLabel.text = String(weather.lowestTemperature)
      weatherTableViewCell.weatherLabel.text = weather.description.rawValue
      
      weatherTableViewCell.dateLabel.textColor = Color.darkBlue
      weatherTableViewCell.highestTemperatureLabel.textColor = Color.darkBlue
      weatherTableViewCell.lowestTemperatureLabel.textColor = Color.darkBlue
      weatherTableViewCell.weatherLabel.textColor = Color.darkBlue
    } else {
      assertionFailure()
    }
  }
}
