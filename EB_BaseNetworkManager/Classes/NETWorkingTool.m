 //
//  NETWorkingTool.m
//  eThings
//
//  Created by ywh on 2017/3/15.
//  Copyright © 2017年 北京自由行动互联网技术有限公司. All rights reserved.
//

#import "NETWorkingTool.h"
#import "UrlConstants.h"
#import "NSString+MD5.h"
#import "LZPublic.h"
#import "RSA.h"
#import "YWHMBProgress.h"
#import "EB_NoRightController.h"
#import "JsonString.h"
#import "UIView+YWHView.h"
#import "SBJson5.h"
#import "UIViewController+EB_OutOfMemory.h"
#import "EB_SaveFileList.h"
#import "TimeTool.h"
#import "EB_VersionUpgradesManager.h"

#import "EB_NetworkCache.h"
#import "EB_NetworkingConfig.h"

#define durationTime 2.0

@interface NETWorkingTool ()

/**
 是AFURLSessionManager的子类，为HTTP的一些请求提供了便利方法，当提供baseURL时，请求只需要给出请求的路径即可
 */
@property (nonatomic, strong) AFHTTPSessionManager *requestManager;
/**
 bgList
 */
@property (nonatomic, strong) NSArray *codeList;

/**
 去除数组
 */
@property (nonatomic, strong) NSArray *urlList;

