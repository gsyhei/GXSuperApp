//
//  XYNavigationManager.h
//  XYJz01
//
//  Created by ShengYong Guo on 2018/7/31.
//  Copyright © 2018年 ShengYong Guo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface XYNavigationManager : NSObject

+ (void)showWithViewController:(UIViewController*)vc
                    coordinate:(CLLocationCoordinate2D)coordinate
                    endAddress:(NSString*)endAddress;

@end
