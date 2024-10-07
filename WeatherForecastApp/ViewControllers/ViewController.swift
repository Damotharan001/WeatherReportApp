//
//  ViewController.swift
//  WeatherForecastApp
//
//  Created by Damotharan KG on 10/12/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    

    @IBOutlet weak var weatherTempLbl: UILabel!
    @IBOutlet weak var weatherConditionLbl: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var locationName: UILabel!

    var lat: Double?
    var lon: Double?
    let locationManager = CLLocationManager()
    var weatherDatas: WeatherDatas?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // requesting permission
        self.requestLocationPermision()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    func requestLocationPermision() {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    @IBAction func searchLocation(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocationSearchVC") as? LocationSearchVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: AnyObject = locations[locations.count - 1]
        let lat = latestLocation.coordinate.latitude
        let lon = latestLocation.coordinate.longitude
        print("latestLocation.coordinate.latitude", latestLocation.coordinate.latitude)
        print("latestLocation.coordinate.longitude", latestLocation.coordinate.longitude)
        self.getWeatherReport(lat: lat, lng: lon)
    }
    
    func getWeatherReport(lat: Double, lng: Double){
        let path = "\(Constant.baseURL)weather?lat=\(lat)&lon=\(lng)&appid=\(Constant.apiKey)"
        let url = NSURL(string: path)
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else
                {
                    print("Something went to wrong...")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    self.handleServerError(response!)
                    return
                }
                do {
                    self.weatherDatas = try JSONDecoder().decode(WeatherDatas.self, from: data)
                }
                catch{
                    print("failed to convert \(error.localizedDescription)")
                    let errors = "\(error.localizedDescription)"
                    self.showAlert(errors)
                }

                self.updateDatas()
        
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.dateLbl.text = dateFormatter.string(from: date)
            }
        }
        task.resume()
    }
    
    func updateDatas(){
        self.locationName.text = self.weatherDatas?.name ?? ""
        self.weatherTempLbl.text = "\(self.weatherDatas?.main?.temp ?? 0.0)"
        self.weatherDatas?.weather?.forEach({ data in
            let iconName = data.icon
            self.weatherImg.image = UIImage(named: iconName ?? "")
            self.weatherConditionLbl.text = data.description ?? ""
        })
    }
    
    func handleServerError(_ res: URLResponse?) {
         print("ERROR: Status Code: \(res!): the status code MUST be between 200 and 299")
        self.showAlert(res?.description ?? "")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if CLLocationManager.locationServicesEnabled() {
            switch(manager.authorizationStatus) {
            case .notDetermined, .restricted, .denied:
                showAlert("Please Allow the Location Permision to get weather of your city")
            case .authorizedAlways, .authorizedWhenInUse:
                print("locationEnabled")
            default:
                break
            }
        } else {
            self.showAlert("Please Turn ON the location services on your device")
        }
        manager.stopUpdatingLocation()
    }
    
    func showAlert(_ message:String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

