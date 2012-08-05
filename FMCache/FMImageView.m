//
//  FMImageView.m
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
    
    _lastLoadOperation = [FMImageLoader loadImageWithURL:url completion:^(UIImage *image, BOOL fromMemory, BOOL isCancelled) {
        
        if (isCancelled)
        {
            return;
        }
        
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