/**
 这个字典是为了实现 取消某一个urlString的本地网络缓存数据而设计，字典结构如下
 key:urlString
 value: @[cacheKey1, cacheKey2]
 当调用clearRequestCache:identifier:方法时，根据key找到对应的value，
 然后进行指定缓存、或者根据urlString批量删除
 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableSet <NSString *>*>*cacheKeys;

@end


@implementation NETWorkingTool

+ (instancetype)shareInstance {
    static NETWorkingTool *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NETWorkingTool alloc] init];
        instance.requestManager = [AFHTTPSessionManager manager] ;
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        instance.requestManager.securityPolicy = securityPolicy;
    });
    
    return instance;
}

//+ (AFHTTPSessionManager *)shareManager{
//    static AFHTTPSessionManager *manager;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        manager = [AFHTTPSessionManager manager];
//    });
//    
//    return manager;
//}

- (instancetype)init {
    if (self = [super init]) {
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
            self.networkStatus = status;
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
//        self.configuration = [[EB_NetworkingConfig alloc] init];
        
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
        
        if (!_cacheKeys) {
            _cacheKeys = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

+ (instancetype)shareNetworkTool {
    
    NETWorkingTool *instance_base = [NETWorkingTool shareInstance];
    [instance_base initialConfig:SERVER_BASEURL];
    [instance_base configJsonResponseSerializer];
    [instance_base configResponseSerializerAcceptableContentTypes];
    [instance_base configAccessTokenNormal:YES];
    [instance_base configHTTPHeaderField];
    return instance_base;
}

//token 切换 前后台切换 baseUrl_不一样
+ (instancetype)defaultNetworkTool {
    NETWorkingTool *instance_base = [NETWorkingTool shareInstance];
    [instance_base initialConfig:SERVER_ADMID_BASEURL];
    [instance_base configJsonResponseSerializer];
    [instance_base configResponseSerializerAcceptableContentTypes];
    [instance_base configAccessTokenNormal:YES];
    [instance_base configHTTPHeaderField];
    return instance_base;
}

//统计导出excel
+ (instancetype)shareNetworkToolCompound {
    
    NETWorkingTool *instance_admin = [NETWorkingTool shareInstance];
    [instance_admin initialConfig:SERVER_BASEURL];
    [instance_admin configCompoundResponseSerializer];
    [instance_admin configAccessTokenNormal:YES];
    [instance_admin configHTTPHeaderField];
    return instance_admin;
}

//参数整理
+ (instancetype)shareNetworkTools {
    NETWorkingTool *instance = [NETWorkingTool shareInstance];
    [instance initialConfig:SERVER_BASEURL];
    instance.requestManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [instance configJsonResponseSerializer];
    [instance configAccessTokenNormal:YES];
    [instance configHTTPHeaderField];
    [instance configQueryStringRequestSerializer];
    return instance;
}

+ (instancetype)defaultBackStageNetWorkTool {
    NETWorkingTool *instance_base = [NETWorkingTool shareInstance];
    [instance_base initialConfig:SERVER_ADMID_BASEURL];
    [instance_base configAccessTokenNormal:NO];
    [instance_base configJsonResponseSerializer];
    [instance_base configHTTPHeaderField];
    return instance_base;
}

- (void)initialConfig:(NSString *)baseUrl {
    _baseUrl = baseUrl;
    self.requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    if (_timeoutInterval > 0) {
        self.requestManager.requestSerializer.timeoutInterval = _timeoutInterval;
    }
    else {
        self.requestManager.requestSerializer.timeoutInterval = EBRequestTimeoutInterval;
    }
    [self.requestManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//    self.requestManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    
}


- (void)configQueryStringRequestSerializer {
    [self.requestManager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
        //在这里面对parameters进行处理
        return [NSString stringWithFormat:@"%@",parameters];
    }];
}


- (void)configCompoundResponseSerializer {
    self.requestManager.responseSerializer = [AFCompoundResponseSerializer serializer];
}

- (void)configJsonResponseSerializer {
    // 设置返回格式
    self.requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
}

- (void)configResponseSerializerAcceptableContentTypes {
    self.requestManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json",@"text/plain",@"text/javascript", nil];
}

- (void)configAccessTokenNormal:(BOOL)isNormal {
    if (isNormal) {
        [self.requestManager.requestSerializer setValue:getAccessToken() forHTTPHeaderField:@"accessToken"];
    }
    else {
        [self.requestManager.requestSerializer setValue:GetBackStageAccessToken() forHTTPHeaderField:@"accessToken"];
    }
}

- (void)configHTTPHeaderField {
    [self.requestManager.requestSerializer setValue:getAppOS() forHTTPHeaderField:@"os"];
    [self.requestManager.requestSerializer setValue:getOSVersion() forHTTPHeaderField:@"osVersion"];
    [self.requestManager.requestSerializer setValue:getDeviceId() forHTTPHeaderField:@"deviceId"];
    [self.requestManager.requestSerializer setValue:getDeviceModel() forHTTPHeaderField:@"phoneMode"];
    [self.requestManager.requestSerializer setValue:getAppVersion() forHTTPHeaderField:@"appVersion"];
    [self.requestManager.requestSerializer setValue:[self timeZoneName] forHTTPHeaderField:@"timeZone"];
    [self.requestManager.requestSerializer setValue:[NSString stringWithFormat:@"%@",@([self memorySize])] forHTTPHeaderField:@"memorySize"];
    if(getThingsId() && getThingsId().length > 0) {
        [self.requestManager.requestSerializer setValue:getThingsId() forHTTPHeaderField:@"thingsId"];
    }
    
    [self.requestManager.requestSerializer setValue:GetCurrentCompanyId() forHTTPHeaderField:@"companyId"];
    if(getCompanyId() && getCompanyId().length > 0) {
        [self.requestManager.requestSerializer setValue:getCompanyId() forHTTPHeaderField:@"companyId"];
    }
}

- (void)cancelAllRequest {
    [self.requestManager invalidateSessionCancelingTasks:YES];
}

#pragma mark - 实例化
- (AFHTTPSessionManager *)requestManager {
    if (!_requestManager) {
        _requestManager = [AFHTTPSessionManager manager] ;
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        _requestManager.securityPolicy = securityPolicy;
    }
    return _requestManager;
}

//- (EB_NetworkingConfig *)disposeConfiguration:(void (^_Nullable)(EB_NetworkingConfig * _Nullable configuration))configurationHandler {
//    //configuration配置
//    EB_NetworkingConfig *configuration = [self.configuration copy];
//    if (configurationHandler) {
//        configurationHandler(configuration);
//    }
//    self.requestManager.requestSerializer = configuration.requestSerializer;
//    self.requestManager.responseSerializer = configuration.responseSerializer;
//    if (configuration.builtinHeaders.count > 0) {
//        for (NSString *key in configuration.builtinHeaders) {
//            [self.requestManager.requestSerializer setValue:configuration.builtinHeaders[key] forHTTPHeaderField:key];
//        }
//    }
//
//    [self.requestManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    if (configuration.timeoutInterval > 0) {
//        self.requestManager.requestSerializer.timeoutInterval = configuration.timeoutInterval;
//    }
//    else {
//        self.requestManager.requestSerializer.timeoutInterval = EBRequestTimeoutInterval;
//    }
//    [self.requestManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//    return configuration;
//}


#pragma mark ---private--
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


//注意一定传递url、method
- (NSString *)getSignWithDictionary:(NSDictionary *)dictionary URL:(NSString *)URL method:(NSString *)method nonce_str:(NSString *)nonce_str {
    //目标字典
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithCapacity:0];
    //随机字符串
    if (nonce_str != nil) {
        [paraDict setObject:nonce_str forKey:@"nonce_str"];
    }
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
                value = NewStringFromUTFString(value);
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
            if ([dictionary isKindOfClass:[NSString class]]) {
                paraString = (NSString *)dictionary;
            } else
            {
                paraString = [[SBJson5Writer alloc] stringWithObject:dictionary];
                paraString = [paraString stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
            }
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
    
    if (![NETwork isEqualToString:@"P"]) {
        [self.requestManager.requestSerializer setValue:mutableString forHTTPHeaderField:@"signBefore"];
    }
    
    if (mutableString.length > 0) {
        NSString *md5String = [mutableString md5With32BitUppercase];
        

//       #ifndef APPSTORE
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSString *key = [NSString stringWithFormat:@"%@_%@",[TimeTool GetCurrentGMT_Time],md5String];
//
//            [EB_SaveFileList writeToFileWithValue:mutableString forKey:key];
//        });
//
//        #endif

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
    NSString *mutableString = [NSString stringWithFormat:@"&key=%@.%@.%@.%@.%@.%@",[URL stringByRemovingPercentEncoding],method,@([content length]),getDeviceId(),getAppOS(),[NETWorkingTool decodedAuthCode:GetAuthCode()]];
    return mutableString;
}


+ (NSString *)decodedAuthCode:(NSString *)base64Str {
    
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMTJC7BtkMoboSeh ptttqNaEs6+ZcWe3Ci8Yajxjps0Db1COwVh38ZOQZp4iQOR7wyGzc5JKwwlxGZNU +BxURzdMNsB/5MKjIEO1hu33yJxtHkQgTQJxZlzd1DTE3v22AyImKrTjgn7WhCFw ngkpE4H/4zXngoZzAN9uGNycKwMXAgMBAAECgYBZ+9TsiC19PcUjajfyfuKFtYi0 82V4F6sAfhmWI7tSZA+ytpSS78X3xEAob2FdGXrRHk3qx2UIHD+lr2UFD0TApymG jPNvbUvomzv6THs4vxY6T8L+BhhSloOoDIAqcXf+NpbH/DN2tblNC2bdbbupoeLc c9o7hql1YK6aC9p8gQJBAOe19yTINbhh0tjiU2tB1mJb6apanhACjpExU8bU8OND Dc86izjuLlkztvXzgfghKj7zD06FDt3P82jAm0bkATUCQQDZadgP2krCDaoRxaH+ eD2vVGIQR9XiFl8Nb+jrG3xW5fE5pWlVVJjZ2IZST/iYeMWqJINYa6LEB4rBYZgr 9iibAkAlNG+RhWAy0epEDtssHq8ore9v/grhMTfpEk2MYIapRwwBmTnfk0b35bjb9xSIXfLllqt/hRfk/83qpPqJwHR9AkEAkj+N1NQdl73DWmMcXmYZ8HgN4y+/Y29zD0HpZ0W89WOGSiXH3lui2l+5s2MSMdaD+LjJFdCJ093S69SvnVrf4wJAaBlCK4i7fgRiyXkvCnMaCE8bZ+8XmFAMGGAQ90pKAQ7Y6S3ms/QFik3NBdfXCv6ndEfuS8oDJAlZiQcOw94YrA==";

    NSString *decodedString = [RSA decryptString:base64Str privateKey:privateKey];

    return decodedString;
}

- (NSDictionary *)getRequestSerializerSignURL:(NSString *)URLString parameters:(NSDictionary *)parameters uuid:(NSString *)uuidString {
    
    NSString *sign = [self getSignWithDictionary:parameters URL:URLString method:@"GET" nonce_str:uuidString];
    
    return @{uuidString:sign};
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

//错误码统一处理的方法
- (BOOL)analyseCodeErrorFromResponseObject:(id)responseObject urlString:(NSString *)URLString {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSString *code = responseObject[@"code"];
        if ([@"0008" isEqualToString:code] && ![URLString containsString:@"rest/app/info"] && ![URLString containsString:@"rest/things/company/"]) {
            NSLog(@"---0008---%@",URLString);
            [EB_VersionUpgradesManager showAlert:URLString];
            return YES;
        }
        if ([self.codeList containsObject:code]) {
            [self noRightVcWithCode:code];
            return YES;
        }
        
        if ([@"1000" isEqualToString:code] || [@"0005" isEqualToString:code])
        {
            NSLog(@"--1000--%@,%@",code,URLString);
            if ([URLString containsString:@"usercenter/u/location/add"]) {
                return YES;
            }
            
            #ifndef APPSTORE
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString *key = [NSString stringWithFormat:@"%@_%@",[TimeTool GetCurrentGMT_Time],code];

                [EB_SaveFileList writeToFileWithValue:key forKey:URLString];
            });

            #endif
            
            EB_ToastTextTimes(((NSDictionary *)responseObject).eb_errorString, SCREEN_HEIGHT/4, durationTime);
        }
        
    }
    return NO;
}

//- (NSArray *)codeList
//{
//    if (!_codeList) {
//        _codeList = @[@"1048",
//                      @"1050",
//                      @"1057",
//                      @"1058",
//                      @"1059",
//                      @"1060",
//                      @"1061",
//                      @"4013",
//                      @"4014",
//                      @"1053",
//                      @"7098"];
//    }
//    return _codeList;
//}

#pragma mark ---public---
//- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
//    self.requestManager.requestSerializer.timeoutInterval = timeoutInterval;
//}

- (NSArray *)tasks {
    return self.requestManager.tasks;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
     parameters:(id _Nullable)parameters
 showMBProgress:(BOOL)show
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure;
{
    if (show) {
        [YWHMBProgress show];
    }
    
    if (!URLString) {
        URLString = @"";
    }

    NSString *requestUrl = [[NSURL URLWithString:URLString relativeToURL:[NSURL URLWithString:self.baseUrl]] absoluteString];
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    [self.requestManager.requestSerializer setValue:[self getSignWithDictionary:parameters URL:URLString method:@"POST" nonce_str:uuidString] forHTTPHeaderField:@"sign" ];
    [self.requestManager.requestSerializer setValue:uuidString forHTTPHeaderField:@"nonce_str"];
    NSURLSessionDataTask * task = [self.requestManager POST:requestUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (show) {
            [YWHMBProgress hide];
        }
        if ([self analyseCodeErrorFromResponseObject:responseObject urlString:URLString]) {
            return;
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
    return task;
}

- (void)GET:(NSString *)URLString
    parameters:(id _Nullable)parameters
showMBProgress:(BOOL)show
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *error))failure;
{
    if (show) {
        [YWHMBProgress show];
    }
    if (!URLString) {
        URLString = @"";
    }
    
    NSString *requestUrl = [[NSURL URLWithString:URLString relativeToURL:[NSURL URLWithString:self.baseUrl]] absoluteString];
    // url 工作表版本更新 过滤
    if (![requestUrl containsString:@"/worktable_offline/version.json"]) {
        NSString *uuidString = [[NSUUID UUID] UUIDString];
        NSString *sign = [self getSignWithDictionary:parameters URL:URLString method:@"GET" nonce_str:uuidString];
        [self.requestManager.requestSerializer setValue:sign forHTTPHeaderField:@"sign"];
        [self.requestManager.requestSerializer setValue:uuidString forHTTPHeaderField:@"nonce_str"];
    }
    [self.requestManager GET:requestUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (show) {
            [YWHMBProgress hide];
        }
        
        //错误码统一处理的方法
        if ([self analyseCodeErrorFromResponseObject:responseObject urlString:URLString]) {
            return;
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

- (void)DELETE:(NSString *)URLString
      parameters:(id _Nullable)parameters
  showMBProgress:(BOOL)show
         success:(void (^)(id responseObject))success
         failure:(void (^)(NSError *error))failure;
{
    if (show) {
        [YWHMBProgress show];
    }
    if (!URLString) {
        URLString = @"";
    }
    
    NSString *requestUrl = [[NSURL URLWithString:URLString relativeToURL:[NSURL URLWithString:self.baseUrl]] absoluteString];
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    [self.requestManager.requestSerializer setValue:[self getSignWithDictionary:parameters URL:URLString method:@"DELETE" nonce_str:uuidString] forHTTPHeaderField:@"sign"];
    [self.requestManager.requestSerializer setValue:uuidString forHTTPHeaderField:@"nonce_str"];
    [self.requestManager DELETE:requestUrl parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (show) {
            [YWHMBProgress hide];
        }
        
        if ([self analyseCodeErrorFromResponseObject:responseObject urlString:URLString]) {
            return;
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

- (void)PUT:(NSString *)URLString
    parameters:(id _Nullable)parameters
showMBProgress:(BOOL)show
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *error))failure;
{
    if (show) {
        [YWHMBProgress show];
    }
    if (!URLString) {
        URLString = @"";
    }
    
    NSString *requestUrl = [[NSURL URLWithString:URLString relativeToURL:[NSURL URLWithString:self.baseUrl]] absoluteString];
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    [self.requestManager.requestSerializer setValue:[self getSignWithDictionary:parameters URL:URLString method:@"PUT" nonce_str:uuidString] forHTTPHeaderField:@"sign"];
    [self.requestManager.requestSerializer setValue:uuidString forHTTPHeaderField:@"nonce_str"];
    [self.requestManager PUT:requestUrl parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (show) {
            [YWHMBProgress hide];
        }
        
        if ([self analyseCodeErrorFromResponseObject:responseObject urlString:URLString]) {
            return;
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

- (void)EB_GET:(NSString *)URLString
    parameters:(id _Nullable)parameters
showMBProgress:(BOOL)show
      progress:(void (^)(NSProgress * _Nonnull))progress
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *error))failure
{
    if (show) {
        [YWHMBProgress show];
    }
    if (!URLString) {
        URLString = @"";
    }
    
    NSString *requestUrl = [[NSURL URLWithString:URLString relativeToURL:[NSURL URLWithString:self.baseUrl]] absoluteString];
    // url 工作表版本更新 过滤
    if (![URLString containsString:@"/worktable_offline/version.json"]) {
        NSString *uuidString = [[NSUUID UUID] UUIDString];
        [self.requestManager.requestSerializer setValue:[self getSignWithDictionary:parameters URL:URLString method:@"GET" nonce_str:uuidString] forHTTPHeaderField:@"sign"];
        [self.requestManager.requestSerializer setValue:uuidString forHTTPHeaderField:@"nonce_str"];
    }
    [self.requestManager GET:requestUrl parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (show) {
            [YWHMBProgress hide];
        }
        
        if ([self analyseCodeErrorFromResponseObject:responseObject urlString:URLString]) {
            return;
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

/*
 #ifndef APPSTORE
 dispatch_async(dispatch_get_global_queue(0, 0), ^{
 NSString *key = [NSString stringWithFormat:@"%@",[TimeTool GetCurrentGMT_Time]];
 
 [EB_SaveFileList writeToFileWithValue:URLString forKey:key];
 });
 
 #endif
 */

@end
