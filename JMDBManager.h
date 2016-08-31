//
//  JMDB.h
//  JetMaster
//
//  Created by Ryan on 16/8/9.
//  Copyright © 2016年 monkey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface JMDBManager : NSObject

+ (instancetype)shareDBManager;

/**
 *  增／删／改
 *
 *  @param sql sql语句
 */
- (void)executeWithSql:(NSString *)sql;


/**
 *  增／删／改(多条数据)
 *
 *  @param sql sql语句
 */
- (void)executeWithSqls:(NSArray *)sqls;


/**
 *  查询
 *
 *  @param sql sql语句
 *
 *  @return 结果集
 */
- (NSArray *)queryWithSql: (NSString *)sql names:(NSArray *)names ;
@end
