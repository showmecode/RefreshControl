//
//  CHViewController.m
//  RefreshControl
//
//  Created by Moch on 8/26/14.
//  Copyright (c) 2014 Moch. All rights reserved.
//

#import "CHViewController.h"
#import "UIScrollView+RefreshControl.h"
#import "RefreshControl.h"

@interface CHViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;;

@end

@implementation CHViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _dataSource = [[NSMutableArray alloc] init];
    for (int i = 0; i < 13; i++) {
        NSString *data = [NSString stringWithFormat:@"initial data number: %d", i];
        [_dataSource addObject:data];
    }
    
    __weak typeof(self) weakSelf = self;


    [self.tableView addTopRefreshControlUsingBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i < 5; i++) {
                NSString *data = [NSString stringWithFormat:@"pull down data random number: %d", arc4random() % 100];
                [weakSelf.dataSource insertObject:data atIndex:0];
            }
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            [weakSelf.tableView topRefreshControlStopRefreshing];
            [weakSelf.tableView reloadData];
        });
    } refreshControlPullType:1 refreshControlStatusType:0];
    
    [self.tableView addBottomRefreshControlUsingBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i < 5; i++) {
                NSString *data = [NSString stringWithFormat:@"pull up data random number: %d", arc4random() % 100];
                [weakSelf.dataSource addObject:data];
            }
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [weakSelf.tableView reloadData];
//            [weakSelf.tableView bottomRefreshControlStopRefreshing];
            [weakSelf.tableView refreshFailureWithHintText:@"网络错误！"];
        });
    } refreshControlPullType:1 refreshControlStatusType:0];
    
    self.tableView.statusTextColor = [UIColor orangeColor];
    self.tableView.loadingCircleColor = [UIColor orangeColor];
    self.tableView.arrowColor = [UIColor orangeColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = _dataSource[indexPath.row];
    
    return cell;
}



@end
