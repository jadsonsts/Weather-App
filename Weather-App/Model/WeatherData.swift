//
//  WeatherData.swift
//  Weather-App
//
//  Created by Jadson on 25/04/22.
//

import Foundation

struct WeatherData: Codable {
    let current: Current
    var hourly: [Hourly]
    var daily: [Daily]
}

struct Current: Codable {
    var temp: Double
    var weather: [Weather]
}

struct Weather: Codable {
    var id: Int
    var main: String
    var description: String
}

struct Hourly: Codable {
    var dt: Int
    var temp: Double
    var weather: [Weather]
}

struct Daily: Codable {
    var dt: Int
    var temp: Temp
    var weather: [Weather]
}

struct Temp: Codable {
    var day: Double
}


//verificar se posso copiar a struct weather para nao repetir. (verificar se devo usar Class ao inves de struct)
// let HWeather: Weather

//struct HWeather: Codable {
//    let id: Int
//    let main: String
//    let description: String
//}


//struct DailyWeather: Codable {
//    let id: Int
//    let main: String
//    let description: String
//}
