//
//  ASCircularOverlayView.m
//
//  Created by André Silva on 06/06/13.
//

#import "ASCircularOverlayView.h"

@implementation ASCircularOverlayView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
        
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, [UIColor blackColor].CGColor);
    CGContextFillEllipseInRect(contextRef, self.bounds);
}

@end
