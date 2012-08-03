//
//  FMImageLoader.h
//  RockSongs
//
//  Created by Maurizio Cremaschi on 8/3/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMImageLoader : NSObject

+ (NSOperation *)loadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image, BOOL fromMemory))completion;
+ (void)cancelOperation:(NSOperation *)operation;

@end
