//
//  LKDBQueryConfig.h
//  LKFMDB_Demo
//
//  Created by lk on 16/3/21.
//  Copyright © 2016年 LK. All rights reserved.
//  github https://github.com/544523660/LKFMDB

//此类为sql语句查询类
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger ,QueryType){
    WHERE = 0,
    AND,
    OR
};


@interface LKDBQueryConfig : NSObject

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
- (LKDBQueryConfig *)object:(Class)obj
                       type:(QueryType)type
                        key:(id)key
                        opt:(NSString *)opt
                      value:(id)value;
/**
 *  生成查询语句
 */
-(NSString *)queryOptionStr;
@end
