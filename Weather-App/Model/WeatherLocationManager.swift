//
//  WeatherLocationManager.swift
//  Weather-App
//
//  Created by Jadson on 25/04/22.
//

import Foundation
import CoreLocation

protocol WeatherLocationManagerDelegate {
    func didUpdateLocation (_ WeatherLocationManager: WeatherLocationManager, weatherLocation: WeatherLocationModel)
    
    func didFailWithError(error: Error)
}

struct WeatherLocationManager {
    let weatherURL = "http://api.openweathermap.org/geo/1.0/direct?limit=1&appid=8a3344af98190e19042af6eb6e51b172" //q=London
    
    var delegate: WeatherLocationManagerDelegate

    func fetchLocation (cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = parseJSON(safeData){
                        delegate.didUpdateLocation(self, weatherLocation: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherLocationData: Data) -> WeatherLocationModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherLocationData.self, from: weatherLocationData)
            let name = decodedData.name
            let latitude = decodedData.lat
            let longitude = decodedData.lon
                        
            let weatherLocation = WeatherLocationModel(name: name, lat: latitude, lon: longitude)
            
            return weatherLocation
        } catch {
            delegate.didFailWithError(error: error)
            return nil
        }
    }
}