//
//  WeatherManager.swift
//  Clima
//
//  Created by Artur Imanbaev on 22.02.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//
protocol WeatherManagerDelegate{
    func didUpdateWeather(weather: WeatherModel)
}
import Foundation

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=84297a1f4eabdb23a8205299f53f48c3&units=metric"
    var delegate: WeatherManagerDelegate? // нашим делегатом будет любой кто подпишется на протокол
    func fetchWeather(_ cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlstring: urlString)
    }
    func locationWeather(_ lat: Double, _ lon: Double){
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(urlstring: urlString)
    }
    func performRequest(urlstring: String ) {
        if let url = URL(string: urlstring) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data{
                    if let weather = self.parseJSON(weatherData: safeData){
                        delegate?.didUpdateWeather(weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, temperature: temp, cityName: name)// тут просто все что из jsona взяли кидаем в WeatherModel
            return weather
        }
        catch {
            print(error)
            return nil
        }
    }
}
