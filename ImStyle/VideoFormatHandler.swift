//
//  VideoFormatHandler.swift
//  ImStyle
//
//  Created by Jake Carlson on 10/24/17.
//  Copyright © 2017 ImageStyle. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VideoFormatHandler {
    
    let sampleRate: Double!
    let mainVC: MainViewController!
    var numFramesLoaded: Int
    var numFramesRequested: Int
    
    init(mainVC: MainViewController) {
        self.sampleRate = 0.05
        self.mainVC = mainVC
        self.numFramesLoaded = 0
        self.numFramesRequested = 0
    }
    
    func videoToArray(videoResource: NSURL) {
        self.numFramesLoaded = 0
        let asset = AVURLAsset(url: videoResource as URL)
        let generator = AVAssetImageGenerator.init(asset: asset)
        let times = Array(stride(from: 0.0, to: Double(asset.duration.value), by: self.sampleRate))
        self.numFramesRequested = times.count
        generator.generateCGImagesAsynchronously(forTimes: times as [NSValue], completionHandler: self.frameGenCompletion(reqT:img:actualT:result:err:))
    }
    
    func frameGenCompletion(reqT: CMTime, img: CGImage?, actualT: CMTime, result: AVAssetImageGeneratorResult, err: Error?) -> Void {
        if (img == nil) {
            print("Could not get image: ", err!)
            self.numFramesRequested -= 1
        } else {
            // update the main view controller with the new frame
            let frame = UIImage(cgImage: img!)
            self.mainVC.videoFrames[0].append(frame)
            self.numFramesLoaded += 1
        }
        if (self.numFramesLoaded == self.numFramesRequested) {
            DispatchQueue.main.async {
                self.mainVC.updateStyle(oldStyle: 0)
            }
        }
    }

}
