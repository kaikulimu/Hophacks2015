//
//  FriendListTableViewController.swift
//  HackathonBase
//
//  Created by Sihao Lu, Vincent Yan on 9/13/15.
//  Copyright © 2015 Sihao Lu, Vincent Yan. All rights reserved.
//

import UIKit
import JGProgressHUD

class FriendListTableViewController: UITableViewController {
    
    var friends = [FriendInfo]()
    var imagePath: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Friends"
        tableView.tableFooterView = UIView()
        ShareManager.sharedInstance.fetchFriendList { (friends, error) -> Void in
            guard error == nil else {
                return
            }
            self.friends = friends!
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCellTableViewCell
        let friend = friends[indexPath.row]
        cell.profileImageView.sd_setImageWithURL(NSURL(string: friend.profileURLString)!)
        cell.titleLabel.text = friend.name
        let isSelf = friend.userID == ShareManager.sharedInstance.facebookUserID!
        cell.accessoryType = isSelf ? .None : .DisclosureIndicator
        cell.statusLabel.text = isSelf ? "You" : "Facebook friend"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let friend = friends[indexPath.row]
        let isSelf = friend.userID == ShareManager.sharedInstance.facebookUserID!
        guard isSelf == false else {
            return
        }
        let hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        hud.textLabel.text = "Sharing secret to \(friend.name)..."
        hud.showInView(view)
        if NSFileManager.defaultManager().fileExistsAtPath(imagePath) {
            uploadImageToFriend(friend, hud: hud)
        } else {
            print("FL: NOT FOUND")
        }
    }
    
    private func uploadImageToFriend(friend: FriendInfo, hud: JGProgressHUD? = nil) {
        ShareManager.sharedInstance.uploadBundledImage(imagePath, shareWithUser: friend.userID) { (error) -> Void in
            hud?.dismiss()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
