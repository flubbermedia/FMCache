//
//  FlickrService.h
//  FMCaching
//
//  Created by Maurizio Cremaschi on 8/2/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleService : NSObject

+ (void)searchImages:(NSString *)search completion:(void (^)(NSArray *photos))completion;

@end
