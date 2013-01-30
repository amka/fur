//
//  METextEditor.m
//  Fur
//
//  Created by Andrey M on 23.01.13.
//  Copyright (c) 2013 Andrey M. All rights reserved.
//

#import "METextEditor.h"

@implementation METextEditor

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
    [super drawRect:dirtyRect];
    // Drawing code here.
}

- (void)insertCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag
{
    if (movement == NSRightTextMovement) return;
    
    // show full replacements
    if (charRange.location != 0) {
        charRange.length += charRange.location;
        charRange.location = 0;
    }

    @try {
        [super insertCompletion:[[word componentsSeparatedByString:@", "] objectAtIndex:0] forPartialWordRange:charRange movement:movement isFinal:flag];
    }
    @catch (NSException *exception) {
        [super insertCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
    }
}

@end
