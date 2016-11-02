//
//  UIImage+Extensions.swift
//  Bonje
//
//  Created by Arjan van der Laan on 12/07/16.
//  Copyright © 2016 Arjan van der Laan. All rights reserved.
//

import UIKit
import CoreImage

extension UIImage {
    func blackAndWhite() -> UIImage {
        let beginImage = UIKit.CIImage(CGImage: self.CGImage!)
        let blackAndWhite: UIKit.CIImage = UIKit.CIFilter(name: "CIColorControls", withInputParameters: [kCIInputImageKey : beginImage, "inputBrightness" : 0.0, "inputContrast" : 1.1, "inputSaturation" : 0.0])!.outputImage!
        let output: UIKit.CIImage = CIFilter(name: "CIExposureAdjust", withInputParameters: [kCIInputImageKey : blackAndWhite, "inputEV" : 0.7])!.outputImage!
        let context: CIContext = CIContext(options: nil)
        let cgiImage: CGImageRef = context.createCGImage(output, fromRect: output.extent)
        let newImage: UIImage = UIImage(CGImage: cgiImage, scale: 0, orientation: self.imageOrientation)
        
        return newImage
    }
}
