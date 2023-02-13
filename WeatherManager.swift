//
//  WeatherManaager.swift
//  Clima
//
//  Created by 具志堅 on 2022/11/12.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=b5e0e4d33a214785ab9aad55fdf0ea25&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration:  .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                delegate?.didFailWithError(error: error)
                return
            }
            guard let safeData = data, let weather = self.parseJSON(safeData) else { return }
            self.delegate?.didUpdateWeather(self,weather: weather)
        }
        task.resume()
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {//アンダーバーを使って外部因数を省略する事によって37行目を簡略化できる
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
