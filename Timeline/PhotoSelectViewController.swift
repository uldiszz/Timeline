//
//  PhotoSelectViewController.swift
//  Timeline
//
//  Created by Uldis Zingis on 18/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import UIKit

class PhotoSelectViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    weak var delegate: PhotoSelectViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func selectImageTapped(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: "Choose image source", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        actionSheet.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionSheet.addAction(photoLibraryAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(cameraAction)
        }
        
        self.present(actionSheet, animated: true, completion: nil)
        
        selectImageButton.setTitle("", for: .normal)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            delegate?.photoSelectViewControllerSelectedImage(image: image)
        }
        dismiss(animated: true, completion: nil)
    }
}

protocol PhotoSelectViewControllerDelegate: class {
    func photoSelectViewControllerSelectedImage(image: UIImage)
}


