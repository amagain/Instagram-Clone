//
//  SimpleCameraView.swift
//  SimpleCamera
//
//

import AVFoundation

import UIKit

class SimpleCameraView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        (layer as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        (layer as! AVCaptureVideoPreviewLayer).masksToBounds = true
        
    }
    
    func set(session: AVCaptureSession) {
        
        (layer as! AVCaptureVideoPreviewLayer).session = session
        
    }
    
    override class var layerClass: AnyClass {
        
        return AVCaptureVideoPreviewLayer.self
        
    }
    
}
