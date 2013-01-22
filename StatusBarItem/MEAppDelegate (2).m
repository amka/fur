//
//  MEAppDelegate.m
//  StatusBarItem
//
//  Created by Andrey M on 08.01.13.
//  Copyright (c) 2013 Andrey M. All rights reserved.
//

#import "MEAppDelegate.h"

@implementation MEAppDelegate

- (id)init {
    if (self = [super init]) {
//        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                                 NO, @"unitC",
//                                                                 YES, @"unitF",
//                                                                 NO, @"autodiscover",
//                                                                 @"", @"locationName"
//                                                                 nil]];
        

    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSStatusBar * systemStatusBar = [NSStatusBar systemStatusBar];
    statusItem = [systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    
    [statusItem setTitle:NSLocalizedString(@"…",@"")];
    [statusItem setHighlightMode:YES];
    [statusItem setImage:[NSImage imageNamed:@"Status.png"]];
    [statusItem setAlternateImage:[NSImage imageNamed:@"StatusHighlighted.png"]];
    // Insert code here to initialize your application
    [statusItem setMenu:_statusMenu];
}

- (void)showPreferencesWindow:(id)sender
{
    if(!_preferencesController)
        _preferencesController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
    
    [_preferencesController showWindow:self];
}

- (void)quit:(id)sender
{
    [NSApp terminate:self];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)notifyUserWithTitle:(NSString *)title informativeText:(NSString *)informativeText
{
    NSUserNotification *notification = [NSUserNotification new];
    [notification setTitle:title];
    [notification setInformativeText:informativeText];
    [notification setSoundName:NSUserNotificationDefaultSoundName];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}


- (void)handleUrl:(NSURL *)url withBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:success failure:nil];
    //    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:nil];
    [operation start];
}

@end
