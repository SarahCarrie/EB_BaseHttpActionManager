//
//  EB_BackStageNetWorkTool.m
//  eThings
//
//  Created by 昊天 on 3/20/18.
//  Copyright © 2018 Beijing FR Information technology Co.,Ltd. All rights reserved.
//

#import "EB_BackStageNetWorkTool.h"
#import "UrlConstants.h"
#import "SBJson5Writer.h"
#import "NSString+MD5.h"
#import "UIView+YWHView.h"
#import "RSA.h"
#import "YWHMBProgress.h"
#import "EB_NoRightController.h"
@interface EB_BackStageNetWorkTool ()
/**
 bgList
 */
@property (nonatomic, strong) NSArray *codeList;
@end
@implementation EB_BackStageNetWorkTool

static EB_BackStageNetWorkTool *instance;
+ (instancetype)defaultBackStageNetWorkTool
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:SERVER_ADMID_BASEURL];
        instance = [[EB_BackStageNetWorkTool alloc] initWithBaseURL:url];
        
        // 设置请求格式
        instance.requestSerializer = [AFJSONRequestSerializer serializer];
        
        // 设置返回格式
        instance.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    [instance initRequestSerializer];
    [instance.requestSerializer setValue:GetBackStageAccessToken() forHTTPHeaderField:@"accessToken"];
    return instance;
}
/**
 获取时区
 
 @return 时区
 */
- (NSString *)timeZoneName
{
    //本地
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    //系统
    NSTimeZone *syszone = [NSTimeZone systemTimeZone];
    // 获取所有已知的时区名称
    NSArray *zoneNames = [NSTimeZone knownTimeZoneNames];
    // 获取指定时区的名称
    NSString *strZoneName = [zone name];
    return strZoneName;
}
- (void)initRequestSerializer
{
    [self.requestSerializer setValue:getAppOS() forHTTPHeaderField:@"os"];
    [self.requestSerializer setValue:[self timeZoneName] forHTTPHeaderField:@"timeZone"];
    [self.requestSerializer setValue:getOSVersion() forHTTPHeaderField:@"osVersion"];
    [self.requestSerializer setValue:getDeviceId() forHTTPHeaderField:@"deviceId"];
    [self.requestSerializer setValue:getAppVersion() forHTTPHeaderField:@"appVersion"];
    [self.requestSerializer setValue:getDeviceModel() forHTTPHeaderField:@"phoneMode"];
    [self.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.requestSerializer.timeoutInterval = 15.0f;
    [self.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    if(getCompanyId() && getCompanyId().length > 0) {
        [self.requestSerializer setValue:getCompanyId() forHTTPHeaderField:@"companyId"];
    }
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    
    return instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return instance;
}
//注意一定传递url、method
- (NSString *)getSignWithDictionary:(NSDictionary *)dictionary URL:(NSString *)URL method:(NSString *)method nonce_str:(NSString *)nonce_str {
    //目标字典
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithCapacity:0];
    //随机字符串
    [paraDict setObject:nonce_str forKey:@"nonce_str"];
    //get方法需要将para 拼接到参数上
    if ([method isEqual:@"GET"]) {
        if (dictionary) {
            __block NSMutableString *temp = [NSMutableString string];
            //是否有? 没有拼接上
            if (![URL containsString:@"?"]) {
                URL = [URL stringByAppendingString:@"?"];
            } else
            {
                URL = [URL stringByAppendingString:@"&"];
            }
            [dictionary.allKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [temp appendString:[NSString stringWithFormat:@"%@=%@",obj,dictionary[obj]]];
                if (idx < dictionary.allKeys.count) {
                    [temp appendString:@"&"];
                }
            }];
            URL = [URL stringByAppendingString:temp];
        }
    }
    //确定是否url拼接参数
    if ([URL containsString:@"?"]) {
        NSArray *tempArr = [URL componentsSeparatedByString:@"?"];
        URL = [tempArr firstObject];
        //        URL = NewStringFromUTFString(URL);
        NSString *paraString = [tempArr lastObject];
        //url para 数组
        NSArray *paraList = [paraString componentsSeparatedByString:@"&"];
        [paraList enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.length > 0 && [obj containsString:@"="]) {
                NSArray *temp = [obj componentsSeparatedByString:@"="];
                NSString *key = [NSString stringWithFormat:@"%@",temp[0]];
                NSString *value = [NSString stringWithFormat:@"%@",temp[1]];
                [paraDict setObject:value forKey:key];
            }
        }];
    }
    //最终字符串
    NSMutableString *mutableString = [NSMutableString stringWithCapacity:0];
    if (dictionary && ![method isEqual:@"GET"]) {
        NSString *paraString = @"";
        if (dictionary && ![method isEqualToString:@"GET"]) {
            
            NSError *parseError = nil;
            paraString = [[SBJson5Writer alloc] stringWithObject:dictionary];
            paraString = [paraString stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
        }
        [paraDict addEntriesFromDictionary:@{@"body":[paraString md5With32BitUppercase]}];
    }
    NSArray *sortArray = [paraDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return  [obj1 compare:obj2 options:NSLiteralSearch] == NSOrderedDescending;
    }];
    for (int i = 0; i < sortArray.count; i++) {
        NSString *key = sortArray[i];
        id value = [paraDict objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            if ([value isEqualToString:@""] || [value containsString:@"null"]) {
                continue;
            }
        }
        [mutableString appendFormat:@"%@=%@&", key, [paraDict objectForKey:key]];
    }
    //删除最后一个&
    mutableString = [NSMutableString stringWithFormat:@"%@",[mutableString substringToIndex:mutableString.length - 1]];
    //带加密字符串
    mutableString = NewStringFromUTFString(mutableString).mutableCopy;
    [mutableString appendFormat:@"%@", [self generateKeyWithContent:mutableString URL:URL method:method]];
    if (mutableString.length > 0) {
        NSString *md5String = [mutableString md5With32BitUppercase];
        return md5String;
    }
    return @"";
}

