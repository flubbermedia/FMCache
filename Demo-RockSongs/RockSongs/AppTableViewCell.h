//
//  AppTableViewCell.h
//  RockSongs
//
//  Created by Maurizio Cremaschi on 8/3/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMImageView.h"

@interface AppTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet FMImageView *imageView1;
@property (strong, nonatomic) IBOutlet FMImageView *imageView2;
@property (strong, nonatomic) IBOutlet FMImageView *imageView3;
@property (strong, nonatomic) IBOutlet FMImageView *imageView4;
@property (strong, nonatomic) IBOutlet FMImageView *imageView5;

@property (assign, nonatomic) BOOL isDark;
@property (assign, nonatomic) BOOL isRandomColors;
@property (assign, nonatomic) CGFloat colorOffset;

@end
