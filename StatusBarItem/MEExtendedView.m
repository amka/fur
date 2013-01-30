//
//  MEExtendedView.m
//  Fur
//
//  Created by Andrey M on 29.01.13.
//  Copyright (c) 2013 Andrey M. All rights reserved.
//

#import "MEExtendedView.h"

@implementation MEExtendedView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSRect fullBounds = [self bounds];
    fullBounds.size.height += 4;
    [[NSBezierPath bezierPathWithRect:fullBounds] setClip];
    
    NSColor *patternColor = [NSColor colorWithPatternImage:[NSImage imageNamed:@"extendedViewBg.png"]];
    [patternColor setFill];
    NSRectFill(fullBounds);
}

@end
