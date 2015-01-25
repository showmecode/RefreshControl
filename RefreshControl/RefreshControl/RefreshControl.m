//
//  RefreshControl.m
//  RefreshControl
//
//  Created by Moch Xiao on 2014-12-25.
//	Copyright (c) 2014 Moch Xiao (htt://github.com/atcuan).
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

#import "RefreshControl.h"
#import "Indicator.h"
#import "Arrow.h"

#define CHImageWithName(NAME) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NAME ofType:@"png"]]
#define kPullControlHeight 44

#pragma mark - RefreshControl

@interface RefreshControl ()

@property (nonatomic, assign, getter = isDragging) BOOL dragging;
@property (nonatomic, assign) UIEdgeInsets scrollViewInsetRecord;
@property (nonatomic, assign) CGSize scrollViewContentSizeRecord;
@property (nonatomic, assign, getter = hasInitInset) BOOL initInset;
@property (nonatomic, assign, getter = isRefreshFailure) BOOL refreshFailure;

@end

@implementation RefreshControl
@synthesize statusLabel = _statusLabel;
@synthesize indicator = _indicator;
@synthesize arrow = _arrow;

#pragma mark -
#pragma mark - RefreshControl

- (void)dealloc {
    //    NSLog(@"%s", __func__);
}

- (id)init {
    self = [super init];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.refreshControlStatusType = RefreshControlStatusTypeTextAndArrow;
        self.userInteractionEnabled = NO;
        [self addTarget:self action:@selector(handleTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)handleTouchEvent:(RefreshControl *)refreshControl {
    if (_touchUpInsideEvent) {
        _touchUpInsideEvent(self);
    } else {
        [self resumeRefreshing];
    }
}

- (void)resumeRefreshing {
    // recover refreshing status
    self.indicator.hidden = NO;
    [self.indicator startAnimation];
    self.statusLabel.text = nil;
    
    if (_begainRefreshing) {
        _begainRefreshing();
    }
    self.userInteractionEnabled = NO;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        UILabel *statusLabel = [UILabel new];
        statusLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        statusLabel.textColor = [UIColor lightGrayColor];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel = statusLabel;
        [self addSubview:_statusLabel];
    }
    
    return _statusLabel;
}

- (Indicator *)indicator {
    if (!_indicator) {
        Indicator *indicator = [Indicator new];
        indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        indicator.hidden = YES;
        _indicator = indicator;
        [self addSubview:indicator];
    }
    
    return _indicator;
}

- (Arrow *)arrow {
    if (!_arrow) {
        Arrow *arrow = [Arrow new];
        arrow.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _arrow = arrow;
        [self addSubview:arrow];
    }
    return _arrow;
}

// add refresh control to super scroll view, when init and dealloc call
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    
    // add Observer for top refresh control
    if (!newSuperview) {
        return;
    }
    if([newSuperview isKindOfClass:[UIScrollView class]]) {
        // retain super scroll view !!!!!!
        _superScrollView = (UIScrollView *)newSuperview;
        [newSuperview addObserver:self
                       forKeyPath:@"contentOffset"
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self settingFrames];
    
    // only need seting once
    [self settingStatusType];
}

- (void)settingStatusType {
    if (self.refreshControlStatusType == RefreshControlStatusTypeText) {
        return;
    } else if (self.refreshControlStatusType == RefreshControlStatusTypeArrow) {
        self.pullToRefreshing        = @"";
        self.pullReleaseToRefreshing = @"";
        self.pullRefreshing          = @"";
        [self settingArrowFrames];
    } else {
        [self settingArrowFrames];
    }
}

- (void)settingArrowFrames {
    self.arrow.bounds = CGRectMake(0, 0, 20, 20);
    self.arrow.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGFloat statusTextMaxBoundingLength = [self statusTextMaxBoundingLength];
    if (statusTextMaxBoundingLength > 0) {
        CGFloat centerX = self.arrow.center.x - statusTextMaxBoundingLength / 2 - 20;
        self.arrow.center = CGPointMake(centerX, self.arrow.center.y);
    }
}

- (CGFloat)statusTextMaxBoundingLength {
    // static is import, this message will called twice when initial with both Top and Bottom RefreshControl
    CGFloat maxBoundingLength = 0.0f;
    NSArray *strings = @[self.pullRefreshing, self.pullReleaseToRefreshing, self.pullToRefreshing];
    for (NSString *string in strings) {
        CGFloat length = [self statusButtonTitleBoundingLengthForText:string];
        if (length > maxBoundingLength) {
            maxBoundingLength = length;
        }
    }
    
    return maxBoundingLength;
}

- (CGFloat)statusButtonTitleBoundingLengthForText:(NSString *)text {
    CGSize boundingRectWithSize = CGSizeMake(CGRectGetWidth(self.statusLabel.bounds),
                                             CGRectGetHeight(self.statusLabel.bounds));
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine |
    NSStringDrawingUsesFontLeading |
    NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *attributes = @{NSFontAttributeName:self.statusLabel.font};
    CGFloat length = [text boundingRectWithSize:boundingRectWithSize
                                        options:options
                                     attributes:attributes
                                        context:nil].size.width;
    return length;
}

// setting self and sub controls frame
- (void)settingFrames {
    if (!self.superScrollView) {
        return;
    }
    
    self.statusLabel.bounds = self.bounds;
    self.statusLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    self.indicator.bounds = CGRectMake(0, 0, 20, 20);
    self.indicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.hasInitInset) {
        _scrollViewInsetRecord = self.superScrollView.contentInset;
        _initInset = YES;
    }
}

