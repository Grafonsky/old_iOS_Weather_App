import UIKit

class CitiesTableController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let cities: [String:[Double]] = ["Volgograd, RU":[48.700001, 44.516666],
                                     "Moscow, RU": [55.751244, 37.618423],
                                     "Minsk, RB": [53.90125, 27.57245],
                                     "Palo Alto, USA": [37.4419, -122.143]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    private func config() {
        configTableView()
    }
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

}
extension CitiesTableController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath)
        let key = Array(cities.keys)[indexPath.row]
        cell.textLabel?.text = key
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = Array(cities.keys)[indexPath.row]
        let value = Array(cities.values)[indexPath.row]
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "WeatherScreenID") as? WeatherController {
            controller.cityName = key
            controller.lat = value[0]
            controller.lon = value[1]
            present(controller, animated: true)
        }
    }
    
    
}
