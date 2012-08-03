//
//  iTunesService.h
//  RockSongs
//
//  Created by Maurizio Cremaschi on 8/3/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iTunesService : NSObject

+ (void)topSongs:(void (^)(NSArray *topSongs))completion;

@end
