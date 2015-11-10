//
//  NewSavedTripsTableViewCell.swift
//  Cycle Atlanta
//
//  Created by C. David Byrd on 10/29/15.
//
//

import UIKit

class SavedTripsTableViewCell: UITableViewCell {

    @IBOutlet weak var TripDuration: UILabel!
    @IBOutlet weak var TripTime: UILabel!
    @IBOutlet weak var TripPurpose: UILabel!
    @IBOutlet weak var CO2_Saved: UILabel!
    @IBOutlet weak var CaloriesBurned: UILabel!
    @IBOutlet weak var TripIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
