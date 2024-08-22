//
//  VacationTableViewCell.swift
//  DesiredVacation
//
//  Created by Synergy01 on 29.07.24.
//

import UIKit

class VacationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var vacationImageView: UIImageView!
    
    @IBOutlet weak var vacationNameLabel: UILabel!

    @IBOutlet weak var vacationLocationLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        vacationImageView?.image = nil
        vacationNameLabel?.text = nil
        vacationLocationLabel?.text = nil
    }
}
