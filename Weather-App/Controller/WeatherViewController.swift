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
    var weatherForecast: WeatherData?
    var latitudeLongitude: (Double, Double)?
    let locationManager = CLLocationManager()
    var location = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        forecastCollectionView.delegate = self
        forecastCollectionView.dataSource = self
        forecastCollectionView.layer.cornerRadius = 10
               
        searchTextField.delegate = self
        getCurrentDay()
        
    }
     
    @IBAction func forecastSegmentControlChanged(_ sender: UISegmentedControl) {
        forecastCollectionView.reloadData()
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
        searchTextField.text = ""
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
    
    func setLabels(with weather: WeatherData){
        self.temperatureLabel.text = String(format: "%.0f"+"°C", weather.current.temp)
        self.conditionImgView.image = UIImage(systemName: self.changeIDtoImage(id: weather.current.weather[0].id))
        self.conditionLabel.text = "\(weather.current.weather[0].main) | \(weather.current.weather[0].description)"
        
        weatherManager.resolveNameLocation(with: location) { [weak self] locationName in
            self?.cityLabel.text = locationName
        }
        //setting the object to use in the collection view forecast and reload it's data to show it
        weatherForecast = weather
        forecastCollectionView.reloadData()
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
        DispatchQueue.main.async {
            if let city = self.searchTextField.text {
                self.cityLabel.text = city
                self.weatherLocationManager.fetchLocation(cityName: city) { location in
                    self.weatherManager.fetchWeather(latitude: location.lat, longitude: location.lon) { locationWeather in
                        self.location = CLLocation(latitude: location.lat, longitude: location.lon)
                        self.setLabels(with: locationWeather)
                    } onError: { errorMessage in
                        self.errorMessageShow(error: errorMessage)
                    }

                } onError: { errorMessage in
                    self.errorMessageShow(error: errorMessage)
                }

            }
        }
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
                self.location = CLLocation(latitude: lat, longitude: lon)
                self.setLabels(with: weather)
            } onError: { errorMessage in
                self.errorMessageShow(error: errorMessage)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Ops", message: "Couldn't get your location: \(error)", preferredStyle: .alert)
        
        //show the message and ask for the location again (maybe)
        let action2 = UIAlertAction(title: "OK", style: .default) { [self] (action) in
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
        
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - CollectionView Delegate | DataSource
extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let result = self.weatherForecast {
            if self.forecastSegmentControl.selectedSegmentIndex == 0 {
                return result.hourly.count
            } else if self.forecastSegmentControl.selectedSegmentIndex == 1 {
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
                if let hourForecast = weatherForecast?.hourly[indexPath.row]  {
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


