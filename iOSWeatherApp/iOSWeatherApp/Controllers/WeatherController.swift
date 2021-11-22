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
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var bgWeatherImage: UIImageView!
    
    var cityName: String = ""
    var lat: Double = 0
    var lon: Double = 0
    var forecast7Days: [Daily] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        loadData(lat: lat, lon: lon)
    }
    
    //MARK: - config funcs
    
    private func config() {
        configCustomViews()
        configTableView()
    }
    
    private func configTableView() {
        forecast5DayTableView.backgroundColor = .clear
        forecast5DayTableView.delegate = self
        forecast5DayTableView.dataSource = self
        forecast5DayTableView.register(UINib(nibName: "CustomForecastCell", bundle: nil), forCellReuseIdentifier: "CustomForecastCell")
    }
    
    private func configCustomViews() {
        forecastView.clipsToBounds = true
        forecastView.layer.cornerRadius = 25
        humidityWindView.clipsToBounds = true
        humidityWindView.layer.cornerRadius = 25
    }
    
    //MARK: - Load data
    
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
                forecast7Days = jsonData.daily
            } catch {
                debugPrint("Error while parsing JSON w/ current weather data")
            }
        }
    }
    
    //MARK: - Set data to UI
    
    private func setWeatherImage(weatherDesc: String) {
        if weatherDesc.contains("clear") {
            weatherImage.image = UIImage(named: "clear.png")
            bgWeatherImage.image = UIImage(named: "bgClear.jpg")
        } else if weatherDesc.contains("clouds") {
            weatherImage.image = UIImage(named: "cloudy.png")
            bgWeatherImage.image = UIImage(named: "bgCloudy.jpg")
        } else if weatherDesc.contains("fog") {
            weatherImage.image = UIImage(named: "fog.png")
            bgWeatherImage.image = UIImage(named: "bgFog.jpg")
        } else if weatherDesc.contains("partly cloudy") {
            weatherImage.image = UIImage(named: "partlyCloudy.png")
            bgWeatherImage.image = UIImage(named: "bgPartlyCloudy.jpg")
        } else if weatherDesc.contains("shower") {
            weatherImage.image = UIImage(named: "showers.png")
            bgWeatherImage.image = UIImage(named: "bgShower.jpg")
        } else if weatherDesc.contains("snow") {
            weatherImage.image = UIImage(named: "snow.png")
            bgWeatherImage.image = UIImage(named: "bgSnow.jpg")
        } else if weatherDesc.contains("thunderstorms") {
            weatherImage.image = UIImage(named: "thunderstorms.png")
            bgWeatherImage.image = UIImage(named: "bgThunder.jpg")
        } else if weatherDesc.contains("windy") {
            weatherImage.image = UIImage(named: "windy.png")
            bgWeatherImage.image = UIImage(named: "bgWindy.jpg")
        }
    }
    
    private func setCurrentDataToUI(data: WeatherData) {
        let jsonCity: String = cityName
        let jsonDegrees: Double = data.current.temp
        let jsonDescription: String = data.current.weather[0].description
        let jsonFeelsLike: String = String(round(data.current.feels_like - 273.15))
        let jsonHumidity: String = String(data.current.humidity)
        let jsonWindSpeed: String = String(data.current.wind_speed)
        setWeatherImage(weatherDesc: jsonDescription)
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
        if forecast7Days.isEmpty {
            return 0
        }
        return forecast7Days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let daily = forecast7Days[indexPath.row]
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
    
}
