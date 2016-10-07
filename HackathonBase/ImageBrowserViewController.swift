//
//  ImageBrowserViewController.swift
//  HackathonBase
//
//  Created by Sihao Lu, Vincent Yan on 9/13/15.
//  Copyright © 2015 Sihao Lu, Vincent Yan. All rights reserved.
//

import UIKit
import Cartography

class ImageBrowserViewController: UIViewController, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        commonSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var imageView2: UIImageView = {
        let tempImageView = UIImageView()
        tempImageView.contentMode = .ScaleAspectFit
        tempImageView.backgroundColor = UIColor.clearColor()
        tempImageView.userInteractionEnabled = false
        return tempImageView
    }()
    
    var image: UIImage? {
        get {
            return imageView2.image
        }
        set(newImage) {
            imageView2.image = newImage
//            imageView.image = newImage
//            imageView.frame = CGRect(origin: CGPointZero, size: newImage?.size ?? view.bounds.size)
//            
//            // Adjust scroll view zooming
//            scrollView.contentSize = newImage?.size ?? self.view.bounds.size
//            let scrollViewFrame = scrollView.frame
//            let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
//            let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
//            let minScale = min(scaleWidth, scaleHeight)
//            scrollView.minimumZoomScale = minScale
//            scrollView.maximumZoomScale = 1.0
//            scrollView.zoomScale = minScale
//            
//            self.centerScrollViewContents()
        }
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView(frame: self.view.bounds)
        scrollView.contentSize = self.view.bounds.size
        scrollView.bouncesZoom = true
        scrollView.delegate = self
        
//        let view = UIView()
//        view.backgroundColor = UIColor.whiteColor()
//        scrollView.addSubview(view)
//        constrain(view) { v in
//            v.edges == inset(v.superview!.edges, 0)
//            return
//        }
        scrollView.addSubview(self.imageView)
        scrollView.bringSubviewToFront(self.imageView)
        
        // Set up gesture recognizer
        var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        return scrollView
        }()
    
    lazy var imageView: UIImageView = {
        let tempImageView = UIImageView()
        tempImageView.contentMode = .ScaleAspectFit
        tempImageView.backgroundColor = UIColor.clearColor()
        tempImageView.userInteractionEnabled = false
        return tempImageView
        }()
    
    lazy private var activityIndicator: UIActivityIndicatorView = {
        let tempActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        tempActivityIndicatorView.hidesWhenStopped = true
        return tempActivityIndicatorView
        }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerScrollViewContents()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    private func commonSetup() {
        view.addSubview(activityIndicator)
        view.addSubview(scrollView)
        view.bringSubviewToFront(scrollView)
        view.addSubview(imageView2)
        
        constrain(scrollView) { v in
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.top == v.superview!.top
            v.bottom == v.superview!.bottom
        }
        
        constrain(imageView2) { v in
            v.edges == v.superview!.edges
        }
        constrain(activityIndicator) { v in
            v.centerX == v.superview!.centerX
            v.centerY == v.superview!.centerY
        }
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        imageView.frame = contentsFrame
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.locationInView(imageView)
        
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
        
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        scrollView.zoomToRect(rectToZoomTo, animated: true)
    }
    
    
    // MARK: Scroll View Delegate
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
