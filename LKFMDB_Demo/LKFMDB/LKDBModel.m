//
//  LKDBModel.m
//  LKFMDB_Demo
//
//  Created by lk on 16/3/21.
//  Copyright © 2016年 LK. All rights reserved.
//  github https://github.com/544523660/LKFMDB

#import "LKDBModel.h"
#import "LKDBTool.h"
@implementation LKDBModel
+ (void)initialize
{
    if (self != [LKDBModel class]) {
        [self createTable];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSDictionary *dic = [self.class getAllProperties];
        _propertyNames = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"name"]];
        _columeTypes = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"type"]];
        _columeNames = [[NSMutableArray alloc] initWithArray:[self.class getColumnNames]];
    }
    
    return self;
}

#pragma mark - base method
/** 数据库中是否存在表 */
+ (BOOL)isExistInTable
{
    __block BOOL res = NO;
    LKDBTool *lkDB = [LKDBTool shareInstance];
    [lkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        res = [db tableExists:tableName];
    }];
    return res;
}

/**
 * 创建表
 * 如果已经创建，返回YES
 */
+ (BOOL)createTable
{
    __block BOOL res = YES;
    LKDBTool *lkDB = [LKDBTool shareInstance];
    [lkDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *columeAndType = [self.class getColumeAndTypeString];
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@);",tableName,columeAndType];
        NSLog(@"sql:%@",sql);
        if (![db executeUpdate:sql]) {
            res = NO;
            *rollback = YES;
            return;
        };
        
        NSMutableArray *columns = [NSMutableArray array];
        FMResultSet *resultSet = [db getTableSchema:tableName];
        while ([resultSet next]) {
            NSString *column = [resultSet stringForColumn:@"name"];
            [columns addObject:column];
        }
        NSDictionary *dict = [self.class getAllProperties];
        NSArray *properties = [self.class getColumnNames];
        
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",columns];
        //过滤数组
        NSArray *resultArray = [properties filteredArrayUsingPredicate:filterPredicate];
        for (NSString *column in resultArray) {
            NSUInteger index = [properties indexOfObject:column];
            NSString *proType = [[dict objectForKey:@"type"] objectAtIndex:index];
            NSString *fieldSql = [NSString stringWithFormat:@"%@ %@",column,proType];
            NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ",NSStringFromClass(self.class),fieldSql];
            if (![db executeUpdate:sql]) {
                res = NO;
                *rollback = YES;
                return ;
            }
        }
    }];
    
    return res;
}

- (BOOL)saveOrUpdate
{
    
    id primaryValue = [self valueForKey:[self.class getPKName][@"pkProperty"]];
    
    LKDBModel *model = [self.class findByPK:primaryValue];
    
    NSString *pk = [self.class getPKName][@"pkProperty"];
    
    id dbPKValue = [model valueForKey:pk];
    
    if (![dbPKValue isEqual:primaryValue]) {
        return [self save];
    }
    
    return [self update];
}

- (BOOL)saveOrUpdateByColumnName:(NSString*)columnName AndColumnValue:(NSString*)columnValue
{
    id record = [self.class findFirstByCriteria:[NSString stringWithFormat:@"where %@ = %@",columnName,columnValue]];
    if (record) {
        id primaryValue = [record valueForKey:[self.class getPKName][@"pkProperty"]]; //取到了主键PK
        if (!primaryValue || primaryValue <= 0) {
            return [self save];
        }else{
            self.pk = [primaryValue intValue];
            return [self update];
        }
    }else{
        return [self save];
    }
}

