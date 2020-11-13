////  photoCameraPermissions.swift
//  Platica
//
//  Created by Jesus Lopez on 11/11/20.
//  
// 

import UIKit
import AVFoundation
import Photos

class PCPermissions: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var givenImageView: UIImageView?
    
    func permissionPrompt(){

        let photoLibraryAction = UIAlertAction(title: "Choose from library", style: UIAlertAction.Style.default) { (alertAction) in
            self.checkPHPermission()
        }
        let cameraAction = UIAlertAction(title: "Take a photo", style: UIAlertAction.Style.default) { (alertAction) in
            self.checkCameraPermission()
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let alert = UIAlertController(title: "Choose your image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(photoLibraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func checkPHPermission() {
        print("checking persmissions")
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    if status == PHAuthorizationStatus.authorized {
                        self.showImagePicker(sourceType: .photoLibrary)
                    } else {
                        self.showDeniedPrompt()
                    }
                }
            }
        case .restricted:
            self.showImagePicker(sourceType: .photoLibrary)
        case .denied:
            self.showDeniedPrompt()
            break
        case .authorized:
            self.showImagePicker(sourceType: .photoLibrary)
            break
        case .limited:
            self.showImagePicker(sourceType: .photoLibrary)
            break
        @unknown default:
            self.showDeniedPrompt()
            break
        }
    
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (success) in
                if success {
                    self.showImagePicker(sourceType: .camera)
                } else {
                    self.showDeniedPrompt()
                }
            }
            break
        case .restricted:
            self.showImagePicker(sourceType: .camera)
            break
        case .denied:
            self.showDeniedPrompt()
            break
        case .authorized:
            self.showImagePicker(sourceType: .camera)
            break
        @unknown default:
            self.showDeniedPrompt()
            break
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
            givenImageView?.image = editedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func showDeniedPrompt() {
        let cancel = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil)
        let alert = UIAlertController(title: "Sorry but our hands are tied", message: "Please go to Settings -> Platica and update your settings to use this feature", preferredStyle: .alert)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    public func getImage(image: UIImageView) {
        givenImageView = image
        permissionPrompt()
        
    }
}
