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
    
    @IBAction func applyStyleTransfer(_ sender: Any) {
        print("Running style transfer")
        let image = (self.imageView.image!).scaled(to: CGSize(width: image_size, height: image_size), scalingMode: .aspectFit).cgImage!
        // disable style transfer button to prevent multiple stylings
        self.styleTransferButton.isEnabled = false
        
        let transferedImage = self.applyStyleTransfer(cgImage: image)
        
        // update image
        self.imageView.image = UIImage(cgImage: transferedImage)
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
    
    private func applyStyleTransfer(cgImage: CGImage) -> CGImage {
        let input = styleInput(inputImage: pixelBuffer(cgImage: cgImage, width: image_size, height: image_size))
        let outFeatures = try! transfer_model.prediction(from: input)
        let output = outFeatures.featureValue(for: "outputImage")!.imageBufferValue!
        CVPixelBufferLockBaseAddress(output, .readOnly)
        let width = CVPixelBufferGetWidth(output)
        let height = CVPixelBufferGetHeight(output)
        let data = CVPixelBufferGetBaseAddress(output)!
        
        let outContext = CGContext(data: data,
                                   width: width,
                                   height: height,
                                   bitsPerComponent: 8,
                                   bytesPerRow: CVPixelBufferGetBytesPerRow(output),
                                   space: CGColorSpaceCreateDeviceRGB(),
                                   bitmapInfo: CGImageByteOrderInfo.order32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue)!
        let outImage = outContext.makeImage()!
        CVPixelBufferUnlockBaseAddress(output, .readOnly)
        
        return outImage
    }
    
    // Reference: https://github.com/prisma-ai/torch2coreml/blob/master/example/fast-neural-style/ios/StyleTransfer/ViewController.swift
    private func pixelBuffer(cgImage: CGImage, width: Int, height: Int) -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
        if status != kCVReturnSuccess {
            fatalError("Cannot create pixel buffer for image")
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue)
        let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer!
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

