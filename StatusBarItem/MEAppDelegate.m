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
        _jsonParser = [[SBJsonParser alloc] init];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Check duplicate instances
    [self deduplicateRunningInstances];
    
    // Check for locationName in user defaults
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"locationName"])
    {
        weatherTimer = [NSTimer scheduledTimerWithTimeInterval:kWWOUpdateInterval
                                                        target:self
                                                      selector:@selector(handleWeatherTimer:)
                                                      userInfo:nil
                                                       repeats:YES];
        [self handleWeatherTimer:weatherTimer];
    } else {
        [self showPreferencesWindow:self];
    }
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"units"] == 0)
    {
        weatherUnit = @"C";
    } else {
        weatherUnit = @"F";
    }

    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"preferencesUpdated"
                                               options:NSKeyValueObservingOptionNew
                                               context:NULL];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"locationName"
                                               options:NSKeyValueObservingOptionNew
                                               context:NULL];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"launchAtLogin"
                                               options:NSKeyValueObservingOptionNew
                                               context:NULL];
    
    NSStatusBar * systemStatusBar = [NSStatusBar systemStatusBar];
    statusItem = [systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    
    [statusItem setTitle:@"N/A"];
    [statusItem setHighlightMode:YES];
    [statusItem setImage:[NSImage imageNamed:@"23.png"]];
    [statusItem setAlternateImage:[NSImage imageNamed:@"23.png"]];
    // Insert code here to initialize your application
    [statusItem setMenu:_statusMenu];
}

- (void)showPreferencesWindow:(id)sender
{
    if(!_preferencesController)
        _preferencesController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
    
    [_preferencesController showWindow:self];
}

- (IBAction)refreshCondition:(id)sender {
    [weatherTimer fire];
}

- (IBAction)shareCondition:(id)sender {

    NSString *conditionString = [NSString stringWithFormat:@"In %@ currently is %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"locationName"], [statusItem title]];
    
    NSSharingService *twitterSharingService = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    [twitterSharingService performWithItems:[NSArray arrayWithObject:conditionString]];
}

- (void)quit:(id)sender
{
    [NSApp terminate:self];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    // remove observers
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"preferencesUpdated"];
    [weatherTimer invalidate];
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

// Send request to worldweatheronline.com to find out current condition
- (void)handleWeatherTimer:(NSTimer *)timer
{
    NSLog(@"Updating weather…");
    NSDictionary *urlParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               [[NSUserDefaults standardUserDefaults] stringForKey:@"locationName"], @"q",
                               kWWOFormat, @"format",
                               kWWOKey, @"key",
                               nil];
    
    NSURL *wwoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?%@",
                                          kWWOBaseUrl,
                                          kWWOWeatherPath,
                                          [urlParams urlEncodedString]]];
    
    [self handleUrl:wwoUrl
          withBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
              _responseString = [operation responseString];
              
              id json = [_jsonParser objectWithString:_responseString];
              NSDictionary *condition = [[json objectForKey:@"data"] objectForKey:@"current_condition"];
              
              NSString *weatherString;
              if ([[NSUserDefaults standardUserDefaults] integerForKey:@"units"] == 0) {
                  weatherString = [NSString stringWithFormat:@"%@˚C", [[condition valueForKey:@"temp_C"] objectAtIndex:0]];
              } else {
                  weatherString = [NSString stringWithFormat:@"%@˚F", [[condition valueForKey:@"temp_F"] objectAtIndex:0]];
              }
                [statusItem setTitle:weatherString];
//              [self notifyUserWithTitle:NSLocalizedString(@"Current condition is",@"")
//                        informativeText:NSLocalizedString(weatherString, @"")];
          }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"locationName"]){
//        weatherTimer = [NSTimer scheduledTimerWithTimeInterval:kWWOUpdateInterval
//                                                        target:self
//                                                      selector:@selector(handleWeatherTimer:)
//                                                      userInfo:nil
//                                                       repeats:YES];
        
    } else if ([keyPath isEqualToString:@"launchAtLogin"]) {
        if ([[change valueForKey:@"new"] integerValue] == 1)
        {
            [self addAppAsLoginItem];
        } else {
            [self removeAppFromLoginItems];
        }
        
    } else {
        [weatherTimer fire];
    }
}


//Check for duplicating running instances of application
- (void)deduplicateRunningInstances
{
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]] count] > 1)
    {
        NSLog(@"Another copy of %@ is already running.", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey]);
        
        [NSApp terminate:nil];
    }
}

// Add application to user login items to start at login
- (void)addAppAsLoginItem
{
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (loginItems) {
        //Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
    }
    CFRelease(loginItems);
}

// Add application from user login items
- (void)removeAppFromLoginItems
{
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
        
		for(int i=0; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray
                                                                        objectAtIndex:i]);
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	}
}

@end