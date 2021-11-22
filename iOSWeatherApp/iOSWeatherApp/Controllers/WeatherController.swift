import UIKit
import Foundation

class WeatherController: UIViewController {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var degreesLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    
    var cityName: String = ""
    var lat: Double = 0
    var lon: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    private func config() {
        loadData(lat: lat, lon: lon)
    }
    
    private func loadData(lat: Double, lon: Double) {
        loadCurrentWeatherData(lat: lat, lon: lon)
    }
        
    private func loadCurrentWeatherData(lat: Double, lon: Double) {
        let session: URLSession = URLSession.shared
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=alerts&appid=\(Constants.OWAPI)") else { return }
        print(url)
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            self.parseWeatherJson(data: data as NSData?, response: response as URLResponse?, error: error as NSError?)
        }
        task.resume()
    }
    
    private func parseWeatherJson(data: NSData?, response: URLResponse?, error: NSError?) {
        if error == nil && data != nil {
            let decoder = JSONDecoder()
            do {
                guard let unwrapData = data else { return }
                guard let jsonData = try? decoder.decode(WeatherData.self, from: unwrapData as Data) else { return }
                DispatchQueue.main.async {
                    self.setCurrentDataToUI(data: jsonData)
                }
            } catch {
                debugPrint("Error while parsing JSON w/ current weather data")
            }
        }
    }
    
    private func setCurrentDataToUI(data: WeatherData) {
        let jsonCity: String = cityName
        let jsonDegrees: Double = data.current.temp
        let jsonDescription: String = data.current.weather[0].description
        let jsonFeelsLike: String = String(round(data.current.feels_like - 273.15))
        cityNameLabel.text = cityName
        degreesLabel.text = String(round(jsonDegrees - 273.15))
        weatherDescriptionLabel.text = jsonDescription
        feelsLikeLabel.text = "Feels like \(jsonFeelsLike)"
    }
    
}

