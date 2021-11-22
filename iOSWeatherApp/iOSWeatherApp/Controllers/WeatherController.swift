import UIKit
import Foundation

class WeatherController: UIViewController {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var degreesLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var forecastView: UIVisualEffectView!
    @IBOutlet weak var forecast5DayTableView: UITableView!
    @IBOutlet weak var humidityWindView: UIVisualEffectView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    var cityName: String = ""
    var lat: Double = 0
    var lon: Double = 0
    var forecast5Days: [Daily] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    private func config() {
        loadData(lat: lat, lon: lon)
        configTableView()
    }
    
    private func configTableView() {
        forecastView.clipsToBounds = true
        forecastView.layer.cornerRadius = 25
        humidityWindView.clipsToBounds = true
        humidityWindView.layer.cornerRadius = 25
        forecast5DayTableView.backgroundColor = .clear
        forecast5DayTableView.delegate = self
        forecast5DayTableView.dataSource = self
        forecast5DayTableView.register(UINib(nibName: "CustomForecastCell", bundle: nil), forCellReuseIdentifier: "CustomForecastCell")
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
                forecast5Days = jsonData.daily
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
        let jsonHumidity: String = String(data.current.humidity)
        let jsonWindSpeed: String = String(data.current.wind_speed)
        cityNameLabel.text = cityName
        degreesLabel.text = String(round(jsonDegrees - 273.15)) + "°"
        weatherDescriptionLabel.text = jsonDescription
        feelsLikeLabel.text = "Feels like \(jsonFeelsLike)°"
        humidityLabel.text = "Humidity: " + jsonHumidity + "%"
        windSpeedLabel.text = "Wind speed: " + jsonWindSpeed + " m/s"
        forecast5DayTableView.reloadData()
    }
    
}
extension WeatherController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if forecast5Days.isEmpty {
            return 0
        }
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let daily = forecast5Days[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomForecastCell", for: indexPath) as? CustomForecastCell {
            cell.backgroundColor = .clear
            let date = Date(timeIntervalSince1970: TimeInterval(daily.dt)).formatted(date: .complete, time: .shortened)
            if let dateString = date.components(separatedBy: ",").first {
                cell.dayOfWeek.text = "\(dateString)"
                cell.degrees.text = String(round(daily.temp.day - 273.15))+"°"
                return cell
            }
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 44
    //    }
    
}
