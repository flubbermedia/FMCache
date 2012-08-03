//
//  FMCache.m
//  FMCaching
//
//  Created by Maurizio Cremaschi on 8/2/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "FMCache.h"
#import <CommonCrypto/CommonDigest.h>

static NSTimeInterval const _defaultTimeoutInterval = 86400;
static NSString * const _cacheFolderName = @"com.flubbermedia.cache";
static NSString * const _cacheDictionaryFileName = @"cache.plist";

static NSString *md5(NSString *string)
{
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

static NSString *cacheDataPath()
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

static NSString *cacheDictionaryPath()
{
    return [cacheDataPath() stringByAppendingPathComponent:_cacheDictionaryFileName];
}

static NSString *cacheFilePathWithKey(NSString *key)
{
    return [cacheDataPath() stringByAppendingPathComponent:md5(key)];
}

@interface FMCache ()

@property (strong, nonatomic) NSOperationQueue *diskOperationQueue;
@property (strong, atomic) NSMutableDictionary *cacheDictionary;

@end

@implementation FMCache

+ (FMCache *)defaultCache
{
    static FMCache *_defaultCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultCache = [FMCache new];
    });
    return _defaultCache;
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
        _diskOperationQueue = [NSOperationQueue new];
        _diskOperationQueue.maxConcurrentOperationCount = 1;
        
        _cacheDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:cacheDictionaryPath()];
        if (_cacheDictionary == nil)
        {
            _cacheDictionary = [NSMutableDictionary new];
        }
                
        [self cleanCacheDictionary];
        [self saveCacheDictionary];
    }
    return self;
}

#pragma mark - Cache

- (BOOL)hasCacheForKey:(NSString*)key
{
	NSDate *date = [_cacheDictionary objectForKey:key];
	if (date && ![[[NSDate date] earlierDate:date] isEqualToDate:date])
    {
        return ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePathWithKey(key)]);
    }
    return NO;
}

- (void)removeCacheForKey:(NSString*)key
{
    [self removeCacheFileForKeyInBackground:key];
    
    [_cacheDictionary removeObjectForKey:key];
    [self saveCacheDictionary];
}

- (void)clearCache
{
    for (NSString *key in _cacheDictionary.allKeys)
    {
        [self removeCacheFileForKeyInBackground:key];
    }
    
    [_cacheDictionary removeAllObjects];
    [self saveCacheDictionary];
}

#pragma mark - Cache Data

- (NSData *)dataForKey:(NSString *)key
{
    if ([self hasCacheForKey:key])
    {
        return [NSData dataWithContentsOfFile:cacheFilePathWithKey(key)];
    }
    
    return nil;
}

- (void)dataForKey:(NSString *)key completion:(void (^)(NSData *data))completion
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue, ^{
        NSData *data = [self dataForKey:key];
        completion(data);
    });
}

- (void)setData:(NSData *)data forKey:(NSString *)key
{
    [self writeDataCacheFileInBackground:data withKey:key];
    
    [_cacheDictionary setObject:[NSDate dateWithTimeIntervalSinceNow:_defaultTimeoutInterval] forKey:key];
    
    //[self saveCacheDictionary];
}

#pragma mark - Cache Image

- (UIImage *)imageForKey:(NSString *)key
{
    NSData *data = [self dataForKey:key];
    return [UIImage imageWithData:data];
}

- (void)imageForKey:(NSString *)key completion:(void (^)(UIImage *image))completion
{
    [self dataForKey:key completion:^(NSData *data) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithData:data];
            completion(image);
        });
    }];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    [self setData:UIImageJPEGRepresentation(image, 0.8) forKey:key];
}

#pragma mark - Utilities

- (void)cleanCacheDictionary
{
    NSMutableArray *removeList = [NSMutableArray array];
    
    for (NSString *key in _cacheDictionary.allKeys)
    {
        NSDate *date = [_cacheDictionary objectForKey:key];
        if ([[[NSDate date] earlierDate:date] isEqualToDate:date])
        {
            [removeList addObject:key];
            [self removeCacheFileForKeyInBackground:key];
        }
    }
    
    if (removeList.count)
    {
        [_cacheDictionary removeObjectsForKeys:removeList];
    }
}

- (void)saveCacheDictionary
{
    [_diskOperationQueue addOperationWithBlock:^{
        [_cacheDictionary writeToFile:cacheDictionaryPath() atomically:YES];
    }];
}

- (void)removeCacheFileForKeyInBackground:(NSString *)key
{
    [_diskOperationQueue addOperationWithBlock:^{
        [[NSFileManager defaultManager] removeItemAtPath:cacheFilePathWithKey(key) error:nil];
    }];
}

- (void)writeDataCacheFileInBackground:(NSData *)data withKey:(NSString *)key
{
    [_diskOperationQueue addOperationWithBlock:^{
        [data writeToFile:cacheFilePathWithKey(key) atomically:YES];
    }];
}

@end
