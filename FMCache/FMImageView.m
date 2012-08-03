//
//  FMImageView.m
//  FMCaching
//
//  Created by Maurizio Cremaschi on 8/2/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "FMImageView.h"
#import "FMImageLoader.h"
#import <QuartzCore/QuartzCore.h>

@interface FMImageView ()

@property (strong, nonatomic) NSOperation *lastLoadOperation;

@end

@implementation FMImageView

- (void)setImageURL:(NSURL *)url
{
    [self setImageURL:url completion:nil];
}

- (void)setImageURL:(NSURL *)url completion:(void (^)(void))completion
{
    _imageURL = url;
    
    self.image = nil;
    
    if (_lastLoadOperation)
    {
        [_lastLoadOperation cancel];
    }
    
    _lastLoadOperation = [FMImageLoader loadImageWithURL:url completion:^(UIImage *image, BOOL fromMemory) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (fromMemory)
            {
                self.image = image;
            }
            else
            {
                [self crossFadeImage:image];
            }
        });
        
        if (completion)
        {
            completion();
        }
    }];
}

- (void)crossFadeImage:(UIImage *)image
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.layer addAnimation:transition forKey:nil];
    
    self.image = image;
}

@end
