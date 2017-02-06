//
//  CameraOverlayView.swift
//  DayLapse
//
//  Created by Saiday on 9/17/16.
//  Copyright © 2016 saiday. All rights reserved.
//

import UIKit

import PureLayout
import RxSwift
import RxCocoa

class CameraOverlayView: UIView, DeviceMotionRecorderDelegate {
    weak var overlayView: UIImageView!
    weak var shotButton: UIButton!
    weak var previewButton: UIButton!
    weak var cancelButton: UIButton!
    weak var imagePickerController: UIImagePickerController?
    weak var deviceMotionRecorder: DeviceMotionRecorder?
    var lastGravityData: (Double, Double, Double)? {
        didSet {
            print("last gravity data =  \(lastGravityData)")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        initCustomViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setOverlayImage(image: UIImage?) {
        if let image = image {
            overlayView.image = image
        }
    }
    
    func setupBindings() {
        _ = overlayView.rx.observe(Bool.self, #keyPath(UIView.hidden)).subscribe(onNext: { [unowned self] (isHidden) in
            self.previewButton.isSelected = isHidden!
            })
    }
    
    func setupSubviews() {
        let overlayView = UIImageView(forAutoLayout: ())
        let screenWidth = UIScreen.main.bounds.size.width
        let cameraPreviewRatio: CGFloat = 4.0 / 3.0
        overlayView.autoSetDimensions(to: CGSize(width: screenWidth, height: screenWidth * cameraPreviewRatio))
        overlayView.layer.isOpaque = false
        overlayView.isOpaque = false
        self.addSubview(overlayView)
        overlayView.autoPinEdge(toSuperviewEdge: .top)
        overlayView.autoAlignAxis(toSuperviewAxis: .vertical)
        self.overlayView = overlayView
        
        let controlsView = UIView(forAutoLayout: ())
        self.addSubview(controlsView)
        controlsView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .top)
        controlsView.autoPinEdge(.top, to: .bottom, of: overlayView)
        
        let shotButton = UIButton(type: .custom)
        shotButton.setImage(UIImage(named: "shot"), for: .normal)
        shotButton.setImage(UIImage(named: "shot_highlight"), for: .highlighted)
        controlsView.addSubview(shotButton)
        shotButton.autoCenterInSuperview()
        self.shotButton = shotButton
        
        let previewButton = UIButton(type: .custom)
        previewButton.setImage(UIImage(named: "preview"), for: .normal)
        previewButton.setImage(UIImage(named: "preview_disabled"), for: .selected)
        controlsView.addSubview(previewButton)
        previewButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        previewButton.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        self.previewButton = previewButton
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        controlsView.addSubview(cancelButton)
        cancelButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        cancelButton.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        self.cancelButton = cancelButton
    }
    
    func initCustomViews() {
        overlayView.alpha = 0.5
        
        shotButton.addTarget(self, action: #selector(shotTapped), for: .touchUpInside)
        previewButton.addTarget(self, action: #selector(previewTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    func shotTapped() {
        overlayView.isHidden = true
        if let picker = imagePickerController {
            picker.takePicture()
        }
        
        if let recorder = deviceMotionRecorder {
            recorder.enableMotionManager(false)
        }
    }
    
    func previewTapped() {
        overlayView.isHidden = !overlayView.isHidden
    }
    
    func cancelTapped() {
        if let picker = imagePickerController {
            picker.dismiss(animated: true, completion: nil)
        }
        
        if let recorder = deviceMotionRecorder {
            recorder.enableMotionManager(false)
        }
    }
    
    // MARK: DeviceMotionRecorderDelegate
    func deviceMotionRecorderDidUpdate(gravityData: (Double, Double, Double)) {
        print("x: \(gravityData.0), y: \(gravityData.2), z:\(gravityData.2)")
    }
}
