//
//  WeatherData.swift
//  Weather-App
//
//  Created by Jadson on 25/04/22.
//

import Foundation

struct WeatherData: Codable {
    let current: Current
    let hourly: [Hourly]
}

struct Current: Codable {
    let temp: Double
    let weather: [Weather]
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
}

struct Hourly: Codable {
    let dt: Int
    let temp: Double
    let hWeather: [HWeather]
}
//verificar se posso copiar a struct weather para nao repetir. (verificar se devo usar Class ao inves de struct)
// let HWeather: Weather
struct HWeather: Codable {
    let id: Int
    let main: String
    let description: String
}

struct Daily: Codable {
    let dt: Int
    let temp: [DailyTemp]
    let weather: [DailyWeather]
}

struct DailyTemp: Codable {
    let day: Double
}

struct DailyWeather: Codable {
    let id: Int
    let main: String
    let description: String
}
