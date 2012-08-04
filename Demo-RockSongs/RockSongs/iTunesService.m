//
//  iTunesService.m
//  RockSongs
//
//  Created by Maurizio Cremaschi on 8/3/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "iTunesService.h"

//static NSString * const _serviceURLString = @"http://itunes.apple.com/us/rss/topsongs/limit=300/genre=21/explicit=true/json";
static NSString * const _serviceURLString = @"http://itunes.apple.com/us/rss/topalbums/limit=300/genre=21/explicit=true/json";

@implementation iTunesService

+ (void)topSongs:(void (^)(NSArray *topSongs))completion
{
    NSURL *url = [NSURL URLWithString:_serviceURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error == nil)
                               {
                                   completion([iTunesService elaborateData:data]);
                               }
                           }];
}

+ (NSArray *)elaborateData:(NSData *)data
{
    NSError *jsonError = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
    if (jsonError)
    {
        return nil;
    }
    
    NSMutableArray *images = [NSMutableArray new];
    NSArray *topsongs = [[json objectForKey:@"feed"] objectForKey:@"entry"];
    
    for (NSDictionary *topsong in topsongs)
    {
        NSArray *imagesLinks = [topsong objectForKey:@"im:image"];
        for (NSDictionary *imageLink in imagesLinks)
        {
            CGFloat height = [[[imageLink objectForKey:@"attributes"] objectForKey:@"height"] floatValue];
            if (height == 55)
            {
                [images addObject:[imageLink objectForKey:@"label"]];
                break;
            }
        }
    }
    
    return [NSArray arrayWithArray:images];
}

@end
