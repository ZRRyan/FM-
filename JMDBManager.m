//
//  JMDB.m
//  JetMaster
//
//  Created by Ryan on 16/8/9.
//  Copyright © 2016年 monkey. All rights reserved.
//

#import "JMDBManager.h"

@implementation JMDBManager

#define DBNAME @"JetMaster.sqlite"

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static JMDBManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

+ (instancetype)shareDBManager {
    return [[self alloc] init];
}


- (instancetype)init {
    if (self = [super init]) {
        [self readyDatabase]; // 初始化数据库
    }
    return self;
}

/**
 *  打开数据库
 */
- (FMDatabase *)openDataBase {
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getPath]];
    if (![db open]) {
        NSLog(@"无法打开数据库");
        
        if ([db hadError]) {
            NSLog(@"数据库打开错误的原因:%d:%@", [db lastErrorCode], [db lastErrorMessage]);
            return nil;
        }
        return nil;
    } else {
        NSLog(@"数据库打开成功");
    }
    
    // 微数据设置缓存，提高查询效率
    [db setShouldCacheStatements:YES];
    
    return db;
}


/**
 *  增／删／改
 *
 *  @param sql sql语句
 */
- (void)executeWithSql:(NSString *)sql {
    FMDatabase *db = [self openDataBase];
    if (db) {
        BOOL result = [db executeUpdate:sql];
        if (!result) {
            NSLog(@"失败");
            if ([db hadError]) {
                ZRLog(@"失败原因 %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            } else {
                ZRLog(@"插入成功");
            }
        }
        [db close];
    }
}


/**
 *  增／删／改(多条数据)，创建表
 *
 *  @param sql sql语句
 */
- (void)executeWithSqls:(NSArray *)sqls {
    FMDatabase *db = [self openDataBase];
    if (db) {
        for (NSString *sql in sqls) {
            BOOL result = [db executeUpdate:sql];
            if (!result) {
                ZRLog(@"失败");
                if ([db hadError]) {
                    ZRLog(@"失败原因 %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                } else {
                    ZRLog(@"操作成功");
                }
            }
        }
        [db close];
    }
}


/**
 *  查询
 *
 *  @param sql sql语句
 *
 *  @return 结果集
 */
- (NSArray *)queryWithSql: (NSString *)sql names:(NSArray *)names {
    
    NSLog(@"%@", sql);
    FMDatabase *db = [self openDataBase];
    if (db) {
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableArray *arrM = [NSMutableArray array];
        while ([rs next]) {
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            for (NSString *name in names) {
                if ([rs stringForColumn:name]) {
                    [dictM setValue:[rs stringForColumn:name] forKey:name];
                }
            }
            [arrM addObject:dictM];
        }
        
        [db close];
        return arrM;
    }
    
    return nil;
}


/**
 *
 *
 *  @return 沙盒路径
 */
- (NSString*)getPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dbPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, DBNAME];
    
    return dbPath;
}


/**
 * 将本地数据库拷贝进沙盒
 *
 *  @return 数据路径
 */
- (void)readyDatabase {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *writeDBPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, DBNAME];
    success = [fileManager fileExistsAtPath:writeDBPath];
    if (!success) {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DBNAME];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:writeDBPath error:&error];
    }
    ZRLog(@"数据库路径：%@", writeDBPath);
}

@end
