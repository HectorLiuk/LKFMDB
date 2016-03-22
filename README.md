# LKFMDB
[![SUPPORT](https://img.shields.io/badge/support-iOS%207%2B%20-blue.svg?style=flat)](https://en.wikipedia.org/wiki/IOS_7)&nbsp;
##对`FMDB`面向对象封装,支持任意类型主键,可对每个字段修饰,傻瓜式操作,一键即可保存更新,用过的人都说好。

##如何使用
1. 首先确保你的程序导入过`FMDB`
2. 导入文件`LKFMDB`
3. 是否需要加密，不需要不用导入`SQLCipher`,下面会介绍如何加密。
4. 对需要创建数据库的类继承`LKDBModel`

##支持`SQLCipher`加密 
默认为加密模式
如需要取消在fmdb文件下FMDatabase.m文件下
    ```
      //注释掉低150行和177行代码
      else{
       [self setKey:DB_SECRETKEY];
      }
    ```

##基本模块介绍
- `LKDBTool` 创建单例对数据库操作
- `LKDBModel` 核心业务模块 对FMDB封装。 核心模块runtime 对属性的获取
- `LKDBColumnDes` 字段修饰模块 对字段修饰
- `LKDBSQLState` sql语句封装模块 -------------正在对此模块封装中......

##方法介绍
###`LKDBTool`
```
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
```

###`LKDBModel`
```
#pragma mark 常用方法
/** 保存或更新
 * 如果不存在主键，保存，
 * 有主键，则更新
 */
- (BOOL)saveOrUpdate;
/** 保存或更新
 * 如果根据特定的列数据可以获取记录，则更新，
 * 没有记录，则保存
 */
- (BOOL)saveOrUpdateByColumnName:(NSString*)columnName AndColumnValue:(NSString*)columnValue;
/** 保存单个数据 */
- (BOOL)save;
/** 批量保存数据 */
+ (BOOL)saveObjects:(NSArray *)array;

+(BOOL)saveOrUpdateObjects:(NSArray *)array;
/** 更新单个数据 */
- (BOOL)update;
/** 批量更新数据*/
+ (BOOL)updateObjects:(NSArray *)array;
/** 删除单个数据 */
- (BOOL)deleteObject;
/** 批量删除数据 */
+ (BOOL)deleteObjects:(NSArray *)array;
/** 通过条件删除数据 */
+ (BOOL)deleteObjectsByCriteria:(NSString *)criteria;
/** 通过条件删除 (多参数）--2 */
+ (BOOL)deleteObjectsWithFormat:(NSString *)format, ...;
/** 清空表 */
+ (BOOL)clearTable;

/** 查询全部数据 */
+ (NSArray *)findAll;

/** 通过主键查询 */
+ (instancetype)findByPK:(id)inPk;

+ (instancetype)findFirstWithFormat:(NSString *)format, ...;

/** 查找某条数据 */
+ (instancetype)findFirstByCriteria:(NSString *)criteria;

+ (NSArray *)findWithFormat:(NSString *)format, ...;

/** 通过条件查找数据
 * 这样可以进行分页查询 @" WHERE pk > 5 limit 10"
 */
+ (NSArray *)findByCriteria:(NSString *)criteria;
/**
 * 创建表
 * 如果已经创建，返回YES
 */
+ (BOOL)createTable;
#pragma mark 必须要重写的方法
/** 如果子类中有一些property不需要创建数据库字段,或者对字段加修饰属性   具体请参考LKDBColumnDes类*/
+ (NSDictionary *)describeColumnDict;
```


###`LKDBColumnDes`
```
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
```

###`LKDBSQLState`
```
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
```











###To do
- 正在对查询删除sql语句封装中.....
- 正在完善API



##欢迎各位大神指导    544523660@qq.com 
#跪求点赞
