//
//  PersonalInfoViewController.swift
//  Cycle Atlanta
//
//  Created by C. David Byrd on 10/30/15.
//
//

import UIKit
import CoreData

class PersonalInfoViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    var managedObjectContext : NSManagedObjectContext?
    var fetchUser : FetchUser?
    var user : User?

    // Allowed values for list entry.
    var ageChoice: [String] = ["", "Less than 18", "18-24", "25-34", "35-44", "45-54", "55-64", "65+"]
    var genderChoice: [String] = ["", "Female", "Male"]
    var ethnicityChoice: [String] = ["", "White", "African American", "Asian", "Native American", "Pacific Islander", "Multi-racial", "Hispanic / Mexican / Latino", "Other"]
    var incomeChoice: [String] = ["", "Less than $20,000", "$20,000 to $39,999", "$40,000 to $59,999", "$60,000 to $74,999", "$75,000 to $99,999", "$100,000 or greater"]
    var cycleFreqChoice: [String] = ["", "Less than once a month", "Several times per month", "Several times per week", "Daily"]
    var riderTypeChoice: [String] = ["", "Strong & fearless", "Enthused & confident", "Comfortable, but cautious", "Interested, but concerned"]
    var riderHistoryChoice: [String] = ["", "Since childhood", "Several years", "One year or less", "Just trying it out / just started"]
    
    // List of lists for brevity and readability elsewhere.
    var pickerLists: [UITextField] = []
    var textFields: [UITextField] = []
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Reusable pop-up picker for list entry.
    @IBOutlet var picker: UIPickerView!
    @IBOutlet var pickerToolbar: UIToolbar!
    var pickerDataSource: [String] = []
    var pickerTarget: UITextField? = nil
    
    @IBOutlet weak var userAge: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userGender: UITextField!
    @IBOutlet weak var userEthnicity: UITextField!
    @IBOutlet weak var userIncome: UITextField!
    @IBOutlet weak var userZipHome: UITextField!
    @IBOutlet weak var userZipWork: UITextField!
    @IBOutlet weak var userZipSchool: UITextField!
    @IBOutlet weak var userCycleFreq: UITextField!
    @IBOutlet weak var userRiderType: UITextField!
    @IBOutlet weak var userRiderHistory: UITextField!
    @IBOutlet weak var userMagnetometer: UISwitch!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init (context: NSManagedObjectContext) {
        self.managedObjectContext = context
        super.init(style: UITableViewStyle.grouped)
    }

    @IBAction func OpenInstructions(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "http://cycleatlanta.org/instructions-v2")!)
    }
    
    @IBAction func AttemptRedownload(_ sender: AnyObject) {
        fetchUser?.fetchUserAndTrip(parent)
    }
    
    @IBAction func doneButton(_ sender: AnyObject) {
        pickerTarget!.resignFirstResponder()
    }
    
    @IBAction func magnetSwitchChanged(_ sender: AnyObject) {
        if let switchState = sender as? UISwitch {
            let userDefaults = UserDefaults.standard
            userDefaults.set(switchState.isOn, forKey: "magnetometerIsOn")
            userDefaults.synchronize()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! CycleAtlantaAppDelegate
        managedObjectContext = appDelegate.managedObjectContext

        pickerLists = [userAge, userGender, userEthnicity, userIncome, userCycleFreq, userRiderType, userRiderHistory]
        textFields = [userEmail, userZipHome, userZipWork, userZipSchool]
        
        for pickerList in pickerLists {
            pickerList.inputView = picker
            pickerList.inputAccessoryView = pickerToolbar
        }

        pickerDataSource = genderChoice
        pickerTarget = userGender
        
        fetchUser = FetchUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let request = NSFetchRequest<NSFetchRequestResult>()
        if let moc = managedObjectContext {
            let entity = NSEntityDescription.entity(forEntityName: "User", in: moc)
            request.entity = entity

            do {
                let count = try moc.count(for: request)
                
                NSLog("saved user count  = %d", count)
                
                if count == 0 {
                    // Create new User.
                    user = createUser()
                } else {
                    // Try to fetch user.
                    do {
                        if let mutableFetchResults = try moc.fetch(request) as? [User] {
                            user = mutableFetchResults[0]
                        } else {
                            NSLog("no saved user")
                        }
                    } catch let error as NSError {
                        NSLog("PersonalIfo viewDidLoad fetch error %@, %@", error, error.localizedDescription)
                    }
                    
                    if user != nil {
                        loadUser()
                    } else {
                        NSLog("init FAIL")
                    }
                }
            } catch {
                NSLog("Error fetching ManagedObjectContext in PersonalInfoViewController.viewWillAppear.")
            }
            
            // Load magnetometer switch preference.
            userMagnetometer.isOn = UserDefaults.standard.bool(forKey: "magnetometerIsOn")
            
        } else {
            NSLog("nil managedObjectContext")
        }
    
        tableView.reloadData()
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Text field delegate functions.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if pickerLists.contains(textField) {
            pickerTarget = textField

            switch textField {
            case userAge: pickerDataSource = ageChoice
            case userGender: pickerDataSource = genderChoice
            case userEthnicity: pickerDataSource = ethnicityChoice
            case userIncome: pickerDataSource = incomeChoice
            case userCycleFreq: pickerDataSource = cycleFreqChoice
            case userRiderType: pickerDataSource = riderTypeChoice
            case userRiderHistory: pickerDataSource = riderHistoryChoice
            default: pickerDataSource = ageChoice
            }
            
            picker.reloadAllComponents()
            picker.selectRow(pickerDataSource.index(of: textField.text!)!, inComponent: 0, animated: true)
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        saveUser()
    }
    
    // Picker data source implementation.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTarget!.text = pickerDataSource[row]
    }
    

    // Data model interaction.
    func createUser() -> User {
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: managedObjectContext!) as! User
        
        do {
            try managedObjectContext?.save()
        } catch let error as NSError {
            NSLog("createUser error %@, %@", error, error.localizedDescription)
        }
        
        return user
    }
    
    func loadListField (_ list: [String], field: NSNumber?) -> String {
        if let f = field?.intValue {
            return list[f]
        } else {
            return ""
        }
    }
    
    func loadUser() {
        // Loads user from data model to view controller.
        if let u = user {
            userAge.text = loadListField(ageChoice, field: u.age)
            userEmail.text = u.email
            userGender.text = loadListField(genderChoice, field: u.gender)
            userEthnicity.text = loadListField(ethnicityChoice, field: u.ethnicity)
            userIncome.text = loadListField(incomeChoice, field: u.income)
            
            userZipHome.text = u.homeZIP
            userZipWork.text = u.workZIP
            userZipSchool.text = u.schoolZIP
            
            userCycleFreq.text = loadListField(cycleFreqChoice, field: u.cyclingFreq)
            userRiderType.text = loadListField(riderTypeChoice, field: u.rider_type)
            userRiderHistory.text = loadListField(riderHistoryChoice, field: u.rider_history)
        } else {
            NSLog("Can't load nil user");
        }
    }
    
    func saveUser() {
        // Saves user from view controller to data model.
        if let u = user {
            u.age = ageChoice.index(of: userAge.text!)! as NSNumber!
            u.email = userEmail.text
            u.gender = genderChoice.index(of: userGender.text!)! as NSNumber!
            u.ethnicity = ethnicityChoice.index(of: userEthnicity.text!)! as NSNumber!
            u.income = incomeChoice.index(of: userIncome.text!)! as NSNumber!
            u.homeZIP = userZipHome.text
            u.workZIP = userZipWork.text
            u.schoolZIP = userZipSchool.text
            u.cyclingFreq = cycleFreqChoice.index(of: userCycleFreq.text!)! as NSNumber!
            u.rider_type = riderTypeChoice.index(of: userRiderType.text!)! as NSNumber!
            u.rider_history = riderHistoryChoice.index(of: userRiderHistory.text!)! as NSNumber!
            
            do {
                try managedObjectContext?.save()
            } catch let error as NSError {
                NSLog("PersonalInfo save error %@, %@", error, error.localizedDescription)
            }
        } else {
            NSLog("Can't load nil user");
        }
    }
    
    @IBAction func clickSave(_ sender: AnyObject) {
        NSLog("Saving User Data")
        if let u = user {
            for field in pickerLists {
                field.resignFirstResponder()
            }
            for field in textFields {
                field.resignFirstResponder()
            }
            
            saveUser()
        } else {
            NSLog("ERROR can't save personal info for nil user")
        }
        
        ALToastView.toast(in: view, withText: "Saved!")
    }
    
}



    
    /*

#import "PersonalInfoViewController.h"
#import "User.h"
#import "constants.h"
#import "ProgressView.h"
#import "CycleAtlantaAppDelegate.h"
#import "ALToastView.h"

#define kMaxCyclingFreq 3


- (UISwitch*) initiateSwitch
{
UISwitch* switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(225.0, 0.0, 80.0, 45.0)];
switchButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"magnetometerIsOn"];
[switchButton addTarget:self action:@selector(saveSwitch:) forControlEvents:UIControlEventValueChanged];
return switchButton;

}

- (void)saveSwitch:(id)sender
{
BOOL state = [sender isOn];
NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
[userDefaults setBool:state forKey:@"magnetometerIsOn"];
[userDefaults synchronize];
}


*/

