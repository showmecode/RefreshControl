//
//  RefreshControl.h
//  RefreshControl
//
//  Created by Moch on 8/26/14.
//  Copyright (c) 2014 Moch. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Indicator;
@class Arrow;

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

typedef NS_ENUM(NSInteger, RefreshControlStatusType) {
    RefreshControlStatusTypeTextAndArrow,
    RefreshControlStatusTypeText,
    RefreshControlStatusTypeArrow
};

@interface RefreshControl : UIControl

@property (nonatomic, assign) RefreshControlType        refreshControlType;
@property (nonatomic, assign) RefreshControlPullType    refreshControlPullType;
@property (nonatomic, assign) RefreshControlState       refreshControlState;
@property (nonatomic, assign) RefreshControlStatusType  refreshControlStatusType;

// get super scroll view
@property (nonatomic, weak, readonly  ) UIScrollView *superScrollView;
// Dragging the vertical direction of the right value (Subclasses override)
@property (nonatomic, assign, readonly) CGFloat      properVerticalPullValue;
// Scroll view content exceeds the height control view (Subclasses override the)
@property (nonatomic, assign, readonly) CGFloat      scrollViewOverViewHeight;

@property (nonatomic, weak, readonly) UILabel *statusLabel;
@property (nonatomic, weak, readonly) Indicator *indicator;
@property (nonatomic, weak, readonly) Arrow *arrow;

// @"Pull down refresh"
@property (nonatomic, strong) NSString *pullToRefreshing;
// @"Loosen refresh"
@property (nonatomic, strong) NSString *pullReleaseToRefreshing;
// @"Refreshing"
@property (nonatomic, strong) NSString *pullRefreshing;
// @"Networking error"
@property (nonatomic, strong) NSString *refreshingFailureHintText;

// external call
- (void)startRefreshing;
- (void)stopRefreshing;
- (void)refreshFailureWithHintText:(NSString *)hintText;

// call back
@property (nonatomic, copy) void (^begainRefreshing)();
@property (nonatomic, copy) void (^endRefreshing)();
@property (nonatomic, copy) void (^touchUpInsideEvent)(RefreshControl *refreshControl);
// refresh agign
- (void)refreshingAgain;

@end

@interface TopRefreshControl : RefreshControl

@end

@interface BottomRefreshControl : RefreshControl

@end