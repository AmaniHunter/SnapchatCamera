//
//  ViewController.swift
//  SnapchatCamera
//
//  Created by Amani Hunter on 5/2/21.
//
import AVFoundation
import UIKit

class ViewController: UIViewController {
    // Capture session
    var session: AVCaptureSession?
    //Photo output
    let output = AVCapturePhotoOutput()
    //video preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    //shutter buttom
    private let shutterButton: UIButton = {
       let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        shutterButton.addTarget(self, action: #selector(getMedia), for: .touchUpInside)
        checkCameraPermissions()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 100)
    }
    private func checkCameraPermissions(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
    
        case .notDetermined:
            // request permission
            AVCaptureDevice.requestAccess(for: .video){[weak self] granted in
                guard granted else {return}
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
                
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    private func setUpCamera(){
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video){
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input){
                    session.addInput(input)
                }
                if session.canAddOutput(output){
                    session.addOutput(output)
                }
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                session.startRunning()
                self.session = session
            } catch{
                print(error)
            }
        }
    }
     @objc private func getMedia(){
        print("Get Media")
        
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {return}
        let image = UIImage(data: data)
        session?.stopRunning()
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        view.addSubview(imageView)
        
        
    }
}
