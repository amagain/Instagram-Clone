//
//  SimpleCameraProtocol.swift
//  SimpleCamera
//
//

import Foundation

import AVFoundation

typealias PhotoCompletionHandler = (_ data: Data?, _ success: Bool) -> Void

typealias VideoCompletionHandler = (_ url: URL?, _ sucess: Bool) -> Void

enum SimpleCameraPosition: Int {
    
    case front, back
    
    func value() -> AVCaptureDevice.Position {
        
        switch self {
            
        case .front:
            
            return AVCaptureDevice.Position.front
            
        case .back:
            
            return AVCaptureDevice.Position.back
            
        }
        
    }
    
}

enum SimpleCameraCaptureMode: Int {
    
    case photo = 1, video
    
    var description: String {
        
        switch self {
            
        case .photo:
            return "PHOTO"
            
        case .video:
            return "VIDEO"
            
        }
        
    }
}

enum SimpleCameraFlashMode: Int {
    
    case off = 0, on, auto, na
    
    var description: String {
        
        switch self {
            
        case .off:
            return "OFF"
            
        case .on:
            return "ON"
            
        case .auto:
            return "AUTO"
            
        case .na:
            
            return "N/A"
            
        }
    }
    
}

enum SimpleCameraTorchMode: Int {
    
    case off = 0, on, na
    
    var description: String {
        
        switch self {
            
        case .off:
            return "OFF"
            
        case .on:
            return "ON"
            
        case .na:
            return "N/A"
            
        }
    }
    
}

protocol SimpleCameraProtocol {
    
    //var isCameraAuthorized: Bool { get }
    
    //func setupPreview() -> AVCaptureSession
    
    func startSession()
    
    func stopSession()
    
    func takePhoto(photoCompletionHandler: @escaping PhotoCompletionHandler)
    
    func takeVideo(videoCompletionHandler: @escaping VideoCompletionHandler)
    
    func toggleFlash(captureMode: SimpleCameraCaptureMode) -> String?
    
    func setPhotoMode()
    
    func setVideoMode()
    
    func toggleCamera()
    
    //var movieOutput: AVCaptureMovieFileOutput { get }
    
    //var photoOutput: AVCapturePhotoOutput { get }
    
    //func stopRecording()
    
    func getFlashSettingName(captureMode: SimpleCameraCaptureMode) -> String?
    
}
