//
//  EB_BaseNetworkError.m
//  eThings
//
//  Created by 自由行动 on 2017/2/28.
//  Copyright © 2017年 北京自由行动互联网技术有限公司. All rights reserved.
//

#import "EB_BaseNetworkError.h"

@implementation EB_BaseNetworkError

- (id)init
{
    _errorCode = ERRORCODE_SERVER500;
    _errorMsg = ERRORMSG_SERVER500;
    
    return self;
}

@end
