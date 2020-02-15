//
//  EB_BackStageNetWorkTool.h
//  eThings
//
//  Created by 昊天 on 3/20/18.
//  Copyright © 2018 Beijing FR Information technology Co.,Ltd. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface EB_BackStageNetWorkTool : AFHTTPSessionManager

+ (instancetype)defaultBackStageNetWorkTool;
- (void)GET:(NSString *)URLString
 parameters:(id)parameters
showMBProgress:(BOOL)show
    success:(void (^)(id responseObject))success
    failure:(void (^)(NSError *error))failure;

- (void)POST:(NSString *)URLString
  parameters:(id)parameters
showMBProgress:(BOOL)show
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure;
@end
