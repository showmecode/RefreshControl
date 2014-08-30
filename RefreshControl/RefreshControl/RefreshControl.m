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
@property (nonatomic, assign, getter = hasInitInset) BOOL initInset;

@end

@implementation RefreshControl
@synthesize statusLabel = _statusLabel;
@synthesize loadingView = _loadingView;
//@synthesize superScrollView = _superScrollView;

#pragma mark -
#pragma mark - override super messages

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
    return [super respondsToSelector:aSelector];
}

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
    if(self.superScrollView) {
        [self.superScrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
    
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
    
    if (!self.initInset) {
        _scrollViewInsetRecord = [self superScrollView].contentInset;
        _initInset = YES;

        [self observeValueForKeyPath:@"contentSize"
                            ofObject:nil
                              change:nil
                             context:nil];
#pragma mark - TODO del ?
        if (self.refreshControlState == RefreshControlStateRefreshing) {
            self.refreshControlState = RefreshControlStateRefreshing;
        }
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
        // 正在拖动，但是还没有到临界点
        self.refreshControlState = RefreshControlStatePulling;
    } else if (contentOffSetVerticalValue > properContentOffsetVerticalValue) {
        // 超过临界点(箭头反向、改变提示文字)，松手会执行Action(显示菊花，改变提示文字)
        self.refreshControlState = RefreshControlStateOveredThreshold;
    } else {
        // 反方向拖动、根本进不来
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
    // 控件滚动到合适位置停留
    if (self.refreshControlType == RefreshControlTypeTop) {
        // 下拉控件
        [UIView animateWithDuration:0.2 animations:^{
            UIEdgeInsets inset = [self superScrollView].contentInset;
            inset.top = self.scrollViewInsetRecord.top + kPullControlHeight;
            [self superScrollView].contentInset = inset;
            // 设置滚动停留的位置
            [self superScrollView].contentOffset =
            CGPointMake(0, -self.scrollViewInsetRecord.top - kPullControlHeight);
        }];
    } else {
        // 上拉控件
        [UIView animateWithDuration:0.2 animations:^{
            UIEdgeInsets inset = [self superScrollView].contentInset;
            CGFloat bottom = self.scrollViewInsetRecord.bottom + kPullControlHeight;
            CGFloat overHeight = [self scrollViewOverViewHeight];
            if (overHeight < 0) {
                bottom -= overHeight;
            }
            inset.bottom = bottom;
            // 设置滚动停留的位置
            [self superScrollView].contentInset = inset;
        }];
    }
    
    if (_begainRefreshing) {
        _begainRefreshing();
    }
}

- (void)stopRefreshing {
    // 事务执行完成
    if (self.refreshControlType == RefreshControlTypeTop) {
        // 下拉控件，滚到父视图头部以上刚好看不见位置(还原inset)
        UIEdgeInsets inset = [self superScrollView].contentInset;
        inset.top = self.scrollViewInsetRecord.top;
        [UIView animateWithDuration:0.2 animations:^{
            [self superScrollView].contentInset = inset;
        }];
    } else {
        // 加载完成，内容没有占满整屏，contentOffset伴随动画回到zero
        CGPoint tempOffset = CGPointZero;
        CGFloat animtionDuration = 0.2;
        CGFloat screenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
        if ([self superScrollView].contentSize.height + kPullControlHeight > screenHeight) {
            tempOffset = [self superScrollView].contentOffset;
            animtionDuration = 0;
        }
        
        // 内容未超过屏幕底端时animtionDuration != 0
        [UIView animateWithDuration:animtionDuration animations:^{
            UIEdgeInsets inset = [self superScrollView].contentInset;
            inset.bottom = self.scrollViewInsetRecord.bottom;
            [self superScrollView].contentInset = inset;
        }];
        
        // 内容超过屏幕底端，不出现回滚动画，直接加载数据，控件`消失`
        if (animtionDuration == 0) {
            [self superScrollView].contentOffset = tempOffset;
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

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
    return [super respondsToSelector:aSelector];
}

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

// 合适的垂直方向拖动的值
- (CGFloat)properVerticalPullValue {
    return self.refreshControlPullType == RefreshControlPullTypeOldFashion ? self.superScrollView.contentInset.top : 0.0f;
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

#pragma mark - BottomRefreshControl

@implementation BottomRefreshControl

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [self.superScrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
    return [super respondsToSelector:aSelector];
}

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
    if (!newSuperview) {
        return;
    }
    if(self.superScrollView) {
        [self.superScrollView removeObserver:self forKeyPath:@"contentSize"];
    }
    if([newSuperview isKindOfClass:[UIScrollView class]]) {
        [newSuperview addObserver:self
                       forKeyPath:@"contentSize"
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
    }
    
    [super willMoveToSuperview:newSuperview];
    NSLog(@"self.superScrollView: %@", self.superScrollView);
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
        CGFloat adjustHeight = self.refreshControlPullType == RefreshControlPullTypeOldFashion ? 0 : kPullControlHeight;
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
