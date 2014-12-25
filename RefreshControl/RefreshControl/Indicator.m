//
//  LoadingView.m
//  GettingStarted
//
//  Created by Moch on 8/29/14.
//  Copyright (c) 2014 Moch. All rights reserved.
//

#import "Indicator.h"

#define CHRadian(x) (M_PI * (x) / 180.0f)

@interface Indicator ()

@property (nonatomic, assign) BOOL resetAnimation;
@property (nonatomic, readwrite, getter = isAnimating) BOOL animating;
@property (nonatomic, assign, getter = isInitializeTime) BOOL initializeTime;

@end

@implementation Indicator

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	if (!newSuperview) {
		self.resetAnimation = NO;
		[self stopRotateAnimation];
	}
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
	[super willMoveToWindow:newWindow];
	
	if (self.isInitializeTime) {
		self.initializeTime = NO;
		return;
	}
	
	if (newWindow) {
		[self startAnimation];
	} else {
		self.resetAnimation = NO;
		[self stopAnimation];
	}
}

- (instancetype)init {
	return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
	CGFloat width = CGRectGetWidth(frame);
	CGFloat height = CGRectGetHeight(frame);
	CGFloat lengthOfSide = MIN(width, height);
	CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, lengthOfSide, lengthOfSide);
	self = [super initWithFrame:newFrame];
	if (self) {
		self.layer.cornerRadius = lengthOfSide / 2;
		self.backgroundColor = [UIColor clearColor];
		self.layer.masksToBounds = YES;
		
		self.resetAnimation = YES;
		self.initializeTime = YES;
	}
	return self;
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
					CHRadian(260),
					CHRadian(-80),
					YES);
	CGContextStrokePath(context);
	CGContextRelease(context);
}

- (void)startAnimation {
	if (self.isAnimating) {
		return;
	}
	
	[self startRotateAnimation];
	
	self.animating = YES;
}

- (void)startRotateAnimation {
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = @(0);
	animation.toValue = @(2 * M_PI);
	animation.duration = 0.6f;
	animation.repeatCount = HUGE_VAL;
	animation.removedOnCompletion = YES;
	animation.delegate = self;
	[self.layer addAnimation:animation forKey:@"RotateAnimation"];
}

- (void)stopAnimation {
	if (!self.animating) {
		return;
	}
	
	[self stopRotateAnimation];
	
	self.animating = NO;
}

- (void)stopRotateAnimation {
	[UIView animateWithDuration:0.3f animations:^{
		self.alpha = 0;
	} completion:^(BOOL finished) {
		[self.layer removeAllAnimations];
		self.alpha = 1;
	}];
}

// animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	if (!self.animating) {
		return;
	}
	
	if (!flag && self.resetAnimation) {
		[self startRotateAnimation];
	}
}


@end