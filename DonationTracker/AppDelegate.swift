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
                $0.server = keys!["parseServer"] as! String
            }
        }
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
    
    


}

