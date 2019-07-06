//
//  SimpleCamera.swift
//  SimpleCamera
//
//

import AVFoundation

import Photos

/*
 AVCaptureSession.startRunning() is a blocking call which can
 take a long time. We dispatch session setup to the sessionQueue so
 that the main queue isn't blocked, which keeps the UI responsive.
 */


class SimpleCamera: NSObject, SimpleCameraProtocol {
    
    fileprivate lazy var session: AVCaptureSession = {
        
        return AVCaptureSession()
        
    }()
    
    fileprivate lazy var movieOutput: AVCaptureMovieFileOutput = {
        
        return AVCaptureMovieFileOutput()
        
    }()
    
    fileprivate lazy var photoOutput: AVCapturePhotoOutput = {
        
        return AVCapturePhotoOutput()
        
    }()
    
    fileprivate var isCaptureSessionConfigured = false
    
    fileprivate var photoSampleBuffer: CMSampleBuffer?
    
    fileprivate var previewPhotoSampleBuffer: CMSampleBuffer?
    
    fileprivate var activeInput: AVCaptureDeviceInput?
    
    fileprivate var outputURL: URL?
    
    fileprivate var videoSessionPreset: AVCaptureSession.Preset = AVCaptureSession.Preset.high
    
    fileprivate var photoSessionPreset: AVCaptureSession.Preset = AVCaptureSession.Preset.photo
    
    fileprivate var cameraPosition: SimpleCameraPosition = .back
    
    fileprivate var photoCompletionHandler: PhotoCompletionHandler?
    
    fileprivate var videoCompletionHandler: VideoCompletionHandler?
    
    fileprivate var flashMode: SimpleCameraFlashMode = .off
    
    fileprivate var cameraView: SimpleCameraView
    
    fileprivate var isCameraAuthorized: Bool {
        
        get {
            
            let cameraMediaType = AVMediaType.video
            
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
            
            if cameraAuthorizationStatus == .authorized {
                
                return true
                
            }
            else {
                
                return false
                
            }
            
        }
        
    }
    
    var currentCaptureMode: SimpleCameraCaptureMode = .photo
    
