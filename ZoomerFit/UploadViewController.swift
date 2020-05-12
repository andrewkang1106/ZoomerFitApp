//
//  UploadViewController.swift
//  ZoomerFit
//
//  Created by Andrew Kang on 4/30/20.
//  Copyright © 2020 Andrew Kang. All rights reserved.
//

import UIKit
import Firebase


class UploadViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var warningText: UILabel!
    @IBOutlet weak var photoSuccess: UILabel!
    @IBOutlet weak var workoutDescription: UITextView!
    @IBOutlet weak var workoutName: UITextField!
    @IBOutlet weak var workoutLength: UITextView!
    
    @IBOutlet weak var detailedDescription: UITextView!
    @IBOutlet weak var equipment: UITextView!
    @IBOutlet weak var submitImage: UIButton!
    
    @IBOutlet weak var selectedMuscles: UITextField!
    
    //@IBOutlet weak var submitVideo: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var muscleSelector: UIPickerView!
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    var muscleGroups = [String]()
    var imagePicker:UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        self.photoSuccess.isHidden = true
        workoutDescription!.layer.borderWidth = 1;
        workoutDescription!.layer.borderColor = UIColor.lightGray.cgColor;
        workoutDescription!.layer.cornerRadius = 6;
        
        workoutName!.layer.borderWidth = 1;
        workoutName!.layer.borderColor = UIColor.lightGray.cgColor;
        workoutName!.layer.cornerRadius = 6;
        
        workoutLength!.layer.borderWidth = 1;
        workoutLength!.layer.borderColor = UIColor.lightGray.cgColor;
        workoutLength!.layer.cornerRadius = 6;
        
        detailedDescription!.layer.borderWidth = 1;
        detailedDescription!.layer.borderColor = UIColor.lightGray.cgColor;
        detailedDescription!.layer.cornerRadius = 6;
        
        equipment!.layer.borderWidth = 1;
        equipment!.layer.borderColor = UIColor.lightGray.cgColor;
        equipment!.layer.cornerRadius = 6;
        
        muscleGroups = ["Back", "Arms", "Stomach", "Chest", "Shoulders", "Legs", "Calves", "Full Body"]
        // Create a storage reference from our storage service
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        imagePicker.delegate = self
        //warningText.isHidden = true

    }
    
    
    @IBAction func uploadWorkout(_ sender: Any) {
        
        if((workoutDescription.text == "How are we getting better today?" && !workoutDescription.text.isEmpty) || (workoutName.text == "") || (selectedMuscles.text == "")) {
            //warningText.isHidden = false
            return
        }
        
        print("UPLOAD CALLED")
        guard let uid = Auth.auth().currentUser?.uid else { return}

        let title = self.workoutName.text
        let muscleGroups = self.selectedMuscles.text
        let description = self.workoutDescription.text
        let detailed = self.detailedDescription.text
        let workoutLength = self.workoutLength.text
        let equipmentNeeded = self.equipment.text
        let coach = Auth.auth().currentUser?.uid
        let coachName = Auth.auth().currentUser?.displayName
        let photoURL = Storage.storage().reference(withPath: "Workout/\(uid)/\(String(describing: self.workoutName.text))").fullPath
        let workout:[String:String?] = ["title": title, "muscleGroups": muscleGroups, "description":description, "detailedDescription": detailed, "workoutLength":workoutLength, "equipment": equipmentNeeded, "coach": coach, "coachName": coachName, "photoURL": photoURL]
        
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("Workouts").addDocument(data: workout) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        performSegue(withIdentifier: "toCategories", sender: nil)
        
    }
    
    @IBAction func selectMuscles(_ sender: Any) {
        picker = UIPickerView.init()
        picker.delegate = self
        
        picker.dataSource=self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(picker)

        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = UIBarStyle.black
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.view.addSubview(toolBar)

    }
    
    @IBAction func submitPhoto(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return muscleGroups.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print(muscleGroups[row])
        self.selectedMuscles.text = muscleGroups[row]
        return (muscleGroups[row])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(muscleGroups[row])
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return}
        let storageRef = Storage.storage().reference().child("Workout/\(uid)/\(String(describing: self.workoutName.text))")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let uploadTask = storageRef.putData(imageData, metadata: metaData) { (metadata, error) in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
          // You can also access to download URL after upload.
          storageRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
              return
            }
          }
        }
    }


    func saveProfile(profileImageURL: URL, completion: @escaping ((_ success:Bool)->())) {
           guard let uid = Auth.auth().currentUser?.uid else { return}
           let databaseRef = Database.database().reference().child("users/profile/\(uid)")
           let userObject = ["photoURL": profileImageURL.absoluteString] as [String:Any]
           databaseRef.setValue(userObject) { error, ref in
               completion(error == nil)
           }
           
       }
    
    
    
}


extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
}
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
        uploadProfileImage(pickedImage) { url in
            if url != nil {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.photoURL = url
                
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User Profile Pic changed")
                        self.saveProfile(profileImageURL: url!) { success in
                            if success {
                                self.dismiss(animated: true, completion: nil)
                            }
                        
                        }
                    } else {
                        print("error")
                    }
                }
                
            }
            else {
                
            }
            
            
        }
        
    }
    picker.dismiss(animated: true, completion: nil)
    self.photoSuccess.isHidden = false
}
}
