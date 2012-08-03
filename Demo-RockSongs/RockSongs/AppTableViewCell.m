//
//  AppTableViewCell.m
//  RockSongs
//
//  Created by Maurizio Cremaschi on 8/3/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "AppTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation AppTableViewCell

- (void)awakeFromNib
{
    [self rotateView:self.imageView1];
    [self rotateView:self.imageView2];
    [self rotateView:self.imageView3];
    [self rotateView:self.imageView4];
    [self rotateView:self.imageView5];
}

- (void)rotateView:(UIView *)view
{
    view.transform = CGAffineTransformMakeRotation(M_PI/2);
}

@end
