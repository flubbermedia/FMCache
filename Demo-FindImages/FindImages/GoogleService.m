//
//  FlickrService.m
//  FMCaching
//
//  Created by Maurizio Cremaschi on 8/2/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "GoogleService.h"

// Google api request parameters
// https://developers.google.com/image-search/v1/jsondevguide#json_args

static NSString * const _serviceURLFormat = @"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&imgsz=small|medium&q=%@";

@implementation GoogleService

+ (void)searchImages:(NSString *)search completion:(void (^)(NSArray *photos))completion
{
    NSString *urlString = [[NSString stringWithFormat:_serviceURLFormat, search] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {                               
                               if (error == nil)
                               {
                                   completion([GoogleService elaborateData:data]);
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
    
    NSMutableArray *photos = [NSMutableArray new];
    NSDictionary *responseData = [json objectForKey:@"responseData"];
    NSArray *results = [responseData objectForKey:@"results"];
    
    for (NSDictionary *result in results)
    {
        [photos addObject:[result objectForKey:@"unescapedUrl"]];
    }
    
    return [NSArray arrayWithArray:photos];
}

@end
