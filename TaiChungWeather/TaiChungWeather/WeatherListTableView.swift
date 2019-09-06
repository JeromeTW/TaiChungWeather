//
//  WeatherListTableView.swift
//  TaiChungWeather
//
//  Created by JEROME on 2019/9/1.
//  Copyright © 2019 jerome. All rights reserved.
//

import DGElasticPullToRefresh
import UIKit

class WeatherListTableView: UITableView {
  private var weatherLoader: WeatherLoader!
  private var dailyQuoteLoader: DailyQuoteLoader!

  enum CellIdentifier {
    static let weatherTableViewCell = "WeatherTableViewCell"
    static let dailyQuoteTableViewCell = "DailyQuoteTableViewCell"
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    print("init?(coder aDecoder: NSCoder)")
  }

  deinit {
    dg_removePullToRefresh()
    printLog("✅ \(self.className) deinit", level: .info)
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    dataSource = self
    delegate = self
    print("awakeFromNib()")
    weatherLoader = WeatherLoader(dataFromInternetSuccessHandler: {
      [weak self] in
      self?.reloadData()
    }) { // dataFromInternetFailedHandler
      [weak self] in
      self?.reloadData()
    }
    weatherLoader.fetchWeatherFromInternet()
    dailyQuoteLoader = DailyQuoteLoader(dataFromInternetSuccessHandler: {
      [weak self] in
      self?.reloadData()
    }) { // dataFromInternetFailedHandler
      [weak self] in
      self?.reloadData()
    }
    dailyQuoteLoader.fetchFromInternet()
    setUpDGElasticPullToRefresh()
  }

  private func setUpDGElasticPullToRefresh() {
    let loadingView = DGElasticPullToRefreshLoadingViewCircle()
    loadingView.tintColor = UIColor.white
    dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
      self?.weatherLoader.fetchWeatherFromInternet()
      self?.dailyQuoteLoader.fetchFromInternet()
    }, loadingView: loadingView)
    dg_setPullToRefreshFillColor(Color.orange)
    dg_setPullToRefreshBackgroundColor(Color.lightTiffanyBlue)
  }
}

// MARK: - UITableViewDataSource

extension WeatherListTableView: UITableViewDataSource {
  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    var count = 0
    if dailyQuoteLoader.isDailyQuoteDataEmpty() == false {
      count += 1
    }
    if weatherLoader.isWeatherDataEmpty() == false {
      let weathers = (weatherLoader.weatherFRC.fetchedObjects!.first! as! WeekWeather).covertToWeatherResults()!
      count += weathers.count
    }
    if dailyQuoteLoader.isDailyQuoteDataEmpty() == false, weatherLoader.isWeatherDataEmpty() == false {
      dg_stopLoading()
    }
    return count
  }

  func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = indexPath.row
    if dailyQuoteLoader.isDailyQuoteDataEmpty() == false, row == 0 {
      let cell = dequeueReusableCell(withIdentifier: CellIdentifier.dailyQuoteTableViewCell, for: indexPath) as! DailyQuoteTableViewCell
      return cell
    } else {
      let cell = dequeueReusableCell(withIdentifier: CellIdentifier.weatherTableViewCell, for: indexPath) as! WeatherTableViewCell
      return cell
    }
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
  func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.backgroundColor = UIColor.clear
    let row = indexPath.row
    if let dailyQuoteTableViewCell = cell as? DailyQuoteTableViewCell {
      guard let quote = dailyQuoteLoader.dailyQuote else {
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
      let weathers = (weatherLoader.weatherFRC.fetchedObjects!.first! as! WeekWeather).covertToWeatherResults()!
      var weather: Weather!
      if dailyQuoteLoader.isDailyQuoteDataEmpty() == false {
        weather = weathers[row - 1] // minus 1 for daily quote.
      } else {
        weather = weathers[row]
      }
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
