# LKFMDB
####对FMDB面向对象封装,支持任意类型主键,可对每个字段修饰,傻瓜式操作,一键即可保存更新,用过的人都说好。

####支持SQLCipher加密 
      默认为加密模式  
      如需要取消在fmdb文件下FMDatabase.m文件下
      注释掉低150行和177行代码
      else{
       [self setKey:DB_SECRETKEY];
      }

####基本模块介绍
- LKDBTool 创建单例对数据库操作
- LKDBModel 核心业务模块，对FMDB封装。 核心模块参考**JSONModel** 对属性的获取
- LKDBColumnDes 修饰 对字段修饰
- LKDBQueryConfig sql语句封装 -------------正在对此模块封装中......

####To do
- 正在对查询删除sql语句封装中.....
- 正在完善API



##欢迎各位大神指导    544523660@qq.com 
#跪求点赞
hhhhhhhhhhh
