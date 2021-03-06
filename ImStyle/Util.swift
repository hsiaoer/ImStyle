//
//  Util.swift
//  ImStyle
//
//  Created by Ian Johnson on 10/5/17.
//  Copyright © 2017 ImageStyle. All rights reserved.
//

import UIKit
import Foundation

extension UIViewController {

    // following 2 functions from https://www.hackingwithswift.com/example-code/media/uiimagewritetosavedphotosalbum-how-to-write-to-the-ios-photo-album
    func saveToPhotoLibrary(uiImage: UIImage) {
        UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(image_callback(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image_callback(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your stylized image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func videoCallbackOnSuccess() {
        let ac = UIAlertController(title: "Saved!", message: "Your stylized video has been saved to your photos.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}
