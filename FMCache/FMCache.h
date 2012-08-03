//
//  FMCache.h
//  FMCaching
//
//  Created by Maurizio Cremaschi on 8/2/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMCache : NSObject

+ (FMCache *)defaultCache;
+ (NSCache *)memoryCache;

- (BOOL)hasCacheForKey:(NSString*)key;
- (void)removeCacheForKey:(NSString*)key;
- (void)clearCache;

- (NSData *)dataForKey:(NSString *)key;
- (void)dataForKey:(NSString *)key completion:(void (^)(NSData *data))completion;
- (void)setData:(NSData *)data forKey:(NSString *)key;

- (UIImage *)imageForKey:(NSString *)key;
- (void)imageForKey:(NSString *)key completion:(void (^)(UIImage *image))completion;
- (void)setImage:(UIImage *)image forKey:(NSString *)key;

@end
