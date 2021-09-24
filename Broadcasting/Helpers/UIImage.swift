//
//  Image.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 02/08/2021.
//

import UIKit
import AVFoundation

extension UIImage {
    var cvPixelBuffer: CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil
        let options: [NSObject: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: false,
            kCVPixelBufferCGBitmapContextCompatibilityKey: false,
            kCVPixelBufferMetalCompatibilityKey: true,
            kCVPixelBufferIOSurfacePropertiesKey: [:] as AnyObject
        ]
        let _ = CVPixelBufferCreate(kCFAllocatorDefault,
                                    Int(size.width),
                                    Int(size.height),
                                    kCVPixelFormatType_32BGRA,
                                    options as CFDictionary,
                                    &pixelBuffer)
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer!),
            width: CVPixelBufferGetWidth(pixelBuffer!),
            height: CVPixelBufferGetHeight(pixelBuffer!),
            bitsPerComponent: cgImage!.bitsPerComponent,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: cgImage!.colorSpace!,
            bitmapInfo: cgImage!.bitmapInfo.rawValue
        )
        context?.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }

    var cmSampleBuffer: CMSampleBuffer {
        let pixelBuffer = cvPixelBuffer
        var newSampleBuffer: CMSampleBuffer?
        var timimgInfo: CMSampleTimingInfo = CMSampleTimingInfo.invalid
        var videoInfo: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil,
                                                     imageBuffer: pixelBuffer!,
                                                     formatDescriptionOut: &videoInfo)
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                           imageBuffer: pixelBuffer!,
                                           dataReady: true,
                                           makeDataReadyCallback: nil,
                                           refcon: nil,
                                           formatDescription: videoInfo!,
                                           sampleTiming: &timimgInfo,
                                           sampleBufferOut: &newSampleBuffer)

        return newSampleBuffer!
    }
}
