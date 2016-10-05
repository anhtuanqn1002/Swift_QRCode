//
//  ViewController.swift
//  QRCodeDemo
//
//  Created by Anh Tuan on 9/25/16.
//  Copyright © 2016 Anh Tuan. All rights reserved.
//

import UIKit
import AVFoundation
import QRCode

final class ViewController: UIViewController {

    /**
     properties
     */
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var qrCodeFrameView: UIView?
    private var messageLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let input: AVCaptureDeviceInput
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            return
        }
        captureSession = AVCaptureSession()
        captureSession?.addInput(input)
        
        let captureOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureOutput)
        captureOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode];
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        captureSession?.startRunning()
        messageLabel = UILabel(frame: CGRect(x: 0, y: 20, width: CGRectGetWidth(view.frame), height: 50))
        messageLabel?.textAlignment = .Center
        messageLabel?.layer.borderWidth = 2.0
        messageLabel?.layer.borderColor = UIColor.greenColor().CGColor
        messageLabel?.textColor = UIColor.greenColor()
        messageLabel?.text = "No QR code is detected"
        view.addSubview(messageLabel!)
        view.bringSubviewToFront(messageLabel!)
        
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.redColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            messageLabel?.text = "No QR code is detected"
            return
        }
        let metaDataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metaDataObj.type == AVMetadataObjectTypeQRCode {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metaDataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds
            if metaDataObj.stringValue != nil {
                messageLabel?.text = metaDataObj.stringValue
            }
        }
    }
}
