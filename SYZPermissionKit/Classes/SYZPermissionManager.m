//
//  SYZPermissionManager.m
//  SYZPermissionKit
//
//  Created by LeeRay on 2018/12/16.
//

#import "SYZPermissionManager.h"
#import <Photos/Photos.h>
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>
#import <EventKit/EventKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
//#import <SYZMediator/SYZMediator.h>
#import <SYZPermissSetting.h>

typedef enum : NSUInteger {
    SYZPermissTypePhoto,
    SYZPermissTypeVideo,
    SYZPermissTypeAudio,
    SYZPermissTypeEvent,
    SYZPermissTypeBluetooth,
    SYZPermissTypeAddressBook,
    SYZPermissTypeRemind
} SYZPermissType;

NSString * SYZPermissTypeName(SYZPermissType type) {
    NSString *name = @"";
    switch (type) {
        case SYZPermissTypePhoto: {
            name = @"相册";
        } break;
        case SYZPermissTypeVideo: {
            name = @"相机";
        } break;
        case SYZPermissTypeAudio: {
            name = @"麦克风";
        } break;
        case SYZPermissTypeEvent: {
            name = @"日历";
        } break;
        case SYZPermissTypeRemind: {
            name = @"提醒事项";
        } break;
        case SYZPermissTypeBluetooth: {
            name = @"蓝牙";
        } break;
        case SYZPermissTypeAddressBook: {
            name = @"通讯录";
        } break;
        default:
            break;
    }
    return name;
}


@implementation SYZPermissionManager

/** 相册权限 */
+ (void)requestAblumWithHandle:(SYZPermissionBlock)handle {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (PHAuthorizationStatusAuthorized == status) {
        [self _handle:handle status:SYZPermissionStatusAuthorized];
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self _handle:handle status:SYZPermissionStatusAuthorized];
            } else {
                [self _handle:handle status:SYZPermissionStatusRestricted type:SYZPermissTypePhoto];
            }
        }];
    }
}

/** 照相机，麦克风权限 */
+ (void)requestMeidaCaptureAccessWithHandle:(SYZPermissionBlock)handle {
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (videoStatus == AVAuthorizationStatusAuthorized && audioStatus == AVAuthorizationStatusAuthorized) {
        [self _handle:handle status:SYZPermissionStatusAuthorized];
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    if (granted) {
                        [self _handle:handle status:SYZPermissionStatusAuthorized];
                    } else {
                        [self _handle:handle status:SYZPermissionStatusRestricted type:SYZPermissTypeAudio];
                    }
                }];
            } else {
                [self _handle:handle status:SYZPermissionStatusRestricted type:SYZPermissTypeVideo];
            }
        }];
    }
}

/** 相机权限 */
+ (void)requestMediaWithHandle:(SYZPermissionBlock)handle {
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (videoStatus == AVAuthorizationStatusAuthorized) {
        [self _handle:handle status:SYZPermissionStatusAuthorized];
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                [self _handle:handle status:SYZPermissionStatusAuthorized];
            } else {
                [self _handle:handle status:SYZPermissionStatusRestricted type:SYZPermissTypeVideo];
            }
        }];
    }
}

/** 麦克风权限 */
+ (void)requestAudioWithHandle:(SYZPermissionBlock)handle {
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (audioStatus == AVAuthorizationStatusAuthorized) {
        [self _handle:handle status:SYZPermissionStatusAuthorized];
    } else {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                [self _handle:handle status:SYZPermissionStatusAuthorized];
            } else {
                [self _handle:handle status:SYZPermissionStatusRestricted type:SYZPermissTypeAudio];
            }
        }];
    }
}

/** 定位权限 */
+ (void)requestLocationWithHandle:(SYZPermissionBlock)handle {
    /*
     if ([CLLocationManager locationServicesEnabled]) {
     SYZPermissionManager *permission = [SYZPermissionManager new];
     permission.manager = [CLLocationManager new];
     [permission.manager requestWhenInUseAuthorization];
     }
     
     CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
     if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
     [self _handle:handle status:SYZPermissionStatusAuthorized];
     } else {
     [self _handle:handle status:SYZPermissionStatusRestricted];
     }
     */
}

