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

- (void)addTopRefreshControlUsingBlock:(void (^)())callback;
- (void)addTopRefreshControlUsingBlock:(void (^)())callback refreshControlPullType:(RefreshControlPullType)refreshControlPullType;
- (void)topRefreshControlStopRefreshing;
- (void)removeTopRefreshControl;

- (void)addBottomRefreshControlUsingBlock:(void (^)())callback;
- (void)addBottomRefreshControlUsingBlock:(void (^)())callback refreshControlPullType:(RefreshControlPullType)refreshControlPullType;
- (void)bottomRefreshControlStopRefreshing;
- (void)removeBottomRefreshControl;

@end
