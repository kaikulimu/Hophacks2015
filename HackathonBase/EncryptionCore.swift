//
//  EncryptionCore.swift
//  HackathonBase
//
//  Created by Sihao Lu, Vincent Yan on 9/10/15.
//  Copyright © 2015 Sihao Lu, Vincent Yan. All rights reserved.
//

import UIKit
import zipzap
import ZipArchive
import FBSDKCoreKit
import CoreImage

typealias ArchiveCompletionBlock = (path: String?, error: NSError?) -> Void
typealias UnarchiveCompletionBlock = (blurredImagePath: String?, originalImagePath: String?, metadataPath: String?, error: NSError?) -> Void

class EncryptionCore: NSObject {
    static let sharedInstance = EncryptionCore()
    
    func archiveBlurredImage(blurredImage: UIImage, withOriginalImage originalImage: UIImage, metadata: NSData?, completionBlock: ArchiveCompletionBlock) {
        let queue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        dispatch_async(queue) {
            let randomName = (NSUUID().UUIDString as NSString).stringByAppendingPathExtension("zip")!
            let path = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(randomName)
            let url = NSURL(fileURLWithPath: path)
            let resultUDID = NSUUID().UUIDString
            let resultImageName = (resultUDID as NSString).stringByAppendingPathExtension("jpg")!
            let resultImagePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(resultImageName)
            let data = NSMutableData()
            data.appendData(UIImageJPEGRepresentation(blurredImage, 0.5)!)
            do {
                let archive = try ZZArchive(URL: url, options: [ZZOpenOptionsCreateIfMissingKey: true])
                let imageItem = ZZArchiveEntry(fileName: "\(resultUDID)-original.jpg", compress: false, dataBlock: { (error) -> NSData! in
                    return UIImageJPEGRepresentation(originalImage, 0.5)
                })
                try archive.updateEntries(
                    metadata != nil ?
                    [
                        imageItem,
                        ZZArchiveEntry(fileName: "\(resultUDID)-metadata.txt", compress: false, dataBlock: { (error) -> NSData! in
                            return metadata!
                        })
                    ] :
                    [
                        imageItem
                    ]
                )
                data.appendData(archive.contents)
                try data.writeToFile(resultImagePath, options: NSDataWritingOptions.AtomicWrite)
                try NSFileManager.defaultManager().removeItemAtPath(path)
                dispatch_async(dispatch_get_main_queue()) {
                    completionBlock(path: resultImagePath, error: nil)
                }
            } catch {
                print(error)
                dispatch_async(dispatch_get_main_queue()) {
                    completionBlock(path: nil, error: error as NSError)
                }
            }
        }
    }
    
    func unarchiveImageBundleWithPath(path: String, completionBlock: UnarchiveCompletionBlock) {
        let queue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        dispatch_async(queue) {
            let archive = ZipArchive()
            if archive.UnzipOpenFile(path) {
                let parentPath = ((path as NSString).stringByDeletingLastPathComponent as NSString).stringByAppendingPathComponent("original")
                let fileName = ((path as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
                let ret = archive.UnzipFileTo(parentPath, overWrite: true)
                if ret == false {
                    print("Fail to unarchive!!!")
                    dispatch_async(dispatch_get_main_queue()) {
                        completionBlock(blurredImagePath: nil, originalImagePath: nil, metadataPath: nil, error: NSError(domain: "Hophacks2015", code: 1, userInfo: nil))
                    }
                }
                archive.UnzipCloseFile()
                let originalImagePath = (parentPath as NSString).stringByAppendingPathComponent(fileName + "-original.jpg")
                let metadataPath = (parentPath as NSString).stringByAppendingPathComponent(fileName + "-metadata.txt")
                let metadataExists = NSFileManager.defaultManager().fileExistsAtPath(metadataPath)
                dispatch_async(dispatch_get_main_queue()) {
                    completionBlock(blurredImagePath: path, originalImagePath: originalImagePath, metadataPath: metadataExists ? metadataPath : nil, error: nil)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    completionBlock(blurredImagePath: nil, originalImagePath: nil, metadataPath: nil, error: NSError(domain: "Hophacks2015", code: 0, userInfo: nil))
                }
            }
        }
    }
}

func metadataFromItems(items: [String]) -> NSData {
    return items.joinWithSeparator("\n").dataUsingEncoding(NSUTF8StringEncoding)!
}

func itemsFromMetadata(path: String) -> [String] {
    do {
        let lines = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        return lines.componentsSeparatedByString("\n")
    } catch {
        return []
    }
}

func originalPhotoPathForBlurredPhotoAtPath(path: String) -> String {
    let parentPath = ((path as NSString).stringByDeletingLastPathComponent as NSString).stringByAppendingPathComponent("original")
    let fileName = ((path as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
    return (parentPath as NSString).stringByAppendingPathComponent(fileName + "-original.jpg")
}

typealias AvoidDupCIImage = CIImage

extension UIImage {
    var blurredImage: UIImage {
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setDefaults()
        let inputImage = AvoidDupCIImage(CGImage: self.CGImage!)
        blurFilter.setValue(inputImage, forKey: kCIInputImageKey)
        blurFilter.setValue(50, forKey: kCIInputRadiusKey)
        let outputImage = blurFilter.outputImage!
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(outputImage, fromRect: inputImage.extent)
        return UIImage(CGImage: cgImage)
    }
    
}
