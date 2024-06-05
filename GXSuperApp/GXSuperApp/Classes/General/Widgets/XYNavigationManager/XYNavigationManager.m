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
    iosMapDic[XY_NAV_TITLE_KEY] = @"苹果地图";
    [maps addObject:iosMapDic];
    
    //百度地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        NSMutableDictionary *baiduMapDic = [NSMutableDictionary dictionary];
        baiduMapDic[XY_NAV_TITLE_KEY] = @"百度地图";
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=%@&mode=driving&coord_type=gcj02",
                                endLocation.latitude,endLocation.longitude,endAddress]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        baiduMapDic[XY_NAV_URL_KEY] = urlString;
        [maps addObject:baiduMapDic];
    }
    
    //高德地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSMutableDictionary *gaodeMapDic = [NSMutableDictionary dictionary];
        gaodeMapDic[XY_NAV_TITLE_KEY] = @"高德地图";
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&backScheme=%@&dlat=%f&dlon=%f&dname=%@&dev=0&style=2",
                                APP_NAME,@"iosamapnavi",endLocation.latitude,endLocation.longitude,endAddress]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        gaodeMapDic[XY_NAV_URL_KEY] = urlString;
        [maps addObject:gaodeMapDic];
    }
    
    //谷歌地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        NSMutableDictionary *googleMapDic = [NSMutableDictionary dictionary];
        googleMapDic[XY_NAV_TITLE_KEY] = @"谷歌地图";
        NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",
                                APP_NAME,@"comgooglemapsnavi",endLocation.latitude, endLocation.longitude]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        googleMapDic[XY_NAV_URL_KEY] = urlString;
        [maps addObject:googleMapDic];
    }
    
    //腾讯地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        NSMutableDictionary *qqMapDic = [NSMutableDictionary dictionary];
        qqMapDic[XY_NAV_TITLE_KEY] = @"腾讯地图";
        NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%f,%f&to=%@&coord_type=1&policy=0",
                                endLocation.latitude, endLocation.longitude, endAddress]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        qqMapDic[XY_NAV_URL_KEY] = urlString;
        [maps addObject:qqMapDic];
    }
    
    return maps;
}


+ (void)showWithViewController:(UIViewController*)vc
                    coordinate:(CLLocationCoordinate2D)coordinate
                    endAddress:(NSString*)endAddress
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"选择地图进行导航" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                }
            }];
            [alert addAction:action];
        }
    }
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
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
