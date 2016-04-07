# LKFMDB
![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)&nbsp;
[![SUPPORT](https://img.shields.io/badge/support-iOS%207%2B%20-blue.svg?style=flat)](https://en.wikipedia.org/wiki/IOS_7)&nbsp;
![Platform info](http://img.shields.io/cocoapods/p/YTKKeyValueStore.svg?style=flat)


##对`FMDB`面向对象封装,支持任意类型主键,可对每个字段修饰,傻瓜式操作,一键即可保存更新,用过的人都说好。

##如何使用
1. 首先确保你的程序导入过`FMDB`
2. 导入文件`LKFMDB`
3. 是否需要加密，不需要不用导入`SQLCipher`,下面会介绍如何加密。
4. 对需要创建数据库的类继承`LKDBModel`

<img src="https://raw.github.com/544523660/LKFMDB_Demo/fmdb.png"><br/>
<img src="https://raw.github.com/544523660/LKFMDB_Demo/vc.png"><br/>
##支持`SQLCipher`加密 
具体介绍：[对FMDB加密-SQLCipher如何使用](http://www.jianshu.com/p/bd7845062cc8)

默认为加密模式
如需要取消在`FMDB`文件下`FMDatabase.m`文件下
```objc
//注释掉第150行和177行代码
else{
[self setKey:DB_SECRETKEY];
}
```

##基本模块介绍
- `LKDBTool` 创建单例对数据库操作
- `LKDBModel` 核心业务模块 对FMDB封装。 核心模块runtime 对属性的获取，下面会对核心代码讲解。
- `LKDBColumnDes` 字段修饰模块 对字段修饰
- `LKDBSQLState` sql语句封装模块 -------------正在对此模块封装中......

##常用方法介绍 - 具体查看Demo 
###`LKDBTool`
```objc
/** 单列 操作数据库保证唯一*/
+ (instancetype)shareInstance;
/**  数据库路径*/
+ (NSString *)dbPath;
/**  切换数据库*/
- (BOOL)changeDBWithDirectoryName:(NSString *)directoryName;
```


###`LKDBModel`
```objc
#pragma mark 常用方法
/** 保存或更新
 * 如果不存在主键，保存，
 * 有主键，则更新
 */
- (BOOL)saveOrUpdate;
/** 保存单个数据 */
- (BOOL)save;
/** 批量保存数据 */
+ (BOOL)saveObjects:(NSArray *)array;
/** 事物保存或跟新 */
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
/** 通过条件删除  */
+ (BOOL)deleteObjectsWithFormat:(NSString *)format, ...;
/** 清空表 */
+ (BOOL)clearTable;
/** 查询全部数据 */
+ (NSArray *)findAll;
/** 查找某条数据 */
+ (instancetype)findFirstByCriteria:(NSString *)criteria;
/** 通过条件查找数据*/
+ (NSArray *)findByCriteria:(NSString *)criteria;

//必须要重写的方法
/** 如果子类中有一些property不需要创建数据库字段,或者对字段加修饰属性 具体请参考LKDBColumnDes类*/
+ (NSDictionary *)describeColumnDict;
```

###`LKDBColumnDes`
请看Demo `User.m`文件如何使用
```objc
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
```objc
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

##核心代码
通过`runtime`获取一个类的属性名称和类型，根据名称和类型生成建表语句。
```objc
// 获得一个类的属性名称操作
  objc_property_t * properties = class_copyPropertyList([self class], &outCount);
  for (int i = 0; i < outCount; i++) {
      objc_property_t property = properties[i];
      //获得属性名称
       NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
      //获得属性类型
       NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
  }

```
##注意
- 比较复杂sql语言需要自己手动输入,然后直接调用`findByCriteria`方法，当然如何一般的直接调用`LKDBSQLState`类方法就OK，如果起别名请使用别名字段访问数据库。
- 创建数据库类时，创建属性把主键放在第一个位置(好像这个无伤大雅，个人喜欢主键放在第一个上懒得改了)，谁有空可以改改这个地方，排序问题。



##欢迎各位大神指导    544523660@qq.com   
#跪求点赞
#跪求点赞
#跪求点赞
