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

#pragma mark - Properties

- (void)setIsDark:(BOOL)isDark
{
    _isDark = isDark;
    
    if (isDark)
    {
        [self setDarkViews];
    }
    else
    {
        [self setLightViews];
    }
}

- (void)setIsRandomColors:(BOOL)isRandomColors
{
    self.imageView1.backgroundColor = [UIColor colorWithWhite:[self randomFloatBetween:0.02 and:0.10] alpha:1.];
    self.imageView2.backgroundColor = [UIColor colorWithWhite:[self randomFloatBetween:0.02 and:0.10] alpha:1.];
    self.imageView3.backgroundColor = [UIColor colorWithWhite:[self randomFloatBetween:0.02 and:0.10] alpha:1.];
    self.imageView4.backgroundColor = [UIColor colorWithWhite:[self randomFloatBetween:0.02 and:0.10] alpha:1.];
    self.imageView5.backgroundColor = [UIColor colorWithWhite:[self randomFloatBetween:0.02 and:0.10] alpha:1.];
}

- (void)setColorOffset:(CGFloat)offset
{
    _colorOffset = offset;
    [self setGradientViews:offset];
}

#pragma mark - Utilities

- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber
{
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

- (void)rotateView:(UIView *)view
{
    view.transform = CGAffineTransformMakeRotation(M_PI/2);
}

- (void)setLightViews
{
    self.imageView1.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.];
    self.imageView2.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.];
    self.imageView3.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.];
    self.imageView4.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.];
    self.imageView5.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.];
}

- (void)setDarkViews
{
    self.imageView1.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.];
    self.imageView2.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.];
    self.imageView3.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.];
    self.imageView4.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.];
    self.imageView5.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.];
}

- (void)setGradientViews:(float)offset
{
    self.imageView1.backgroundColor = [UIColor colorWithWhite:(0.01 + offset) alpha:1.];
    self.imageView2.backgroundColor = [UIColor colorWithWhite:(0.02 + offset) alpha:1.];
    self.imageView3.backgroundColor = [UIColor colorWithWhite:(0.03 + offset) alpha:1.];
    self.imageView4.backgroundColor = [UIColor colorWithWhite:(0.04 + offset) alpha:1.];
    self.imageView5.backgroundColor = [UIColor colorWithWhite:(0.05 + offset) alpha:1.];
}

@end