    private lazy var videoDeviceDiscoverySession = {
        
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)
        
    }()
    
    private override init() {
        
        self.cameraView = SimpleCameraView()
        
    }
    
    init(cameraView: SimpleCameraView) {
        
        self.cameraView = cameraView
        
    }
    
    init(cameraView: SimpleCameraView, videoPreset: AVCaptureSession.Preset, photoPreset: AVCaptureSession.Preset, cameraPosition: SimpleCameraPosition, captureMode: SimpleCameraCaptureMode) {
        
        self.videoSessionPreset = videoPreset
        
        self.photoSessionPreset = photoPreset
        
        self.cameraPosition = cameraPosition
        
        self.currentCaptureMode = captureMode
        
        self.cameraView = cameraView
        
    }
    
    init(cameraView: SimpleCameraView, cameraPosition: SimpleCameraPosition, captureMode: SimpleCameraCaptureMode) {
        
        self.cameraPosition = cameraPosition
        
        self.currentCaptureMode = captureMode
        
        self.cameraView = cameraView
        
    }
    
    func getFlashSettingName(captureMode: SimpleCameraCaptureMode) -> String? {
        
        switch captureMode {
            
        case .photo:
            
            return flashMode.description
            
        case .video:
            
            return currentTorchMode()?.1
            
        }
        
    }
    
    func toggleCamera() {
        
        sessionQueue().async { [unowned self] in
            
            guard let activeInput = self.activeInput else { return }
            
            let currentVideoDevice = activeInput.device
            
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch currentPosition {
                
            case .unspecified, .front:
                
                preferredPosition = .back
                
                preferredDeviceType = .builtInDualCamera
                
            case .back:
                
                preferredPosition = .front
                
                preferredDeviceType = .builtInWideAngleCamera
                
            }
            
            self.changeCameraPosition(activeInput: activeInput, preferredPosition: preferredPosition, preferredDeviceType: preferredDeviceType)
            
        }
        
    }
    
    func setCamera(position: SimpleCameraPosition) {
        
        sessionQueue().async { [unowned self] in
        
            guard let activeInput = self.activeInput else { return }
            
            let currentVideoDevice = activeInput.device
            
            let currentPosition = currentVideoDevice.position
            
            if currentPosition == self.cameraPosition.value() {
                
                return
                
            }
            
            let preferredPosition: AVCaptureDevice.Position
            
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch position {
                
            case .back:
                
                preferredDeviceType = .builtInDualCamera
                
                preferredPosition = AVCaptureDevice.Position.back
                
            case .front:
                
                preferredDeviceType = .builtInDualCamera
                
                preferredPosition = AVCaptureDevice.Position.front
                
            }
            
            self.changeCameraPosition(activeInput: activeInput, preferredPosition: preferredPosition, preferredDeviceType: preferredDeviceType)
        
        }
        
    }
    
    fileprivate func changeCameraPosition(activeInput: AVCaptureDeviceInput, preferredPosition: AVCaptureDevice.Position, preferredDeviceType: AVCaptureDevice.DeviceType) {
        
        let devices = self.videoDeviceDiscoverySession.devices
        
        var newVideoDevice: AVCaptureDevice? = nil
        
        // First, look for a device with both the preferred position and device type. Otherwise, look for a device with only the preferred position.
        if let device = devices.filter({ $0.position == preferredPosition && $0.deviceType == preferredDeviceType }).first {
            
            newVideoDevice = device
            
        }
        else if let device = devices.filter({ $0.position == preferredPosition }).first {
            
            newVideoDevice = device
            
        }
        
        if let videoDevice = newVideoDevice {
            
            do {
                
                if videoDevice.position == .front || videoDevice.position == .unspecified {
                    
                    self.setTorchMode(newTorchMode: SimpleCameraTorchMode.off)
                    
                    self.setFlashMode(newFlashMode: SimpleCameraFlashMode.off)
                    
                }
                else {
                    
                    self.setTorchMode(newTorchMode: SimpleCameraTorchMode.na)
                    
                    self.setFlashMode(newFlashMode: SimpleCameraFlashMode.na)
                    
                }
                
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                
                self.session.beginConfiguration()
                
                // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
                self.session.removeInput(activeInput)
                
                if self.session.canAddInput(videoDeviceInput) {
                    self.session.addInput(videoDeviceInput)
                    self.activeInput = videoDeviceInput
                }
                else {
                    self.session.addInput(activeInput)
                }
                
                if let connection = self.movieOutput.connection(with: AVMediaType.video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
                
                self.session.commitConfiguration()
            }
            catch {
                print("Error occured while creating video device input: \(error)")
            }
            
        }
        
    }
    
    func setPhotoMode() {
        
        sessionQueue().async { [unowned self] in
            
            self.session.beginConfiguration()
            
            self.session.removeOutput(self.movieOutput)
            
            self.session.sessionPreset = self.photoSessionPreset
            
            self.setFlashMode(newFlashMode: .off)
            
            self.setTorchMode(newTorchMode: .off)
            
            self.currentCaptureMode = SimpleCameraCaptureMode.photo
            
            self.session.commitConfiguration()
            
        }
        
    }
    
    func setVideoMode() {
        
        sessionQueue().async { [unowned self] in
            
            if self.session.canAddOutput(self.movieOutput) {
                
                self.session.beginConfiguration()
                
                self.session.addOutput(self.movieOutput)
                
                self.session.sessionPreset = self.videoSessionPreset
                
                self.setTorchMode(newTorchMode: .off)
                
                self.setFlashMode(newFlashMode: .off)
                
                self.currentCaptureMode = SimpleCameraCaptureMode.video
                
                self.session.commitConfiguration()
                
            }
            
        }
        
    }
    
    func toggleFlash(captureMode: SimpleCameraCaptureMode) -> String? {
        
        var modeName: String? = ""
        
        switch captureMode {
            
        case .photo:
            modeName = toggleFlashMode()
            
        case .video:
            modeName = toggleTorchMode()
            
        }
        
        return modeName
        
    }
    
    // MARK:- Flash Modes (Still Photo)
    func setFlashMode(newFlashMode: SimpleCameraFlashMode) {
        
        flashMode = newFlashMode
        
    }
    
    func toggleFlashMode() -> String? {
        
        guard let activeInput = activeInput else { return nil }
        
        if activeInput.device.position == .front || activeInput.device.position == .unspecified {
            
            flashMode = SimpleCameraFlashMode.na
            
        }
        else {
            
            var currentMode = flashMode.rawValue
            
            currentMode += 1
            
            if currentMode > 2 {
                
                currentMode = 0
                
            }
            
            flashMode = SimpleCameraFlashMode(rawValue: currentMode)!
            
        }
        
        var flashModeName = ""
        
        switch flashMode {
            
        case .auto:
            flashModeName = "AUTO"
            
        case .off:
            flashModeName = "OFF"
            
        case .on:
            flashModeName = "ON"
            
        case .na:
            flashModeName = "N/A"
        }
        
        return flashModeName
        
    }
    
    // MARK: Torch Modes (Video)
    func setTorchMode(newTorchMode: SimpleCameraTorchMode) {
        
        guard let device = activeInput?.device else { return }
        
        if (device.hasTorch) {
            
            let newMode = AVCaptureDevice.TorchMode(rawValue: newTorchMode.rawValue)!
            
            if device.isTorchModeSupported(newMode) {
                do {
                    try device.lockForConfiguration()
                    device.torchMode = newMode
                    device.unlockForConfiguration()
                    //flashLabel.text = currentFlashMode().name
                } catch {
                    print("Error setting torch mode: \(error)")
                }
            }
            
        }
    }
    
    
    func toggleTorchMode() -> String? {
        
        guard let activeInput = activeInput else { return nil }
        
        let device = activeInput.device
        
        if device.hasTorch {
            
            guard var currentMode = currentTorchMode()?.mode else { return nil }
            
            if activeInput.device.position == .front || activeInput.device.position == .unspecified {
                
                currentMode = 0
                
            }
            else {
                
                currentMode += 1
                
                if currentMode > 1 {
                    
                    currentMode = 0
                    
                }
                
            }
            
            let newMode = AVCaptureDevice.TorchMode(rawValue: currentMode)!
            
            if device.isTorchModeSupported(newMode) {
                do {
                    
                    try device.lockForConfiguration()
                    
                    device.torchMode = newMode
                    
                    device.unlockForConfiguration()
                    
                    return currentTorchMode()?.name
                    
                } catch {
                    
                    print("Error setting torch mode: \(error)")
                    
                }
                
            }
            
        }
        
        return nil
    }
    
    fileprivate func currentTorchMode() -> (mode: Int, name: String)? {
        
        guard let activeInput = activeInput else { return nil }
        
        let currentMode = activeInput.device.torchMode.rawValue
        
        var modeName: String!
        
        switch currentMode {
        case 0:
            modeName = "OFF"
        case 1:
            modeName = "ON"
        default:
            modeName = "OFF"
        }
        
        if !activeInput.device.hasFlash {
            modeName = "N/A"
        }
        
        return (currentMode, modeName)
        
    }
    
    
    func setupPreview() -> AVCaptureSession {
        
        return session
        
    }
    
    func configureSession() -> Bool {
        
        cameraView.set(session: session)
        
        // prepare to make changes
        session.beginConfiguration()
        
        switch currentCaptureMode {
            
        case.photo:
            
            session.sessionPreset = photoSessionPreset
            
        case .video:
            
            session.sessionPreset = videoSessionPreset
            
        }
        
        // Setup for Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone!)
            if session.canAddInput(micInput) {
                session.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        do {
            // create a video capture device
            
            let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
            // try creating a device input for the video capture device – note: this might throw an exception!
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
            // check whether we can add this device input to our session
            if session.canAddInput(videoDeviceInput) {
                // we can – add it!
                session.addInput(videoDeviceInput)
                activeInput = videoDeviceInput
            } else {
                // we can't – escape!
                print("Failed to add video device input")
                session.commitConfiguration()
                return false
            }
            // check whether we can add our photo output
            
            if session.canAddOutput(photoOutput) {
                // we can – add it!
                session.addOutput(photoOutput)
                // request high-res photo support
                photoOutput.isHighResolutionCaptureEnabled = true
            } else {
                // we can't – escape!
                print("Failed to add photo output")
                session.commitConfiguration()
                return false
            }
            
        } catch {
            // something went wrong – escape!
            print("Failed to create device input: \(error)")
            session.commitConfiguration()
            return false
        }
        
        // if we made it here then everything went well – commit the configuration
        session.commitConfiguration()
        
        // start the capture session
        self.sessionQueue().async {
            self.session.startRunning()
        }
        
        // return success
        return true
        
    }
    
    func stopSession() {
        
        if session.isRunning {
            
            sessionQueue().async { [unowned self] in
                
                self.session.stopRunning()
                
            }
            
        }
        
    }
    
    func startSession() {
        
        if self.isCaptureSessionConfigured {
            
            if !self.session.isRunning {
                
                self.sessionQueue().async {
                    
                    self.session.startRunning()
                    
                }
                
            }
            
        } else {
            // First time: request camera access, configure capture session and start it.
            self.checkCameraAuthorization({ [weak self] authorized in
                
                guard let strongSelf = self else { return }
                
                guard authorized else {
                    print("Permission to use camera denied.")
                    return
                }
                
                strongSelf.sessionQueue().async {
                    if strongSelf.configureSession() {
                        strongSelf.isCaptureSessionConfigured = true
                        strongSelf.session.startRunning()
                    }
                    
                }
                
            })
            
        }
        
    }
    
    func sessionQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    //MARK:- Camera Orientation
    
    fileprivate func currentVideoOrientation() -> AVCaptureVideoOrientation {
        
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        return orientation
    }
    
    fileprivate func checkCameraAuthorization(_ completionHandler: @escaping ((_ authorized: Bool) -> Void)) {
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            
        case .authorized:
            //The user has previously granted access to the camera.
            
            completionHandler(true)
            
        case .notDetermined:
            // The user has not yet been presented with the option to grant video access so request access.
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { success in
                completionHandler(success)
            })
            
        case .denied:
            // The user has previously denied access.
            completionHandler(false)
            
        case .restricted:
            // The user doesn't have the authority to request access e.g. parental restriction.
            completionHandler(false)
        }
    }
    
    func takePhoto(photoCompletionHandler: @escaping PhotoCompletionHandler) {
        
        if currentCaptureMode != .photo {
            
            return
            
        }
        
        let photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        
        var flashModeSetting: AVCaptureDevice.FlashMode!
        
        switch flashMode {
            
        case .auto:
            flashModeSetting = AVCaptureDevice.FlashMode.auto
            
        case.off:
            flashModeSetting = AVCaptureDevice.FlashMode.off
            
        case .on:
            flashModeSetting = AVCaptureDevice.FlashMode.on
            
        case .na:
            
            flashModeSetting = AVCaptureDevice.FlashMode.off
            
        }
        
        photoSettings.flashMode = flashModeSetting
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        self.photoCompletionHandler = photoCompletionHandler
        
    }
    
    func takeVideo(videoCompletionHandler: @escaping VideoCompletionHandler) {
        
        if currentCaptureMode != .video {
            
            return
            
        }
        
        if movieOutput.isRecording == false {
            
            if let connection = movieOutput.connection(with: AVMediaType.video) {
            
                if connection.isVideoOrientationSupported {
                    
                    connection.videoOrientation = currentVideoOrientation()
                    
                }
                
                if connection.isVideoStabilizationSupported {
                    
                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                    
                }
                
            }
            
            guard let device = activeInput?.device else {
                
                videoCompletionHandler(nil, false)
                
                return
                
            }
            
            if device.isSmoothAutoFocusSupported {
                
                do {
                    
                    try device.lockForConfiguration()
                    
                    device.isSmoothAutoFocusEnabled = false
                    
                    device.unlockForConfiguration()
                    
                } catch {
                    
                    print("Error setting configuration: \(error)")
                    
                }
                
            }
            
            outputURL = tempURL()
            
            movieOutput.startRecording(to: outputURL!, recordingDelegate: self)
            
            self.videoCompletionHandler = videoCompletionHandler
            
        }
        else {
            
            stopRecording()
            
        }
        
    }
    
    
    func stopRecording() {
        
        if movieOutput.isRecording == true {
            
            movieOutput.stopRecording()
            
        }
        
    }
    
}

