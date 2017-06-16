//
//  TripDetailsViewController.swift
//  Cycle Atlanta
//
//  Created by C. David Byrd on 4/2/17.
//
//

import UIKit

protocol TripDetailsDelegate {
    func sendDetails(value : String)
}

class TripDetailsViewController: UIViewController {

    @IBOutlet weak var detailText: UITextView!
    
    var delegate : TripDetailsDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        detailText.layer.borderColor = UIColor.black.cgColor
        detailText.layer.borderWidth = 1
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        detailText.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.sendDetails(value: detailText.text)
        } else {
            print ("No delegate for saveButton()!")
        }
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
