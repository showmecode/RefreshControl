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
#define kPullControlHeight 64

#pragma mark - RefreshControl

@interface RefreshControl ()

@property (nonatomic, assign, getter = isDragging) BOOL dragging;
@property (nonatomic, assign) UIEdgeInsets scrollViewInsetRecord;
@property (nonatomic, assign) CGSize scrollViewContentSizeRecord;
@property (nonatomic, assign, getter = hasInitInset) BOOL initInset;

@end

@implementation RefreshControl
@synthesize statusLabel = _statusLabel;
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

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        UILabel *statusLabel = [UILabel new];
        statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        statusLabel.textColor = [UIColor lightGrayColor];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel = statusLabel;
        [self addSubview:_statusLabel];
    }
    
    return _statusLabel;
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
    
    self.statusLabel.bounds = self.bounds;
    self.statusLabel.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    
    self.loadingView.bounds = CGRectMake(0, 0, 30, 30);
    self.loadingView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
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
        NSLog(@"start refreshing contentOffset: %@", NSStringFromCGPoint(self.superScrollView.contentOffset));
        NSLog(@"start refreshing contentSize: %@", NSStringFromCGSize(self.superScrollView.contentSize));
        
        [UIView animateWithDuration:0.2 animations:^{
            UIEdgeInsets inset = self.superScrollView.contentInset;
            inset.top = self.scrollViewInsetRecord.top + kPullControlHeight;
            self.superScrollView.contentInset = inset;
            // Set the scroll position to stay
            self.superScrollView.contentOffset =
            CGPointMake(0, -self.scrollViewInsetRecord.top - kPullControlHeight);
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
        if (_scrollViewContentSizeRecord.height != self.superScrollView.contentSize.height) {
            animationDuration = 0.0f;
            CGFloat contentHeightAdded = self.superScrollView.contentOffset.y + self.superScrollView.contentSize.height - self.scrollViewContentSizeRecord.height;
            self.superScrollView.contentOffset = CGPointMake(self.superScrollView.contentOffset.x, contentHeightAdded);
        }
        [UIView animateWithDuration:animationDuration animations:^{
            UIEdgeInsets inset = self.superScrollView.contentInset;
            inset.top = self.scrollViewInsetRecord.top;
            self.superScrollView.contentInset = inset;
        }];
    } else {
        // Loading is complete, the content does not fill the entire screen, contentOffset accompanying animation back to zero
        CGPoint tempOffset = CGPointZero;
        NSTimeInterval animtionDuration = 0.2f;
        CGFloat screenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
        if (self.superScrollView.contentSize.height + kPullControlHeight > screenHeight) {
            tempOffset = self.superScrollView.contentOffset;
            animtionDuration = 0.0f;
        }
        
        // AnimtionDuration bottom of the screen when the content does not exceed! = 0
        UIEdgeInsets inset = self.superScrollView.contentInset;
        inset.bottom = self.scrollViewInsetRecord.bottom;
        [UIView animateWithDuration:animtionDuration animations:^{
            self.superScrollView.contentInset = inset;
        }];
        
        // Content exceeds the bottom of the screen, there are no rollback animation, direct load data, control `disappear`
        if (animtionDuration == 0.0f) {
            self.superScrollView.contentOffset = tempOffset;
        }
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
            self.loadingView.hidden = YES;
            [self.loadingView stopAnimation];
        }
            break;
        case RefreshControlStatePulling: {
            self.statusLabel.text = self.pullToRefreshing;
        }
            break;
        case RefreshControlStateOveredThreshold: {
            self.statusLabel.text = self.pullReleaseToRefreshing;
        }
            break;
        case RefreshControlStateRefreshing: {
            self.loadingView.hidden = NO;
            [self.loadingView startAnimation];
            self.statusLabel.text = nil;
        }
            break;
        default:
            break;
    }
}

@end

#pragma mark -
#pragma mark - TopRefreshControl

@implementation TopRefreshControl

- (instancetype)init {
    self = [super init];
    if (self) {
        self.refreshControlType      = RefreshControlTypeTop;
        self.pullToRefreshing        = @"Pull down refresh";
        self.pullReleaseToRefreshing = @"Loosen refresh";
        self.pullRefreshing          = @"Refreshing";
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
        self.pullToRefreshing        = @"Pull up load more";
        self.pullReleaseToRefreshing = @"Loosen refresh";
        self.pullRefreshing          = @"Refreshing";
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
