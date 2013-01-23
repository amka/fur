//
//  MEAppDelegate.h
//  StatusBarItem
//
//  Created by Andrey M on 08.01.13.
//  Copyright (c) 2013 Andrey M. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#import "AFHTTPRequestOperation.h"
#import "SBJson.h"
#import "NSDictionary+URLEncoding.h"
#import "MEPreferencesWindowController.h"
#import "MEConstants.h"

@interface MEAppDelegate : NSObject <NSApplicationDelegate> {    
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightImage;
    
    NSTimer *weatherTimer;
    
    SBJsonParser *_jsonParser;
    NSString *_responseString;
    NSString *weatherUnit;
}

@property NSString *locationName;

@property (retain) PreferencesWindowController *preferencesController;
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *statusMenu;

- (IBAction)quit:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)refreshCondition:(id)sender;

- (void)notifyUserWithTitle:(NSString *)title informativeText:(NSString *)informativeText;
- (void)handleUrl:(NSURL *)url withBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success;
- (void)handleWeatherTimer:(NSTimer *)timer;
- (void)deduplicateRunningInstances;

- (void)addAppAsLoginItem;
- (void)removeAppFromLoginItems;
@end
