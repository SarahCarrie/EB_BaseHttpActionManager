//
//  NETWorkingTool.h
//  eThings
//
//  Created by ywh on 2017/3/15.
//  Copyright © 2017年 北京自由行动互联网技术有限公司. All rights reserved.
//


#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

#import "UrlConstants.h"

@class EB_NetworkingConfig;

NS_ASSUME_NONNULL_BEGIN

@interface NETWorkingTool : NSObject

@property (nonatomic) NSTimeInterval timeoutInterval;
@property (nonatomic, strong, readonly) NSArray *tasks;

@property (nonatomic, strong, readonly) NSString *baseUrl;

/**
 *  当前的网络状态
 */
@property (nonatomic, assign) AFNetworkReachabilityStatus networkStatus;


+ (instancetype)shareNetworkTool;//json-json

+ (instancetype)shareNetworkTools;//http-json

+ (instancetype)shareNetworkToolCompound; //json-Compound

//后台请求-token
+ (instancetype)defaultBackStageNetWorkTool;


/**
 我的事,超管登录
 ****baseUrl有变化****
 @return instance
 */
+ (instancetype)defaultNetworkTool;

/**
 上层的请求配置，通过该属性传递，保证该类内部不处理上层的逻辑
 */
//@property(nonatomic, strong) EB_NetworkingConfig * _Nullable configuration;


/**
 POST

 @param URLString 请求路径
 @param parameters 参数
 @param show 是否等待
 @param success success description
 @param failure failure description
 */
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id _Nullable)parameters
                showMBProgress:(BOOL)show
                       success:(void (^)(id responseObject))success
                       failure:(void (^)(NSError *error))failure;

/**
 GET
 
 @param URLString 请求路径
 @param parameters 参数
 @param show 是否等待
 @param success success description
 @param failure failure description
 */
- (void)GET:(NSString *)URLString
    parameters:(id _Nullable)parameters
showMBProgress:(BOOL)show
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *error))failure;

- (void)EB_GET:(NSString *)URLString
    parameters:(id _Nullable)parameters
showMBProgress:(BOOL)show
      progress:(void (^)(NSProgress * _Nonnull))progress
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *error))failure;

/**
 DELET
 
 @param URLString 请求路径
 @param parameters 参数
 @param show 是否等待
 @param success success description
 @param failure failure description
 */
- (void)DELETE:(NSString *)URLString
      parameters:(id _Nullable)parameters
  showMBProgress:(BOOL)show
         success:(void (^)(id responseObject))success
         failure:(void (^)(NSError *error))failure;

/**
 PUT
 
 @param URLString 请求路径
 @param parameters 参数
 @param show 是否等待
 @param success success description
 @param failure failure description
 */
- (void)PUT:(NSString *)URLString
    parameters:(id _Nullable)parameters
showMBProgress:(BOOL)show
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *error))failure;


//---
+ (NSString *)decodedAuthCode:(NSString *)base64Str;

/**
 取消所有请求
 */
- (void)cancelAllRequest;


@end

NS_ASSUME_NONNULL_END