- (BOOL)save
{
    NSString *tableName = NSStringFromClass(self.class);
    NSMutableString *keyString = [NSMutableString string];
    NSMutableString *valueString = [NSMutableString string];
    NSMutableArray *insertValues = [NSMutableArray  array];
    for (int i = 0; i < self.columeNames.count; i++) {
        NSString *proname = [self.columeNames objectAtIndex:i];
        [keyString appendFormat:@"%@,", proname];
        [valueString appendString:@"?,"];
        id value = [self valueForKey:self.propertyNames[i]];
        if (!value) {
            value = @"";
        }
        [insertValues addObject:value];
    }
    
    [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
    [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
    
    LKDBTool *lkDB = [LKDBTool shareInstance];
    __block BOOL res = NO;
    [lkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString];
        res = [db executeUpdate:sql withArgumentsInArray:insertValues];
        self.pk = res?[NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
        NSLog(res?@"插入成功":@"插入失败");
    }];
    return res;
}

/** 批量保存用户对象 */
+ (BOOL)saveObjects:(NSArray *)array
{
    //判断是否是JKBaseModel的子类
    for (LKDBModel *model in array) {
        if (![model isKindOfClass:[LKDBModel class]]) {
            return NO;
        }
    }
    
    __block BOOL res = YES;
    LKDBTool *lkDB = [LKDBTool shareInstance];
    // 如果要支持事务
    [lkDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (LKDBModel *model in array) {
            NSString *tableName = NSStringFromClass(model.class);
            NSMutableString *keyString = [NSMutableString string];
            NSMutableString *valueString = [NSMutableString string];
            NSMutableArray *insertValues = [NSMutableArray  array];
            for (int i = 0; i < model.columeNames.count; i++) {
                NSString *proname = [model.columeNames objectAtIndex:i];
                [keyString appendFormat:@"%@,", proname];
                [valueString appendString:@"?,"];
                id value = [model valueForKey:[self.class getAllProperties][@"name"][i]];
                if (!value) {
                    value = @"";
                }
                [insertValues addObject:value];
            }
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
            
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:insertValues];
            model.pk = flag?[NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
            NSLog(flag?@"插入成功":@"插入失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}

+(BOOL)saveOrUpdateObjects:(NSArray *)array{
    BOOL flag = YES;
    for (LKDBModel *model in array) {
        BOOL tempF = [model saveOrUpdate];
        if (!tempF) {
            flag = NO;
        }
    }
    return flag;
}
/** 更新单个对象 */
- (BOOL)update
{
    LKDBTool *lkDB = [LKDBTool shareInstance];
    __block BOOL res = NO;
    [lkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        id primaryValue = [self valueForKey:[self.class getPKName][@"pkProperty"]];
        if (!primaryValue || primaryValue <= 0) {
            return ;
        }
        NSMutableString *keyString = [NSMutableString string];
        NSMutableArray *updateValues = [NSMutableArray  array];
        for (int i = 0; i < self.columeNames.count; i++) {
            NSString *proname = [self.columeNames objectAtIndex:i];
            [keyString appendFormat:@" %@=?,", proname];
            id value = [self valueForKey:self.propertyNames[i]];
            if (!value) {
                value = @"";
            }
            [updateValues addObject:value];
        }
        
        //删除最后那个逗号
        [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?;", tableName, keyString, [self.class getPKName][@"pkColumn"]];
        [updateValues addObject:primaryValue];
        res = [db executeUpdate:sql withArgumentsInArray:updateValues];
        NSLog(res?@"更新成功":@"更新失败");
    }];
    return res;
}

/** 批量更新用户对象*/
+ (BOOL)updateObjects:(NSArray *)array
{
    for (LKDBModel *model in array) {
        if (![model isKindOfClass:[LKDBModel class]]) {
            return NO;
        }
    }
    __block BOOL res = YES;
    LKDBTool *lkDB = [LKDBTool shareInstance];
    // 如果要支持事务
    [lkDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (LKDBModel *model in array) {
            NSString *tableName = NSStringFromClass(model.class);
            id primaryValue = [model valueForKey:[self.class getPKName][@"pkProperty"]];
            if (!primaryValue || primaryValue <= 0) {
                res = NO;
                *rollback = YES;
                return;
            }
            
            NSMutableString *keyString = [NSMutableString string];
            NSMutableArray *updateValues = [NSMutableArray  array];
            for (int i = 0; i < model.columeNames.count; i++) {
                NSString *proname = [model.columeNames objectAtIndex:i];
                [keyString appendFormat:@" %@=?,", proname];
                id value = [model valueForKey:[self.class getAllProperties][@"name"][i]];
                if (!value) {
                    value = @"";
                }
                [updateValues addObject:value];
            }
            
            //删除最后那个逗号
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@=?;", tableName, keyString, [self.class getPKName][@"pkColumn"]];
            [updateValues addObject:primaryValue];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:updateValues];
            NSLog(flag?@"更新成功":@"更新失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    
    return res;
}

/** 删除单个对象 */
- (BOOL)deleteObject
{
    LKDBTool *lkDB = [LKDBTool shareInstance];
    __block BOOL res = NO;
    [lkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        id primaryValue = [self valueForKey:[self.class getPKName][@"pkProperty"]];
        if (!primaryValue || primaryValue <= 0) {
            return ;
        }
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,[self.class getPKName][@"pkColumn"]];
        res = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
        NSLog(res?@"删除成功":@"删除失败");
    }];
    return res;
}

/** 批量删除用户对象 */
+ (BOOL)deleteObjects:(NSArray *)array
{
    for (LKDBModel *model in array) {
        if (![model isKindOfClass:[LKDBModel class]]) {
            return NO;
        }
    }
    
    __block BOOL res = YES;
    LKDBTool *lkDB = [LKDBTool shareInstance];
    // 如果要支持事务
    [lkDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (LKDBModel *model in array) {
            NSString *tableName = NSStringFromClass(model.class);
            id primaryValue = [model valueForKey:[self.class getPKName][@"pkProperty"]];
            if (!primaryValue || primaryValue <= 0) {
                return ;
            }
            
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,[self.class getPKName][@"pkColumn"]];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
            NSLog(flag?@"删除成功":@"删除失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}

/** 通过条件删除数据 */
+ (BOOL)deleteObjectsByCriteria:(NSString *)criteria
{
    LKDBTool *lkDB = [LKDBTool shareInstance];
    __block BOOL res = NO;
    [lkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ %@ ",tableName,criteria];
        res = [db executeUpdate:sql];
        NSLog(res?@"删除成功":@"删除失败");
    }];
    return res;
}

/** 通过条件删除 (多参数）--2 */
+ (BOOL)deleteObjectsWithFormat:(NSString *)format, ...
{
    va_list ap;
    va_start(ap, format);
    NSString *criteria = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
    va_end(ap);
    
    return [self deleteObjectsByCriteria:criteria];
}

/** 清空表 */
+ (BOOL)clearTable
{
    LKDBTool *lkDB = [LKDBTool shareInstance];
    __block BOOL res = NO;
    [lkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
        res = [db executeUpdate:sql];
        NSLog(res?@"清空成功":@"清空失败");
    }];
    return res;
}

/** 查询全部数据 */
+ (NSArray *)findAll
{
    NSLog(@"jkdb---%s",__func__);
    LKDBTool *lkDB = [LKDBTool shareInstance];
    NSMutableArray *users = [NSMutableArray array];
    [lkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            LKDBModel *model = [[self.class alloc] init];
            for (int i=0; i< model.columeNames.count; i++) {
                NSString *columeName = [model.columeNames objectAtIndex:i];
                NSString *columeType = [model.columeTypes objectAtIndex:i];
                if ([columeType isEqualToString:SQLTEXT]) {
                    [model setValue:[resultSet stringForColumn:columeName] forKey:model.propertyNames[i]];
                } else {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columeName]] forKey:model.propertyNames[i]];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
    }];
    
    return users;
}

+ (instancetype)findFirstWithFormat:(NSString *)format, ...
{
    va_list ap;
    va_start(ap, format);
    NSString *criteria = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
    va_end(ap);
    
    return [self findFirstByCriteria:criteria];
}

/** 查找某条数据 */
+ (instancetype)findFirstByCriteria:(NSString *)criteria
{
    NSArray *results = [self.class findByCriteria:criteria];
    if (results.count < 1) {
        return nil;
    }
    
    return [results firstObject];
}

+ (instancetype)findByPK:(id)inPk
{
    NSString *condition = [NSString stringWithFormat:@"WHERE  %@ = %@",[self.class getPKName][@"pkColumn"],inPk];
    
    NSArray *columnType = [self.class getAllProperties][@"type"];
    
    if ([[columnType firstObject] isEqualToString:SQLTEXT]) {
        condition = [NSString stringWithFormat:@"WHERE  %@ = '%@'",[self.class getPKName][@"pkColumn"],inPk];
    }
    return [self findFirstByCriteria:condition];
}

+ (NSArray *)findWithFormat:(NSString *)format, ...
{
    va_list ap;
    va_start(ap, format);
    NSString *criteria = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
    va_end(ap);
    
    return [self findByCriteria:criteria];
}

/** 通过条件查找数据 */
+ (NSArray *)findByCriteria:(NSString *)criteria
{
    LKDBTool *lkDB = [LKDBTool shareInstance];
    NSMutableArray *users = [NSMutableArray array];
    [lkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSArray *columnType = [self.class getAllProperties][@"type"];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ %@",tableName,criteria];
        
        if ([[columnType firstObject] isEqualToString:SQLTEXT]) {
            
        }
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            LKDBModel *model = [[self.class alloc] init];
            for (int i=0; i< model.columeNames.count; i++) {
                NSString *columeName = [model.columeNames objectAtIndex:i];
                NSString *columeType = [model.columeTypes objectAtIndex:i];
                if ([columeType isEqualToString:SQLTEXT]) {
                    [model setValue:[resultSet stringForColumn:columeName] forKey:model.propertyNames[i]];
                } else {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columeName]] forKey:model.propertyNames[i]];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
    }];
    
    return users;
}




#pragma mark 基本方法
/**
 *  获取该类的所有属性
 */
+ (NSDictionary *)getPropertys
{
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    NSArray *theTransients = [[self class] transients];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //获取属性名
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([theTransients containsObject:propertyName]) {
            continue;
        }
        [proNames addObject:propertyName];
        //获取属性类型等参数
        NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        /*
         各种符号对应类型，部分类型在新版SDK中有所变化，如long 和long long
         c char         C unsigned char
         i int          I unsigned int
         l long         L unsigned long
         s short        S unsigned short
         d double       D unsigned double
         f float        F unsigned float
         q long long    Q unsigned long long
         B BOOL
         @ 对象类型 //指针 对象类型 如NSString 是@“NSString”
         
         
         64位下long 和long long 都是Tq
         SQLite 默认支持五种数据类型TEXT、INTEGER、REAL、BLOB、NULL
         因为在项目中用的类型不多，故只考虑了少数类型
         */
        if ([propertyType hasPrefix:@"T@"]) {
            [proTypes addObject:SQLTEXT];
        } else if ([propertyType hasPrefix:@"Ti"]||[propertyType hasPrefix:@"TI"]||[propertyType hasPrefix:@"Ts"]||[propertyType hasPrefix:@"TS"]||[propertyType hasPrefix:@"TB"]) {
            [proTypes addObject:SQLINTEGER];
        } else {
            [proTypes addObject:SQLREAL];
        }
        
    }
    free(properties);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}

/** 获取所有属性，包含主键pk */
+ (NSDictionary *)getAllProperties
{
    NSDictionary *dict = [self.class getPropertys];
    
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    [proNames addObjectsFromArray:[dict objectForKey:@"name"]];
    [proTypes addObjectsFromArray:[dict objectForKey:@"type"]];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}
/** 获取列名 */
+ (NSArray *)getColumns
{
    LKDBTool *lkDB = [LKDBTool shareInstance];
    NSMutableArray *columns = [NSMutableArray array];
    [lkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        FMResultSet *resultSet = [db getTableSchema:tableName];
        while ([resultSet next]) {
            NSString *column = [resultSet stringForColumn:@"name"];
            [columns addObject:column];
        }
    }];
    return [columns copy];
}

