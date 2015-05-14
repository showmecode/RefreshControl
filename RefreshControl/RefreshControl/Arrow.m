//
//  Arrow.m
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

#ifdef LOG_DEALLOC
- (void)dealloc {
    NSLog(@"%s: %@", __FUNCTION__, self);
}
#endif

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