//随机字符串
- (NSString *)getRandomParmString {
    NSMutableString *saltStr = [NSMutableString stringWithCapacity:0];
    for (int i = 0; i < 8; i++) {
        NSString *hexString = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%1x", arc4random() % 16]];
        [saltStr appendString:hexString];
    }
    return saltStr;
}

//组合key
- (NSString *)generateKeyWithContent:(NSString *)content URL:(NSString *)URL method:(NSString *)method {
    NSString *mutableString = [NSString stringWithFormat:@"&key=%@.%@.%@.%@.%@.%@",URL,method,@([content length]),getDeviceId(),getAppOS(),[EB_BackStageNetWorkTool decodedAuthCode:GetAuthCode()]];
    return mutableString;
}


+ (NSString *)decodedAuthCode:(NSString *)base64Str {
    
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMTJC7BtkMoboSeh ptttqNaEs6+ZcWe3Ci8Yajxjps0Db1COwVh38ZOQZp4iQOR7wyGzc5JKwwlxGZNU +BxURzdMNsB/5MKjIEO1hu33yJxtHkQgTQJxZlzd1DTE3v22AyImKrTjgn7WhCFw ngkpE4H/4zXngoZzAN9uGNycKwMXAgMBAAECgYBZ+9TsiC19PcUjajfyfuKFtYi0 82V4F6sAfhmWI7tSZA+ytpSS78X3xEAob2FdGXrRHk3qx2UIHD+lr2UFD0TApymG jPNvbUvomzv6THs4vxY6T8L+BhhSloOoDIAqcXf+NpbH/DN2tblNC2bdbbupoeLc c9o7hql1YK6aC9p8gQJBAOe19yTINbhh0tjiU2tB1mJb6apanhACjpExU8bU8OND Dc86izjuLlkztvXzgfghKj7zD06FDt3P82jAm0bkATUCQQDZadgP2krCDaoRxaH+ eD2vVGIQR9XiFl8Nb+jrG3xW5fE5pWlVVJjZ2IZST/iYeMWqJINYa6LEB4rBYZgr 9iibAkAlNG+RhWAy0epEDtssHq8ore9v/grhMTfpEk2MYIapRwwBmTnfk0b35bjb9xSIXfLllqt/hRfk/83qpPqJwHR9AkEAkj+N1NQdl73DWmMcXmYZ8HgN4y+/Y29zD0HpZ0W89WOGSiXH3lui2l+5s2MSMdaD+LjJFdCJ093S69SvnVrf4wJAaBlCK4i7fgRiyXkvCnMaCE8bZ+8XmFAMGGAQ90pKAQ7Y6S3ms/QFik3NBdfXCv6ndEfuS8oDJAlZiQcOw94YrA==";
    
    NSString *decodedString = [RSA decryptString:base64Str privateKey:privateKey];
    
    return decodedString;
}

