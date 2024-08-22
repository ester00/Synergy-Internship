//
//  LandmarkInLabel.swift
//  TravelApp
//
//  Created by Synergy01 on 22.07.24.
//

import UIKit

class LandmarkInLabel: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!

    func setCityName(_ cityName: String) {
        cityLabel.text = "Landmarks in: \(cityName)"
    }
}
