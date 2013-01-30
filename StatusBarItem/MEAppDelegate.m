//
//  MEAppDelegate.m
//  StatusBarItem
//
//  Created by Andrey M on 08.01.13.
//  Copyright (c) 2013 Andrey M. All rights reserved.
//

#import "MEAppDelegate.h"
#import "MEStartupUtility.h"

@implementation MEAppDelegate

- (id)init {
    if (self = [super init]) {
        _jsonParser = [[SBJsonParser alloc] init];
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Check duplicate instances
    [self deduplicateRunningInstances];
    
    // Check for locationName in user defaults
    if ([userDefaults stringForKey:@"locationName"])
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
    
    if ([userDefaults integerForKey:@"units"] == 0)
    {
        weatherUnit = @"C";
    } else {
        weatherUnit = @"F";
    }

    [userDefaults addObserver:self
                   forKeyPath:@"preferencesUpdated"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    [userDefaults addObserver:self
                   forKeyPath:@"locationName"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    [userDefaults addObserver:self
                   forKeyPath:@"launchAtLogin"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    
    NSStatusBar * systemStatusBar = [NSStatusBar systemStatusBar];
    statusItem = [systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    
    [statusItem setTitle:@"N/A"];
    [statusItem setHighlightMode:YES];
    [statusItem setImage:[NSImage imageNamed:@"23.png"]];
    [statusItem setAlternateImage:[NSImage imageNamed:@"23.png"]];
    
    NSMenuItem *extendedItem = [[NSMenuItem alloc] initWithTitle:@"Extended view" action:nil keyEquivalent:@""];
    [extendedItem setView:_extendedView];
    [_statusMenu insertItem:extendedItem atIndex:0];
    
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

    NSString *conditionString = [NSString stringWithFormat:@"In %@ currently is %@", [userDefaults stringForKey:@"locationName"], [statusItem title]];
    
    NSSharingService *twitterSharingService = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    [twitterSharingService performWithItems:[NSArray arrayWithObject:conditionString]];
}

- (void)quit:(id)sender
{
    [NSApp terminate:self];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [userDefaults synchronize];
    // remove observers
//    [userDefaults removeObserver:self forKeyPath:@"preferencesUpdated"];
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
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:10];
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
              if ([userDefaults integerForKey:@"units"] == 0) {
                  weatherString = [NSString stringWithFormat:@"%@˚C", [[condition valueForKey:@"temp_C"] objectAtIndex:0]];
              } else {
                  weatherString = [NSString stringWithFormat:@"%@˚F", [[condition valueForKey:@"temp_F"] objectAtIndex:0]];
              }

              [statusItem setTitle:weatherString];
              [_tempLabel setStringValue:weatherString];

              [_cityLabel setStringValue:[userDefaults stringForKey:@"locationName"]];
              [_conditionLabel setStringValue:[[[[condition valueForKey:@"weatherDesc"] objectAtIndex:0] valueForKey:@"value"] objectAtIndex:0]];
              
              // Convert observation time from UTC to local
              NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
              [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
              [dateFormatter setDateStyle:NSDateFormatterNoStyle];
              [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
              NSDate *date = [dateFormatter dateFromString:[[[condition valueForKey:@"observation_time"] objectAtIndex:0] substringToIndex:5]];
              
              [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
              [_observationTimeLabel setStringValue:[NSString stringWithFormat:@"registered at %@", [dateFormatter stringFromDate:date]]];

              NSImage *conditionImage = [NSImage imageNamed:[NSString stringWithFormat:@"%@.png", [[condition valueForKey:@"weatherCode"] objectAtIndex:0]]];

              NSLog(@"weatherCode: %@",[NSString stringWithFormat:@"%@", [[condition valueForKey:@"weatherCode"] objectAtIndex:0]]);
              if ([conditionImage isMemberOfClass:[NSNull class]]) {
                  [_conditionImageView setImage:[NSImage imageNamed:@"0.png"]];
              } else {
                  [_conditionImageView setImage:conditionImage];
              }
              
//              [self notifyUserWithTitle:NSLocalizedString(@"Current condition is",@"")
//                        informativeText:NSLocalizedString(weatherString, @"")];
          }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"locationName"]){
        if (!weatherTimer) {
            weatherTimer = [NSTimer scheduledTimerWithTimeInterval:kWWOUpdateInterval
                                                            target:self
                                                          selector:@selector(handleWeatherTimer:)
                                                          userInfo:nil
                                                           repeats:YES];
        }
        
    } else if ([keyPath isEqualToString:@"launchAtLogin"]) {
        if ([[change valueForKey:@"new"] integerValue] == 1)
        {
            [MEStartupUtility addAppAsLoginItem];
        } else {
            [MEStartupUtility removeAppFromLoginItems];
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

@end
