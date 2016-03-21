//
//  LKDBColumnDes.h
//  LKFMDB_Demo
//
//  Created by lk on 16/3/21.
//  Copyright © 2016年 LK. All rights reserved.
//  github https://github.com/544523660/LKFMDB
//
// NOTModify  //无任何修饰
// PrimaryKey   //设置主键
// AUTOINCREMENT  //自增长
// NOTNULL  //非空
// UNIQUE //约束


// 此类为修饰类
#import <Foundation/Foundation.h>
/** 修饰 */
#define DEFAULT(value) @"DEFAULT value"//默认值  text格式‘’ integer 1
/** 限制值 */
#define CHECK(value) @"value" //限制值
/** 外键 */
#define FOREIGNKEY(talbeName,filed) @"REFERENCES talbeName (filed)"//设置外键

@interface LKDBColumnDes : NSObject
/** 别名 */
@property (nonatomic, copy)  NSString *columnName;
/** 限制 */
@property (nonatomic, copy)  NSString *check;
/** 默认 */
@property (nonatomic, copy)  NSString *defaultValue;
/** 外键 */
@property (nonatomic, copy)  NSString *foreignKey;
/** 是否为主键 */
@property (nonatomic, assign, getter=isPrimaryKey)  BOOL      primaryKey;
/** 是否为唯一 */
@property (nonatomic, assign, getter=isUnique)  BOOL      unique;
/** 是否为不为空 */
@property (nonatomic, assign, getter=isNotNull)  BOOL      notNull;
/** 是否为自动升序 如何为text就不能自动升序 */
@property (nonatomic, assign, getter=isAutoincrement)  BOOL      autoincrement;
/** 此属性是否创建数据库字段 */
@property (nonatomic, assign, getter=isUseless) BOOL useless;

/**
 *  主键便利构造器
 */
- (instancetype)initWithAuto:(BOOL)isAutoincrement isNotNull:(BOOL)notNull check:(NSString *)check defaultVa:(NSString *)defaultValue;
/**
 *  一般字段便利构造器
 */
- (instancetype)initWithgeneralFieldWithAuto:(BOOL)isAutoincrement  unique:(BOOL)isUnique isNotNull:(BOOL)notNull check:(NSString *)check defaultVa:(NSString *)defaultValue;
/**
 *  外键构造器
 */
- (instancetype)initWithFKFiekdUnique:(BOOL)isUnique isNotNull:(BOOL)notNull check:(NSString *)check default:(NSString *)defaultValue foreignKey:(NSString *)foreignKey;
/**
 *  判断是否起别名
 */
- (BOOL)isCustomColumnName:(NSString *)attribiteName;
/**
 *  生成修饰语句
 */
- (NSString *)finishModify;



@end
