//
//  AppDelegate.swift
//  DonationTracker
//
//  Created by Gabe Wilson on 9/29/18.
//  Copyright © 2018 Gabe Wilson. All rights reserved.
//

import UIKit
import Parse
import UserNotifications
import AWSS3
import AWSCore
import AWSSQS
import AWSMobileClient

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().barTintColor = UIColor(red: 0, green: 51/255, blue: 102/255, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        let configuration = ParseClientConfiguration {
            if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
                let keys = NSDictionary(contentsOfFile: path)
                print(keys!["sendGridKey"] as! String)
                $0.applicationId = (keys!["parseAppId"] as! String)
                $0.clientKey = (keys!["parseClientKey"] as! String)
                $0.server = "https://parseapi.back4app.com"
            }
        }
        //7C597q7LCCOeeGumHMdMAeaIAAz9whQmyjmxcL7E
        
        
        // Don't forget to set up your credentials in AppDelegate.swift and
        // the imports in your Obj-C bridging-header.

        // Initialize the Amazon Cognito credentials provider

        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USWest2,
           identityPoolId:"us-west-2:52ef1f93-439d-4c8c-a793-54ba31e3b965")
        let awsConfiguration = AWSServiceConfiguration(region:.USWest2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = awsConfiguration
        
        
        
        /*
        
        // Send single message to SQS
        
        let createdAt = Date() // convert using a date formatter
        
        
        let queueURL: String = "https://sqs.us-west-2.amazonaws.com/886923046348/VLPostActionsAggRobotQ"
        
        // Votes metrics
        let downVotes = 0
        let upVotes = 0
        let reports = 0
        
        // Ids
        let postId = "tk1JmMQdOC"
        let userObjectId = "c3gwPvVEAm"
        let vlOrgObjectId = "pO5bAMg5lF"
        
        // Date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let date = dateFormatter.string(from: Date()) + "Z"
        
        // Votes data as a dictionary
        let votesDictionary = ["objectId" : postId, "User" : ["__type": "Pointer", "className": "_User", "objectId" : userObjectId], "VLOrgChannels" : ["__type": "Pointer", "className": "VLOrgChannels", "objectId" : vlOrgObjectId], "createdAt": date, "updatedAt": date, "post_id": postId, "user_id": userObjectId, "vl_org_channels_id": vlOrgObjectId, "upVotes": upVotes, "downVotes": downVotes, "reports": reports] as [String : Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: votesDictionary, options: .prettyPrinted)
            let convertedString = String(data: jsonData, encoding: String.Encoding.utf8)!
            print(convertedString)
            SQS().sendMessage(msg: convertedString, queueURL: queueURL)
        } catch {
            print(error.localizedDescription)
        }
        
        let sentimentsQueueURL: String = "https://sqs.us-west-2.amazonaws.com/886923046348/VLSentimentsQ"
        
        let sentimentsDictionary = ["post_id": "r94chztV3K", "channel": "@starbucks", "vl_org_channel_id": "wMtZ3kC9DZ", "user_id": "rjVpsJSrhU", "sentiment": "Rant", "createdAt": "2019-11-18T21:20:25.041Z"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sentimentsDictionary, options: .prettyPrinted)
            let convertedString = String(data: jsonData, encoding: String.Encoding.utf8)!
            print(convertedString)
            SQS().sendMessage(msg: convertedString, queueURL: sentimentsQueueURL)
        } catch {
            print(error.localizedDescription)
        }*/
        
        
        /*let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                                identityPoolId:"us-east-1:816a224f-f440-4ad0-a342-39b6e2712e2c")
        let configuration2 = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration2
        
        // Get the queue's URL
        let getQueueUrlRequest = AWSSQSGetQueueUrlRequest()
        getQueueUrlRequest!.queueName = queueName
        sqs.getQueueUrl(getQueueUrlRequest!).continueWith { (task) -> AnyObject! in
           print("Getting queue URL")
           if let error = task.error {
              print(error)
           }
           if task.result != nil {
              if let queueUrl = task.result!.queueUrl {
                 // Got the queue's URL, try to send the message to the queue
                 let sendMsgRequest = AWSSQSSendMessageRequest()!
                 sendMsgRequest.queueUrl = queueUrl
                 sendMsgRequest.messageBody = "MY TEST MESSAGE!"

                 // Add message attribute if needed
                 let msgAttribute = AWSSQSMessageAttributeValue()!
                 msgAttribute.dataType = "String"
                 msgAttribute.stringValue = "MY ATTRIBUTE VALUE"
                 sendMsgRequest.messageAttributes = [:]
                 sendMsgRequest.messageAttributes!["MY_ATTRIBUTE_NAME"] = msgAttribute

                 // Send the message
                sqs.sendMessage(sendMsgRequest).continueWith { (task) -> AnyObject! in
                    if let error = task.error {
                       print(error)
                    }

                    if task.result != nil {
                       print("Success! Check the queue on AWS console!")
                    }
                    return nil
                 }
              } else {
                 // No URL found, do something?
              }
           }
           return nil
        }*/
        
        
        //self.uploadToS3()
        //self.getS3Object()
        
        let S3BucketName = "village-lync"
        let accessKey = "AKIAIOTX5KV5XDDLKYCQ"
        let secretKey = "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"
        let cp = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let config = AWSServiceConfiguration(region: AWSRegionType.USWest2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = config
        let ext = "jpg"
        let url = Bundle.main.path(forResource: "landscape", ofType: ext)!
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        
        uploadRequest.body = URL(fileURLWithPath: url)
        uploadRequest.key = "landscape.jpg"
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType = "image/jpeg"
        uploadRequest.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith { (task) -> AnyObject? in
            if let error = task.error {
                print("Upload failed ❌ (\(error))")
            }
            if task.result != nil {
                let s3URL = NSURL(string: "http://s3.amazonaws.com/\(S3BucketName)/\(uploadRequest.key!)")!
                print("Uploaded to:\n\(s3URL)")
            }
            else {
                print("Unexpected empty result.")
            }
            return nil
        }

        
        
        /*
        let credentialsProvider2 = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                                identityPoolId:"us-east-1:816a224f-f440-4ad0-a342-39b6e2712e2c")
        let configuration2 = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider2)
        AWSServiceManager.default().defaultServiceConfiguration = configuration2
        let ext = "jpg"
        let imageURL = Bundle.main.path(forResource: "test-1", ofType: ext)!
        let localImageURL = URL(fileURLWithPath: imageURL)
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest!.body = localImageURL
        uploadRequest!.key = ProcessInfo.processInfo.globallyUniqueString + "." + ext
        uploadRequest!.bucket = S3BucketName
        uploadRequest!.contentType = "image/" + ext
        
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { (task) -> AnyObject! in
            if let error = task.error {
                print("Upload failed ❌ (\(error))")
            }
            if task.result != nil {
                let s3URL = NSURL(string: "http://s3.amazonaws.com/\(S3BucketName)/\(uploadRequest!.key!)")!
                print("Uploaded to:\n\(s3URL)")
            }
            else {
                print("Unexpected empty result.")
            }
            return nil
        }
        */
        Parse.initialize(with: configuration)
        //setupNotification()
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options:[.alert,.sound,.badge]) { (granted, error) in
                if granted{
                    UIApplication.shared.registerForRemoteNotifications()
                }else{
                    print("Notification permission denied.")
                }
            }
            
        } else {
            // For ios 9 and below
            let type: UIUserNotificationType = [.alert,.sound,.badge];
            let setting = UIUserNotificationSettings(types: type, categories: nil);
            UIApplication.shared.registerUserNotificationSettings(setting);
            UIApplication.shared.registerForRemoteNotifications()
        }
        /*if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            GMSPlacesClient.provideAPIKey(keys!["googleKey"] as! String)
        }*/
        /*let resource = "test"
        let type = "jpg"
        let key = "\(resource).\(type)"
        let localImagePath = Bundle.main.path(forResource: resource, ofType: type)
        let localImageURL = URL(fileURLWithPath: localImagePath!)
        
        let remoteName = "test.jpg"
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
        let S3BucketName = "uswestvillagelync-deployments-mobilehub-918807125"
        /*let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = localImageURL
        uploadRequest.key = key
        uploadRequest.bucket = S3BucketName
        //uploadRequest.contentType = "image/jpeg"
        uploadRequest.acl = .publicReadWrite*/
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith(block: { (task: AWSTask) -> Any? in
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                print("Uploaded to:\(publicURL)")
            }
            return nil
        })*/
        return true
    }
    

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    //Come back here francis' device
    func setupNotification() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay ]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                print("trying to register")
                UIApplication.shared.registerForRemoteNotifications()
                
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("in delegate method.")
        DataModel.deviceToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received a push")
        
        if (application.applicationState == .active) {
            print("Received a push while the app is active")
            print("Background!")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller1VC = storyboard.instantiateViewController(withIdentifier: "ItemDetailsVC") as! ItemDetailsVC
            let nav = UINavigationController(rootViewController: controller1VC)
            let rootVC = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
        } else {
            print("Background!")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller1VC = storyboard.instantiateViewController(withIdentifier: "ItemDetailsVC") as! ItemDetailsVC
            let nav = UINavigationController(rootViewController: controller1VC)
            let rootVC = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
             
            if PFUser.current() != nil {
                print(userInfo, "this is the user info")
                if let identifier = userInfo["identifier"] as? String {
                    print("this far")
                    if identifier == "employeeToAdmin" {
                        print("CHECK HERE GOT A REQUEST FROM EMPLOYEE")
                        //next show the employees vc.
                    } else if identifier == "newItem" {
                        if let info = userInfo["aps"] as? Dictionary <String, String> {
                            print(userInfo)
                            let message = info["message"]! as String
                            let objectId = info["objectId"]! as String
                            print("This is the message:", message, objectId)
                            DataModel.fromPush = true
                            DataModel.pushObjectId = objectId
                            rootVC.selectedIndex = 1
                            rootVC.viewControllers![1] = nav
                            self.window!.rootViewController = rootVC
                        }
                    }
                }
                
            }
            
            //Come back JSON to send
            /*{
                "aps": {
                    "alert": "New Adidas",
                    "sound": "",
                    "message": "Message"
                    "objectId": "22G74cxMSl"
                }
            }*/
        }
        
    }
    
    func getS3Object() {
        let S3BucketName = "village-lync"
        
        let transferManager = AWSS3TransferManager.default()
        
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test-1.jpg")
        
        if let downloadRequest = AWSS3TransferManagerDownloadRequest(){
            downloadRequest.bucket = S3BucketName
            downloadRequest.key = "91313086-A94D-4211-9F09-81CA6E650B41-65019-000121D7950EE0BD.jpg"
            downloadRequest.downloadingFileURL = downloadingFileURL
            
            transferManager.download(downloadRequest).continueWith(executor: AWSExecutor.default(), block: { (task: AWSTask<AnyObject>) -> Any? in
                if( task.error != nil){
                    print(task.error!.localizedDescription)
                    return nil
                } else {
                    print("No Error")
                }
                
                print(task.result!)
                
                if let data = NSData(contentsOf: downloadingFileURL) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        print("Got the data", data)
                        DataModel.s3Image = UIImage(data: data as Data)!
                    })
                }
            return nil
            })
        }
    }
    
    func uploadToS3() {
        // configure S3
        let S3BucketName = "village-lync"

        // configure authentication with Cognito
        let CognitoPoolID = "us-west-2:230c87c6-319e-4cff-bb33-2ed89be3615a"
        let Region = AWSRegionType.USWest2
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:Region,
            identityPoolId:CognitoPoolID)
        let configuration = AWSServiceConfiguration(region:Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        //uploadRequest.acl = .publicRead
        
        let ext = "jpg"
        let imageURL = Bundle.main.path(forResource: "landscape", ofType: ext)!
        let localImageURL = URL(fileURLWithPath: imageURL)
        
        uploadRequest.body = localImageURL
        uploadRequest.key = ProcessInfo.processInfo.globallyUniqueString + "." + ext
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType = "image/" + ext
        
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith { (task) -> AnyObject! in
            if let error = task.error {
                print("Upload failed ❌ (\(error))")
            }
            if task.result != nil {
                let s3URL = NSURL(string: "http://s3.amazonaws.com/\(S3BucketName)/\(uploadRequest.key!)")!
                print("Uploaded to:\n\(s3URL)")
            }
            else {
                print("Unexpected empty result.")
            }
            return nil
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func jsonToString(json: AnyObject){
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            print(convertedString) // <-- here is ur string

        } catch let myJSONError {
            print(myJSONError)
        }

    }
    
    


}

