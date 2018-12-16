//
//  SYZPermissSetting.h
//  SYZPermissionKit
//
//  Created by LeeRay on 2018/12/16.
//

#import <Foundation/Foundation.h>
#import <SYZUIBasekit/SYZUIBasekit.h>
@interface SYZPermissSetting : NSObject

SYZSingletonInterface();

@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *appBundle;
@end
