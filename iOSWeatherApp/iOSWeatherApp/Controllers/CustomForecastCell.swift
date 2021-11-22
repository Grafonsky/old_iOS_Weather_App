//
//  CustomForecastCell.swift
//  iOSWeatherApp
//
//  Created by Bohdan Hawrylyshyn on 22.11.2021.
//

import UIKit

class CustomForecastCell: UITableViewCell {
    @IBOutlet weak var dayOfWeek: UILabel!
    @IBOutlet weak var degrees: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
