//
//  LocalPhotosViewController.swift
//  HackathonBase
//
//  Created by Sihao Lu, Vincent Yan on 9/13/15.
//  Copyright © 2015 Sihao Lu, Vincent Yan. All rights reserved.
//

import UIKit

class LocalPhotosViewController: GalleryViewController, GalleryDataSource {

    var photoURLs: [NSURL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.navigationItem.title = "Stored photos"
        self.edgesForExtendedLayout = .None
        do {
            let contentURLs = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(NSTemporaryDirectory()).filter({ (path) -> Bool in
                return (path as NSString).pathExtension == "jpg"
            }).map { (path) -> NSURL in
                return NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(path))
            }
            photoURLs += contentURLs
            self.reloadData()
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.setToolbarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gallery(gallery: GalleryViewController, numberOfImagesInSection section: Int) -> Int {
        return photoURLs.count
    }
    
    func gallery(gallery: GalleryViewController, imageURLAtIndexPath indexPath: NSIndexPath) -> NSURL {
        return photoURLs[indexPath.row]
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
