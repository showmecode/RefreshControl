//
//  UIScrollView+RefreshControl.m
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

#import "UIScrollView+RefreshControl.h"
#import "Indicator.h"
#import "Arrow.h"
#import <objc/runtime.h>

static const void *TopRefreshControlKey = &TopRefreshControlKey;
static const void *BottomRefreshControlKey = &BottomRefreshControlKey;

@interface UIScrollView ()

@property(nonatomic, weak) TopRefreshControl *topRefreshControl;
@property(nonatomic, weak) BottomRefreshControl *bottomRefreshControl;

@end

@implementation UIScrollView (RefreshControl)

#pragma mark - TopRefreshControl

- (void)setTopRefreshControl:(TopRefreshControl *)topRefreshControl {
    [self willChangeValueForKey:@"TopRefreshControlKey"];
    objc_setAssociatedObject(self, TopRefreshControlKey, topRefreshControl, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"TopRefreshControlKey"];
}

- (TopRefreshControl *)topRefreshControl {
    return objc_getAssociatedObject(self, &TopRefreshControlKey);
}

- (void)addTopRefreshControlUsingBlock:(void (^)())callback {
    [self addTopRefreshControlUsingBlock:callback
                  refreshControlPullType:RefreshControlPullTypeSensitive
                refreshControlStatusType:RefreshControlStatusTypeText];
}

- (void)addTopRefreshControlUsingBlock:(void (^)())callback
                refreshControlPullType:(RefreshControlPullType)refreshControlPullType
              refreshControlStatusType:(RefreshControlStatusType)refreshControlStatusType {
    if (!self.topRefreshControl) {
        TopRefreshControl *topRefreshControl = [TopRefreshControl new];
        topRefreshControl.refreshControlPullType = refreshControlPullType;
        topRefreshControl.refreshControlStatusType = refreshControlStatusType;
        self.topRefreshControl = topRefreshControl;
        [self addSubview:topRefreshControl];
    }
    self.topRefreshControl.begainRefreshing = callback;
}

- (void)topRefreshControlStopRefreshing {
    [self topRefreshControlStopRefreshingWithHintText:nil];
}

- (void)topRefreshControlStopRefreshingWithHintText:(NSString *)hintText {
    if (self.topRefreshControl && self.topRefreshControl.refreshControlState == RefreshControlStateRefreshing) {
        [self.topRefreshControl stopRefreshingWithHintText:hintText];
    }
}

- (void)removeTopRefreshControl {
    [self.topRefreshControl removeFromSuperview];
    self.topRefreshControl = nil;
}

- (void)topRefreshControlRefreshFailureWithHintText:(NSString *)hintText {
    [self.topRefreshControl refreshFailureWithHintText:hintText];
}

- (void)addTouchUpInsideEventForTopRefreshControlUsingBlock:(void (^)(RefreshControl *refreshControl))callback {
    self.topRefreshControl.touchUpInsideEvent = callback;
}

- (void)topRefreshControlResumeRefreshing {
    [self.topRefreshControl resumeRefreshing];
}

#pragma mark - BootomRefreshControl

- (void)setBottomRefreshControl:(BottomRefreshControl *)bottomRefreshControl {
    [self willChangeValueForKey:@"BottomRefreshControlKey"];
    objc_setAssociatedObject(self, BottomRefreshControlKey, bottomRefreshControl, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"BottomRefreshControlKey"];
}

- (BottomRefreshControl *)bottomRefreshControl {
    return objc_getAssociatedObject(self, &BottomRefreshControlKey);;
}

- (void)addBottomRefreshControlUsingBlock:(void (^)())callback {
    [self addBottomRefreshControlUsingBlock:callback
                     refreshControlPullType:RefreshControlPullTypeSensitive
                   refreshControlStatusType:RefreshControlStatusTypeText];
}

- (void)addBottomRefreshControlUsingBlock:(void (^)())callback
                   refreshControlPullType:(RefreshControlPullType)refreshControlPullType
                 refreshControlStatusType:(RefreshControlStatusType)refreshControlStatusType {
    if (!self.bottomRefreshControl) {
        BottomRefreshControl *bottomRefreshControl = [BottomRefreshControl new];
        bottomRefreshControl.refreshControlPullType = refreshControlPullType;
        bottomRefreshControl.refreshControlStatusType = refreshControlStatusType;
        self.bottomRefreshControl = bottomRefreshControl;
        [self addSubview:bottomRefreshControl];
    }
    self.bottomRefreshControl.begainRefreshing = callback;
}

- (void)bottomRefreshControlStopRefreshing {
    [self bottomRefreshControlStopRefreshingWithHintText:nil];
}

