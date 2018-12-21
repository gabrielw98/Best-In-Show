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
        //AF1 #cool #shoes $14.99
        //print(DataModel.name, DataModel.tags, DataModel.price)
        
        let NewItem = PFObject(className: "Item")
        NewItem["itemCategory"] = DataModel.category
        NewItem["name"] = DataModel.name
        NewItem["itemPrice"] = DataModel.price
        NewItem["tags"] = DataModel.tags
        NewItem["locationId"] = DataModel.employeeWorkPlace
        var results = DataModel.locations?.filter({ (Workplace) -> Bool in
            Workplace.objectId == DataModel.employeeWorkPlace
        })
        if let location = results![0] as? Location {
            let locationPointer = PFObject(withoutDataWithClassName: "Location", objectId: location.objectId)
            NewItem["location"] = locationPointer
        }
        if let imageData = self.imageView.image!.jpegData(.low) {
            let file = PFFile(name: "img.png", data: imageData)
            NewItem["image"] = file
        }
        NewItem.saveInBackground { (success, error) in
            if success {
                DataModel.resetAddData()
                print("Success: Item saved.")
            }
        }
        DataModel.items.insert(Item(object: NewItem, image: self.imageView.image!), at: 0)
        DataModel.currentAddItemPage = "Name"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabbarVC = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
        if let vcs = tabbarVC.viewControllers,
            let nc = vcs[1] as? UINavigationController,
            let itemVC = nc.topViewController as? ItemFeedVC {
                itemVC.fromNewItem = true
        }
        self.present(tabbarVC, animated: false, completion: nil)
        tabbarVC.selectedIndex = 1
    }
    override func viewDidLoad() {
        print(DataModel.name, DataModel.tags, DataModel.price)
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
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
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

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    var pngData: Data? { return UIImagePNGRepresentation(self) }
    
    func jpegData(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}