#pragma mark - observeing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if(![keyPath isEqualToString:@"contentOffset"]) {
        return;
    }
    
    UIScrollView *scrollView = (UIScrollView *)object;
    if(_dragging != scrollView.isDragging) {
        if(!scrollView.isDragging) {
            [self scrollViewDidEndDragging:scrollView willDecelerate:NO];
        }
        
        _dragging = scrollView.isDragging;
    }
    [self scrollViewDidScroll:scrollView];
}

#pragma mark - scrollview delegate messages

// super scroll view just begain pulling
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffSetVerticalValue = scrollView.contentOffset.y * self.refreshControlType;
    
    // when initial, this called 3 times, first = 0, others = 64
    CGFloat properVerticalPullValue = [self properVerticalPullValue];
    
    //    NSLog(@"contentOffSetVerticalValue = %f", contentOffSetVerticalValue);
    
    // "<" is import, can not use "<=", when initial, "<" will let control flow continue, at last
    // refreshControlState = RefreshControlStateHidden, if use "<=", refreshControlState = RefreshControlStateOveredThreshold
    // will casue bug which is in TopRefreshControl first time pull up will refreshing...
    if (contentOffSetVerticalValue <  properVerticalPullValue) {
        return;
    }
    if(self.refreshControlState == RefreshControlStateRefreshing) {
        return;
    }
    
    CGFloat properContentOffsetVerticalValue = properVerticalPullValue + kPullControlHeight;
    
    //    NSLog(@"properContentOffsetVerticalValue = %f", properContentOffsetVerticalValue);
    
    if (contentOffSetVerticalValue <= properContentOffsetVerticalValue) {
        // Being dragged, but not to the critical point
        self.refreshControlState = RefreshControlStatePulling;
    } else if (contentOffSetVerticalValue > properContentOffsetVerticalValue) {
        // Above the critical point (arrow reverse, change prompt text), let go will execute Action (display chrysanthemums, change prompt text)
        self.refreshControlState = RefreshControlStateOveredThreshold;
    } else {
        // Drag the opposite direction, initial time will come here
        self.refreshControlState = RefreshControlStateHidden;
    }
}

// super scroll view already stop pulling, will decelerate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(self.refreshControlState == RefreshControlStateRefreshing) {
        if (self.isRefreshFailure) {
            [self resumeRefreshing];
            _refreshFailure = NO;
        }
        return;
    }
    
    if (self.refreshControlState == RefreshControlStateOveredThreshold) {
        _scrollViewInsetRecord = scrollView.contentInset;
        self.refreshControlState = RefreshControlStateRefreshing;
        [self startRefreshing];
    }
}

