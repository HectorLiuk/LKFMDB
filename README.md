# LKFMDB
####对`FMDB`面向对象封装,支持任意类型主键,可对每个字段修饰,傻瓜式操作,一键即可保存更新,用过的人都说好。

####支持`SQLCipher`加密 
      默认为加密模式  
      如需要取消在fmdb文件下FMDatabase.m文件下
      注释掉低150行和177行代码
      else{
       [self setKey:DB_SECRETKEY];
      }

####基本模块介绍
- `LKDBTool` 创建单例对数据库操作
- `LKDBModel` 核心业务模块，对FMDB封装。 核心模块runtime 对属性的获取
- `LKDBColumnDes` 修饰 对字段修饰
- `LKDBSQLState` sql语句封装 -------------正在对此模块封装中......

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
```


####To do
- 正在对查询删除sql语句封装中.....
- 正在完善API



##欢迎各位大神指导    544523660@qq.com 
#跪求点赞
