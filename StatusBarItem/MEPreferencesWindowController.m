//
//  MEPreferencesWindowController.m
//  StatusBarItem
//
//  Created by Andrey M on 08.01.13.
//  Copyright (c) 2013 Andrey M. All rights reserved.
//

#import "MEPreferencesWindowController.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] setValue:[_locationField stringValue] forKey:@"locationName"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"preferencesUpdated"];
}
@end