- (void)startRefreshing {
    // Controls to scroll to the appropriate location to stay
    if (self.refreshControlType == RefreshControlTypeTop) {
        _scrollViewContentSizeRecord = self.superScrollView.contentSize;
        //        NSLog(@"start refreshing contentOffset: %@", NSStringFromCGPoint(self.superScrollView.contentOffset));
        //        NSLog(@"start refreshing contentSize: %@", NSStringFromCGSize(self.superScrollView.contentSize));
        
        [UIView animateWithDuration:0.2 animations:^{
            UIEdgeInsets inset = self.superScrollView.contentInset;
            inset.top = self.scrollViewInsetRecord.top + kPullControlHeight;
            self.superScrollView.contentInset = inset;
            // Set the scroll position to stay
            self.superScrollView.contentOffset = CGPointMake(0, -self.scrollViewInsetRecord.top - kPullControlHeight);
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            UIEdgeInsets inset = self.superScrollView.contentInset;
            CGFloat bottom = self.scrollViewInsetRecord.bottom + kPullControlHeight;
            CGFloat overHeight = [self scrollViewOverViewHeight];
            if (overHeight < 0) {
                bottom -= overHeight;
            }
            inset.bottom = bottom;
            // Set the scroll position to stay
            self.superScrollView.contentInset = inset;
        }];
    }
    if (_begainRefreshing) {
        _begainRefreshing();
    }
}

- (void)stopRefreshing {
    if (self.refreshControlType == RefreshControlTypeTop) {
        // Drop-down control, rolled over just can not see the parent view of the head position (reduction inset)
        NSTimeInterval animationDuration = 0.2f;
        CGFloat contentHeightAdded = self.superScrollView.contentOffset.y + self.superScrollView.contentSize.height - self.scrollViewContentSizeRecord.height;
        if (_scrollViewContentSizeRecord.height != self.superScrollView.contentSize.height) {
            animationDuration = 0.0f;
            self.superScrollView.contentOffset = CGPointMake(self.superScrollView.contentOffset.x, contentHeightAdded);
        }
        
        UIEdgeInsets inset = self.superScrollView.contentInset;
        inset.top = self.scrollViewInsetRecord.top;
        [UIView animateWithDuration:animationDuration animations:^{
            self.superScrollView.contentInset = inset;
        }];
    } else {
        // Loading is complete, the content does not fill the entire screen, contentOffset accompanying animation back to zero
        NSTimeInterval animtionDuration = 0.2f;
        CGFloat screenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
        if (self.superScrollView.contentSize.height + kPullControlHeight > screenHeight) {
            animtionDuration = 0.0f;
        }
        
        // AnimtionDuration bottom of the screen when the content does not exceed! = 0
        UIEdgeInsets inset = self.superScrollView.contentInset;
        inset.bottom = self.scrollViewInsetRecord.bottom;
        [UIView animateWithDuration:animtionDuration animations:^{
            self.superScrollView.contentInset = inset;
        }];
    }
    self.refreshControlState = RefreshControlStateHidden;
    if (_endRefreshing) {
        _endRefreshing();
    }
}

- (void)setRefreshControlState:(RefreshControlState)refreshControlState {
    if (_refreshControlState == refreshControlState) {
        return;
    }
    _refreshControlState = refreshControlState;
    
    switch(refreshControlState) {
        case RefreshControlStateHidden: {
            [self.indicator stopAnimation];
            self.indicator.hidden = YES;
            self.arrow.hidden = NO;
        }
            break;
        case RefreshControlStatePulling: {
            self.statusLabel.text = self.pullToRefreshing;
            if (self.refreshControlType == RefreshControlTypeTop) {
                [self.arrow rotation];
            } else {
                [self.arrow identity];
            }
        }
            break;
        case RefreshControlStateOveredThreshold: {
            self.statusLabel.text = self.pullReleaseToRefreshing;
            if (self.refreshControlType == RefreshControlTypeTop) {
                [self.arrow identity];
            } else {
                [self.arrow rotation];
            }
        }
            break;
        case RefreshControlStateRefreshing: {
            self.indicator.hidden = NO;
            [self.indicator startAnimation];
            self.statusLabel.text = nil;
            self.arrow.hidden = YES;
        }
            break;
        default:
            break;
    }
}

