//
//  EB_ActionBaseOpration.m
//  eThings
//
//  Created by 自由行动 on 2017/3/3.
//  Copyright © 2017年 北京自由行动互联网技术有限公司. All rights reserved.
//

#import "EB_ActionBaseOpration.h"
#import "UrlConstants.h"
#import "StringUtil.h"
#import "AppDelegate.h"
#import "UIView+YWHView.h"
#import "ET_BaseTools.h"

@implementation EB_ActionBaseOpration

+(EB_BaseNetworkError*)parseCode:(id)responseObj
{
    EB_BaseNetworkError* error = [[EB_BaseNetworkError alloc]init];
    if (!responseObj) {
        error.errorCode = ERRORCODE_SERVER500;
        error.errorMsg = ERRORMSG_SERVER500;
        return error;
    }
    
    //parse msgCode & msgInfo & data
    if ([responseObj isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dictionary = (NSDictionary*)responseObj;
        
        NSString *msgCode = [dictionary objectForKey:JSONDATA_CODE];
        NSString *msgInfo = [dictionary objectForKey:JSONDATA_MSG];
        
        if ([StringUtil isEmpty:msgCode] || ![msgCode isEqualToString:JSONDATA_CODE_OK]) {
            //failure and switch code
            if ([ERRORCODE_0001 isEqualToString:msgCode]) {
                error.errorCode = ERRORCODE_0001;
                error.errorMsg = kLocalizedString(@"服务器异常", nil);
            }
            else if ([ERRORCODE_0005 isEqualToString:msgCode]) {
                error.errorCode = ERRORCODE_0005;
                error.errorMsg = kLocalizedString(@"缺少关键业务参数", nil);
            }
            else if ([ERRORCODE_0003 isEqualToString:msgCode]) {
                error.errorCode = ERRORCODE_0003;
                error.errorMsg = kLocalizedString(@"没有权限", nil);
            }
            else if([ERRORCODE_1001 isEqualToString:msgCode]) {
                error.errorCode = ERRORCODE_1001;
                error.errorMsg = kLocalizedString(@"不支持的类型", nil);
            }else if([ERRORCODE_1002 isEqualToString:msgCode]) {
                error.errorCode = ERRORCODE_1002;
                error.errorMsg = kLocalizedString(@"用户不存在", nil);
            }else if([ERRORCODE_1003 isEqualToString:msgCode]) {
                error.errorCode = ERRORCODE_1003;
                error.errorMsg = kLocalizedString(@"好友不存在", nil);
            }else if([ERRORCODE_1004 isEqualToString:msgCode]) {
                error.errorCode = ERRORCODE_1004;
                error.errorMsg = kLocalizedString(@"验证码错误，请重试", nil);
            }else if([ERRORCODE_1005 isEqualToString:msgCode]) {
                error.errorCode = ERRORCODE_1005;
                error.errorMsg = kLocalizedString(@"密码错误", nil);
            }else if([ERRORCODE_1006 isEqualToString:msgCode]) {
                //Token已经过期
                error.errorCode = ERRORCODE_1006;
                error.errorMsg = kLocalizedString(@"账户登录信息已过期，请重新登录", nil);
                //token过期，弹出登录窗
                [self gotoLoginForToken];
            }else if([ERRORCODE_1007 isEqualToString:msgCode]) {
                //Token不存在-账户登录信息已过期，请重新登录
                error.errorCode = ERRORCODE_1007;
                error.errorMsg = kLocalizedString(@"账户登录信息已过期，请重新登录", nil);
                //token过期，弹出登录窗
                [self gotoLoginForToken];
            }else if([ERRORCODE_1008 isEqualToString:msgCode]) {
                error.errorCode = ERRORCODE_1008;
                error.errorMsg = kLocalizedString(@"公司不存在", nil);
            }else if([ERRORCODE_1009 isEqualToString:msgCode]) {
                error.errorCode = ERRORCODE_1009;
                error.errorMsg = kLocalizedString(@"不支持的类型", nil);
            }else if([ERRORCODE_1010 isEqualToString:msgCode]) {
                error.errorCode = ERRORCODE_1010;
                error.errorMsg = kLocalizedString(@"部门不存在", nil);
            }else {
                if ([StringUtil isEmpty:msgInfo]) {
                    error.errorCode = ERRORCODE_CUSTOM;
                    error.errorMsg = kLocalizedString(@"请求数据失败", nil);
                }else{
                    error.errorCode = msgCode;
                    error.errorMsg = msgInfo;
                }
            }
            return error;
        }
        
    }else{
        error.errorCode = ERRORCODE_SERVER500;
        error.errorMsg = ERRORMSG_SERVER500;
        return error;
    }
    return nil;
}

+ (EB_BaseNetworkError *)errorParseResponse:(id)responseObj {
    EB_BaseNetworkError* error = [[EB_BaseNetworkError alloc] init];
    if (!responseObj || ![responseObj isKindOfClass:[NSDictionary class]]) {
        error.errorCode = ERRORCODE_SERVER500;
        error.errorMsg = ERRORMSG_SERVER500;
        return error;
    }
    
    //parse msgCode & msgInfo & data
    NSDictionary *dictionary = (NSDictionary*)responseObj;
    
    NSString *msgCode = dictionary[JSONDATA_CODE];
    NSString *msgInfo = dictionary[JSONDATA_MSG];
    
    if ([msgCode isEqualToString:JSONDATA_CODE_OK]) {
        return nil;
    }
    
//#warning 强制更新未定版本
//    if ([msgCode isEqualToString:ERRORCODE_0008]) {
////        [UIViewController eb_alertTitle:kLocalizedString(@"提示", nil) message:kLocalizedString(@"下载最新版本才能继续使用", nil) preferredStyle:UIAlertControllerStyleAlert cancelBlock:nil confirmBlock:^{
////            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/%E4%BA%8B%E4%BA%8B%E6%98%8E/id1274852118?mt=8"]];
////        }];
//    }
    
    if([msgCode isEqualToString:ERRORCODE_1006] || [msgCode isEqualToString:ERRORCODE_1007]) {
        //token过期，弹出登录窗
        [self gotoLoginForToken];
    }
    
    NSString *name = [NSString stringWithFormat:@"ErrorCode_Msg_%@",msgCode];
    NSDictionary *dict = [self getErrorCodeMsgDict];
    msgInfo = GetString(dict[name]);
    error.errorCode = msgCode;
    error.errorMsg = msgInfo;
    if (!msgInfo || msgInfo.length <= 0) {
        error.errorMsg = GetString(dictionary[JSONDATA_MSG]);
    }
    if (!error.errorMsg || error.errorMsg.length <= 0) {
        error.errorMsg = GetString(dictionary[@"message"]);
    }
    if (!error.errorMsg || error.errorMsg.length <= 0) {
        error.errorMsg = ERRORMSG_SERVER500;
    }
    return error;
}

+ (NSDictionary *)getErrorCodeMsgDict {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ErrorCodeMsg" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    return dict;
}

+ (void)gotoLoginForToken
{
    //处理token过期业务，弹出确认弹窗，跳往登录页面
    if (EB_NewCheckStringIsEmpty([EB_UntilDefault userObjForKey:@"username"])) {
        return;
    }
    [EB_UserInfo ClearData];
    [EB_UntilDefault removeUserObjForKey:@"username"];
    [EB_UntilDefault removeUserObjForKey:@"pwd"];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *nVC = appDelegate.navigationController;
    if ([[ET_BaseTools currentViewController] isKindOfClass:NSClassFromString(@"EB_LoginOfPhoneViewController")]) {
        return;
    }
    [nVC popToRootViewControllerAnimated:YES];
}

@end