extension SimpleCamera: AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    
    //MARK:- Video Methods
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
            
            videoCompletionHandler!(nil, false)
            
        } else {
            
            let videoRecorded = outputURL! as URL
            
            videoCompletionHandler!(videoRecorded, true)
            
        }
        
    }
    
    func tempURL() -> URL? {
        
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            
            return URL(fileURLWithPath: path)
            
        }
        
        return nil
        
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     willBeginCaptureFor resolvedSettings:
        AVCaptureResolvedPhotoSettings) {
        // update the UI?
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        guard error == nil, let photoSampleBuffer = photoSampleBuffer else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        self.photoSampleBuffer = photoSampleBuffer
        
        self.previewPhotoSampleBuffer = previewPhotoSampleBuffer
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        guard let photoCompletionHandler = self.photoCompletionHandler else { return }

        guard error == nil else {

            print("Error in capture process: \(String(describing: error))")

            photoCompletionHandler(nil, false)

            return

        }

        guard let imageData = photo.fileDataRepresentation() else {

            print("Unable to create image data.")

            photoCompletionHandler(nil, false)

            return

        }

        photoCompletionHandler(imageData, true)

    }

    /*
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {

        guard let photoCompletionHandler = self.photoCompletionHandler else { return }

        guard error == nil else {

            print("Error in capture process: \(String(describing: error))")

            photoCompletionHandler(nil, true)

            return

        }

        if let photoSampleBuffer = self.photoSampleBuffer {

            guard let jpegData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(
                forJPEGSampleBuffer: photoSampleBuffer,
                previewPhotoSampleBuffer: self.previewPhotoSampleBuffer)
                else {

                    print("Unable to create JPEG data.")

                    photoCompletionHandler(nil, true)

                    return
            }

            photoCompletionHandler(jpegData, false)

        }

    }
    */
    
    /*
    func saveSampleBufferToPhotoLibrary(_ sampleBuffer: CMSampleBuffer,
                                        previewSampleBuffer: CMSampleBuffer?,
                                        completionHandler: ((_ success: Bool, _ error: Error?) -> Void)?) {
        
        guard let jpegData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(
            forJPEGSampleBuffer: sampleBuffer,
            previewPhotoSampleBuffer: previewSampleBuffer)
            else {
                print("Unable to create JPEG data.")
                completionHandler?(false, nil)
                return
        }
        
        PHPhotoLibrary.shared().performChanges( {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: PHAssetResourceType.photo, data: jpegData, options: nil)
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                completionHandler?(success, error)
            }
        })
        
    }
     */
    
}
