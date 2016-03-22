//
//  ViewController.m
//  LKFMDB_Demo
//
//  Created by lk on 16/3/21.
//  Copyright © 2016年 LK. All rights reserved.
//

#import "ViewController.h"
#import "User.h"
#import "LKDBTool.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
//多个子线程插入5条帅哥
- (IBAction)saveData1:(id)sender {
    for (int i = 0; i < 5; i++) {
        User *user = [User new];
        user.account = [NSString stringWithFormat:@"%d",i];
        user.name = [NSString stringWithFormat:@"帅哥%d",i];
        user.sex = @"男";
        user.age = i;
        user.descn = @"我是帅哥";
        user.height = 175+i;
        
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            [user save];
        });
        
    }
}
//开辟队列插入5条欧巴
- (IBAction)saveData2:(id)sender {
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_async(q1, ^{
        for (int i = 5; i < 10; ++i) {
            User *user = [[User alloc] init];
            user.account = [NSString stringWithFormat:@"%d",i];
            user.name = @"欧巴";
            user.sex = @"女Or男";
            user.age = i+5;
            [user save];
        }
    });
}
//事务插入100个呵呵
- (IBAction)saveData3:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < 100; i++) {
            User *user = [[User alloc] init];
            user.name = [NSString stringWithFormat:@"呵呵%d",i];
            user.age = 10+i;
            user.sex = @"女";
            user.account = [NSString stringWithFormat:@"%d",i];
            [array addObject:user];
        }
        [User saveObjects:array];
    });
}

//条件删除
- (IBAction)delete:(id)sender {
    LKDBSQLState *sql = [[LKDBSQLState alloc] object:[User class] type:WHERE key:@"age" opt:@"=" value:@"4"];
    
    [User deleteObjectsWithFormat:[sql sqlOptionStr]];

}

//多子线程删除
- (IBAction)delete1:(id)sender {
    for (int i = 0; i < 5; i++) {
        User *user = [User new];
        user.account = [NSString stringWithFormat:@"%d",i];
        user.name = [NSString stringWithFormat:@"帅哥%d",i];
        user.sex = @"男";
        user.descn = @"我是帅哥";
        user.height = 185;
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            [user deleteObject];
        });
        
    }
}
//事务删除
- (IBAction)detete2:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < 100; i++) {
            User *user = [[User alloc] init];
            user.name = [NSString stringWithFormat:@"呵呵%d",i];
            user.age = 10+i;
            user.sex = @"女";
            [array addObject:user];
        }
        [User deleteObjects:array];
    });
}


//多子线程更新
- (IBAction)update1:(id)sender {
    for (int i = 0; i < 5; i++) {
        User *user = [User new];
        user.account = [NSString stringWithFormat:@"%d",i];
        user.name = [NSString stringWithFormat:@"帅哥%d",i];
        user.sex = @"男";
        user.descn = @"我是更新的数据:我是帅哥我自豪";
        user.height = 185;
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            [user saveOrUpdate];
        });
    }
    
    
}
//事务更新
- (IBAction)update2:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < 100; i++) {
            User *user = [[User alloc] init];
            user.name = [NSString stringWithFormat:@"呵呵%d",i];
            user.age = 10+i;
            user.sex = @"女";
            user.descn = @"我是事务更新-呵呵";
            [array addObject:user];
        }
        [User saveOrUpdateObjects:array];
    });
}





//查一条数据
- (IBAction)query1:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LKDBSQLState *query = [[LKDBSQLState alloc] object:[User class] type:WHERE key:@"account" opt:@"=" value:@"3"];
        
        User *users = [User findFirstByCriteria:[query sqlOptionStr]];
        NSLog(@"第一条:%@",users);
    });
}
//条件查询
- (IBAction)query2:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LKDBSQLState *sql = [[LKDBSQLState alloc] object:[User class] type:WHERE key:@"age" opt:@"<" value:@"4"];
        
        NSArray *dataArray = [User findByCriteria:[sql sqlOptionStr]];
        
        for (User *user in dataArray) {
            NSLog(@"条件查询%@",user);
        }
        
    });
}
//查询全部
- (IBAction)query3:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (User *user in [User findAll]) {
            NSLog(@"全部%@",user);
        }
        
    });
}
//分页查询
- (IBAction)query4:(id)sender {
    static int rowid = 0;
    //支持自定义查询语句  sql查询过多  具体请查看sql写法
    //LKDBSQLState只支持一般常用sql语句
    NSArray *array = [User findByCriteria:[NSString stringWithFormat:@" WHERE rowid > %d limit 10",rowid]];
    
    for (User *user in array) {
        NSLog(@"分页查询%@",user);
    }
}










- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
