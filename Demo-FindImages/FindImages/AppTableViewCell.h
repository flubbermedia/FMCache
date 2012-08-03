//
//  Cell.h
//  FMCaching
//
//  Created by Maurizio Cremaschi on 8/2/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMImageView.h"

@interface AppTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet FMImageView *asyncImageView;

@end
