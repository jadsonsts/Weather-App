//
//  WeatherManager.swift
//  Weather-App
//
//  Created by Jadson on 25/04/22.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateLocation (_ WeatherManager: WeatherManager, weatherLocation: WeatherModel)
    
    func didFailWithError(error: Error)
}


struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/onecall?units=metric   [&lat={lat}&lon={lon}]"
    let apiKey = "&exclude=minutely,alerts&appid=8a3344af98190e19042af6eb6e51b172"
}
