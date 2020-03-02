//
//  TPNotificationReceiptService.swift
//  NotificationRecepitExtension
//
//  Created by Guillermo Gutiérrez Doral on 11/02/2020.
//  Copyright © 2020 TwinCoders. All rights reserved.
//

import Foundation
import UserNotifications

@objc public class TPNotificationReceiptService: NSObject {
    let serverUrl: String
    
    @objc public convenience init(subdomain: String = "app") {
        self.init(serverUrl: "https://\(subdomain).twinpush.com/api/v2")
    }
    
    @objc public init(serverUrl: String) {
        self.serverUrl = serverUrl
    }
    
    @objc public func reportNotificationReceipt(notification: UNNotificationContent, onComplete: @escaping () -> Void) {
        let userInfo = notification.userInfo
        
        guard
            let notificationId = userInfo["tp_id"] as? Int,
            let deviceId = userInfo["tp_device_id"] as? Int else
        {
            NSLog("[TPNotificationReceiptService] Notification payload doesn't contain required fields, ignoring")
            onComplete()
            return
        }
        
        reportNotificationReceipt(deviceId: deviceId, notificationId: notificationId, onComplete: onComplete)
    }
    
    @objc func reportNotificationReceipt(deviceId: Int, notificationId: Int, onComplete: @escaping () -> Void) {
        NSLog("[TPNotificationReceiptService] Marking notification %d as received", notificationId)
        let urlStr = "\(serverUrl)/devices/\(deviceId)/notifications/\(notificationId)/received_notification"
        guard let url = URL(string: urlStr) else {
            NSLog("[TPNotificationReceiptService] Invalid URL format: %s", urlStr)
            onComplete()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("[TPNotificationReceiptService] Error found while updating notification %s: %s", notificationId, error.localizedDescription)
            }
            NSLog("[TPNotificationReceiptService] Notification receipt send successfully")
            onComplete()
        }
        
        // Start the task
        task.resume()
    }
}
