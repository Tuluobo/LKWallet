//
//  QRCodeViewController.swift
//  LKWallet
//
//  Created by Hao Wang on 11/11/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import UIKit
import AVKit
import SVProgressHUD

class QRCodeViewController: BaseViewController {

    var height: CGFloat!

    @IBOutlet weak var scanLineImageView: UIImageView!
    @IBOutlet weak var scanLineTopCons: NSLayoutConstraint!
    @IBOutlet weak var scanLineHeightCons: NSLayoutConstraint!
    // MARK: - 懒加载
    /// 输入对象， 竖向为
    lazy var input: AVCaptureDeviceInput? = {
        guard let capture = AVCaptureDevice.default(for: .video) else { return nil }
        return try? AVCaptureDeviceInput(device: capture)
    }()
    /// 会话
    lazy var session: AVCaptureSession = AVCaptureSession()
    /// 输出对象
    lazy var output: AVCaptureMetadataOutput =  {
        let op = AVCaptureMetadataOutput()
        // 在这里，参照坐标系和其他地方不一样
        // 在Apple iOS 中 一般以左上角为原点
        // 在这里，右上角为原点，主要是将iPhone 左转90度，转为横屏
        let viewFrame = self.view.frame
        let y = ((viewFrame.width - self.height)/2) / viewFrame.width
        let x = ((viewFrame.height - self.height)/2 - 20) / viewFrame.height
        let width = self.height / viewFrame.size.height
        let height = self.height / viewFrame.size.width
        
        op.rectOfInterest = CGRect(x: x, y: y, width: width, height: height)
        return op
    }()
    /// 预览图层
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        AVCaptureVideoPreviewLayer(session: self.session)
    }()
    
    // MARK: - 生命周期方法
    override func viewDidLoad() {
        super.viewDidLoad()
        TraceManager.shared.traceEvent(event: "scan_enter")
        
        height = scanLineHeightCons.constant
        // 设置导航右边按钮
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_gallery"), style: .plain, target: self, action: #selector(openGallery))
        // 对摄像头开始扫描处理
        scanQRCode()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 设置扫描波约束
        scanLineTopCons.constant = 0 - scanLineHeightCons.constant
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 3.0) {
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.scanLineTopCons.constant = self.scanLineHeightCons.constant
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - 内部控制方法
    private func scanQRCode() {
        guard let input = input else { return }

        if !session.canAddInput(input), !session.canAddOutput(output) { return }
        session.addInput(input)
        session.addOutput(output)
        
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        previewLayer.frame = view.frame
        view.layer.insertSublayer(previewLayer, at: 0)
        // start
        session.startRunning()
    }
    
    // MARK: - 按钮操作
    /**
     打开相册
     */
    @objc func openGallery() {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            return
        }
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        present(imagePickerVC, animated: true, completion: nil)
    }
    
    fileprivate func handleQRData(string: String?) {
        guard let accountString = string else {
            SVProgressHUD.showError(withStatus: "没有检测到二维码信息！")
            return
        }
        let account = Account(name: nil, address: accountString)
        guard AccountManager.manager.verify(account: account) else {
            SVProgressHUD.showError(withStatus: "账号格式不正确！")
            return
        }
        if AccountManager.manager.queryAllAccount().contains(account) {
            SVProgressHUD.showError(withStatus: "此账号已添加，不能被再次添加！")
            return
        }
        guard AccountManager.manager.add(accounts: [account]) else {
            SVProgressHUD.showError(withStatus: "账号保存失败！")
            return
        }
        SVProgressHUD.showSuccess(withStatus: "账号添加成功！")
        session.stopRunning()
        self.navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension QRCodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        picker.dismiss(animated: true, completion: nil)
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector!.features(in: CIImage(image: image)!)
        handleQRData(string: (features.last as? CIQRCodeFeature)?.messageString)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 处理扫描信息
        for object in metadataObjects {
            guard let dataObject = previewLayer.transformedMetadataObject(for: object) as? AVMetadataMachineReadableCodeObject else { return }
            switch dataObject.type {
            case .qr:
                handleQRData(string: dataObject.stringValue)
            default: break
            }
        }
    }

}
