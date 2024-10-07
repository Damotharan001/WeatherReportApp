//
//  LocationSearchVC.swift
//  WeatherForecastApp
//
//  Created by Damotharan KG on 11/12/23.
//

import UIKit

class LocationSearchVC: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchLocationTF: UITextField!
    var weekWeatherData: WeekWeatherData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchButton.isHidden = false
        self.removeButton.isHidden = true
        self.searchButton.setTitle("", for: .normal)
        self.removeButton.setTitle("", for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.searchLocationTF.text = "chennai"
        self.locationSearchs(searchText: self.searchLocationTF)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func locationSearchs(searchText: UITextField){
        let path = "\(Constant.baseURL)forecast?q=\(searchText.text ?? "")&units=metric&appid=\(Constant.apiKey)"
        let url = NSURL(string: path)
        let task = URLSession.shared.dataTask(with:url! as URL) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else
                {
                    print("Something went to wrong...")
                    return
                }
                do {
                    self.weekWeatherData = try JSONDecoder().decode(WeekWeatherData.self, from: data)
                }
                catch{
                    print("failed to convert \(error.localizedDescription)")
                    let errors = "\(error.localizedDescription)"
                    self.showAlert(errors)
                }
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    @IBAction func removeAction(_ sender: Any) {
        self.searchButton.isHidden = false
        self.removeButton.isHidden = true
        self.searchLocationTF.text = ""
    }
    @IBAction func searchAction(_ sender: Any) {
        self.searchButton.isHidden = true
        self.removeButton.isHidden = false
        self.locationSearchs(searchText: self.searchLocationTF)
        
    }
    func showAlert(_ message:String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
extension LocationSearchVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weekWeatherData?.list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekCell", for: indexPath) as! WeekCell
        cell.weatherView.layer.cornerRadius = 10
        cell.weatherView.backgroundColor = UIColor(named: "darkSkyBlue")
        cell.weatherView.layer.cornerRadius = 10.0
        cell.weatherView.layer.shadowRadius = 10.0
        cell.weatherView.clipsToBounds = true
        cell.weekDaysLbl.text = self.weekWeatherData?.list?[indexPath.row].dt_txt
        cell.weatherConditionLbl.text = self.weekWeatherData?.list?[indexPath.row].weather?.first?.description ?? ""
        let iconName = self.weekWeatherData?.list?[indexPath.row].weather?.first?.icon ?? ""
        cell.weatherCondImage.image = UIImage(named: iconName)
        cell.weatherTempLbl.text = "\(self.weekWeatherData?.list?[indexPath.row].main?.temp ?? 0)"
        return cell
    }
}
