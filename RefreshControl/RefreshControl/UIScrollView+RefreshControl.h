//
//  UIScrollView+RefreshControl.h
//  RefreshControl
//
//  Created by Moch Xiao on 2015-02-03.
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
- (void)topRefreshControlStopRefreshingWithHintText:(NSString *)hintText;
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
- (void)bottomRefreshControlStopRefreshingWithHintText:(NSString *)hintText;
- (void)removeBottomRefreshControl;
- (void)bottomRefreshControlRefreshFailureWithHintText:(NSString *)hintText;
- (void)addTouchUpInsideEventForBottomRefreshControlUsingBlock:(void (^)(RefreshControl *refreshControl))callback;
- (void)bottomRefreshControlResumeRefreshing;

#pragma mark - Initialize refreshing

- (void)topRefreshControlStartInitializeRefreshing;

#pragma mark - GetRefreshControl's state

- (RefreshControlState)topRefreshControlState;
- (RefreshControlState)bottomRefreshControlState;

#pragma mark - Top pull background view

- (void)addTopRefreshControlBackgroundView:(UIView *)backgroundView;

@end
