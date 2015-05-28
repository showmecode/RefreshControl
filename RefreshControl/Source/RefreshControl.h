//
//  RefreshControl.h
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

@property (nonatomic, strong, readonly) UILabel *statusLabel;
@property (nonatomic, strong, readonly) Indicator *indicator;
@property (nonatomic, strong, readonly) Arrow *arrow;

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
- (void)stopRefreshingWithHintText:(NSString *)hintText;
- (void)refreshFailureWithHintText:(NSString *)hintText;

// call back
@property (nonatomic, copy) void (^begainRefreshing)();
@property (nonatomic, copy) void (^endRefreshing)();
@property (nonatomic, copy) void (^touchUpInsideEvent)(RefreshControl *refreshControl);
// resume refreshing state
- (void)resumeRefreshing;

// TopRefreshControl override
- (void)removeBackgroundView;


@end

@interface TopRefreshControl : RefreshControl

@property (nonatomic, strong) UIView *backgroundView;

@end

@interface BottomRefreshControl : RefreshControl

@end