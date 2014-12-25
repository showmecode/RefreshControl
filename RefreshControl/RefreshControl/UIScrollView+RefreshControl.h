//
//  UIScrollView+RefreshControl.h
//  RefreshControl
//
//  Created by Moch on 8/27/14.
//  Copyright (c) 2014 Moch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshControl.h"

@interface UIScrollView (RefreshControl)

@property (nonatomic, strong) NSString *topRefreshControlPullToRefreshingText;
@property (nonatomic, strong) NSString *topRefreshControlPullReleaseToRefreshingText;
@property (nonatomic, strong) NSString *topRefreshControlpullRefreshingText;

@property (nonatomic, strong) NSString *bottomRefreshControlPullToRefreshingText;
@property (nonatomic, strong) NSString *bottomRefreshControlPullReleaseToRefreshingText;
@property (nonatomic, strong) NSString *bottomRefreshControlpullRefreshingText;

@property (nonatomic, strong) UIColor *statusTextColor;
@property (nonatomic, strong) UIColor *loadingCircleColor;
@property (nonatomic, strong) UIColor *arrowColor;

#pragma mark - TopRefreshControl

- (void)addTopRefreshControlUsingBlock:(void (^)())callback;
- (void)addTopRefreshControlUsingBlock:(void (^)())callback
                refreshControlPullType:(RefreshControlPullType)refreshControlPullType
              refreshControlStatusType:(RefreshControlStatusType)refreshControlStatusType;
- (void)topRefreshControlStopRefreshing;
- (void)removeTopRefreshControl;
- (void)topRefreshControlRefreshFailureWithHintText:(NSString *)hintText;
- (void)addTouchUpInsideEventForTopRefreshControlUsingBlock:(void (^)(RefreshControl *refreshControl))callback;
- (void)topRefreshControlResumeRefreshing;

#pragma mark - BootomRefreshControl

- (void)addBottomRefreshControlUsingBlock:(void (^)())callback;
- (void)addBottomRefreshControlUsingBlock:(void (^)())callback
                   refreshControlPullType:(RefreshControlPullType)refreshControlPullType
                 refreshControlStatusType:(RefreshControlStatusType)refreshControlStatusType;
- (void)bottomRefreshControlStopRefreshing;
- (void)removeBottomRefreshControl;
- (void)bottomRefreshControlRefreshFailureWithHintText:(NSString *)hintText;
- (void)addTouchUpInsideEventForBottomRefreshControlUsingBlock:(void (^)(RefreshControl *refreshControl))callback;
- (void)bottomRefreshControlResumeRefreshing;

#pragma mark - Initialize refreshing

- (void)topRefreshControlStartInitializeRefreshing;

@end
