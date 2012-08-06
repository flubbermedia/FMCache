//
//  FMCache.m
//
//  Created by Maurizio Cremaschi and Andrea Ottolina on 8/2/12.
//  Copyright 2012 Flubber Media Ltd.
//
//  Distributed under the permissive zlib License
//  Get the latest version from https://github.com/flubbermedia/FMCache
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "FMCache.h"
#import <CommonCrypto/CommonDigest.h>

static NSTimeInterval const _defaultTimeoutInterval = 86400.;
static NSString * const _cacheFolderName = @"com.flubbermedia.cache";
static NSString * const _cacheDictionaryFileName = @"cache.plist";

@interface NSString (md5)

- (NSString *)md5;

@end

@implementation NSString (md5)

- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

@end

@interface FMCache ()

@property (strong) NSMutableDictionary *cacheDictionary;

@end

@implementation FMCache

+ (FMCache *)diskCache
{
    static FMCache *_diskCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _diskCache = [FMCache new];
    });
    return _diskCache;
}

+ (NSCache *)memoryCache
{
    static NSCache *_memoryCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _memoryCache = [NSCache new];
    });
    return _memoryCache;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        if (&UIApplicationDidEnterBackgroundNotification)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidEnterBackground:)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
        }
        
        _cacheDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[FMCache cacheDictionaryPath]];
        if (_cacheDictionary == nil)
        {
            _cacheDictionary = [NSMutableDictionary new];
        }
        
        [self removeExpiredObjects];
    }
    return self;
}

#pragma mark - Class Methods

+ (id)objectForKey:(NSString *)key
{
    return [[FMCache diskCache] objectForKey:key];
}

+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key
{
    [[FMCache diskCache] setObject:object forKey:key];
}

+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key expirationDate:(NSDate *)date
{
    [[FMCache diskCache] setObject:object forKey:key expirationDate:date];
}

+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key useMemory:(BOOL)useMemory
{
    [[FMCache diskCache] setObject:object forKey:key useMemory:useMemory];
}

+ (void)setObject:(id <NSCoding>)object forKey:(NSString *)key expirationDate:(NSDate *)date useMemory:(BOOL)useMemory
{
    [[FMCache diskCache] setObject:object forKey:key expirationDate:date useMemory:useMemory];
}

+ (void)removeObjectForKey:(NSString*)key
{
    [[FMCache diskCache] removeObjectForKey:key];
}

+ (void)removeAllObject
{
    [[FMCache diskCache] removeAllObject];
}

+ (BOOL)hasObjectForKey:(NSString*)key
{
    return [[FMCache diskCache] hasObjectForKey:key];
}

+ (BOOL)hasObjectOnDiskForKey:(NSString *)key
{
    return [[FMCache diskCache] hasObjectOnDiskForKey:key];
}

+ (BOOL)hasObjectInMemoryForKey:(NSString *)key
{
    return [[FMCache diskCache] hasObjectInMemoryForKey:key];
}

#pragma mark - Instance Methods

- (id)objectForKey:(NSString *)key
{
    if ([self hasObjectInMemoryForKey:key])
    {
        return [[FMCache memoryCache] objectForKey:key];
    }
    
    if ([self hasObjectOnDiskForKey:key])
    {
        NSString *filePath = [FMCache cacheFilePathWithKey:key];
        return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    
    return nil;
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key
{
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:_defaultTimeoutInterval];
    [self setObject:object forKey:key expirationDate:expirationDate useMemory:YES];
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key expirationDate:(NSDate *)date
{
    [self setObject:object forKey:key expirationDate:date useMemory:YES];
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key useMemory:(BOOL)useMemory
{
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:_defaultTimeoutInterval];
    [self setObject:object forKey:key expirationDate:expirationDate useMemory:useMemory];
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key expirationDate:(NSDate *)date useMemory:(BOOL)useMemory
{
    if (object == nil || key == nil || date == nil)
    {
        return;
    }
    
    @synchronized (_cacheDictionary)
    {
        [_cacheDictionary setObject:date forKey:key];
    }
    
    if (useMemory)
    {
        [[FMCache memoryCache] setObject:object forKey:key];
    }
    
    NSString *filePath = [FMCache cacheFilePathWithKey:key];
    [NSKeyedArchiver archiveRootObject:object toFile:filePath];
}

- (void)removeObjectForKey:(NSString*)key
{
    if (key == nil)
    {
        return;
    }
    
    @synchronized (_cacheDictionary)
    {
        [_cacheDictionary removeObjectForKey:key];
    }
    
    [self removeObjectFileForKey:key];
}

- (void)removeAllObject
{
    for (NSString *key in _cacheDictionary.allKeys)
    {
        [self removeObjectForKey:key];
    }
}

- (BOOL)hasObjectForKey:(NSString*)key
{
    return ([self hasObjectInMemoryForKey:key] || [self hasObjectOnDiskForKey:key]);
}
            
- (BOOL)hasObjectOnDiskForKey:(NSString *)key
{
    @synchronized (_cacheDictionary)
    {
        NSDate *date = [_cacheDictionary objectForKey:key];
        if (date && ![[[NSDate date] earlierDate:date] isEqualToDate:date])
        {
            NSString *filePath = [FMCache cacheFilePathWithKey:key];
            return ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
        }
    }
    
    return NO;
}

- (BOOL)hasObjectInMemoryForKey:(NSString *)key
{
    return ([[FMCache memoryCache] objectForKey:key] != nil);
}

#pragma mark - Paths

+ (NSString *)cacheDataPath
{
    NSString *folder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    folder = [folder stringByAppendingPathComponent:_cacheFolderName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folder])
    {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return folder;
}

+ (NSString *)cacheDictionaryPath
{
    return [[FMCache cacheDataPath] stringByAppendingPathComponent:_cacheDictionaryFileName];
}

+ (NSString *)cacheFilePathWithKey:(NSString *)key
{
    return [[FMCache cacheDataPath] stringByAppendingPathComponent:[key md5]];
}

#pragma mark - Utilities

- (void)removeObjectFileForKey:(NSString *)key
{
    NSString *filePath = [FMCache cacheFilePathWithKey:key];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

- (void)removeExpiredObjects
{
    @synchronized (_cacheDictionary)
    {
        NSMutableArray *expiredObjects = [NSMutableArray array];
        
        for (NSString *key in _cacheDictionary.allKeys)
        {
            NSDate *date = [_cacheDictionary objectForKey:key];
            if ([[[NSDate date] earlierDate:date] isEqualToDate:date])
            {
                [expiredObjects addObject:key];
                [self removeObjectFileForKey:key];
            }
        }
        
        if (expiredObjects.count)
        {
            [_cacheDictionary removeObjectsForKeys:expiredObjects];
        }
    }
}

#pragma mark - Application Notifications

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    @synchronized (_cacheDictionary)
    {
        [_cacheDictionary writeToFile:[FMCache cacheDictionaryPath] atomically:YES];
    }
}

@end
