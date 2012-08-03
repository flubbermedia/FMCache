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

@property (strong, atomic) NSOperationQueue *networkOperationQueue;

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
        _networkOperationQueue = [NSOperationQueue new];
        _networkOperationQueue.maxConcurrentOperationCount = 3;
    }
    return self;
}

+ (NSOperation *)loadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image, BOOL fromMemory))completion
{
    return [[FMImageLoader sharedLoader] loadImageWithURL:url completion:completion];
}

- (NSOperation *)loadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image, BOOL fromMemory))completion
{
    //memory cache
    UIImage *memoryImage = [[FMCache memoryCache] objectForKey:url.absoluteString];
    if (memoryImage)
    {
        completion(memoryImage, YES);
    }
    
    //disk cache
    if ([[FMCache defaultCache] hasCacheForKey:url.absoluteString])
    {
        [[FMCache defaultCache] imageForKey:url.absoluteString
                                 completion:^(UIImage *image) {
                                     [[FMCache memoryCache] setObject:image forKey:url.absoluteString];
                                     completion(image, NO);
                                 }];
        return nil;
    }

    //download remote
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        if (image)
        {
            [[FMCache defaultCache] setImage:image forKey:url.absoluteString];
            [[FMCache memoryCache] setObject:image forKey:url.absoluteString];
        }
        completion(image, NO);
    }];
    
    [_networkOperationQueue addOperation:op];
    
    return op;
}

@end
