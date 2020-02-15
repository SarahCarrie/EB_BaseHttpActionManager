//
//  EB_ActionBaseOpration.h
//  eThings
//
//  Created by 自由行动 on 2017/3/3.
//  Copyright © 2017年 北京自由行动互联网技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EB_BaseNetworkError.h"

@interface EB_ActionBaseOpration : NSObject

+(EB_BaseNetworkError*)parseCode:(id)responseObj;

//rn_获取fail的错误码用此方法
+ (EB_BaseNetworkError *)errorParseResponse:(id)responseObj;

+(void)gotoLoginForToken;

@end
