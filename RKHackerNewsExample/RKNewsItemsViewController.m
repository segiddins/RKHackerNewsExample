// RKNewsItemsViewController.m
// 
// Copyright (c) 2013 RestKit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//   http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "RKNewsItemsViewController.h"
#import <RestKit/Network/RKObjectManager.h>
#import "RKNewsItem.h"

@interface RKNewsItemsViewController ()

@property (nonatomic, retain) NSArray *items;

@end

@implementation RKNewsItemsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshItem;
    [self refresh];
}

- (void)refresh
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"items/_search" parameters:@{@"filter[fields][type]" : @"submission", @"limit" : @100, @"sortby" : @"create_ts desc"} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.items = mappingResult.array;
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@">>> Error: %@", error);
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Opening %@", [self.items[indexPath.row] submissionURL]);
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    UIViewController *vc = [UIViewController new];
    [vc.view addSubview:webView];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[self.items[indexPath.row] submissionURL]];
    [webView loadRequest:request];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    RKNewsItem *item = self.items[indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.username;
}

@end
