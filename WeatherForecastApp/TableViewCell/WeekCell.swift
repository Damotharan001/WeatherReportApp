//
//  WeekCell.swift
//  WeatherForecastApp
//
//  Created by Damotharan KG on 11/12/23.
//

import UIKit

class WeekCell: UITableViewCell {

    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var weatherConditionLbl: UILabel!
    @IBOutlet weak var weatherCondImage: UIImageView!
    @IBOutlet weak var weatherTempLbl: UILabel!
    @IBOutlet weak var weekDaysLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
