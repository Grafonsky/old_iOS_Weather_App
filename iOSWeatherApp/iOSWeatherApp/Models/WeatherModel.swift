import UIKit

enum Constants {
    static let OWAPI = "OPENWEATHERMAP API KEY"
}

struct WeatherData: Codable {
    var lat: Double
    var lon: Double
    var current: Current
}

struct Current: Codable {
    var temp: Double
    var feels_like: Double
    var humidity: Double
    var wind_speed: Double
    var weather: [Weather]
}

struct Weather: Codable {
    var main: String
    var description: String
}
