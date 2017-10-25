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
    var imageSize: Int
    var callback: Selector
    
    init(mainVC: MainViewController, imageSize: Int, callback: Selector) {
        self.sampleRate = 0.01
        self.mainVC = mainVC
        self.numFramesLoaded = 0
        self.numFramesRequested = 0
        self.imageSize = imageSize
        self.callback = callback
    }
    
    func videoToArray(videoResource: NSURL) {
        self.numFramesLoaded = 0
        let asset = AVURLAsset(url: videoResource as URL)
        DispatchQueue.global().async {
            self.sampleFrames(asset: asset)
        }
//        let generator = AVAssetImageGenerator.init(asset: asset)
//        let times = Array(stride(from: 0.0, to: Double(CMTimeGetSeconds(asset.duration)), by: self.sampleRate))
//        self.numFramesRequested = times.count
//        generator.generateCGImagesAsynchronously(forTimes: times as [NSValue], completionHandler: self.frameGenCompletion(reqT:img:actualT:result:err:))
    }
    
    func sampleFrames(asset: AVAsset) {
        let generator = AVAssetImageGenerator.init(asset: asset)
        let times = Array(stride(from: 0.0, to: Double(CMTimeGetSeconds(asset.duration)), by: self.sampleRate))
        self.numFramesRequested = times.count
        for t in times {
            do {
                let image = try generator.copyCGImage(at: CMTimeMakeWithSeconds(t, asset.duration.timescale), actualTime: nil)
                
                let frame = UIImage(cgImage: image).scaled(to: CGSize(width: self.imageSize, height: self.imageSize), scalingMode: .aspectFit)
                self.mainVC.videoFrames[0].append(frame)
                self.numFramesLoaded += 1
            }
            catch {
                self.numFramesRequested -= 1
            }
        }
        DispatchQueue.main.async {
            self.mainVC.videoTimer?.invalidate()
            self.mainVC.videoTimer = Timer.scheduledTimer(timeInterval: self.sampleRate, target: self.mainVC, selector: self.callback, userInfo: nil, repeats: true)
            self.mainVC.displayingVideo = true
            self.mainVC.updateStyle(oldStyle: 0)
        }
    }
    
    func frameGenCompletion(reqT: CMTime, img: CGImage?, actualT: CMTime, result: AVAssetImageGeneratorResult, err: Error?) -> Void {
        if (img == nil) {
            print("Could not get image: ", err!)
            self.numFramesRequested -= 1
        } else {
            // update the main view controller with the new frame
            let frame = UIImage(cgImage: img!).scaled(to: CGSize(width: self.imageSize, height: self.imageSize), scalingMode: .aspectFit)
            self.mainVC.videoFrames[0].append(frame)
            self.numFramesLoaded += 1
        }
        if (self.numFramesLoaded == self.numFramesRequested) {
            DispatchQueue.main.async {
                self.mainVC.videoTimer?.invalidate()
                self.mainVC.videoTimer = Timer.scheduledTimer(timeInterval: self.sampleRate, target: self.mainVC, selector: self.callback, userInfo: nil, repeats: true)
                self.mainVC.displayingVideo = true
                self.mainVC.updateStyle(oldStyle: 0)
            }
        }
    }

}