- (void)refreshFailureWithHintText:(NSString *)hintText {
    _refreshFailure = YES;
    self.userInteractionEnabled = YES;
    [self.indicator stopAnimation];
    self.indicator.hidden = YES;
    
    NSString *hint = hintText ? : self.refreshingFailureHintText;
    self.statusLabel.text = hint;
}

@end

#pragma mark -
#pragma mark - TopRefreshControl

@implementation TopRefreshControl

- (instancetype)init {
    self = [super init];
    if (self) {
        self.refreshControlType      = RefreshControlTypeTop;
        self.pullToRefreshing        = @"下拉刷新";
        self.pullReleaseToRefreshing = @"松开刷新";
        self.pullRefreshing          = @"刷新中...";
        self.refreshingFailureHintText = @"刷新失败，请点击重新刷新！";
    }
    return self;
}

// Dragging the vertical direction of the right value
- (CGFloat)properVerticalPullValue {
    return self.refreshControlPullType == RefreshControlPullTypeInsensitive ? self.superScrollView.contentInset.top : 0.0f;
}

- (void)settingFrames {
    if (!self.superScrollView) {
        return;
    }
    
    self.frame = CGRectMake(0, -kPullControlHeight, CGRectGetWidth(self.superScrollView.bounds), kPullControlHeight);
    
    [super settingFrames];
}

@end

#pragma mark -
#pragma mark - BottomRefreshControl

@implementation BottomRefreshControl

- (instancetype)init {
    self = [super init];
    if (self) {
        self.refreshControlType      = RefreshControlTypeBottom;
        self.pullToRefreshing        = @"上拉加载更多";
        self.pullReleaseToRefreshing = @"松开加载";
        self.pullRefreshing          = @"加载中...";
        self.refreshingFailureHintText = @"加载失败，请点击重新加载！";
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    [self.superview removeObserver:self forKeyPath:@"contentSize"];
    
    if (!newSuperview) {
        return;
    }
    if([newSuperview isKindOfClass:[UIScrollView class]]) {
        [newSuperview addObserver:self
                       forKeyPath:@"contentSize"
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
    }
}

- (void)settingFrames {
    if (!self.superScrollView) {
        return;
    }
    CGFloat contentHeight    = self.superScrollView.contentSize.height;
    CGFloat insetHeight      = self.scrollViewInsetRecord.top + self.scrollViewInsetRecord.bottom;
    CGFloat scrollViewHeight = CGRectGetHeight(self.superScrollView.frame) - insetHeight;
    CGFloat y                = MAX(contentHeight, scrollViewHeight);
    self.frame               = CGRectMake(0, y, CGRectGetWidth(self.superScrollView.frame), kPullControlHeight);
    
    [super settingFrames];
}

- (CGFloat)scrollViewOverViewHeight {
    CGFloat insetHeight = self.scrollViewInsetRecord.top + self.scrollViewInsetRecord.bottom;
    CGFloat height = CGRectGetHeight(self.superScrollView.frame) - insetHeight;
    return self.superScrollView.contentSize.height - height;
}

- (CGFloat)properVerticalPullValue {
    CGFloat overHeight = [self scrollViewOverViewHeight];
    CGFloat result = self.scrollViewInsetRecord.top;
    if (overHeight > 0) {
        CGFloat adjustHeight = self.refreshControlPullType == RefreshControlPullTypeInsensitive ? 0 : kPullControlHeight;
        return overHeight - result - adjustHeight;
    } else {
        return -result;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    [self settingFrames];
}

@end
