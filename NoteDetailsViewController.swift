//
//  NoteDetailsViewController.swift
//  Cycle Atlanta
//
//  Created by C. David Byrd on 7/9/17.
//
//

import UIKit

protocol NoteDetailsDelegate {
    func sendNoteDetails(value : String)
    func sendNoteImage(image : UIImage)
}

class NoteDetailsViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var detailText: UITextView!
    
    var delegate : NoteDetailsDelegate? = nil
    
    var imagePicker : UIImagePickerController!
    
    var firstTap = true
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBAction func takePhoto(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        photo.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        detailText.layer.borderColor = UIColor.black.cgColor
        detailText.layer.borderWidth = 1
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        //detailText.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if let delegate = self.delegate {
            if let pic = photo.image {
                delegate.sendNoteImage(image: pic)
            }
            delegate.sendNoteDetails(value: detailText.text)
        } else {
            print ("No delegate for saveButton()!")
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapBackground(_ sender: Any) {
        detailText.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if firstTap {
            detailText.text = ""
            firstTap = false
        }
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
