//
//  LKDBSQLState.h
//  LKFMDB_Demo
//
//  Created by lk on 16/3/22.
//  Copyright © 2016年 LK. All rights reserved.
//
//  github https://github.com/544523660/LKFMDB

#import "LKDBModel.h"

typedef NS_ENUM(NSInteger ,QueryType){
    WHERE = 0,
    AND,
    OR
};


@interface LKDBSQLState : NSObject

@property (nonatomic, assign) QueryType type;
/**
 *  查询方法
 *
 *  @param obj   model类
 *  @param type  查询类型
 *  @param key   key
 *  @param opt   条件
 *  @param value 值
 */
- (LKDBSQLState *)object:(Class)obj
                       type:(QueryType)type
                        key:(id)key
                        opt:(NSString *)opt
                      value:(id)value;
/**
 *  生成查询语句
 */
-(NSString *)sqlOptionStr;



//todo sort 对排序语句

@end
