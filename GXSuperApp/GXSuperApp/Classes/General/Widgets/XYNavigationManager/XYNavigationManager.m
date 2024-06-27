//
//  XYNavigationManager.m
//  XYJz01
//
//  Created by ShengYong Guo on 2018/7/31.
//  Copyright © 2018年 ShengYong Guo. All rights reserved.
//

#import "XYNavigationManager.h"
#import <MapKit/MapKit.h>

#define XY_NAV_TITLE_KEY  @"title"
#define XY_NAV_URL_KEY    @"url"
// app名称
#define APP_NAME          [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]

@implementation XYNavigationManager


#pragma mark - 导航方法
+ (NSArray<NSDictionary*> *)getInstalledMapEndLocation:(CLLocationCoordinate2D)endLocation
                                            endAddress:(NSString*)endAddress
{
    NSMutableArray *maps = [NSMutableArray array];
    
    //苹果地图
    NSMutableDictionary *iosMapDic = [NSMutableDictionary dictionary];
    iosMapDic[XY_NAV_TITLE_KEY] = @"Apple Maps";
    [maps addObject:iosMapDic];
    
    //谷歌地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        NSMutableDictionary *googleMapDic = [NSMutableDictionary dictionary];
        googleMapDic[XY_NAV_TITLE_KEY] = @"Google Maps";
        NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",
                                APP_NAME,@"comgooglemapsnavi",endLocation.latitude, endLocation.longitude]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        googleMapDic[XY_NAV_URL_KEY] = urlString;
        [maps addObject:googleMapDic];
    }
    
    return maps;
}

+ (void)showWithViewController:(UIViewController*)vc
                    coordinate:(CLLocationCoordinate2D)coordinate
                    endAddress:(NSString*)endAddress
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Select the map to navigate" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *maps = [XYNavigationManager getInstalledMapEndLocation:coordinate endAddress:endAddress];
    NSInteger index = maps.count;
    for (int i = 0; i < index; i++) {
        NSString * title = maps[i][XY_NAV_TITLE_KEY];
        if (i == 0) {
            UIAlertAction * action = [UIAlertAction actionWithTitle:title style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                [XYNavigationManager navAppleMapWithCoordinate:coordinate endAddress:endAddress];
            }];
            [alert addAction:action];
        } else {
            UIAlertAction * action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *urlString = maps[i][XY_NAV_URL_KEY];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            }];
            [alert addAction:action];
        }
    }
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL];
    [alert addAction:action];
    [vc presentViewController:alert animated:YES completion:nil];
}

//苹果地图
+ (void)navAppleMapWithCoordinate:(CLLocationCoordinate2D)coordinate endAddress:(NSString*)endAddress {
    //用户位置
    MKMapItem *currentLoc = [MKMapItem mapItemForCurrentLocation];
    //终点位置
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
    toLocation.name = endAddress;
    
    NSArray *items = @[currentLoc,toLocation];
    //第一个
    NSDictionary *dic = @{
                          MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
                          MKLaunchOptionsMapTypeKey : @(MKMapTypeStandard),
                          MKLaunchOptionsShowsTrafficKey : @(YES)
                          };
    //第二个，都可以用
    //    NSDictionary * dic = @{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
    //                           MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]};
    
    [MKMapItem openMapsWithItems:items launchOptions:dic];
}

@end
