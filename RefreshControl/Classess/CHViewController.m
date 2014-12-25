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

@interface CHViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;;

@end

@implementation CHViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
    return [super respondsToSelector:aSelector];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
	
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
	self.tableView.delegate = self;
	
    _dataSource = [[NSMutableArray alloc] init];
	for (int i = 0; i < 6; i++) {
		NSString *data = [NSString stringWithFormat:@"initial data number: %d", i];
		CGFloat height = arc4random() % 66 + 44;
		
		[_dataSource addObject:@{@"content":data, @"height":@(height)}];
	}
	
    __weak typeof(self) weakSelf = self;

    [self.tableView addTopRefreshControlUsingBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			for (int i = 0; i < 5; i++) {
				NSString *data = [NSString stringWithFormat:@"pull down data random number: %d", arc4random() % 100];
				CGFloat height = arc4random() % 66 + 44;
				[weakSelf.dataSource insertObject:@{@"content":data, @"height":@(height)} atIndex:0];
			}
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[weakSelf.tableView reloadData];
			[weakSelf.tableView topRefreshControlStopRefreshing];
        });
    } refreshControlPullType:RefreshControlPullTypeSensitive refreshControlStatusType:RefreshControlStatusTypeText];
    
    [self.tableView addBottomRefreshControlUsingBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i < 5; i++) {
                NSString *data = [NSString stringWithFormat:@"pull up data random number: %d", arc4random() % 100];
				CGFloat height = arc4random() % 66 + 44;
                [weakSelf.dataSource addObject:@{@"content":data, @"height":@(height)}];
            }
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            [weakSelf.tableView bottomRefreshControlStopRefreshing];
//            [weakSelf.tableView bottomRefreshControlRefreshFailureWithHintText:@"加载失败，请点击重试！"];
        });
    } refreshControlPullType:RefreshControlPullTypeInsensitive refreshControlStatusType:RefreshControlStatusTypeText];
    
    self.tableView.statusTextColor = [UIColor orangeColor];
    self.tableView.loadingCircleColor = [UIColor orangeColor];
    self.tableView.arrowColor = [UIColor orangeColor];
    
    [self.tableView addTouchUpInsideEventForBottomRefreshControlUsingBlock:^(RefreshControl *refreshControl) {
        [weakSelf.tableView bottomRefreshControlResumeRefreshing];
    }];
}

#pragma mark - 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self.dataSource[indexPath.row][@"height"] floatValue];
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
	
	NSString *text = _dataSource[indexPath.row][@"content"];
	cell.textLabel.text = text;
	
	return cell;
}

@end
