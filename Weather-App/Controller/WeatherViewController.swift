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
    
    var weatherLocationManager = WeatherLocationManager()
    var weatherManager = WeatherManager()
    var latitudeLongitude: (Double, Double)?
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherLocationManager.delegate = self
        weatherManager.delegate = self
        
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
            weatherLocationManager.fetchLocation(cityName: city)
        }
        
        if let lat = self.latitudeLongitude?.0, let lon = self.latitudeLongitude?.1 {
            self.weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }

    }
}

//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ WeatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImgView.image = UIImage(systemName: weather.conditionName)
            self.conditionLabel.text = weather.description
        }
    }
    
    func didFailWithError(error: Error) {
        debugPrint(error) //change
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
        debugPrint(error) //change
    }
    
    
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
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


