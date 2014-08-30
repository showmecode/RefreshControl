//
//  UIScrollView+RefreshControl.m
//  RefreshControl
//
//  Created by Moch on 8/27/14.
//  Copyright (c) 2014 Moch. All rights reserved.
//

#import "UIScrollView+RefreshControl.h"
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
                  refreshControlPullType:RefreshControlPullTypeFashion];
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
                     refreshControlPullType:RefreshControlPullTypeFashion];
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

@end
