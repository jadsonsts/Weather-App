//
//  ViewController.swift
//  Weather-App
//
//  Created by Jadson on 24/04/22.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var conditionImgView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    @IBOutlet weak var forecastSegmentControl: UISegmentedControl!
    
    
    var weatherLocationManager = WeatherLocationManager()
    var weatherManager = WeatherManager()
    //var weatherForecast: WeatherModel?
    var weatherForecast: WeatherData?
    var latitudeLongitude: (Double, Double)?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherLocationManager.delegate = self
        forecastCollectionView.delegate = self
        forecastCollectionView.dataSource = self
        
        searchTextField.delegate = self
        getCurrentDay()

    }
    @IBAction func weatherSegmentSelected(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    func getCurrentDay(){
        let today = Date(timeInterval: 0, since: Date())
        let date = DateFormatter()
        date.dateStyle = .long
        date.timeStyle = .none
        date.string(from: today)
        dateLabel.text = date.string(from: today)
    }
    
    func errorMessageShow(error: String) {
        let alert = UIAlertController(title: "Ops", message: "Couldn't get your location: \(error)", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default) { [self] (action) in
            //locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Please type a city name"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            cityLabel.text = city
            weatherLocationManager.fetchLocation(cityName: city)
        }
        
        if let lat = self.latitudeLongitude?.0, let lon = self.latitudeLongitude?.1 {
            self.weatherManager.fetchWeather(latitude: lat, longitude: lon) { weather in
                self.weatherForecast = weather
            } onError: { errorMessage in
                self.errorMessageShow(error: errorMessage)
            }
            
        }

    }
}


//MARK: - WeatherLocationManagerDelegate
extension WeatherViewController: WeatherLocationManagerDelegate {
    func didUpdateLocation(_ WeatherLocationManager: WeatherLocationManager, weatherLocation: WeatherLocationModel) {
        DispatchQueue.main.async {
            self.cityLabel.text = weatherLocation.cityName
            self.latitudeLongitude?.0 = weatherLocation.lat
            self.latitudeLongitude?.1 = weatherLocation.lon
        }
    }
    
    func didFailLocationWithError(error: Error) {
        errorMessageShow(error: "\(error)")
    }
    
    
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon) { weather in
                self.weatherForecast = weather
            } onError: { errorMessage in
                self.errorMessageShow(error: errorMessage)
                debugPrint(errorMessage)
            }

        }
            
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Ops", message: "Couldn't get your location: \(error)", preferredStyle: .alert)
        
        //let action = UIAlertAction(title: "OK", style: .default) // only show the message
        
        //show the message and ask for the location again (maybe)
        let action2 = UIAlertAction(title: "OK", style: .default) { [self] (action) in
            //locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
        
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
}

extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
//    func initForecast(forecast: [WeatherModel]) {
//        weatherForecast = forecast
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let result = weatherForecast {
            if forecastSegmentControl.selectedSegmentIndex == 0 {
                return result.hourly.count
            } else if forecastSegmentControl.selectedSegmentIndex == 1 {
                return result.daily.count
            } else {
                return 0
            }
        }
            return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath) as? DetailsWeatherCollectionViewCell {
            if forecastSegmentControl.selectedSegmentIndex == 0 {
                if let hourForecast = weatherForecast?.hourly[indexPath.row] {
                    cell.updateCellHour(hourly: hourForecast)
                }
            } else if forecastSegmentControl.selectedSegmentIndex == 1 {
                if let dayForecast = weatherForecast?.daily[indexPath.row] {
                    cell.updateCellDay(daily: dayForecast)
                }
            }

            return cell
        }
        return DetailsWeatherCollectionViewCell()
    }
    
    
}


