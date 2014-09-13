//
//  UIScrollView+RefreshControl.m
//  RefreshControl
//
//  Created by Moch on 8/27/14.
//  Copyright (c) 2014 Moch. All rights reserved.
//

#import "UIScrollView+RefreshControl.h"
#import "LoadingView.h"
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
                  refreshControlPullType:RefreshControlPullTypeSensitive];
}

- (void)addTopRefreshControlUsingBlock:(void (^)())callback
                refreshControlPullType:(RefreshControlPullType)refreshControlPullType {
    if (!self.topRefreshControl) {
        TopRefreshControl *topRefreshControl = [TopRefreshControl new];
        topRefreshControl.refreshControlPullType = refreshControlPullType;
        self.topRefreshControl = topRefreshControl;
        [self addSubview:topRefreshControl];
    }
    self.topRefreshControl.begainRefreshing = callback;
}

- (void)topRefreshControlStopRefreshing {
    if (self.topRefreshControl) {
        [self.topRefreshControl stopRefreshing];
    }
}

- (void)removeTopRefreshControl {
    [self.topRefreshControl removeFromSuperview];
    self.topRefreshControl = nil;
}

#pragma mark - BootomRefreshControl

- (void)setBottomRefreshControl:(BottomRefreshControl *)bottomRefreshControl {
    [self willChangeValueForKey:@"BottomRefreshControlKey"];
    objc_setAssociatedObject(self, BottomRefreshControlKey, bottomRefreshControl, OBJC_ASSOCIATION_ASSIGN);
}

- (BottomRefreshControl *)bottomRefreshControl {
    return objc_getAssociatedObject(self, &BottomRefreshControlKey);;
}

- (void)addBottomRefreshControlUsingBlock:(void (^)())callback {
    [self addBottomRefreshControlUsingBlock:callback
                     refreshControlPullType:RefreshControlPullTypeSensitive];
}

- (void)addBottomRefreshControlUsingBlock:(void (^)())callback
                   refreshControlPullType:(RefreshControlPullType)refreshControlPullType {
    if (!self.bottomRefreshControl) {
        BottomRefreshControl *bottomRefreshControl = [BottomRefreshControl new];
        bottomRefreshControl.refreshControlPullType = refreshControlPullType;
        self.bottomRefreshControl = bottomRefreshControl;
        [self addSubview:bottomRefreshControl];
    }
    self.bottomRefreshControl.begainRefreshing = callback;
}

- (void)bottomRefreshControlStopRefreshing {
    if (self.bottomRefreshControl) {
        [self.bottomRefreshControl stopRefreshing];
    }
}

- (void)removeBottomRefreshControl {
    [self.bottomRefreshControl removeFromSuperview];
    self.bottomRefreshControl = nil;
}

#pragma mark - process refresh failure

- (void)refreshFailureWithHintText:(NSString *)hintText {
    if (self.topRefreshControl.refreshControlState == RefreshControlStateRefreshing) {
        [self.topRefreshControl refreshFailureWithHintText:hintText];
        return;
    }
    if (self.bottomRefreshControl.refreshControlState == RefreshControlStateRefreshing) {
        [self.bottomRefreshControl refreshFailureWithHintText:hintText];
    }
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
    self.topRefreshControl.statusButton.titleLabel.textColor = statusTextColor;
    self.bottomRefreshControl.statusButton.titleLabel.textColor = statusTextColor;
}

- (UIColor *)statusTextColor {
    return self.topRefreshControl.statusButton.currentTitleColor;
}

- (void)setLoadingCircleColor:(UIColor *)loadingCircleColor {
    self.topRefreshControl.loadingView.lineColor = loadingCircleColor;
    self.bottomRefreshControl.loadingView.lineColor = loadingCircleColor;
}

- (UIColor *)loadingCircleColor {
    return self.topRefreshControl.loadingView.lineColor;
}


@end
