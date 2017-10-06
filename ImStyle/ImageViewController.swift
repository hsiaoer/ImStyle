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
import Photos
import CoreImage

class ImageViewController: UIViewController {
    // image selection reference:
    // https://medium.com/@abhimuralidharan/accessing-photos-in-ios-swift-3-43da29ca4ccb
    
    @IBOutlet weak var openPhotoLib: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var clearImageButton: UIButton!
    @IBOutlet weak var styleTransferButton: UIButton!
    
    private let transfer_model = style().model;
    private let image_size = 720
    
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
    
    
    @IBAction func styleTransferButtonPressed(_ sender: Any) {
        print("Starting Style Transfer")
        let image = (self.imageView.image!).scaled(to: CGSize(width: image_size, height: image_size), scalingMode: .aspectFit)
        // disable style transfer button to prevent multiple stylings
        self.styleTransferButton.isEnabled = false
        
        let transferedImage = applyStyleTransfer(uiImage: image, model: transfer_model)
        
        // update image
        self.imageView.image = transferedImage
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

}

extension ImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

