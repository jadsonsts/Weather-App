//
//  WeatherManager.swift
//  Weather-App
//
//  Created by Jadson on 25/04/22.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather (_ WeatherManager: WeatherManager, weather: WeatherModel)
    
    func didFailWithError(error: Error)
}


struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/onecall?units=metric"
    let apiKey = "&exclude=minutely,alerts&appid=8a3344af98190e19042af6eb6e51b172"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather (latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)\(apiKey)"
        performWeatherRequest(with: urlString)
    }
    
    func performWeatherRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = parseWeatherJson(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
            
    }
    func parseWeatherJson(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodeData.current.weather[0].id
            let temp = decodeData.current.temp
            let desc = "\(decodeData.current.weather[0].main) | \(decodeData.current.weather[0].description)"
            
            let hourDate = decodeData.hourly[0].dt
            let hourWeatherID = decodeData.hourly[0].weather[0].id
            let hourTemp = decodeData.hourly[0].temp
                        
            let dayDate = decodeData.daily[0].dt
            let dayWeatherID = decodeData.daily[0].weather[0].id
            let dayTemp = decodeData.daily[0].temp.day
                        
            let weather = WeatherModel(conditionId: id, temperature: temp, description: desc, hourDate: hourDate, hourWeatherID: hourWeatherID, hourTemp: hourTemp, dayDate: dayDate, dayWeatherID: dayWeatherID, daytemp: dayTemp)
            
            print(decodeData)
//            print(weather)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
