//
//  SYZPermissionManager.h
//  SYZPermissionKit
//
//  Created by LeeRay on 2018/12/16.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    SYZPermissionStatusNotDetermined,
    SYZPermissionStatusRestricted,
    SYZPermissionStatusDenied,
    SYZPermissionStatusAuthorized,
} SYZPermissionStatus;

typedef void (^SYZPermissionBlock)(SYZPermissionStatus status);
@interface SYZPermissionManager : NSObject

/** 相册权限 */
+ (void)requestAblumWithHandle:(SYZPermissionBlock)handle;

/** 照相机，麦克风权限 */
+ (void)requestMeidaCaptureAccessWithHandle:(SYZPermissionBlock)handle;

/** 相机权限 */
+ (void)requestMediaWithHandle:(SYZPermissionBlock)handle;

/** 麦克风权限 */
+ (void)requestAudioWithHandle:(SYZPermissionBlock)handle;

/** 定位权限 */
+ (void)requestLocationWithHandle:(SYZPermissionBlock)handle;

/** 日历权限 */
+ (void)requestEventWithHandle:(SYZPermissionBlock)handle;

/** 蓝牙权限 */
+ (void)requestBluetoothWithHandle:(SYZPermissionBlock)handle;

/** 提醒权限 */
+ (void)requestReminderWithHandle:(SYZPermissionBlock)handle;

/** 通讯录权限 */
+ (void)requestAddressBookWithHandle:(SYZPermissionBlock)handle;

/** 推送权限 */
//+ (void)requestPushNotificationWithHandle:(SYZPermissionBlock)handle;

@end
