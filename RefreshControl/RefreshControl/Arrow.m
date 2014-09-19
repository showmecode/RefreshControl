//
//  Arrow.m
//  DrawingArrow
//
//  Created by Moch on 9/18/14.
//  Copyright (c) 2014 Moch. All rights reserved.
//

#import "Arrow.h"

#pragma mark - UIBezierPath (Arrow)

@interface UIBezierPath (Arrow)
@end

#define kArrowPointCount 7
@implementation UIBezierPath (Arrow)
+ (UIBezierPath *)bezierPathWithArrowFromPoint:(CGPoint)startPoint
                                       toPoint:(CGPoint)endPoint
                                     tailWidth:(CGFloat)tailWidth
                                     headWidth:(CGFloat)headWidth
                                    headLength:(CGFloat)headLength {
    CGFloat length = hypotf(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    CGPoint points[kArrowPointCount];
    [self axisAlignedArrowPoints:points forLength:length tailWidth:tailWidth headWidth:headWidth headLength:headLength];
    CGAffineTransform transform = [self transformForStartPoint:startPoint
                                                      endPoint:endPoint
                                                        length:length];
    CGMutablePathRef cgPath = CGPathCreateMutable();
    CGPathAddLines(cgPath, &transform, points, sizeof points / sizeof *points);
    CGPathCloseSubpath(cgPath);
    UIBezierPath *uiPath = [UIBezierPath bezierPathWithCGPath:cgPath];
    CGPathRelease(cgPath);
    
    return uiPath;
}

+ (void)axisAlignedArrowPoints:(CGPoint[kArrowPointCount])points
                     forLength:(CGFloat)length
                     tailWidth:(CGFloat)tailWidth
                     headWidth:(CGFloat)headWidth
                    headLength:(CGFloat)headLength {
    CGFloat tailLength = length - headLength;
    points[0] = CGPointMake(0, tailWidth / 2);
    points[1] = CGPointMake(tailLength, tailWidth / 2);
    points[2] = CGPointMake(tailLength, headWidth / 2);
    points[3] = CGPointMake(length, 0);
    points[4] = CGPointMake(tailLength, -headWidth / 2);
    points[5] = CGPointMake(tailLength, -tailWidth / 2);
    points[6] = CGPointMake(0, -tailWidth / 2);
}

+ (CGAffineTransform)transformForStartPoint:(CGPoint)startPoint
                                   endPoint:(CGPoint)endPoint
                                     length:(CGFloat)length {
    CGFloat cosine = (endPoint.x - startPoint.x) / length;
    CGFloat sine = (endPoint.y - startPoint.y) / length;
    return (CGAffineTransform){ cosine, sine, -sine, cosine, startPoint.x, startPoint.y };
}
@end

#pragma mark - Arrow

@interface Arrow ()
@end

@implementation Arrow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.color = [UIColor lightGrayColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGPoint startPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds));
    CGFloat tailWidth = CGRectGetWidth(self.bounds) / 3;
    CGFloat headWidth = CGRectGetWidth(self.bounds) * 0.7;
    CGFloat headLength = CGRectGetHeight(self.bounds) / 2;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArrowFromPoint:startPoint
                                                            toPoint:endPoint
                                                          tailWidth:tailWidth
                                                          headWidth:headWidth
                                                         headLength:headLength];
    [self.color setFill];
    [bezierPath fill];
}

- (void)rotation {
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeRotation(M_PI);
    }];
}

- (void)identity {
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

@end
