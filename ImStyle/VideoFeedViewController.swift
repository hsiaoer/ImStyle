// Real-time style transfer

import UIKit
import AVFoundation
import VideoToolbox

class VideoFeedViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveImageButton: UIButton!
    let cameraSession = AVCaptureSession()
    var perform_transfer = true
    
    var model = style().model
    
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureDevice = AVCaptureDevice.default(for: .video)!
        // front-facing camera:
        // let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)!
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            cameraSession.beginConfiguration()
            
            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput()
            
            dataOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if (cameraSession.canAddOutput(dataOutput) == true) {
                cameraSession.addOutput(dataOutput)
            }
            
            cameraSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.styletransfer.video-output")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var frame = view.frame
        frame.size.height = frame.size.height - 35.0
        
        cameraSession.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        connection.videoOrientation = .portrait
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvImageBuffer: imageBuffer)
            let img = UIImage(ciImage: ciImage).resizeTo(CGSize(width: 720, height: 720))
            if let uiImage = img {
                let outImage = applyStyleTransfer(uiImage: uiImage)
                DispatchQueue.main.async {
                    self.imageView.image = outImage
                }
            }
        }
    }
    
    private func applyStyleTransfer(uiImage: UIImage) -> UIImage {
        if(perform_transfer){
            let input = styleInput(inputImage: uiImage.buffer()!)
            let outFeatures = try! model.prediction(from: input)
            let output = outFeatures.featureValue(for: "outputImage")!.imageBufferValue!
            return toUIImage(pixelBuffer: output)
        } else {
            return uiImage
        }
    }
    
    private func toUIImage(pixelBuffer: CVPixelBuffer) -> UIImage {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, nil, &cgImage)
        return UIImage(cgImage: cgImage!)
    }
    
    @IBAction func toggle_transfer(_ sender: Any) {
        perform_transfer = !perform_transfer
        self.saveImageButton.isEnabled = perform_transfer
    }
    
    // following 2 functions from https://www.hackingwithswift.com/example-code/media/uiimagewritetosavedphotosalbum-how-to-write-to-the-ios-photo-album
    @IBAction func save_image(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, #selector(image_callback(_:didFinishSavingWithError:contextInfo:)), nil)
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
    
}

extension UIImage {
    func buffer() -> CVPixelBuffer? {
        return UIImage.buffer(from: self)
    }
    
    // Taken from:
    // https://stackoverflow.com/questions/44462087/how-to-convert-a-uiimage-to-a-cvpixelbuffer
    // https://www.hackingwithswift.com/whats-new-in-ios-11
    static func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func resizeTo(_ size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

