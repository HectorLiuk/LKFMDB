//
//  LKDBColumnDes.m
//  LKFMDB_Demo
//
//  Created by lk on 16/3/21.
//  Copyright © 2016年 LK. All rights reserved.
//  github https://github.com/544523660/LKFMDB

#import "LKDBColumnDes.h"
//bool
#define NOTModify @"" //无任何修饰
#define PrimaryKey  @"primary key" //设置主键
#define AUTOINCREMENT @"AUTOINCREMENT" //自增长
#define NOTNULL @"NOT NULL" //非空
#define UNIQUE @"UNIQUE" //约束
@implementation LKDBColumnDes
/**
 *  主键便利构造器
 *
 */
- (instancetype)initWithAuto:(BOOL)isAutoincrement isNotNull:(BOOL)notNull check:(NSString *)check defaultVa:(NSString *)defaultValue{
    if (self = [super init]) {
        _autoincrement = isAutoincrement;
        _notNull = notNull;
        _check = check;
        _defaultValue = defaultValue;
        
    }
    return self;
}
/**
 *  一般字段便利构造器
 */
- (instancetype)initWithgeneralFieldWithAuto:(BOOL)isAutoincrement  unique:(BOOL)isUnique isNotNull:(BOOL)notNull check:(NSString *)check defaultVa:(NSString *)defaultValue{
    if (self = [super init]) {
        _autoincrement = isAutoincrement;
        _notNull = notNull;
        _check = check;
        _unique = isUnique;
        _defaultValue = defaultValue;
    }
    return self;
}
/**
 *  外键构造器
 */
- (instancetype)initWithFKFiekdUnique:(BOOL)isUnique isNotNull:(BOOL)notNull check:(NSString *)check default:(NSString *)defaultValue foreignKey:(NSString *)foreignKey{
    if (self = [super init]) {
        _notNull = notNull;
        _check = check;
        _unique = isUnique;
        _defaultValue = defaultValue;
        _foreignKey = foreignKey;
    }
    return self;
}


- (NSString *)finishModify{
    
    return CheckStrNull([self customModifyWithPK:self.isPrimaryKey autoIn:self.isAutoincrement unique:self.isUnique isNotNull:self.isNotNull check:nil defaultV:self.defaultValue foreignKey:self.foreignKey]);
}

#pragma mark -----util method-----
/** 拼接修饰语句 */
- (NSMutableString *)customModifyWithPK:(BOOL)is_prim_key autoIn:(BOOL)isAuotoincrement  unique:(BOOL)isUnique isNotNull:(BOOL)notNull check:(NSString *)check defaultV:(NSString *)defaultValue foreignKey:(NSString *)foreignKey{
    NSMutableString *modify = [NSMutableString string];
    
    [modify appendFormat:@"%@",[self isPrimKey:is_prim_key]];
    [modify appendFormat:@"%@",[self isAutoincrement:isAuotoincrement]];
    [modify appendFormat:@"%@",[self isUnique:isUnique]];
    [modify appendFormat:@"%@",[self isNotNull:notNull]];
    [modify appendFormat:@"%@",[self checkStingNull:defaultValue]];
    [modify appendFormat:@"%@",[self checkStingNull:foreignKey]];
    
    if (modify.length > 0) {
        [modify deleteCharactersInRange:NSMakeRange(modify.length-1,1)];
    }
    
    
    return modify;
}


/** 是否为主键 */
- (NSString *)isPrimKey:(BOOL)boolValue{
    
    return boolValue?[self checkStingNull:PrimaryKey]:@"";
    
}
/** 是否为自动升序 */
- (NSString *)isAutoincrement:(BOOL)boolValue{
    
    return boolValue?[self checkStingNull:AUTOINCREMENT]:@"";
    
}
/** 是否为约束 */
- (NSString *)isUnique:(BOOL)boolValue{
    
    return boolValue?[self checkStingNull:UNIQUE]:@"";
    
}
/** 是否为非空 */
- (NSString *)isNotNull:(BOOL)boolValue{
    
    return boolValue?[self checkStingNull:NOTNULL]:@"";
    
}

- (NSString *)checkStingNull:(id)emptyStr{
    if (emptyStr == nil || emptyStr == NULL ) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@ ",emptyStr];
}


- (BOOL)isCustomColumnName:(NSString *)attribiteName{
    
    return [attribiteName isEqualToString:self.columnName];
}

NSString * CheckStrNull(id Str){
    if (Str == nil || Str == NULL || Str == [NSNull null]){
        return @"";
    }
    return Str;
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[LKDBColumnDes class]]) {
        LKDBColumnDes *des = object;
        return [des.columnName isEqualToString:des.columnName];
    }
    return NO;
}

@end