/** 日历权限 */
+ (void)requestEventWithHandle:(SYZPermissionBlock)handle {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if (status == EKAuthorizationStatusAuthorized) {
        [self _handle:handle status:SYZPermissionStatusAuthorized];
    } else {
        [self _requestEventOrReminderWith:EKEntityTypeEvent handle:handle permiss:SYZPermissTypeEvent];
    }
}

/** 蓝牙权限 */
+ (void)requestBluetoothWithHandle:(SYZPermissionBlock)handle {
    CBCentralManager *manager = [[CBCentralManager alloc] init];
    if (@available(iOS 10.0, *)) {
        CBManagerState status = [manager state];
        if (status == CBManagerStatePoweredOn) {
            [self _handle:handle status:SYZPermissionStatusAuthorized];
        } else {
            [self _handle:handle status:SYZPermissionStatusRestricted type:SYZPermissTypeBluetooth];
        }
    } else {
        CBPeripheralManagerAuthorizationStatus status = [CBPeripheralManager authorizationStatus];
        if (status == CBPeripheralManagerAuthorizationStatusAuthorized) {
            [self _handle:handle status:SYZPermissionStatusAuthorized];
        } else {
            [self _handle:handle status:SYZPermissionStatusRestricted type:SYZPermissTypeBluetooth];
        }
    }
}

/** 提醒权限 */
+ (void)requestReminderWithHandle:(SYZPermissionBlock)handle {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    if (status == EKAuthorizationStatusAuthorized) {
        [self _handle:handle status:SYZPermissionStatusAuthorized type:SYZPermissTypeRemind];
    } else {
        [self _requestEventOrReminderWith:EKEntityTypeReminder handle:handle permiss:SYZPermissTypeRemind];
    }
}

/** 通讯录权限 */
+ (void)requestAddressBookWithHandle:(SYZPermissionBlock)handle {
    if (@available(iOS 9.0, *)) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusAuthorized) {
            [self _handle:handle status:SYZPermissionStatusAuthorized];
        } else {
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    [self _handle:handle status:SYZPermissionStatusAuthorized];
                } else {
                    [self _handle:handle status:SYZPermissionStatusRestricted type:SYZPermissTypeAddressBook];
                }
            }];
        }
    } else {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            [self _handle:handle status:SYZPermissionStatusAuthorized type:SYZPermissTypeAddressBook];
        } else {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    [self _handle:handle status:SYZPermissionStatusAuthorized];
                } else {
                    [self _handle:handle status:SYZPermissionStatusRestricted type:SYZPermissTypeAddressBook];
                }
            });
        }
    }
}

/** 推送权限 */
//+ (void)requestPushNotificationWithHandle:(SYZPermissionBlock)handle { }

#pragma mark - Private
+ (void)_handle:(SYZPermissionBlock)handle status:(SYZPermissionStatus)status type:(SYZPermissType)type {
    if (status != SYZPermissionStatusAuthorized) {
//        NSString *appName = [SYZPermissSetting sharedInstance].appName;
//        NSString *permissName = SYZPermissTypeName(type);
//        NSString *message = [NSString stringWithFormat:@"请在iPhone的“设置->%@”开启%@访问权限", appName, permissName];
//        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
//        [alertVc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            [self _handle:handle status:status];
//        }]];
//        [alertVc addAction:[UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            if (@available(iOS 10.0, *)) {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
//            } else {
//                NSString *appBundle = [SYZPermissSetting sharedInstance].appBundle;
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"prefs:root=%@", SYZNoNilString(appBundle)]]];
//            }
//        }]];
        
//        [SYZGlobalMediator.currentViewController presentViewController:alertVc animated:YES completion:nil];
    } else {
        [self _handle:handle status:status];
    }
}

+ (void)_handle:(SYZPermissionBlock)handle status:(SYZPermissionStatus)status {
    if ([NSThread isMainThread]) {
        if (handle) {
            handle(status);
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handle) {
                handle(status);
            }
        });
    }
}



+ (void)_requestEventOrReminderWith:(EKEntityType)type handle:(SYZPermissionBlock)handle permiss:(SYZPermissType)permiss {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:type completion:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            [self _handle:handle status:SYZPermissionStatusAuthorized];
        } else {
            [self _handle:handle status:SYZPermissionStatusRestricted type:permiss];
        }
    }];
}

@end