#pragma mark - util method
/**
 *  创建数据库sql语句
 */
+ (NSString *)getColumeAndTypeString
{
    NSMutableString* pars = [NSMutableString string];
    NSDictionary *dict = [self.class getAllProperties];
    
    NSMutableArray *columns = [self.class getColumnNames];
    NSMutableArray *proTypes = [dict objectForKey:@"type"];
    
    for (int i=0; i< columns.count; i++) {
        [pars appendFormat:@"%@ %@ %@",[columns objectAtIndex:i],[proTypes objectAtIndex:i],[self.class PKAndColumnModify][i]];
        if(i+1 != columns.count)
        {
            [pars appendString:@","];
        }
    }
    return pars;
}

- (NSString *)description
{
    NSString *result = @"";
    NSDictionary *dict = [self.class getAllProperties];
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    for (int i = 0; i < proNames.count; i++) {
        NSString *proName = [proNames objectAtIndex:i];
        id  proValue = [self valueForKey:proName];
        result = [result stringByAppendingFormat:@"%@:%@\n",proName,proValue];
    }
    return result;
}



#pragma mark get modify column
/**
 *  不需要创建字段的属性名称
 */
+ (NSMutableArray *)transients{
    NSMutableArray *transients = [NSMutableArray array];
    
    [[self.class describeColumnDict] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        LKDBColumnDes *columnDes = obj;
        if (columnDes.isUseless) {
            [transients addObject:key];
        }
    }];
    return transients;
}
/**
 * 创建数据库字段修饰
 */
