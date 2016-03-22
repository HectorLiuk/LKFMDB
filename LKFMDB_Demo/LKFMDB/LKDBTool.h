//
//  LKDBTool.h
//  LKFMDB_Demo
//
//  Created by lk on 16/3/21.
//  Copyright © 2016年 LK. All rights reserved.
//  github https://github.com/544523660/LKFMDB

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "FMDB.h"
#import <objc/runtime.h>
#import "LKDBColumnDes.h"
#import "LKDBSQLState.h"

@interface LKDBTool : NSObject

@property (nonatomic, retain, readonly) FMDatabaseQueue *dbQueue;
/**
 *  单列 操作数据库保证唯一
 */
+ (instancetype)shareInstance;
/**
 *  数据库路径
 */
+ (NSString *)dbPath;
/**
 *  切换数据库
 */
- (BOOL)changeDBWithDirectoryName:(NSString *)directoryName;

@end
