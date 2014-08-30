//
//  LoadingView.h
//  GettingStarted
//
//  Created by Moch on 8/29/14.
//  Copyright (c) 2014 Moch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, readonly, getter = isAnimating) BOOL animating;

- (void)startAnimation;
- (void)stopAnimation;

@end
