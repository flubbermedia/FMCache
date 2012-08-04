//
//  FMImageLoader.m
//  RockSongs
//
//  Created by Maurizio Cremaschi on 8/3/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "FMImageLoader.h"
#import "FMCache.h"

@interface FMImageLoader ()

@property (strong, atomic) NSOperationQueue *operationQueue;

@end

@implementation FMImageLoader

+ (FMImageLoader *)sharedLoader
{
    static FMImageLoader *_sharedLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLoader = [FMImageLoader new];
    });
    return _sharedLoader;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _operationQueue = [NSOperationQueue new];
        _operationQueue.maxConcurrentOperationCount = 3;
    }
    return self;
}

+ (NSOperation *)loadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image, BOOL fromMemory, BOOL isCancelled))completion
{
    return [[FMImageLoader sharedLoader] loadImageWithURL:url completion:completion];
}

- (NSOperation *)loadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image, BOOL fromMemory, BOOL isCancelled))completion
{
    if ([FMCache hasObjectInMemoryForKey:url.absoluteString])
    {
        UIImage *image = [FMCache objectForKey:url.absoluteString];
        completion(image, YES, NO);
        return nil;
    }
    
    if ([FMCache hasObjectOnDiskForKey:url.absoluteString])
    {
        NSBlockOperation *op = [NSBlockOperation new];
        [op addExecutionBlock:^{
            UIImage *image = [FMCache objectForKey:url.absoluteString];
            [FMCache setObject:image forKey:url.absoluteString];            
            completion(image, NO, op.isCancelled);
        }];
        [_operationQueue addOperation:op];
        return op;
    }
    
    
    NSBlockOperation *op = [NSBlockOperation new];
    [op addExecutionBlock:^{
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        [FMCache setObject:image forKey:url.absoluteString];
        completion(image, NO, op.isCancelled);
    }];
    [_operationQueue addOperation:op];
    return op;
}

@end
