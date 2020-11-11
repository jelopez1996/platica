//
//  RegisterViewController.swift
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AVFoundation
import Photos

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var credentialView: UIView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var completeButton: UIButton!
    var textFields: [UITextField]?

    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()


        firstName.delegate = self
        lastName.delegate = self
        password.delegate = self
        email.delegate = self

        textFields = [firstName, lastName, email, password]


        // Set contactView to be half that of the screen

        contactView.layer.cornerRadius = K.cornerRadius
        contactView.layer.shadowColor = UIColor.black.cgColor
        contactView.layer.shadowOffset = CGSize(width: 1, height: 1)
        contactView.layer.shadowOpacity = K.shadowOpacity

        // Add shadows and round edges to credentialView
        credentialView.layer.cornerRadius = K.cornerRadius
        credentialView.layer.shadowColor = UIColor.black.cgColor
        credentialView.layer.shadowOffset = CGSize(width: 1, height: 1)
        credentialView.layer.shadowOpacity = K.shadowOpacity

        // Add shadows and round edges to complete button
        completeButton.layer.cornerRadius = K.cornerRadius
        completeButton.layer.shadowColor = UIColor.black.cgColor
        completeButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        completeButton.layer.shadowOpacity = K.shadowOpacity
       
    }



    @IBAction func imagePressed(_ sender: UIButton) {
        uploadButton.isSelected = true
        showImagePickerActionSheet()
    }

    @IBAction func completePressed(_ sender: Any) {

        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (data, error) in
            if((error) != nil) {
                let alert = UIAlertController(title: "Error creating your account", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let imageData = self.profilePic.image!.jpegData(compressionQuality: 0.75)
                if let userId = Auth.auth().currentUser?.uid {
                    self.db.collection("profileImages").addDocument(data: ["image" : imageData!, "type": "profile", "owner": userId]) { (error) in
                        if((error) != nil) {
                            print(error!.localizedDescription)
                        } else {
                            // Segue into the conversations page
                            self.performSegue(withIdentifier: K.registerToConversationsSegue, sender: self)
                        }
                    }
                }
                
                
            }
        }
    }


}
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func checkPhotoLibraryPermissions() {
        if #available(iOS 14, *) {
            switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
                case .denied:
                    print("Denied")
                case .authorized:
                    print("Authorized")
                case .notDetermined:
                    print("Not determined")
                case .restricted:
                    print("restricted")
                case .limited:
                    print("limited")
                @unknown default:
                    print("Unkown")
            }
        } else {
            switch PHPhotoLibrary.authorizationStatus() {
            case .denied:
                print("Denied")
            
            case .authorized:
                print("Authorized")
            
            case .notDetermined:
                print("Not determined")
            case .restricted:
                print("restricted")
            case .limited:
                print("limited")
            @unknown default:
                print("Unkown")
            }
        }
        
    }
    
    func checkCameraPermissions(){
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            case .denied:
                let alert = UIAlertController(title: "Unable to access the Camera", message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            case .restricted:
                print("Restricted, device owner must approve")
            case .authorized:
                print("Authorized, proceed")
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { success in
                    if success {
                        print("Permission granted, proceed")
                    } else {
                        print("Permission denied")
                    }
                }
            default:
                print("Default case passed")
            }
    }
    
    func showImagePickerActionSheet() {
        checkPhotoLibraryPermissions()
        let photoLibraryAction = UIAlertAction(title: "Choose from library", style: UIAlertAction.Style.default) { (alertAction) in
            self.showImagePicker(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take a photo", style: UIAlertAction.Style.default) { (alertAction) in
            self.showImagePicker(sourceType: .camera)
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let alert = UIAlertController(title: "Choose your image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(photoLibraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancel)
        present(alert, animated: true) {
            self.uploadButton.isSelected = false
        }
    }
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profilePic.image = editedImage
            profilePic.layer.cornerRadius = profilePic.frame.size.height / 2
            profilePic.layer.borderWidth = 1
            profilePic.layer.masksToBounds = false
            profilePic.layer.borderColor = UIColor.black.cgColor
            profilePic.clipsToBounds = true

        }
        dismiss(animated: true, completion: nil)
    }

}

extension RegisterViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField.tag == 2) {
            textField.layer.borderColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.0)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.tag == 3){
            self.view.endEditing(true)
        } else {
            textField.resignFirstResponder()
            self.textFields?[textField.tag + 1].becomeFirstResponder()
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        if(textField.tag == 2) {
            if(!Helper.isValidEmail(email: textField.text!)) {
                textField.layer.borderColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
                textField.layer.borderWidth = 2.0
                completeButton.isEnabled = false
            }
        }

        if(firstName.text! != "" && lastName.text! != "" && Helper.isValidEmail(email: email.text!) && password.text! != ""){
            completeButton.isEnabled = true
        } else {
            completeButton.isEnabled = false
        }

    }
    
}
