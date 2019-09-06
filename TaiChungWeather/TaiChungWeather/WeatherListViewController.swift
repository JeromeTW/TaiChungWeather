//
//  WeatherListViewController.swift
//  TaiChungWeather
//
//  Created by JEROME on 2018/2/1.
//  Copyright © 2018年 jerome. All rights reserved.
//

import UIKit

class WeatherListViewController: UIViewController {
  @IBOutlet var weatherListTableView: WeatherListTableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupTableView()
  }

  // MARK: - Navigation Bar

  private func setupNavigationBar() {
    let dateString = Date().weekDay.getString()
    title = R.string.localizable.today() + " \(dateString)"
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Color.darkBlue]
  }

  // MARK: - TableView

  private func setupTableView() {
    guard let backgroundImage = R.image.background() else {
      assertionFailure()
      return
    }

    let tempImageView = UIImageView(image: backgroundImage)
    tempImageView.frame = weatherListTableView.frame
    weatherListTableView.backgroundView = tempImageView
    weatherListTableView.rowHeight = UITableView.automaticDimension
    weatherListTableView.estimatedRowHeight = view.frame.width * 60 / 375
  }
}
