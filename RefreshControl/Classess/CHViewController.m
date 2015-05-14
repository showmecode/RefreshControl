//
//  CHViewController.m
//  RefreshControl
//
//  Created by Moch Xiao on 2014-12-25.
//  Copyright (c) 2014 Moch Xiao (https://github.com/atcuan).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CHViewController.h"
#import "UIScrollView+RefreshControl.h"
#import "RefreshControl.h"

@interface CHViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation CHViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
}
//
//- (BOOL)respondsToSelector:(SEL)aSelector {
//    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
//    return [super respondsToSelector:aSelector];
//}

static NSInteger count = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    _dataSource = [[NSMutableArray alloc] init];
    
    __weak typeof(self) weakSelf = self;
    
    [self.tableView addTopRefreshControlUsingBlock: ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i < 5; i++) {
                NSString *data = [NSString stringWithFormat:@"pull down data random number: %d", arc4random() % 100];
                CGFloat height = arc4random() % 66 + 44;
                [weakSelf.dataSource insertObject:@{ @"content":data, @"height":@(height) } atIndex:0];
            }
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
//            [weakSelf.tableView topRefreshControlStopRefreshing];
            [weakSelf.tableView topRefreshControlStopRefreshingWithHintText:@"刷新成功"];
        });
    } refreshControlPullType:RefreshControlPullTypeInsensitive refreshControlStatusType:RefreshControlStatusTypeTextAndArrow];


//    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 160)];
//    backgroundView.backgroundColor = [UIColor lightGrayColor];
//    [self.tableView addTopRefreshControlBackgroundView:backgroundView];
    [self.tableView addTopRefreshControlBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dinosaur"]]];

    [self.tableView addBottomRefreshControlUsingBlock: ^{
        if (count < 1) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (int i = 0; i < 5; i++) {
                    NSString *data = [NSString stringWithFormat:@"pull up data random number: %d", arc4random() % 100];
                    CGFloat height = arc4random() % 66 + 44;
                    [weakSelf.dataSource addObject:@{ @"content":data, @"height":@(height) }];
                }
                count++;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
//                [weakSelf.tableView bottomRefreshControlStopRefreshing];
                [weakSelf.tableView bottomRefreshControlStopRefreshingWithHintText:@"已经加载完所有数据"];

            });
        } else {
//            [weakSelf.tableView bottomRefreshControlStopRefreshing];
//            [weakSelf.tableView bottomRefreshControlStopRefreshingWithHintText:@"已经加载完所有数据"];
            
            [weakSelf.tableView bottomRefreshControlRefreshFailureWithHintText:@"加载失败，请点击重试！"];
        }
    } refreshControlPullType:RefreshControlPullTypeInsensitive refreshControlStatusType:RefreshControlStatusTypeText];
    
    self.tableView.statusTextColor = [UIColor orangeColor];
    self.tableView.loadingCircleColor = [UIColor orangeColor];
    self.tableView.arrowColor = [UIColor orangeColor];
    
    [self.tableView addTouchUpInsideEventForBottomRefreshControlUsingBlock: ^(RefreshControl *refreshControl) {
        [weakSelf.tableView bottomRefreshControlResumeRefreshing];
    }];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView topRefreshControlStartInitializeRefreshing];
//    });
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
