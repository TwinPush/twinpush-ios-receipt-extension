TwinPush Receipt Extension
==================

[![Badge w/ Version](https://cocoapod-badges.herokuapp.com/v/TwinPushReceiptExtension/badge.png)](https://cocoapods.org/pods/TwinPushReceiptExtension)
[![Badge w/ Platform](https://cocoapod-badges.herokuapp.com/p/TwinPushReceiptExtension/badge.svg)](https://cocoapods.org/pods/TwinPushReceiptExtension)
[![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)](https://github.com/TwinPush/ios-sdk/blob/master/LICENSE)

Companion library for the native iOS SDK for [TwinPush platform](http://twinpush.com) that adds notification receipts support.

## Installation


### Creating the Notification Service Extension

Apple Push Notification Service delivers the notifications directly to the operating system instead of the application. In order to intercept the notifications and send the delivery receipt we'll use the [Notification Service Extension](https://developer.apple.com/reference/usernotifications/unnotificationserviceextension). To create one in XCode go to `File` -> `New` -> `Target` and select **Notification Service Extension**.

![](http://i.imgur.com/G34LtGh.png)

Enter a name for the extension and make sure to embed it to your application.

![](http://i.imgur.com/6ZCGEuq.png)

It will create a new target with a single class named `NotificationService`. We'll come later to edit this file.

### Installing the extension library

The Notification Service Extension is in fact a different target separated from the application and it doesn't include any library included in the application, so we have to import a new framework in order to report the receipt confirmation to TwinPush platform.

We've created a simplified version of the SDK that consists in a single method that reports receipt confirmations to TwinPush.

#### Using CocoaPods
When using CocoaPods, add a dependency to `TwinPushReceiptExtension` to your notification service extension target. For example, your `Podfile` may look like this:

```
target 'MyApp' do
  use_frameworks!

  pod 'TwinPushSDK'
end

target 'MyAppNotificationExtension' do
  use_frameworks!

  pod TwinPushReceiptExtension
end
```

Note that the `TwinPushReceiptExtension` is added to the extension target and not the application target. Make sure that the target name matches the name that you entered when creating the Notification Service Extension.

#### Manually copying sources

Another way to include the library in your extension is manually copying the source files to your project. To do so, go to the Github repository and copy the content of [the library code provided](https://github.com/TwinPush/ios-sdk/blob/master/TwinPushReceiptExtension/TPNotificationReceiptService.swift) in your Notification Service Extension directory.

Make sure to include this file in your Notification Service Extension target:

![](https://i.imgur.com/qXMsx4d.png)

### Send notification receipts

Once installed, we can go back to the `NotificationService` class created earlier and report the received notifications to the TwinPush  platform. As this is a different target, it's required to setup the App ID and environment URL again:


~~~objective-c
// Objective-C
#import "NotificationService.h"
@import TwinPushReceiptExtension; // Exclude this import if not using CocoaPods 

@interface NotificationService ()
@property(nonatomic, strong) TPNotificationReceiptService* receiptService;
@end

@implementation NotificationService

- (instancetype)init {
    if (self = [super init]) {
        self.receiptService = [[TPNotificationReceiptService alloc] initWithAppId:@"MY_APP_ID" subdomain:@"TP_SUBDOMAIN"];
    }
    return self;
}

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    
    UNMutableNotificationContent* bestAttemptContent = [request.content mutableCopy];
    
#ifdef DEBUG
    // Use this to verify that the extenion is being called
    bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", bestAttemptContent.title];
#endif
    
    [_receiptService reportNotificationReceiptWithNotification:request.content onComplete:^{
        contentHandler(bestAttemptContent);
    }];
}

@end
~~~
~~~swift
// Swift
import UserNotifications
import TwinPushReceiptExtension // Exclude this import if not using CocoaPods

class NotificationService: UNNotificationServiceExtension {

    let receiptService = TPNotificationReceiptService(appId: "MY_APP_ID", subdomain: "TP_SUBDOMAIN")

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        if let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) {
            
            #if DEBUG
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            #endif
            
            receiptService.reportNotificationReceipt(notification: request.content) {
                contentHandler(bestAttemptContent)
            }
        }
    }
}
~~~
