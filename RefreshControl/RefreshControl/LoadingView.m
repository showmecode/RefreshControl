//
//  LoadingView.m
//  GettingStarted
//
//  Created by Moch on 8/29/14.
//  Copyright (c) 2014 Moch. All rights reserved.
//

#import "LoadingView.h"

#define CHRadian(x) (2 * M_PI / 360 * x)

@interface LoadingView ()

@property (nonatomic, assign) CGFloat radian;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    CGFloat lengthOfSide = MIN(width, height);
    CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, lengthOfSide, lengthOfSide);
    self = [super initWithFrame:newFrame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = lengthOfSide / 2;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)setBounds:(CGRect)bounds {
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = CGRectGetHeight(bounds);
    CGFloat lengthOfSide = MIN(width, height);
    CGRect newBounds = CGRectMake(0, 0, lengthOfSide, lengthOfSide);
    self.layer.cornerRadius = lengthOfSide / 2;
    self.layer.masksToBounds = YES;
    
    [super setBounds:newBounds];
}

- (void)drawRect:(CGRect)rect {
    if (self.radian <= 0) {
        _radian = 0;
    }
    
    CGFloat lineWidth = 1.0f;
    UIColor *lineColor = [UIColor lightGrayColor];
    if (self.lineWidth) {
        lineWidth = self.lineWidth;
    }
    if (self.lineColor) {
        lineColor = self.lineColor;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRetain(context);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextAddArc(context,
                    CGRectGetMidX(self.bounds),
                    CGRectGetMidY(self.bounds),
                    CGRectGetWidth(self.bounds) / 2 - lineWidth,
                    CHRadian(120),
                    CHRadian(120) + CHRadian(330) * self.radian,
                    0);
    CGContextStrokePath(context);
    CGContextRelease(context);
}

- (void)setRadian:(CGFloat)radian {
    _radian = radian;
    [self setNeedsDisplay];
}

- (void)startAnimation {
    if (self.isAnimating) {
        [self stopAnimation];
        [self.layer removeAllAnimations];
    }
    _animating = YES;
    
    self.radian = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02f
                                                  target:self
                                                selector:@selector(drawPathAnimation:)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)drawPathAnimation:(NSTimer *)timer {
    self.radian += 0.03f;
    
    if (self.radian >= 1) {
        self.radian = 1;
        [timer invalidate];
        self.timer = nil;
        [self startRotateAnimation];
    }
}

- (void)startRotateAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(0);
    animation.toValue = @(2 * M_PI);
    animation.duration = 1.0f;
    animation.repeatCount = HUGE_VAL;
    animation.removedOnCompletion = YES;
    [self.layer addAnimation:animation forKey:@"keyFrameAnimation"];
}

- (void)stopAnimation {
    _animating = NO;
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self stopRotateAnimation];
}

- (void)stopRotateAnimation {
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.radian = 0;
        [self.layer removeAllAnimations];
        self.alpha = 1;
    }];
}

@end
