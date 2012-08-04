//
//  FMCache.h
//
//  Created by Maurizio Cremaschi on 8/2/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMCache : NSObject

+ (id)objectForKey:(NSString *)key;

+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key;
+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key expirationDate:(NSDate *)date;

+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key useMemory:(BOOL)useMemory;
+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key expirationDate:(NSDate *)date useMemory:(BOOL)useMemory;

+ (void)removeObjectForKey:(NSString*)key;
+ (void)removeAllObject;

+ (BOOL)hasObjectForKey:(NSString*)key;
+ (BOOL)hasObjectOnDiskForKey:(NSString*)key;
+ (BOOL)hasObjectInMemoryForKey:(NSString*)key;

@end
