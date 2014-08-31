//
//  RefreshControl.h
//  RefreshControl
//
//  Created by Moch on 8/26/14.
//  Copyright (c) 2014 Moch. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoadingView;

typedef NS_ENUM(NSInteger, RefreshControlType) {
    RefreshControlTypeTop    = -1,
    RefreshControlTypeBottom = 1
};

typedef NS_ENUM(NSInteger, RefreshControlPullType) {
    RefreshControlPullTypeSensitive,
    RefreshControlPullTypeInsensitive
};

typedef NS_ENUM (NSInteger, RefreshControlState) {
    RefreshControlStateHidden,           // Reverse drag state
    RefreshControlStatePulling,          // Drag state
    RefreshControlStateOveredThreshold,  // Exceeds the critical value of the state
    RefreshControlStateRefreshing        // Perform the action status
};

@interface RefreshControl : UIView

@property (nonatomic, assign) RefreshControlType     refreshControlType;
@property (nonatomic, assign) RefreshControlPullType refreshControlPullType;
@property (nonatomic, assign) RefreshControlState    refreshControlState;

// get super scroll view
@property (nonatomic, weak, readonly  ) UIScrollView *superScrollView;
// Dragging the vertical direction of the right value (Subclasses override)
@property (nonatomic, assign, readonly) CGFloat      properVerticalPullValue;
// Scroll view content exceeds the height control view (Subclasses override the)
@property (nonatomic, assign, readonly) CGFloat      scrollViewOverViewHeight;

@property (nonatomic, weak, readonly) UILabel     *statusLabel;
@property (nonatomic, weak, readonly) LoadingView *loadingView;

// @"Pull down refresh"
@property (nonatomic, strong) NSString *pullToRefreshing;
// @"Loosen refresh"
@property (nonatomic, strong) NSString *pullReleaseToRefreshing;
// @"Refreshing"
@property (nonatomic, strong) NSString *pullRefreshing;

// external call
- (void)startRefreshing;
- (void)stopRefreshing;

// call back
@property (nonatomic, copy) void(^begainRefreshing)();
@property (nonatomic, copy) void(^endRefreshing)();

@end

@interface TopRefreshControl : RefreshControl

@end

@interface BottomRefreshControl : RefreshControl

@end