//
//  FMImageView.h
//  FMCaching
//
//  Created by Maurizio Cremaschi on 8/2/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMImageView : UIImageView

@property (strong, nonatomic) NSURL *imageURL;

- (void)setImageURL:(NSURL *)url completion:(void (^)(void))completion;

@end
