//
//  ImageCaptureVC.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 11/20/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Parse

class ImageCaptureVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var imageCaptured = false
    
    @IBOutlet weak var retakePhotoOutlet: UIButton!
    @IBOutlet weak var postItemOutlet: UIButton!
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captureButtonOutlet: UIButton!
    
    @IBAction func captureImageAction(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func retakePhotoAction(_ sender: Any) {
        toggleHideImageView()
    }
    
    @IBAction func postItemAction(_ sender: Any) {
        let Item = PFObject(className: "Items")
        Item["Category"] = "Clothing"
        Item[""] = ""
        Item[""] = ""
        Item[""] = ""
        Item[""] = ""
        DataModel.currentAddItemPage = "Name"
        self.performSegue(withIdentifier: "mapUnwind", sender: nil)
    }
    override func viewDidLoad() {
        print("in image capture")
        //navigationItem.rightBarButtonItem = nil
        captureButtonOutlet.layer.borderColor = UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor
        captureButtonOutlet.layer.borderWidth = 3.0
        captureButtonOutlet.layer.cornerRadius =  captureButtonOutlet.frame.width/2
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        runCaptureSession()
        print(imageView.frame, "before1 ")
    }

    override func viewDidAppear(_ animated: Bool) {
       self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        imageView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if imageCaptured {
            imageView.isHidden = false
        }
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func toggleHideImageView() {
        if imageView.isHidden {
            imageView.isHidden = false
            retakePhotoOutlet.isHidden = false
            postItemOutlet.isHidden = false
        } else {
            imageView.isHidden = true
            retakePhotoOutlet.isHidden = true
            postItemOutlet.isHidden = true
            imageCaptured = false
        }
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                print("made it")
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                print("made it 2")
                frontCamera = device
            }
        }
        print("made it here device")
        currentCamera = backCamera
    }
    
    func setupInputOutput() {
        do {
            print("after")
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            if self.captureSession.canAddOutput(photoOutput!) {
                self.captureSession.addOutput(photoOutput!)
            }
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
        } catch {
            print(error)
        }
        
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = .resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func runCaptureSession() {
        captureSession.startRunning()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            imageView.image = UIImage(data: imageData)
            imageCaptured = true
            toggleHideImageView()
        }
    }
    
    
}

