//
//  DetailsWeatherCollectionViewCell.swift
//  Weather-App
//
//  Created by Jadson on 25/04/22.
//

import UIKit

class DetailsWeatherCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    func updateCell(weather: WeatherModel) {
        timeLabel.text = "7am"
        weatherImage.image = UIImage(systemName: weather.conditionDayName)
        tempLabel.text = "\(weather.daytemp)°C"
    }
}
