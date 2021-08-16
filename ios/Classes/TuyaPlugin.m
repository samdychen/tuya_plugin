#import "TuyaPlugin.h"
#import "AppKey.h"
#import <TuyaSmartHomeKit/TuyaSmartKit.h>
#import <Foundation/Foundation.h>

// // DEV: c9hh5yam7xh3dnrdngh3, csdhmfg943w8qkxjarke8gw4h7dnhcng
// // UAT: n9waratyf5etpdukara3, cymwhdcgnm9xsupcjmv9q8k87exdgjga
// static NSString APP_KEY = @"n9waratyf5etpdukara3";
// static NSString APP_SECRET = @"cymwhdcgnm9xsupcjmv9q8k87exdgjga";

static NSString *STATUS_FAILURE_WITH_NETWORK_ERROR = @"1001";
static NSString *STATUS_FAILURE_WITH_BIND_GWIDS = @"1002";
static NSString *STATUS_FAILURE_WITH_BIND_GWIDS_1 = @"1003";
static NSString *STATUS_FAILURE_WITH_GET_TOKEN = @"1004";
static NSString *STATUS_FAILURE_WITH_CHECK_ONLINE_FAILURE = @"1005";
static NSString *STATUS_FAILURE_WITH_OUT_OF_TIME = @"1006";
static NSString *STATUS_DEV_CONFIG_ERROR_LIST = @"1007";
static int WHAT_EC_ACTIVE_ERROR = 0x02;
static int WHAT_EC_ACTIVE_SUCCESS = 0x03;
static int WHAT_AP_ACTIVE_ERROR = 0x04;
static int WHAT_AP_ACTIVE_SUCCESS = 0x05;
static int WHAT_EC_GET_TOKEN_ERROR = 0x06;
static int WHAT_DEVICE_FIND = 0x07;
static int WHAT_BIND_DEVICE_SUCCESS = 0x08;
static long CONFIG_TIME_OUT = 100;

typedef enum {
    ACTIVE_TYPE_EC = 0,
    ACTIVE_TYPE_AP = 1,
} ActiveType;

@interface TuyaPlugin() <TuyaSmartActivatorDelegate>

@property (nonatomic, strong) FlutterResult result;     // 平台返回
@property (nonatomic, assign) ActiveType eActiveType;

@end

@implementation TuyaPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"tuya_plugin" binaryMessenger:[registrar messenger]];
    
    TuyaPlugin* instance = [[TuyaPlugin alloc] init];
    
    [TuyaSmartSDK sharedInstance].appGroupId = APP_GROUP_ID;
    
    [[TuyaSmartSDK sharedInstance] setDebugMode:YES];
    [[TuyaSmartSDK sharedInstance] startWithAppKey:APP_KEY secretKey:APP_SECRET];
    
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    self.result = result;
    NSLog(@"收到消息 -- %@", call.method);
    
    if ([@"set_ec_net" isEqualToString:call.method]) {
        self.eActiveType = ACTIVE_TYPE_EC;
        [self startConfigWiFi:call.arguments[@"ssid"] password:call.arguments[@"password"] token:call.arguments[@"token"]];
    } else if ([@"set_ap_net" isEqualToString:call.method]) {
        self.eActiveType = ACTIVE_TYPE_AP;
        [self startApConfigWiFi:call.arguments[@"ssid"] password:call.arguments[@"password"] token:call.arguments[@"token"]];
    }else if ([@"uid_login" isEqualToString:call.method]) {
        [[TuyaSmartUser sharedInstance] loginOrRegisterWithCountryCode:call.arguments[@"countryCode"] uid:call.arguments[@"uid"]  password:call.arguments[@"passwd"] createHome:YES success:^(id result1) {
            
            NSString *jsonStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:result1 options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
            [self callResult:200 Message:jsonStr];
        } failure:^(NSError *error) {
            [self callResult:400 Message:error.domain];
        }];
    } else {
        result(FlutterMethodNotImplemented);
    }
}


/// EZ配网
/// @param ssid ssid
/// @param password password
/// @param token token
- (void)startConfigWiFi:(NSString *)ssid password:(NSString *)password token:(NSString *)token {
    // 设置 TuyaSmartActivator 的 delegate，并实现 delegate 方法
    [[TuyaSmartActivator sharedInstance] setDelegate:self];

    // 开始配网，快连模式对应 mode 为 TYActivatorModeEZ
    
    [[TuyaSmartActivator sharedInstance] startConfigWiFi:TYActivatorModeEZ ssid:ssid password:password token:token timeout:100];
}


/// AP配网
/// @param ssid ssid
/// @param password password
/// @param token token
- (void)startApConfigWiFi:(NSString *)ssid password:(NSString *)password token:(NSString *)token {
    // 设置 TuyaSmartActivator 的 delegate，并实现 delegate 方法
    [[TuyaSmartActivator sharedInstance] setDelegate:self];

    // 开始配网，热点模式对应 mode 为 TYActivatorModeAP
    [[TuyaSmartActivator sharedInstance] startConfigWiFi:TYActivatorModeAP ssid:ssid password:password token:token timeout:100];
}

#pragma mark - 内部方法

/// 返回给Flutter层指定数据
/// @param code 错误码
/// @param msg 错误消息
- (void) callResult:(NSInteger) code Message:(NSString *) msg {
    if (self.result) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:[NSString stringWithFormat:@"%ld", (long)code] forKey:@"code"];
        [info setObject:msg forKey:@"msg"];
        
        self.result(info);
    } else {
        NSLog(@"error : 没有找到返回的方法 .... ");
    }
}

/// 返回给Flutter层带data的指定数据
/// @param code 错误码
/// @param msg 错误信息
/// @param data 数据
- (void) callResult:(NSInteger) code Message:(NSString *) msg Data:(NSString *) data {
    if (self.result) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:[NSString stringWithFormat:@"%ld", (long)code] forKey:@"code"];
        [info setObject:msg forKey:@"msg"];
        [info setObject:data forKey:@"data"];
        
        self.result(info);
    } else {
        NSLog(@"error : 没有找到返回的方法 .... ");
    }
}

#pragma mark - TuyaSmartActivator 代理方法

- (void)activator:(TuyaSmartActivator *)activator didReceiveDevice:(TuyaSmartDeviceModel *)deviceModel error:(NSError *)error {

    if (!error && deviceModel) {
        //配网成功
        NSLog(@"NSLog与printf的区别");
        
        if (self.eActiveType == ACTIVE_TYPE_EC) {
            [self callResult:WHAT_EC_ACTIVE_SUCCESS Message:deviceModel.devId];
        } else {
            [self callResult:WHAT_AP_ACTIVE_SUCCESS Message:deviceModel.devId];
        }
    }

    if (error) {
        NSLog(@"NSLog与printf的区别");
        //配网失败
        if (self.eActiveType == ACTIVE_TYPE_EC) {
            [self callResult:WHAT_EC_ACTIVE_ERROR Message:@"EC Fail"];
        } else {
            [self callResult:WHAT_AP_ACTIVE_ERROR Message:@"fail"];
        }
    }
}

@end


