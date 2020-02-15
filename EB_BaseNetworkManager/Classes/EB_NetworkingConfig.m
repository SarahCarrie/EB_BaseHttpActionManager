//
//  EB_NetworkingConfig.m
//  eThings
//
//  Created by Fengrui_Ning on 2019/9/18.
//  Copyright © 2019 Beijing FR Information technology Co.,Ltd. All rights reserved.
//

#import "EB_NetworkingConfig.h"
#import "EB_BaseNetworkError.h"

const CGFloat EBRequestTimeoutInterval = 30.0f;

@implementation EB_NetworkingConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeoutInterval = EBRequestTimeoutInterval;
        _requestCachePolicy = EB_RequestReturnCacheOrLoadToCache;
        _ebError = [EB_BaseNetworkError class];
        _resultCacheDuration = 86400;
    }
    return self;
}

- (AFHTTPRequestSerializer *)requestSerializer {
    if (!_requestSerializer) {
        _requestSerializer = [AFHTTPRequestSerializer serializer];
        _requestSerializer.timeoutInterval = _timeoutInterval;
    }
    return _requestSerializer;
}

- (AFHTTPResponseSerializer *)responseSerializer {
    if (!_responseSerializer) {
        _responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _responseSerializer;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    EB_NetworkingConfig *configuration = [[EB_NetworkingConfig alloc] init];
    configuration.resultCacheDuration = self.resultCacheDuration;
    configuration.requestCachePolicy = self.requestCachePolicy;
    configuration.baseURL = [self.baseURL copy];
    configuration.builtinHeaders = [self.builtinHeaders copy];
    configuration.builtinBodys = [self.builtinBodys copy];
    configuration.resposeHandle = [self.resposeHandle copy];
    configuration.requestSerializer = [self.requestSerializer copy];
    configuration.responseSerializer = [self.responseSerializer copy];
    configuration.responseSerializer.acceptableContentTypes = self.responseSerializer.acceptableContentTypes;
    configuration.ebError = self.ebError;
    return configuration;
}


@end
