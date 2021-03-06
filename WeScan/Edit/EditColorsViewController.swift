//
//  EditScanViewController.swift
//  WeScan
//
//  Created by Alejandro Reyes on 2/12/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation
import UIKit

let zillyBlue: UIColor = UIColor(red: 24/255.0, green: 172/255.0, blue: 248/255.0, alpha: 1)

final class EditColorsViewController : UIViewController {

    @IBOutlet private var slider: UISlider!
    @IBOutlet private var grayOptionView: UIView!
    @IBOutlet private var colorOptionView: UIView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var sliderView: UIView!

    private var image: UIImage
    private lazy var previousColoredImage: UIImage = image

    enum ColorOption {
        case gray, color
    }
    private var currentMode: ColorOption = .color { didSet { updateSelectedMode() } }
    var didFinishEditingImageHandler: ((UIImage) -> ())?

    // MARK: Lifecycle
    init(image: UIImage) {
        self.image = image
        let bundle = Bundle(for: EditColorsViewController.self)
        super.init(nibName: "EditColorsViewController", bundle: bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = zillyBlue
        grayOptionView.layer.borderWidth = 4.0
        colorOptionView.layer.borderWidth = 4.0
        title = NSLocalizedString("Edit Colors", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .done, target: self, action: #selector(donePressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
        imageView.image = image
        updateSelectedMode()
    }

    // MARK: Convenience
    private func updateSelectedMode() {
        if currentMode == .color {
            colorOptionView.layer.borderColor = zillyBlue.cgColor
            grayOptionView.layer.borderColor = UIColor.clear.cgColor
        } else {
            colorOptionView.layer.borderColor = UIColor.clear.cgColor
            grayOptionView.layer.borderColor = zillyBlue.cgColor
        }
        view.layoutIfNeeded()
    }

    private func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    // MARK: Actionns
    @IBAction func didTapColorOptionView(_ sender: UIButton) {
        guard currentMode != .color else { return }
        imageView.image = applyImageContrast(contrastValue: CGFloat(slider.value), with: previousColoredImage)
        currentMode = .color
        generateHapticFeedback()
    }
    
    @IBAction func didTapGrayOptionView(_ sender: UIButton) {
        guard currentMode != .gray else { return }
        previousColoredImage = imageView.image!
        imageView.image = applyImageContrast(contrastValue: CGFloat(slider.value), with: image.noir)
        currentMode = .gray
        generateHapticFeedback()
    }

    @objc private func donePressed() {
        didFinishEditingImageHandler?(imageView.image!)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func sliderDidChange(_ sender: UISlider) {
        imageView.image = applyImageContrast(contrastValue: CGFloat(sender.value))
    }

    func applyImageContrast(contrastValue: CGFloat, with newImage: UIImage? = nil) -> UIImage {
        let defaultCGImage = currentMode == .color ? image.cgImage! : image.noir!.cgImage!
        let context = CIContext(options: nil)
        let contrastFilter = CIFilter(name: "CIColorControls")!
        contrastFilter.setValue(CIImage(cgImage: newImage?.cgImage ?? defaultCGImage), forKey: "inputImage")
        contrastFilter.setValue(contrastValue, forKey: "inputContrast")
        let outputImage = contrastFilter.outputImage!
        let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        let newUIImage = UIImage(cgImage: cgImage!)
        return newUIImage
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}
