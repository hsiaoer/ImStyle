//
//  ViewController.swift
//  ImStyle
//
//  Created by Jake Carlson on 10/3/17.
//  Copyright © 2017 ImageStyle. All rights reserved.
//

import UIKit
import MobileCoreServices
import QuartzCore
import CoreML

class ViewController: UIViewController {
    // image selection reference:
    // https://medium.com/@abhimuralidharan/accessing-photos-in-ios-swift-3-43da29ca4ccb
    
    @IBOutlet weak var openPhotoLib: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var clearImageButton: UIButton!
    @IBOutlet weak var styleTransferButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openLibraryAction(_ sender: Any) {
        self.openPhotoLibrary()
    }
    
    @IBAction func clearImage(_ sender: Any) {
        self.imageView.image = nil
        self.clearImageButton.isEnabled = false
        self.styleTransferButton.isEnabled = false
    }
    
    @IBAction func applyStyleTransfer(_ sender: Any) {
        print("Running style transfer")
        // disable style transfer button to prevent multiple stylings
        self.styleTransferButton.isEnabled = false
        
//        let transferedImage = self.applyStyleTransfer(image: (self.imageView.image)!, model: "./Models/wave.mlmodel")
        
        // update image
//        self.imageView.image = transferedImage
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true)
            self.clearImageButton.isEnabled = true
            self.styleTransferButton.isEnabled = true
            
        } else {
            print("Cannot open photo library")
            return
        }
    }
    
    func applyStyleTransfer(image: UIImage, model: String) {
        
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        
        print(info)
        // get the image
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        // save to imageView
        imageView.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            picker.dismiss(animated: true)
        }
        
        print("Photo selection canceled")
    }
}

