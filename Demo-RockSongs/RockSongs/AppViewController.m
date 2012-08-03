//
//  AppViewController.m
//  RockSongs
//
//  Created by Maurizio Cremaschi on 8/3/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "AppViewController.h"
#import "AppTableViewCell.h"
#import "iTunesService.h"
#import <QuartzCore/QuartzCore.h>

@interface AppViewController ()

@property (strong, nonatomic) NSArray *datasource;

@end

@implementation AppViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [iTunesService topSongs:^(NSArray *topSongs) {
        _datasource = topSongs;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    self.tableView.frame = CGRectMake(0., 0., 200., 200.);
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor clearColor];
    
    CATransform3D t = CATransform3DIdentity;
    t.m34 = 1/-500.;
    t = CATransform3DRotate(t, -M_PI/180*90, 0., 0., 1.);
    t = CATransform3DRotate(t, M_PI/180*30, 1., 0., 0.);
    self.tableView.layer.transform = t;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ceil(_datasource.count / 5.);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    AppTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSInteger startIndex = indexPath.row * 5;
    
    cell.imageView1.imageURL = [NSURL URLWithString:[self objectInDatasourceAtIndex:startIndex + 0]];
    cell.imageView2.imageURL = [NSURL URLWithString:[self objectInDatasourceAtIndex:startIndex + 1]];
    cell.imageView3.imageURL = [NSURL URLWithString:[self objectInDatasourceAtIndex:startIndex + 2]];
    cell.imageView4.imageURL = [NSURL URLWithString:[self objectInDatasourceAtIndex:startIndex + 3]];
    cell.imageView5.imageURL = [NSURL URLWithString:[self objectInDatasourceAtIndex:startIndex + 4]];
    
    return cell;
}

- (NSString *)objectInDatasourceAtIndex:(NSUInteger)index
{
    if (index < _datasource.count)
    {
        return [_datasource objectAtIndex:index];
    }
    return nil;
}

@end
