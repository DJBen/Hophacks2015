//
//  ShareManager.swift
//  HackathonBase
//
//  Created by Sihao Lu on 9/12/15.
//  Copyright © 2015 Sihao Lu. All rights reserved.
//

import UIKit
import CloudKit

class ShareManager: NSObject {
    static let sharedInstance = ShareManager()
    
    var facebookUserID: String?
    var facebookUserName: String?
    var facebookPictureURL: NSURL?
    
    var shouldHandlePushNotification = false
    
    var publicDatabase: CKDatabase {
        return CKContainer.defaultContainer().publicCloudDatabase
    }
    
    func fetchCurrentFacebookUser(completionBlock: ((error: NSError?) -> Void)? = nil) {
        guard FBSDKAccessToken.currentAccessToken() != nil else {
            return
        }
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,name,picture"]).startWithCompletionHandler { (connection, result, error) -> Void in
            guard error == nil else {
                print(error)
                completionBlock?(error: nil)
                return
            }
            // { id: "xxx", name = "Person" }
            self.facebookUserID = result["id"] as? String
            self.facebookUserName = result["name"] as? String
            if let picture = result["picture"] as? [String: AnyObject], data = picture["data"] as? [String: AnyObject], urlString = data["url"] as? String {
                self.facebookPictureURL = NSURL(string: urlString)
            }
            self.uploadUserInfo()
            completionBlock?(error: error)
        }
    }

    func uploadUserInfo() {
        guard facebookUserID != nil else {
            return
        }
        let record = CKRecord(recordType: "Account", recordID: CKRecordID(recordName: facebookUserID!))
        record["userID"] = facebookUserID!
        record["name"] = facebookUserName!
        record["device"] = UIDevice.currentDevice().identifierForVendor!.UUIDString
        record["profilePicture"] = facebookPictureURL!.absoluteString
        publicDatabase.saveRecord(record) { (record, error) -> Void in
            guard error == nil else {
                print("save user info: \(error)")
                return
            }
            print("Saves record to the cloud")
        }
        // Subscribe to changes
        let predicate = NSPredicate(format: "sharedUser == %@", facebookUserID!)
        let subscription = CKSubscription(recordType: "Image", predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
        let info = CKNotificationInfo()
        info.alertLocalizationKey = "New Secret Photo"
        info.alertBody = "Someone shared a secret photo with you. Check it out!"
        info.shouldBadge = true
        subscription.notificationInfo = info
        publicDatabase.saveSubscription(subscription) { (subscription, error) -> Void in
            guard error == nil else {
                print("subscription: \(error)")
                return
            }
            print("Finish saving subscription to listen to new photo.")
        }
    }
    
    func uploadBundledImage(imagePath: NSString, shareWithUser otherUserID: String, completion: (error: NSError?) -> Void) {
        let asset = CKAsset(fileURL: NSURL(fileURLWithPath: imagePath as String))
        let record = CKRecord(recordType: "Image", recordID: CKRecordID(recordName: facebookUserID!))
        record["creator"] = facebookUserID!
        record["data"] = asset
        record["sharedUser"] = otherUserID
        let mainThreadCompletion: (error: NSError?) -> Void = { error in
            dispatch_async(dispatch_get_main_queue()) {
                completion(error: error)
            }
        }
        publicDatabase.saveRecord(record) { (record, error) -> Void in
            guard error == nil else {
                print(error)
                mainThreadCompletion(error: error)
                return
            }
            mainThreadCompletion(error: nil)
        }
    }
    
    func fetchImagesSharedWithMe(completion: (records: [CKRecord]?, error: NSError?) -> Void) {
        let query = CKQuery(recordType: "Image", predicate: NSPredicate(format: "sharedUser == %@", facebookUserID!))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let mainThreadCompletion: (records: [CKRecord]?, error: NSError?) -> Void = { records, error in
            dispatch_async(dispatch_get_main_queue()) {
                completion(records: records, error: error)
            }
        }
        publicDatabase.performQuery(query, inZoneWithID: nil) { (records, error) -> Void in
            guard error == nil else {
                print(error)
                mainThreadCompletion(records: nil, error: error)
                return
            }
            mainThreadCompletion(records: records, error: error)
        }
    }
}
