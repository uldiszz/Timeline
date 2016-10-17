//
//  AddPostTableViewController.swift
//  Timeline
//
//  Created by Uldis Zingis on 17/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var captionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func selectImageTapped(_ sender: AnyObject) {
        selectImageButton.setTitle("", for: .normal)
        postImageView.image = #imageLiteral(resourceName: "sampleImage")
    }
    
    @IBAction func addPostTapped(_ sender: AnyObject) {
        guard let image = postImageView.image, let caption = captionTextField.text else { presentAlert(); return }
        if caption != "" {
            PostController.sharedController.createPost(image: image, caption: caption)
            dismiss(animated: true, completion: nil)
        } else {
            presentAlert()
        }
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "Failed to create post", message: "Image/caption is missing.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Try again", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
