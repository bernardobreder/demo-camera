//
//  ViewController.swift
//  demo-camera-ios
//
//  Created by Bernardo Breder on 04/08/19.
//  Copyright © 2019 Bernardo Breder. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    // AVCapturePhotoOutput
    let stillImageOutput = AVCaptureStillImageOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: .back)
        let devices = discovery.devices.filter({ $0.hasMediaType(AVMediaType.video) && $0.position == AVCaptureDevice.Position.back }).first
        if let captureDevice = devices, let input = try? AVCaptureDeviceInput(device: captureDevice) {
            captureSession.addInput(input)
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
            captureSession.startRunning()
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecType.jpeg]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.bounds = view.bounds
            previewLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            let cameraPreview = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.size.width, height: view.bounds.size.height))
            cameraPreview.layer.addSublayer(previewLayer)
            cameraPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveToCamera(sender:))))
            view.addSubview(cameraPreview)
        }
    }
    
    @objc func saveToCamera(sender: UITapGestureRecognizer) {
        if let videoConnection = stillImageOutput.connection(with: AVMediaType.video) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                guard let imageDataSampleBuffer = imageDataSampleBuffer else { return }
                guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer), let image = UIImage(data: imageData) else { return }
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }


}

