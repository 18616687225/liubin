//
//  FMDataBaseManager.h
//  GameClient
//  数据库管理
//  Created by liubin on 13-1-8.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"

@interface FMDataBaseManager : NSObject
{
    FMDatabase       *m_userDatabaseHandle;     //用户数据库句柄
    FMDatabase       *m_globalDatabaseHandle;   //公用数据库句柄
}

@property(nonatomic,retain) FMDatabase *userDatabaseHandle;
@property(nonatomic,retain) FMDatabase *globalDatabaseHandle;


/*********************************************************************
 函数名称 : shareInstance
 函数描述 : 获取FMDataBaseManager实例
 参数 : N/A
 返回值 : FMDataBaseManager实例
 作者 : 刘斌
 *********************************************************************/
+ (FMDataBaseManager*) shareInstance;

/*********************************************************************
 函数名称 : startDatabaseHanlde
 函数描述 : 启动数据库句柄
 参数 :
 userDBName : 用户数据库全路径名
 globalDBName : 全局数据库路径
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)startDatabaseHandle:(NSString *)userDBName globalDBName:(NSString *)globalDBName;

/*********************************************************************
 函数名称 : createGlobalDatabase
 函数描述 : 创建全局数据库，生成所有的表
 参数 :
 dbName : 数据库全路径名
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL) createGlobalDatabase:(NSString *)dbName;

/*********************************************************************
 函数名称 : createUserDatabase
 函数描述 : 创建用户数据库，生成所有的表
 参数 :
 dbName : 数据库全路径名
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL) createUserDatabase:(NSString *)dbName;

/*********************************************************************
 函数名称 : openUserDatabase
 函数描述 : 打开用户数据库
 参数 : N/A
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)openUserDatabase;

/*********************************************************************
 函数名称 : closeUserDatabase
 函数描述 : 关闭用户数据库
 参数 : N/A
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)closeUserDatabase;

/*********************************************************************
 函数名称 : openGlobeDatabase
 函数描述 : 打开全局数据库
 参数 : N/A
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)openGlobeDatabase;

/*********************************************************************
 函数名称 : closeGlobeDatabase
 函数描述 : 关闭全局数据库
 参数 : N/A
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)closeGlobeDatabase;

/*********************************************************************
 函数名称 : updataDatabase
 函数描述 : 执行创建、删除、新增、更新数据库操作
 参数 :
 sql : 数据库执行语句
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)updataDatabase:(FMDatabase *)dbHandle withSql:(NSString *) sql, ...;

/*********************************************************************
 函数名称 : transactionUpdataDatabase
 函数描述 : 执行多条创建、删除、新增、更新数据库操作
 参数 :
 sql : 数据库执行语句
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL) transactionUpdataDatabase:(FMDatabase *)dbHandle
                      withSqlArray:(NSArray *) sqlArray;

/*********************************************************************
 函数名称 : queryDatabase
 函数描述 : 查询数据库返回结果集
 参数 :
 sql : 数据库执行语句
 返回值 : 查询结果集合
 作者 : 刘斌
 *********************************************************************/
- (FMResultSet *) queryDatabase:(FMDatabase*)fmdb
                        withSql:(NSString*) sql, ... ;

@end
