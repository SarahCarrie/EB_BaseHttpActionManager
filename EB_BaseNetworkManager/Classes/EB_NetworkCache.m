//
//  EB_NetworkCache.m
//  eThings
//
//  Created by Fengrui_Ning on 2019/9/18.
//  Copyright © 2019 Beijing FR Information technology Co.,Ltd. All rights reserved.
//

#import "EB_NetworkCache.h"
#import <YYCache.h>
#import <YYDiskCache.h>


#define EB_Key_sign        @"sign"
#define EB_Key_timestamp   @"timestamp"

static NSString *const EBNetworkResponseCache = @"EBNetworkResponseCache";
static NSString *const EBNetworkResponseCacheTimeOut = @"EBNetworkResponseCacheTimeOut";

@implementation EB_NetworkCache

static YYCache *_dataCache;

+ (void)initialize {
    _dataCache = [YYCache cacheWithName:EBNetworkResponseCache];
}


/**
 写入缓存
 
 */
+ (void)setHttpCache:(id)httpData
                 URL:(NSString *)URL
          parameters:(NSDictionary *)parameters{
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:[self detailNOCareParams:parameters]];
    //异步缓存,不会阻塞主线程
    [_dataCache setObject:httpData forKey:cacheKey withBlock:nil];
    //缓存请求过期时间
    [self setCacheInvalidTimeWithCacheKey:cacheKey];
    
}

/**
 获取缓存
 
 */
+ (id)httpCacheForURL:(NSString *)URL
           parameters:(NSDictionary *)parameters
       cacheValidTime:(NSTimeInterval)cacheValidTime{
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:[self detailNOCareParams:parameters]];
    id cache = [_dataCache objectForKey:cacheKey];
    
    if (!cache) {
        return nil;
    }
    
    if ([self verifyInvalidCache:cacheKey resultCacheDuration:cacheValidTime]) {
        return cache;
    }else{
        [_dataCache.diskCache removeObjectForKey:cacheKey];
        NSString *cacheDurationKey = [NSString stringWithFormat:@"%@_%@",cacheKey, EBNetworkResponseCacheTimeOut];
        [_dataCache.diskCache removeObjectForKey:cacheDurationKey];
        return nil;
    }
    
}

+ (NSInteger)getAllHttpCacheSize {
    return [_dataCache.diskCache totalCost];
}

+ (void)removeAllHttpCache {
    
    [_dataCache.diskCache removeAllObjectsWithProgressBlock:^(int removedCount, int totalCount) {
        NSLog(@"删除数量 = %d ，总数量 = %d",removedCount , totalCount);
    } endBlock:^(BOOL error) {
        NSLog(@"删除http完成 = %d",error);
    }];
}

+(void)removeHttpCacheWithUrl:(NSString *)url
                   parameters:(NSDictionary *)parameters{
    
    NSString *cacheKey = [self cacheKeyWithURL:url parameters:[self detailNOCareParams:[self detailNOCareParams:parameters]]];
    [_dataCache.diskCache removeObjectForKey:cacheKey withBlock:^(NSString * _Nonnull key) {
        
    }];
}


+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    if(!parameters || parameters.count == 0){return URL;};
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@",URL,paraString];
    
    return [NSString stringWithFormat:@"%@",cacheKey];
}


/**
 因为每次请求都要加时间，到时参数不一样。所以存取缓存要忽略此参数
 */
+(NSDictionary *)detailNOCareParams:(NSDictionary *)params{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
    [dic removeObjectsForKeys:@[EB_Key_sign,EB_Key_timestamp]];
    return dic.copy;
}

/**
 存入缓存创建时间
 */
+ (void)setCacheInvalidTimeWithCacheKey:(NSString *)cacheKey{
    
    NSString *cacheDurationKey = [NSString stringWithFormat:@"%@_%@",cacheKey, EBNetworkResponseCacheTimeOut];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    //    NSTimeInterval invalidTime = nowTime + resultCacheDuration;
    [_dataCache setObject:@(nowTime) forKey:cacheDurationKey withBlock:nil];
}

/**
 判断缓存是否有效，有效则返回YES
 */
+ (BOOL)verifyInvalidCache:(NSString *)cacheKey
       resultCacheDuration:(NSTimeInterval )resultCacheDuration{
    //获取该次请求失效的时间戳
    NSString *cacheDurationKey = [NSString stringWithFormat:@"%@_%@",cacheKey, EBNetworkResponseCacheTimeOut];
    id createTime = [_dataCache objectForKey:cacheDurationKey];
    NSTimeInterval createTime1 = [createTime doubleValue];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    if ((nowTime - createTime1) < resultCacheDuration) {
        return YES;
    }
    return NO;
}

@end
