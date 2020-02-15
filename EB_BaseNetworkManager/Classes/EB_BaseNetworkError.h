//
//  EB_BaseNetworkError.h
//  eThings
//
//  Created by 自由行动 on 2017/2/28.
//  Copyright © 2017年 北京自由行动互联网技术有限公司. All rights reserved.
//

#define ERRORCODE_NONETWORK @"100"      //网络不给力，请检查网络设置
#define ERRORMSG_NONETWORK kLocalizedString(@"网络不给力，请检查网络设置", nil)      //网络不给力，请检查网络设置
#define ERRORCODE_SERVER500 @"101"      //服务器错误
#define ERRORMSG_SERVER500 kLocalizedString(@"服务器错误", nil)      //服务器错误
#define ERRORCODE_NOTDATA @"102"      //数据为空
#define ERRORMSG_NOTDATA kLocalizedString(@"数据为空", nil)      //数据为空
#define ERRORCODE_CUSTOM @"103"      //自定义错误

#define ERRORCODE_0001 @"0001"        //系统错误-      new 服务器异常
#define ERRORCODE_0005 @"0005"      //缺少关键业务参数
#define ERRORCODE_0003 @"0003"        //没有权限

#define ERRORCODE_0008 @"0008"        //强制升级

#define ERRORCODE_1001 @"1001"        //不支持的类型
#define ERRORCODE_1002 @"1002"        //用户不存在
#define ERRORCODE_1003 @"1003"        //Friend好友不存在
#define ERRORCODE_1004 @"1004"        //Code不存在
#define ERRORCODE_1005 @"1005"        //密码错误
#define ERRORCODE_1006 @"1006"        //Token已经过期
#define ERRORCODE_1007 @"1007"        //Token不存在
#define ERRORCODE_1008 @"1008"        //公司不存在
#define ERRORCODE_1009 @"1009"        //不支持的类型
#define ERRORCODE_1010 @"1010"        //部门不存在


#define ERRORCODE_1011 @"1011"        //手机号已经存在
#define ERRORCODE_1012 @"1012"        //非法的状态
#define ERRORCODE_1013 @"1013"        //无权限
#define ERRORCODE_1014 @"1014"        //公司详情已经存在
#define ERRORCODE_1015 @"1015"        //无效的手机号码
#define ERRORCODE_1016 @"1016"        //重复发送过验证码
#define ERRORCODE_1017 @"1017"        //没有绑定手机号
#define ERRORCODE_1018 @"1018"        //不能转移到子部门
#define ERRORCODE_1019 @"1019"        //不能删除员工
#define ERRORCODE_1020 @"1020"        //不能删除该部门

#define ERRORCODE_1031 @"1031"        //30天内不允许在更换

#define ERRORCODE_3001 @"3001"        //不能删除别人的评论
#define ERRORCODE_3002 @"3002"        //有人回复您，不能删
#define ERRORCODE_3003 @"3003"        //该动态已被删除
#define ERRORCODE_3004 @"3004"        //该动态已被删除
#define ERRORCODE_3005 @"3005"        //不是本人操作
#define ERRORCODE_3006 @"3006"        //
#define ERRORCODE_3007 @"3007"        //
#define ERRORCODE_3008 @"3008"        //
#define ERRORCODE_3009 @"3009"        //
#define ERRORCODE_3010 @"3010"        //
#define ERRORCODE_3011 @"3011"        //
#define ERRORCODE_3012 @"3012"        //

#define ERRORCODE_4001  @"4001"        //">非法的数据</string>
#define ERRORCODE_4002  @"4002"            //">不支持的操作</string>
#define ERRORCODE_4003  @"4003"            //">未实现</string>

#define ERRORCODE_6001  @"6001"            //
#define ERRORCODE_6002  @"6002"            //
#define ERRORCODE_6003  @"6003"            //
#define ERRORCODE_6004  @"6004"            //

#define ERRORCODE_6011  @"6011"            //
#define ERRORCODE_6012  @"6012"            //
#define ERRORCODE_6013  @"6013"            //
#define ERRORCODE_6014  @"6014"            //
#define ERRORCODE_6015  @"6015"
#define ERRORCODE_6016  @"6015" //
#define ERRORCODE_6017  @"6015"

#define ERRORCODE_6021  @"6015"
#define ERRORCODE_6031  @"6015"
#define ERRORCODE_6032  @"6015"
#define ERRORCODE_6040  @"6015"
#define ERRORCODE_6041  @"6041"

#define ERRORCODE_7001 @"7001"
#define ERRORCODE_7002 @"7001"
#define ERRORCODE_7003 @"7001"
#define ERRORCODE_7004 @"7001"
#define ERRORCODE_7005 @"7001"
#define ERRORCODE_7006 @"7001"
#define ERRORCODE_7007 @"7001"

#define ERRORCODE_7011 @"7001"
#define ERRORCODE_7012 @"7001"
#define ERRORCODE_7013 @"7001"
#define ERRORCODE_7014 @"7001"

#define ERRORCODE_7051 @"7001"
#define ERRORCODE_7052 @"7001"
#define ERRORCODE_7053 @"7001"
#define ERRORCODE_7054 @"7001"
#define ERRORCODE_7055 @"7001"
#define ERRORCODE_7061 @"7001"
#define ERRORCODE_7071 @"7001"


#import <Foundation/Foundation.h>

@interface EB_BaseNetworkError : NSObject

//错误代码
@property (nonatomic, strong) NSString* errorCode;

//错误信息
@property (nonatomic, strong) NSString* errorMsg;

@end
