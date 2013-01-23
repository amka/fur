//
//  MEPreferencesWindowController.m
//  StatusBarItem
//
//  Created by Andrey M on 08.01.13.
//  Copyright (c) 2013 Andrey M. All rights reserved.
//

#import "MEPreferencesWindowController.h"

@implementation PreferencesWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        completionWords = [[NSMutableArray alloc] init];
        _jsonParser = [[SBJsonParser alloc] init];
        self.animate = NO;
}
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [_locationField setDelegate:self];
    [[self window] setLevel:NSFloatingWindowLevel];
    [[self window] makeFirstResponder:self];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] setValue:[_locationField stringValue] forKey:@"locationName"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"preferencesUpdated"];
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    if ([obj object] == _locationField)
    {
        // Don't send request if location less then 3 chars
        if ([[_locationField  stringValue] length] < 3)
            return;
        
        if (amAutoComplete) {
            return;
        }
        else {
            [_locationField setEnabled:NO];
            amAutoComplete = YES;
            NSDictionary *urlParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [_locationField stringValue], @"q",
                                       kWWOFormat, @"format",
                                       kWWOKey, @"key",
                                       @"5", @"num_of_results",
                                       nil];
            
            NSURL *wwoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?%@",
                                                  kWWOBaseUrl,
                                                  kWWOSearchPath,
                                                  [urlParams urlEncodedString]]];
            
            NSLog(@"%@", wwoUrl);
            NSURLRequest *request = [NSURLRequest requestWithURL:wwoUrl];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation , id responseObject) {
                
                
                id json = [_jsonParser objectWithString:[operation responseString]];
                NSDictionary *search_api = [json objectForKey:@"search_api"];
                [completionWords removeAllObjects];
                if ([search_api class] != [NSNull class]) {
                    NSDictionary *results = [search_api objectForKey:@"result"];
                    
                    for (id item in results)
                    {
//                        NSLog(@"%@", [[[item objectForKey:@"areaName"] objectAtIndex:0] valueForKey:@"value"]);
                        NSString *areaName = [[[item objectForKey:@"areaName"] objectAtIndex:0] objectForKey:@"value"];
                        NSString *country = [[[item objectForKey:@"country"] objectAtIndex:0] objectForKey:@"value" ];
                        NSString *region = [[[item objectForKey:@"region"] objectAtIndex:0] objectForKey:@"value" ];
                        [completionWords addObject:[NSString stringWithFormat:@"%@, %@, %@",
                                                    areaName,
                                                    region,
                                                    country,
                                                    nil]];
                    }
                    NSLog(@"%@", completionWords);
                
                }

                // Enable locationField and set it as focused
                self.animate = NO;
                [_locationField setEnabled:YES];
                [[self window] makeFirstResponder:_locationField];
                [[_locationField currentEditor] setSelectedRange:NSMakeRange([[_locationField stringValue] length], 0)];
                
                // Invoke complete function to show completion list
                [[[obj userInfo] objectForKey:@"NSFieldEditor"] complete:nil];
                amAutoComplete = NO;
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                self.animate = NO;
                [_locationField setEnabled:YES];
                [[self window] makeFirstResponder:_locationField];
                [[_locationField currentEditor] setSelectedRange:NSMakeRange([[_locationField stringValue] length], 0)];
                amAutoComplete = NO;
            }];
            //    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:nil];
            self.animate = YES;
            [operation start];
        }
    }
}

- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
    // prevent overriding inserted text
    *index = -1;
    return completionWords;
}


- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)client
{
    if ([client isKindOfClass:[NSTextField class]])
    {
        if (!_meTextEditor)
        {
            _meTextEditor = [[METextEditor alloc] init];
            [_meTextEditor setFieldEditor:YES];
        }
        return _meTextEditor;
    }
    return nil;
}
@end
