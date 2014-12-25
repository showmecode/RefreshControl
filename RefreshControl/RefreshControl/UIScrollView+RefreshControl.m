//
//  UIScrollView+RefreshControl.m
//  RefreshControl
//
//  Created by Moch on 8/27/14.
//  Copyright (c) 2014 Moch. All rights reserved.
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
    if (self.topRefreshControl) {
		[self.topRefreshControl stopRefreshing];

//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.topRefreshControl stopRefreshing];
//        });
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
    if (self.bottomRefreshControl) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.bottomRefreshControl stopRefreshing];
        });
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

@end