- (void)bottomRefreshControlStopRefreshingWithHintText:(NSString *)hintText; {
    if (self.bottomRefreshControl && self.bottomRefreshControl.refreshControlState == RefreshControlStateRefreshing) {
        [self.bottomRefreshControl stopRefreshingWithHintText:hintText];
    }
}

- (void)removeBottomRefreshControl {
    [self.bottomRefreshControl removeFromSuperview];
    self.bottomRefreshControl = nil;
}

- (void)bottomRefreshControlRefreshFailureWithHintText:(NSString *)hintText {
    [self.bottomRefreshControl refreshFailureWithHintText:hintText];
}

- (void)addTouchUpInsideEventForBottomRefreshControlUsingBlock:(void (^)(RefreshControl *refreshControl))callback {
    self.bottomRefreshControl.touchUpInsideEvent = callback;
}

- (void)bottomRefreshControlResumeRefreshing {
    [self.bottomRefreshControl resumeRefreshing];
}

#pragma mark - override accessors

- (void)setTopRefreshControlPullToRefreshingText:(NSString *)topRefreshControlPullToRefreshingText {
    self.topRefreshControl.pullToRefreshing = topRefreshControlPullToRefreshingText;
}

- (NSString *)topRefreshControlPullToRefreshingText {
    return self.topRefreshControl.pullToRefreshing;
}

- (void)setTopRefreshControlPullReleaseToRefreshingText:(NSString *)topRefreshControlPullReleaseToRefreshingText {
    self.topRefreshControl.pullReleaseToRefreshing = topRefreshControlPullReleaseToRefreshingText;
}

- (NSString *)topRefreshControlPullReleaseToRefreshingText {
    return self.topRefreshControl.pullReleaseToRefreshing;
}

- (void)setTopRefreshControlpullRefreshingText:(NSString *)topRefreshControlpullRefreshingText {
    self.topRefreshControl.pullRefreshing = topRefreshControlpullRefreshingText;
}

- (NSString *)topRefreshControlpullRefreshingText {
    return self.topRefreshControl.pullRefreshing;
}

- (void)setBottomRefreshControlPullToRefreshingText:(NSString *)bottomRefreshControlPullToRefreshingText {
    self.bottomRefreshControl.pullToRefreshing = bottomRefreshControlPullToRefreshingText;
}

- (NSString *)bottomRefreshControlPullToRefreshingText {
    return self.bottomRefreshControl.pullToRefreshing;
}

- (void)setBottomRefreshControlPullReleaseToRefreshingText:(NSString *)bottomRefreshControlPullReleaseToRefreshingText {
    self.bottomRefreshControl.pullReleaseToRefreshing = bottomRefreshControlPullReleaseToRefreshingText;
}

- (NSString *)bottomRefreshControlPullReleaseToRefreshingText {
    return self.bottomRefreshControl.pullReleaseToRefreshing;
}

- (void)setBottomRefreshControlpullRefreshingText:(NSString *)bottomRefreshControlpullRefreshingText {
    self.bottomRefreshControl.pullRefreshing = bottomRefreshControlpullRefreshingText;
}

- (NSString *)bottomRefreshControlpullRefreshingText {
    return self.bottomRefreshControl.pullRefreshing;
}

- (void)setStatusTextColor:(UIColor *)statusTextColor {
    self.topRefreshControl.statusLabel.textColor = statusTextColor;
    self.bottomRefreshControl.statusLabel.textColor = statusTextColor;
}

- (UIColor *)statusTextColor {
    return self.topRefreshControl.statusLabel.textColor;
}

- (void)setLoadingCircleColor:(UIColor *)loadingCircleColor {
    self.topRefreshControl.indicator.lineColor = loadingCircleColor;
    self.bottomRefreshControl.indicator.lineColor = loadingCircleColor;
}

- (UIColor *)loadingCircleColor {
    return self.topRefreshControl.indicator.lineColor;
}

- (void)setArrowColor:(UIColor *)arrowColor {
    self.topRefreshControl.arrow.color = arrowColor;
    self.bottomRefreshControl.arrow.color = arrowColor;
}

- (UIColor *)arrowColor {
    return self.topRefreshControl.arrow.color;
}

#pragma mark -

- (void)topRefreshControlStartInitializeRefreshing {
    [self.topRefreshControl setRefreshControlState:RefreshControlStateRefreshing];
    [self.topRefreshControl startRefreshing];
}

#pragma mark - GetRefreshControl's state

- (RefreshControlState)topRefreshControlState {
    return self.topRefreshControl.refreshControlState;
}

- (RefreshControlState)bottomRefreshControlState {
    return self.bottomRefreshControl.refreshControlState;
}

#pragma mark - Top pull background view

- (void)addTopRefreshControlBackgroundView:(UIView *)backgroundView {
    self.topRefreshControl.backgroundView = backgroundView;
}

@end
