//
//  WeatherLocationManager.swift
//  Weather-App
//
//  Created by Jadson on 25/04/22.
//

import Foundation
import CoreLocation

typealias onAPILocationSuccess = (WeatherLocationData) -> Void
typealias onAPILocationError = (String) -> Void

struct WeatherLocationManager {
    let weatherURL = "https://api.openweathermap.org/geo/1.0/direct?limit=1&appid=8a3344af98190e19042af6eb6e51b172"
    
    let session = URLSession(configuration: .default)

    func fetchLocation (cityName: String, onSuccess: @escaping onAPILocationSuccess, onError: @escaping onAPILocationError) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        
        if let url = URL(string: urlString) {
            
            let task = session.dataTask(with: url) { data, response, error in
                
                DispatchQueue.main.async {
                    
                    if let error = error {
                        onError(error.localizedDescription)
                        return
                    }
                    guard let data = data else {
                        onError("Invalid Location")
                        return
                    }
                    do {
                        let locationData = try JSONDecoder().decode([WeatherLocationData].self, from: data)
                        debugPrint(locationData)
                        onSuccess(locationData[0])
                    } catch {
                        onError(error.localizedDescription)
                    }

                }
            }
            task.resume()
        }
    }
}