+ (NSMutableArray *)PKAndColumnModify{
    NSMutableArray *modifies = [NSMutableArray array];
    NSMutableArray *properties = [self.class getAllProperties][@"name"];
    NSDictionary *desDic = [self.class describeColumnDict];
    
    for (int i = 0; i < properties.count ; i++) {
        NSString *property = properties[i];
        LKDBColumnDes *des = desDic[property];
        if (desDic[property]) {
            [modifies addObject:[des finishModify]];
        }else{
            [modifies addObject:@""];
        }
    }
    return modifies;
}
/**
 *  得到起过别名的数据库字段
 */
+ (NSMutableArray *)getColumnNames{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [[self.class describeColumnDict] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        LKDBColumnDes *columnDes = obj;
        if (columnDes.columnName != nil) {
            if (![columnDes isCustomColumnName:key]) {
                [dic setValue:columnDes.columnName forKey:key];
            }
        }
        
    }];
    
    NSMutableArray *properties = [self.class getPropertys][@"name"];
    for (int i =0 ; i < properties.count; i++) {
        if (dic[properties[i]]){
            [properties replaceObjectAtIndex:i withObject:dic[properties[i]]];
        }
    }
    
    return properties;
}
/**
 *  获得主键名称 属性名和别名
 */
+ (NSDictionary *)getPKName{
    NSMutableDictionary *pk = [NSMutableDictionary dictionary];
    [[self.class describeColumnDict] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        LKDBColumnDes *columnDes = obj;
        if (columnDes.isPrimaryKey) {
            if (columnDes.columnName != nil) {
                if (![columnDes isCustomColumnName:key]) {
                    [pk setValue:columnDes.columnName forKey:@"pkColumn"];
                    [pk setValue:key forKey:@"pkProperty"];
                }
            }else{
                [pk setValue:key forKey:@"pkColumn"];
                [pk setValue:key forKey:@"pkProperty"];
                
            }
        }
    }];
    return pk;
}

#pragma mark - must be override method
/** 如果子类中有一些property不需要创建数据库字段,或者对字段加修饰属性   具体请参考LKDBColumnDes类*/
+ (NSDictionary *)describeColumnDict{
    return @{};
}



@end
