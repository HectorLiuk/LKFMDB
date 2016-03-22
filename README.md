# LKFMDB
[![SUPPORT](https://img.shields.io/badge/support-iOS%207%2B%20-blue.svg?style=flat)](https://en.wikipedia.org/wiki/IOS_7)&nbsp;
###对`FMDB`面向对象封装,支持任意类型主键,可对每个字段修饰,傻瓜式操作,一键即可保存更新,用过的人都说好。

###如何使用
1. 默认程序导入过`FMDB`
2. 导入文件`LKFMDB`
3. 是否需要加密，不需要不用导入`SQLCipher`,下面会介绍如何加密。
4. 对需要创建数据库的类继承`LKDBModel`

###支持`SQLCipher`加密 
    默认为加密模式
    如需要取消在fmdb文件下FMDatabase.m文件下
      //注释掉低150行和177行代码
      else{
       [self setKey:DB_SECRETKEY];
      }

###基本模块介绍
- `LKDBTool` 创建单例对数据库操作
- `LKDBModel` 核心业务模块 对FMDB封装。 核心模块runtime 对属性的获取
- `LKDBColumnDes` 字段修饰模块 对字段修饰
- `LKDBSQLState` sql语句封装模块 -------------正在对此模块封装中......


####`LKDBTool`
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

###`LKDBModel`











###To do
- 正在对查询删除sql语句封装中.....
- 正在完善API



##欢迎各位大神指导    544523660@qq.com 
#跪求点赞