- (void)POST:(NSString *)URLString
  parameters:(id)parameters
showMBProgress:(BOOL)show
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure
{
    if (show) {
        [YWHMBProgress show];
    }
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    [self.requestSerializer setValue:[self getSignWithDictionary:parameters URL:URLString method:@"POST" nonce_str:uuidString] forHTTPHeaderField:@"sign" ];
    [self.requestSerializer setValue:uuidString forHTTPHeaderField:@"nonce_str"];
    [self POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (show) {
            [YWHMBProgress hide];
        }
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *code = responseObject[@"code"];
            if ([self.codeList containsObject:code]) {
                [self noRightVcWithCode:code];
                return ;
            } else if ([@"1000" isEqualToString:code])
            {
                NSLog(@"--1000--%@",URLString);
                EB_ToastTextBottom(((NSDictionary *)responseObject).eb_errorString, SCREEN_HEIGHT/2);
            }
        }
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [YWHMBProgress hide];
        if (failure) {
            failure(error);
        }
    }];
}

- (void)GET:(NSString *)URLString
 parameters:(id)parameters
showMBProgress:(BOOL)show
    success:(void (^)(id responseObject))success
    failure:(void (^)(NSError *error))failure
{
    if (show) {
        [YWHMBProgress show];
    }
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    [self.requestSerializer setValue:[self getSignWithDictionary:parameters URL:URLString method:@"GET" nonce_str:uuidString] forHTTPHeaderField:@"sign"];
    [self.requestSerializer setValue:uuidString forHTTPHeaderField:@"nonce_str"];
    [self GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (show) {
            [YWHMBProgress hide];
        }
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *code = responseObject[@"code"];
            if ([self.codeList containsObject:code]) {
                [self noRightVcWithCode:code];
                return ;
            } else if ([@"1000" isEqualToString:code])
            {
                NSLog(@"--1000--%@",URLString);
                EB_ToastTextBottom(((NSDictionary *)responseObject).eb_errorString, SCREEN_HEIGHT/2);
            }
        }
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (show) {
            [YWHMBProgress hide];
        }
        if (failure) {
            failure(error);
        }
    }];
}

- (void)noRightVcWithCode:(NSString *)code
{
    EB_NoRightController *vc = [EB_NoRightController EB_AlertWithCode:code];
    UIViewController *currentVc = [ET_BaseTools currentViewController];
    if ([currentVc isKindOfClass:[EB_NoRightController class]]) {
        return;
    }
    [[ET_BaseTools currentViewController].navigationController presentViewController:vc animated:YES completion:nil];
}
- (NSArray *)codeList
{
    if (!_codeList) {
        _codeList = @[@"1048",
                      @"1050",
                      @"1057",
                      @"1058",
                      @"1059",
                      @"1060",
                      @"1061",
                      @"4013",
                      @"4014",
                      @"1053",
                      @"7098"];
    }
    return _codeList;
}

@end
