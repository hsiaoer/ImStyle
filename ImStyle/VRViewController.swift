//
//  VRViewController.swift
//  ImStyle
//
//  Created by Ian Johnson on 10/10/17.
//  Copyright © 2017 ImageStyle. All rights reserved.
//

import UIKit

class VRViewController: VideoFeedViewController {
    
    
    @IBOutlet weak var rightEyeView: UIImageView!
    @IBOutlet weak var leftEyeView: UIImageView!
    
    override func updateOutputImage(uiImage: UIImage) {
        self.rightEyeView.image = uiImage;
        self.leftEyeView.image  = uiImage;
    }
    
}
