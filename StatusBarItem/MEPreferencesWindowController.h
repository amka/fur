//
//  MEPreferencesWindowController.h
//  StatusBarItem
//
//  Created by Andrey M on 08.01.13.
//  Copyright (c) 2013 Andrey M. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController <NSWindowDelegate> {
    BOOL autodiscover;
}

@property (strong) IBOutlet NSWindow *preferencesWindow;

@property (weak) IBOutlet NSButton *locationDiscoverField;
@property (weak) IBOutlet NSTextField *locationField;
@property (weak) IBOutlet NSMatrix *unitsField;



@end
