//
//  NotificationService.swift
//  NotificationService
//
//  Created by CJ Lin on 2016/9/6.
//  Copyright © 2016年 CJ. All rights reserved.
//

import UserNotifications

/**
 demo push payload
 {
    "aps" : {
        "alert" : {
            "title" : "title",
            "subtitle" : "subtitle",
            "body" : "body"
        },
        "mutable-content" : 1
	},
	"my-attachment": "http://www.qilook.com/wp-content/uploads/2015/08/Screen-Shot-2015-08-04-at-12.52.28-PM.png"
 }
 */
class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceiveNotificationRequest(request: UNNotificationRequest, withContentHandler contentHandler: (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler

        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        guard let bestAttemptContent = bestAttemptContent else { return }

        bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"

        guard let imageURLString = request.content.userInfo["my-attachment"] as? String,
            let imageURL = NSURL(string: imageURLString),
            let fileName = imageURL.lastPathComponent else {
                contentHandler(bestAttemptContent)
                return
        }

        let dataTask = NSURLSession.sharedSession().dataTaskWithURL(imageURL) { (data, response, error) in
            guard let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(fileName) else {
                contentHandler(bestAttemptContent)
                return
            }

            data?.writeToURL(fileURL, atomically: true)
            guard let attachment = try? UNNotificationAttachment(identifier: "image", URL: fileURL, options: nil) else {
                contentHandler(bestAttemptContent)
                return
            }

            bestAttemptContent.attachments = [attachment]
            contentHandler(bestAttemptContent)
        }
        dataTask.resume()
    }
}
