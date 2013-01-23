//
//  MEPreferencesWindowController.h
//  StatusBarItem
//
//  Created by Andrey M on 08.01.13.
//  Copyright (c) 2013 Andrey M. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AFHTTPRequestOperation.h"
#import "SBJson.h"
#import "NSDictionary+URLEncoding.h"
#import "MEConstants.h"

@interface PreferencesWindowController : NSWindowController <NSWindowDelegate, NSTextFieldDelegate> {
    BOOL autodiscover;
    BOOL amAutoComplete;
    NSMutableArray *completionWords;
    SBJsonParser *_jsonParser;
}

@property (strong) IBOutlet NSWindow *preferencesWindow;

@property (weak) IBOutlet NSButton *locationDiscoverField;
@property (weak) IBOutlet NSTextField *locationField;
@property (weak) IBOutlet NSMatrix *unitsField;

@end
