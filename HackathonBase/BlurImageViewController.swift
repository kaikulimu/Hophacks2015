//
//  BlurImageViewController.swift
//  HackathonBase
//
//  Created by Sihao Lu, Vincent Yan on 9/12/15.
//  Copyright © 2015 Sihao Lu, Vincent Yan. All rights reserved.
//

import UIKit
import JGProgressHUD

let tileSize: CGSize = CGSizeMake(100, 40)

class BlurImageViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var replacedTiles = Set<NSIndexPath>()
    
    var originalImage: UIImage!
    var originalOrientation: UIImageOrientation!
    var blurredImage: UIImage!
    var previousPoint: CGPoint?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.image = originalImage
        
        let hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        hud.textLabel.text = "Pre-processing..."
        hud.showInView(view)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            let halfSize = CGSizeMake(self.originalImage.size.width / 2, self.originalImage.size.height / 2)
            let hasAlpha = false
            let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
            UIGraphicsBeginImageContextWithOptions(halfSize, !hasAlpha, scale)
            self.originalImage.drawInRect(CGRect(origin: CGPointZero, size: halfSize))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.originalImage = scaledImage
            self.blurredImage = scaledImage.blurredImage.imageByFixingOrientationFromSourceImage(self.originalOrientation)
            dispatch_async(dispatch_get_main_queue()) {
                self.imageView.image = self.originalImage
                hud.dismiss()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    @IBAction func nextStep(sender: UIBarButtonItem) {
        let hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        hud.textLabel.text = "Saving blurred image..."
        hud.showInView(view)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            let exportedImage = self.exportedImage()
            EncryptionCore.sharedInstance.archiveBlurredImage(exportedImage, withOriginalImage: self.originalImage, metadata: nil, completionBlock: { (path, error) -> Void in
                print(path)
            })
            dispatch_async(dispatch_get_main_queue()) {
                hud.dismiss()
                self.finish()
            }
        }
    }
    
    private func finish() {
        performSegueWithIdentifier("Finish", sender: self)
    }
    
    private func askToSharePhotoWithPath(path: String) {
        
    }
    
    @IBAction func clearBlur(sender: UIBarButtonItem) {
        replacedTiles.removeAll()
        imageView.image = originalImage
    }
    
    @IBAction func panGestureDetected(sender: UIPanGestureRecognizer) {
        let point = sender.locationInView(imageView)
        switch sender.state {
        case .Began:
            replaceTileAtPoint(point)
            previousPoint = point
        case .Changed:
            replaceTilesFromPoint(previousPoint!, toPoint: point)
            previousPoint = point
        case .Ended:
            replaceTilesFromPoint(previousPoint!, toPoint: point)
            previousPoint = nil
        default:
            break
        }
    }
    
    private func replaceTilesFromPoint(point1: CGPoint, toPoint point2: CGPoint) {
        let absolutePoint = CGPointMake(point1.x / imageView.frame.size.width, point1.y / imageView.frame.size.height)
        let count = CGSizeMake(blurredImage.size.width / tileSize.width, blurredImage.size.height / tileSize.height)
        let gridOnDisplay = sliceRectWithAbsolutePoint(absolutePoint, size: imageView.frame.size, count: count)
        let offset = CGPointMake(point2.x - point1.x, point2.y - point1.y)
        let iterations = max(abs(offset.x / gridOnDisplay.size.width), abs(offset.y / gridOnDisplay.size.height))
        let unitMovement = CGPointMake(offset.x / iterations, offset.y / iterations)
        var point = point1
        for _ in 0..<Int(ceil(iterations)) {
            replaceTileAtPoint(point)
            point = CGPointMake(point.x + unitMovement.x, point.y + unitMovement.y)
        }
    }
    
    private func replaceTileAtPoint(point: CGPoint) {
        let absolutePoint = CGPointMake(point.x / imageView.frame.size.width, point.y / imageView.frame.size.height)
        guard absolutePoint.x >= 0 && absolutePoint.x <= 1 && absolutePoint.y >= 0 && absolutePoint.y <= 1 else {
            return
        }
        let gridOnSource = blurredImage.sliceRectWithAbsolutePoint(absolutePoint)
        let count = CGSizeMake(originalImage.size.width / tileSize.width, originalImage.size.height / tileSize.height)
        let gridOnDisplay = sliceRectWithAbsolutePoint(absolutePoint, size: imageView.frame.size, count: count)
        let tSize = CGSizeMake(imageView.frame.size.width / count.width, imageView.frame.size.height / count.height)
        let screenIndexPath = NSIndexPath(indexes: [Int(gridOnDisplay.origin.x / tSize.width), Int(gridOnDisplay.origin.y / tSize.height)], length: 2)
        guard replacedTiles.contains(screenIndexPath) == false else {
            return
        }
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, true, UIScreen.mainScreen().scale)
        imageView.image!.drawInRect(imageView.bounds)
        replacedTiles.insert(screenIndexPath)
        let croppedImage = UIImage(CGImage: CGImageCreateWithImageInRect(blurredImage.CGImage!, gridOnSource)!)
        croppedImage.drawInRect(gridOnDisplay)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        imageView.image = image
        UIGraphicsEndImageContext()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func exportedImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(originalImage.size, true, UIScreen.mainScreen().scale)
        let count = CGSizeMake(originalImage.size.width / tileSize.width, originalImage.size.height / tileSize.height)
        originalImage.drawAtPoint(CGPointZero)
        for x in 0..<Int(count.width) {
            for y in 0..<Int(count.height) {
                let indexPath = NSIndexPath(indexes: [x, y], length: 2)
                if replacedTiles.contains(indexPath) {
                    let gridOnSource = CGRectMake(CGFloat(x) * tileSize.width, CGFloat(y) * tileSize.height, tileSize.width, tileSize.height)
                    let croppedImage = UIImage(CGImage: CGImageCreateWithImageInRect(blurredImage.CGImage!, gridOnSource)!)
                    croppedImage.drawInRect(gridOnSource)
                }
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func sliceRectWithAbsolutePoint(absolutePoint: CGPoint, size: CGSize, count: CGSize) -> CGRect {
        let targetImagePoint = CGPointMake(absolutePoint.x * size.width, absolutePoint.y * size.height)
        let tSize = CGSizeMake(size.width / count.width, size.height / count.height)
        let clampedTargetImagePoint = CGPoint(x: Int(round(targetImagePoint.x / tSize.width)) * Int(tSize.width), y : Int(round(targetImagePoint.y / tSize.height)) * Int(tSize.height))
        return CGRect(origin: clampedTargetImagePoint, size: tSize)
    }
}

extension UIImage {
    func sliceRectWithAbsolutePoint(absolutePoint: CGPoint) -> CGRect {
        let targetImagePoint = CGPointMake(absolutePoint.x * size.width, absolutePoint.y * size.height)
        let clampedTargetImagePoint = CGPoint(x: Int(round(targetImagePoint.x / tileSize.width)) * Int(tileSize.width), y : Int(round(targetImagePoint.y / tileSize.height)) * Int(tileSize.height))
        return CGRect(origin: clampedTargetImagePoint, size: tileSize)
    }
}
