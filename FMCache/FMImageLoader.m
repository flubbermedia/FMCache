//
//  FMImageLoader.m
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

#import "FMImageLoader.h"
#import "FMCache.h"

static NSTimeInterval const _defaultTimeoutInterval = 604800.; // 1 week

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

#pragma Class methods

+ (NSOperation *)loadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image, BOOL fromMemory, BOOL isCancelled))completion
{
    return [[FMImageLoader sharedLoader] loadImageWithURL:url completion:completion];
}

+ (NSOperation *)loadImageWithURL:(NSURL *)url expirationDate:(NSDate *)date completion:(void (^)(UIImage *image, BOOL fromMemory, BOOL isCancelled))completion;
{
    return [[FMImageLoader sharedLoader] loadImageWithURL:url expirationDate:date completion:completion];
}

#pragma Instance methods

- (NSOperation *)loadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image, BOOL fromMemory, BOOL isCancelled))completion
{
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:_defaultTimeoutInterval];
    return [[FMImageLoader sharedLoader] loadImageWithURL:url expirationDate:expirationDate completion:completion];
}

- (NSOperation *)loadImageWithURL:(NSURL *)url expirationDate:(NSDate *)date completion:(void (^)(UIImage *image, BOOL fromMemory, BOOL isCancelled))completion
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
        __weak NSBlockOperation *weakOp = op;
        [op addExecutionBlock:^{
            UIImage *image = [FMCache objectForKey:url.absoluteString];
            if (image)
            {
                [FMCache setObject:image forKey:url.absoluteString expirationDate:date];
            }
            else
            {
                [FMCache removeObjectForKey:url.absoluteString];
            }
            completion(image, NO, weakOp.isCancelled);
        }];
        [_operationQueue addOperation:op];
        
        return op;
    }
    
    
    NSBlockOperation *op = [NSBlockOperation new];
    __weak NSBlockOperation *weakOp = op;
    [op addExecutionBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        if (image)
        {
            [FMCache setObject:image forKey:url.absoluteString expirationDate:date];
        }
        else
        {
            [FMCache removeObjectForKey:url.absoluteString];
        }
        completion(image, NO, weakOp.isCancelled);
    }];
    [_operationQueue addOperation:op];
    return op;
}

@end
