//
//  RefreshControl.m
//  RefreshControl
//
//  Created by Moch on 8/26/14.
//  Copyright (c) 2014 Moch. All rights reserved.
//

#import "RefreshControl.h"
#import "LoadingView.h"

#define CHImageWithName(NAME) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NAME ofType:@"png"]]
#define kPullControlHeight 44

#pragma mark - RefreshControl

@interface RefreshControl ()

@property (nonatomic, assign, getter = isDragging) BOOL dragging;
@property (nonatomic, assign) UIEdgeInsets scrollViewInsetRecord;
@property (nonatomic, assign) CGSize scrollViewContentSizeRecord;
@property (nonatomic, assign, getter = hasInitInset) BOOL initInset;

@end

@implementation RefreshControl
@synthesize statusButton = _statusButton;
@synthesize loadingView = _loadingView;

#pragma mark -
#pragma mark - RefreshControl

- (id)init {
    self = [super init];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    return self;
}

- (UIButton *)statusButton {
    if (!_statusButton) {
        UIButton *statusButton = [UIButton new];
        statusButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        statusButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        statusButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [statusButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [statusButton addTarget:self action:@selector(handleStatusButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _statusButton = statusButton;
        [self addSubview:_statusButton];
    }
    
    return _statusButton;
}

- (void)handleStatusButtonPressed:(UIButton *)sender {
    // recover refreshing status
    self.loadingView.hidden = NO;
    [self.loadingView startAnimation];
    [self.statusButton setTitle:nil forState:UIControlStateNormal];
    
    if (_begainRefreshing) {
        _begainRefreshing();
    }
}

- (LoadingView *)loadingView {
    if (!_loadingView) {
        LoadingView *loadingView = [LoadingView new];
        loadingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _loadingView = loadingView;
        [self addSubview:loadingView];
    }
    
    return _loadingView;
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
}

// setting self and sub controls frame
- (void)settingFrames {
    if (!self.superScrollView) {
        return;
    }
    
    self.statusButton.bounds = self.bounds;
    self.statusButton.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    self.loadingView.bounds = CGRectMake(0, 0, 20, 20);
    self.loadingView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
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
    //    NSLog(@"contentOffSetVerticalValue = %f", contentOffSetVerticalValue);
    CGFloat properVerticalPullValue = [self properVerticalPullValue];
    
    if (contentOffSetVerticalValue <=  properVerticalPullValue) {
        return;
    }
    if(self.refreshControlState == RefreshControlStateRefreshing) {
        return;
    }
    
    CGFloat properContentOffsetVerticalValue = properVerticalPullValue + kPullControlHeight;
    
    if (contentOffSetVerticalValue <= properContentOffsetVerticalValue) {
        // Being dragged, but not to the critical point
        self.refreshControlState = RefreshControlStatePulling;
    } else if (contentOffSetVerticalValue > properContentOffsetVerticalValue) {
        // Above the critical point (arrow reverse, change prompt text), let go will execute Action (display chrysanthemums, change prompt text)
        self.refreshControlState = RefreshControlStateOveredThreshold;
    } else {
        // Drag the opposite direction, did not come
        self.refreshControlState = RefreshControlStateHidden;
    }
}

// super scroll view already stop pulling, will decelerate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(self.refreshControlState == RefreshControlStateRefreshing) {
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
            [self.loadingView stopAnimation];
            self.loadingView.hidden = YES;
        }
            break;
        case RefreshControlStatePulling: {
            [self.statusButton setTitle:self.pullToRefreshing forState:UIControlStateNormal];
        }
            break;
        case RefreshControlStateOveredThreshold: {
            [self.statusButton setTitle:self.pullReleaseToRefreshing forState:UIControlStateNormal];
        }
            break;
        case RefreshControlStateRefreshing: {
            self.loadingView.hidden = NO;
            [self.loadingView startAnimation];
            [self.statusButton setTitle:nil forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (void)refreshFailureWithHintText:(NSString *)hintText {
    [self.loadingView stopAnimation];
    self.loadingView.hidden = YES;
    
    NSString *hint = hintText ? : self.refreshingFailureHintText;
    [self.statusButton setTitle:hint forState:UIControlStateNormal];
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
    
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    self.frame = CGRectMake(0, -kPullControlHeight, width, kPullControlHeight);
    
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
