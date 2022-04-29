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
    

    
    func formatUnixToHour(hour: Double) -> String {
        let newDate = Date(timeIntervalSince1970: hour)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium //Set time style
        dateFormatter.dateStyle = .none
        dateFormatter.dateFormat = "hh"
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: newDate)

        return localDate
    }
    func formatUnixToDate(date: Double) -> String {
                let newDate = Date(timeIntervalSince1970: date)
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .none //Set time style
                dateFormatter.dateStyle = .short
                dateFormatter.dateFormat = "dd"
                dateFormatter.timeZone = .current
                let localDate = dateFormatter.string(from: newDate)

                return localDate
        }
    
    func updateCellHour (hourly: Hourly) {
        let hourDouble = Double(hourly.dt)
        timeLabel.text = "\(formatUnixToDate(date: hourDouble))"
        weatherImage.image = UIImage(systemName: changeIDtoImage(id: hourly.weather[0].id))
        tempLabel.text = "\(hourly.temp)°C"
    }
    
    func updateCellDay (daily: Daily) {
        let dailyDouble = Double(daily.dt)
        timeLabel.text = "\(formatUnixToDate(date: dailyDouble))"
        tempLabel.text = "\(daily.temp.day)°C"
        weatherImage.image = UIImage(systemName: changeIDtoImage(id: daily.weather[0].id))
        

        
    }
    
    func changeIDtoImage (id: Int) -> String {
        switch id {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "snowflake"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud"
        default:
            return "cloud"
        }
    }
}


//UIImage(systemName: weather.conditionName)
