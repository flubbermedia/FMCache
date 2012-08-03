//
//  ViewController.m
//  FMCaching
//
//  Created by Maurizio Cremaschi on 8/2/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "AppViewController.h"
#import "AppTableViewCell.h"
#import "GoogleService.h"

@interface AppViewController ()

@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSArray *datasource;

@end

@implementation AppViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _queue = [NSOperationQueue new];
    
    [self searchImages:@"funky monkey"];
}

- (void)searchImages:(NSString *)searchText
{
    _datasource = nil;
    [self.tableView reloadData];
    
    [GoogleService searchImages:searchText
                    completion:^(NSArray *photos) {
                        _datasource = photos;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    AppTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSURL *url = [NSURL URLWithString:[_datasource objectAtIndex:indexPath.row]];
    cell.asyncImageView.imageURL = url;
    
    return cell;
}

#pragma mark - Search Bar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchImages:searchBar.text];
    
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

@end
