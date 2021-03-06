//
//  GroupCurrentViewController.swift
//  GroupAlarm
//
//  Created by Justin Matsnev on 8/3/15.
//  Copyright (c) 2015 Justin Matsnev. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Bolts

class FriendTableViewCell : UITableViewCell {
    @IBOutlet var friendName : UILabel!
    @IBOutlet var statusCircle : UIImageView!
}

class GroupCurrentAlarmViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var groupAlarmLabel : String!
    var groupAlarmDate : String!
    var groupAlarmTime : NSDate!
    var groupAlarmObject : PFObject!
    var groupObjId : String!
    var cameFromAppDel : Bool = false
    @IBOutlet weak var statusImage : UIImageView!
    @IBOutlet weak var alarmLabel : UILabel!
    @IBOutlet weak var alarmDate : UILabel!
    @IBOutlet weak var alarmTime : UILabel!
    var dateFormatterTime = NSDateFormatter()
    var dateFormatterDate = NSDateFormatter()
    @IBOutlet var tableView : UITableView!
    var usersFriends : NSMutableArray = NSMutableArray()
    let queryUserAlarm = PFQuery(className: "UserAlarmRole")
    let queryAlarm = PFQuery(className: "Alarm")
    var currentUser = PFUser.currentUser()
    var queryAlarmObject : PFObject!

    override func didReceiveMemoryWarning() {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()

    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        Mixpanel.sharedInstance().track("user made it to Group current alarm")
        tableView.delegate = self
        tableView.dataSource = self
        dateFormatterTime.dateFormat = "h:mm a"
        dateFormatterDate.dateFormat = "EEEE, MMMM d"
       
        querying(queryUserAlarm)
        
        if cameFromAppDel == true {
            let objectTime = queryAlarmObject["alarmTime"] as! NSDate
            let stringTime = dateFormatterTime.stringFromDate(objectTime).lowercaseString
            let stringDate = dateFormatterDate.stringFromDate(objectTime).lowercaseString
            let objectLabel = queryAlarmObject["alarmLabel"] as! String
            alarmDate.text = stringDate
            alarmTime.text = stringTime
            alarmLabel.text = objectLabel
            Mixpanel.sharedInstance().track("user came from notification")
        }
        if cameFromAppDel == false {
            let alarmTimeString = dateFormatterTime.stringFromDate(groupAlarmTime)
            alarmDate.text = groupAlarmDate
            alarmTime.text = alarmTimeString
            alarmLabel.text = groupAlarmLabel
            Mixpanel.sharedInstance().track("user came from current alarms page")

        }
        

    }
    
    func queryingAlarmClass(query : PFQuery) {
        if cameFromAppDel == true {

        query.whereKey("objectId", equalTo: groupObjId)
        queryAlarmObject = query.getFirstObject()
            
        }
        if cameFromAppDel == false {
                                                                                                    
        }
    }
    
    func querying(query : PFQuery) {
        queryingAlarmClass(queryAlarm)

        if cameFromAppDel == true {
                query.whereKey("alarm", equalTo: queryAlarmObject)
                query.whereKey("alarmActivated", equalTo: true)
                query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if error == nil {
                        for result in objects! {
                            self.usersFriends.addObject(result)

                        }
                        self.tableView.reloadData()
                    }
                }
            
            
        }
        if cameFromAppDel == false {
         let alarmObject = groupAlarmObject
         query.whereKey("alarm", equalTo: alarmObject)
        query.whereKey("alarmActivated", equalTo: true)
         query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                for result in objects! {

                        self.usersFriends.addObject(result)
                    }
                self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func dismissGroupController(sender : AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return usersFriends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FriendTableViewCell
        let object = self.usersFriends[indexPath.row] as! PFObject
        let checkedIn = object["checkIn"] as! Bool
        let userObject = object["user"] as! PFObject
        userObject.fetchIfNeeded()
        let userFullName = userObject["FullName"] as! String
        if userObject.objectId == currentUser?.objectId   {
            
            cell.friendName.text = userFullName + " (me)"
            if checkedIn == true {
                cell.statusCircle.image = UIImage(named: "greenstatusButton.png")
                Mixpanel.sharedInstance().track("user turned green")
            }
            else {
                cell.statusCircle.image = UIImage(named: "greystatusButton.png")
                Mixpanel.sharedInstance().track("user turned red")
            }
        }
        else {
            cell.friendName.text = userFullName
            if checkedIn == true {
                cell.statusCircle.image = UIImage(named: "greenstatusButton.png")
                Mixpanel.sharedInstance().track("user turned green")

            }
            else {
                cell.statusCircle.image = UIImage(named: "greystatusButton.png")
                Mixpanel.sharedInstance().track("user turned red")

            }
        }
        
      
        return cell

    }
    
    
}