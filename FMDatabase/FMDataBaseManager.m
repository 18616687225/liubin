//
//  FMDataBaseManager.m
//  GameClient
//  数据库管理
//  Created by liubin on 13-1-8.
//
//

#import "FMDataBaseManager.h"

@implementation FMDataBaseManager
@synthesize userDatabaseHandle = m_userDatabaseHandle;
@synthesize globalDatabaseHandle = m_globalDatabaseHandle;

/*********************************************************************
 函数名称 : shareInstance
 函数描述 : 获取FMDataBaseManager实例
 参数 : N/A
 返回值 : FMDataBaseManager实例
 作者 : 刘斌
 *********************************************************************/
+ (FMDataBaseManager*) shareInstance
{
    static FMDataBaseManager *stat_dataBaseManager = nil;
    
    if (nil == stat_dataBaseManager)
    {
        @synchronized(self)
        {
            stat_dataBaseManager = [[FMDataBaseManager alloc] init];
        }
    }
    
    return stat_dataBaseManager;
}

/*********************************************************************
函数名称 : startDatabaseHanlde
函数描述 : 启动数据库句柄
参数 :
userDBName : 用户数据库全路径名
globalDBName : 全局数据库路径
返回值 : 成功/失败
作者 : 刘斌
*********************************************************************/
- (BOOL)startDatabaseHandle:(NSString *)userDBName globalDBName:(NSString *)globalDBName
{
    if (0 == [userDBName length] + [globalDBName length])
    {
        NSLog(@"数据库路径错误!");
        return NO;
    }
    
    BOOL ret = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:userDBName])
    {
        ret = [self createUserDatabase:userDBName];
    }
    else
    {
        self.userDatabaseHandle = [FMDatabase databaseWithPath:userDBName];
    }
    
    if (!ret)
    {
        NSLog(@"用户数据库不存在");
        return NO;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:globalDBName])
    {
        ret = [self createGlobalDatabase:globalDBName];
    }
    else
    {
        self.globalDatabaseHandle = [FMDatabase databaseWithPath:globalDBName];
    }
    
    if (!ret)
    {
        NSLog(@"全局数据库不存在");
        return NO;
    }
    
    return YES;
}

/*********************************************************************
 函数名称 : createGlobalDatabase
 函数描述 : 创建全局数据库，生成所有的表
 参数 :
 dbName : 数据库全路径名
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL) createGlobalDatabase:(NSString *)dbName
{
    if (0 != [dbName length])
    {
        self.globalDatabaseHandle = [FMDatabase databaseWithPath:dbName];
        
        BOOL ret = [self openGlobeDatabase];
        if (ret)
        {
            //创建数据库中所有的表
            
            [self closeGlobeDatabase];
        }
        return ret;
    }
    return NO;
}

/*********************************************************************
 函数名称 : createUserDatabase
 函数描述 : 创建用户数据库，生成所有的表
 参数 :
 dbName : 数据库全路径名
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL) createUserDatabase:(NSString *)dbName
{
    if (0 != [dbName length])
    {
        self.userDatabaseHandle = [FMDatabase databaseWithPath:dbName];
        
        BOOL ret = [self openUserDatabase];
        if (ret)
        {
            //创建数据库中所有的表
            
            [self closeUserDatabase];
        }
        return ret;
    }
    return NO;
}

/*********************************************************************
 函数名称 : openUserDatabase
 函数描述 : 打开用户数据库
 参数 : N/A
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)openUserDatabase
{
    BOOL ret = NO;
    if (![self.userDatabaseHandle open])
    {
        ret = [self.userDatabaseHandle open];
        mtDBCheckerSetMainHandle(self.userDatabaseHandle);
    }
    else
    {
        ret = YES;
    }
    
    return ret;
}

/*********************************************************************
 函数名称 : closeUserDatabase
 函数描述 : 关闭用户数据库
 参数 : N/A
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)closeUserDatabase
{
    mtDBCheckerSetMainHandle(nil);
    return [self.userDatabaseHandle close];
}

/*********************************************************************
 函数名称 : openGlobeDatabase
 函数描述 : 打开全局数据库
 参数 : N/A
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)openGlobeDatabase
{
    BOOL ret = NO;
    if (![self.globalDatabaseHandle open])
    {
        ret = [self.userDatabaseHandle open];
    }
    else
    {
        ret = YES;
    }
    
    return ret;
}

/*********************************************************************
 函数名称 : closeGlobeDatabase
 函数描述 : 关闭全局数据库
 参数 : N/A
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)closeGlobeDatabase
{
    return [self.globalDatabaseHandle close];
}

/*********************************************************************
 函数名称 : updataDatabase
 函数描述 : 执行创建、删除、新增、更新数据库操作
 参数 :
 sql : 数据库执行语句
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL)updataDatabase:(FMDatabase *)dbHandle withSql:(NSString *) sql, ...
{
    va_list args;
	va_start(args, sql);
	
	BOOL ret = [dbHandle open];
	if (ret)
	{
		// 执行创建、删除、新增、更新数据库操作
		ret = [dbHandle executeUpdate:sql error:nil withArgumentsInArray:nil orVAList:args];
		[dbHandle close];
	}
	va_end(args);
	
	return ret;
}

/*********************************************************************
 函数名称 : transactionUpdataDatabase
 函数描述 : 执行多条创建、删除、新增、更新数据库操作
 参数 :
 sql : 数据库执行语句
 返回值 : 成功/失败
 作者 : 刘斌
 *********************************************************************/
- (BOOL) transactionUpdataDatabase:(FMDatabase *)dbHandle
                      withSqlArray:(NSArray *) sqlArray
{
    @synchronized(self)
    {
        BOOL ret;
        if ((ret = [dbHandle open]))
        {
            // 启动事物处理
            [dbHandle beginTransaction];
            
            for (int i = 0; i < [sqlArray count]; i++)
            {
                NSString* sql = (NSString*)[sqlArray objectAtIndex:i];
                ret = [dbHandle executeUpdate:sql];
                if (!ret)
                {
                    break;
                }
            }
            
            if (!ret)
            {
                // 任何一条执行失败，回滚
                [dbHandle rollback];
            }
            else
            {
                // 全部成功，确认
                [dbHandle commit];
            }
            
            [dbHandle close];
        }
        
        return ret;
    }
}

/*********************************************************************
 函数名称 : queryDatabase
 函数描述 : 查询数据库返回结果集
 参数 :
 sql : 数据库执行语句
 返回值 : 查询结果集合
 作者 : 刘斌
 *********************************************************************/
- (FMResultSet *) queryDatabase:(FMDatabase*)fmdb
                        withSql:(NSString*) sql, ...
{
    va_list args;
	va_start(args, sql);
    
	// 获取数据库
	FMResultSet *resultSet;
	// 查询数据库，返回结果集
	resultSet = [fmdb executeQuery:sql withArgumentsInArray:nil orVAList:args];
	
	va_end(args);
	return resultSet;
}

@end
