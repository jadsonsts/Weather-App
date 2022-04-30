//
//  WeatherManager.swift
//  Weather-App
//
//  Created by Jadson on 25/04/22.
//

import Foundation
import CoreLocation

typealias onAPISuccess = (WeatherData) -> Void
typealias onAPIError = (String) -> Void


class WeatherManager {
    //static let shared = WeatherManager()
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/onecall?units=metric"
    let apiKey = "&exclude=minutely,alerts&appid=8a3344af98190e19042af6eb6e51b172"
    
    let session = URLSession(configuration: .default)
    
    func fetchWeather (latitude: CLLocationDegrees, longitude: CLLocationDegrees, onSuccess: @escaping onAPISuccess, onError: @escaping onAPIError) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)\(apiKey)"
        
        if let url = URL(string: urlString) {
            
            let task = session.dataTask(with: url) { data, response, error in
                
                DispatchQueue.main.async {
                    
                    if let error = error {
                        onError(error.localizedDescription)
                        return
                    }
                    guard let data = data else {
                        onError("Invalid data")
                        return
                    }
                    do {
                        let items = try JSONDecoder().decode(WeatherData.self, from: data)
                        onSuccess(items)
                    } catch {
                        onError(error.localizedDescription)
                    }
                }
            }
            task.resume()
        }
        
    }
    
    public func resolveNameLocation (with location: CLLocation, completion: @escaping((String?) -> Void)) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: .current ) { placemarks, error in
            guard let place = placemarks?.first, error == nil else {
                completion(nil)
                return
            }
            var cityName = ""
            if let locality = place.locality {
                cityName += locality
            }
            
            completion(cityName)
        }
    }
    
}
