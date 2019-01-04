//
//  Created by Jesse MacFadyen on 10-05-29.
//  Copyright 2010 Nitobi. All rights reserved.
//  Copyright (c) 2011, IBM Corporation
//  Copyright 2011, Randy McMillan
//  Copyright 2012, Andrew Lunny, Adobe Systems
//

#import "ChildBrowserCommand.h"
#import <Cordova/CDVViewController.h>

#define kOpenWebPageInBrowserPrefix @"shoutem://openInBrowser?url="

@implementation ChildBrowserCommand

@synthesize callbackId, childBrowser, CLOSE_EVENT, LOCATION_CHANGE_EVENT, OPEN_EXTERNAL_EVENT;

- (void)pluginInitialize {
    CLOSE_EVENT = [NSNumber numberWithInt:0];
    LOCATION_CHANGE_EVENT = [NSNumber numberWithInt:1];
    OPEN_EXTERNAL_EVENT = [NSNumber numberWithInt:2];
}

- (void)openExternal:(CDVInvokedUrlCommand *)command
{
    NSString *url = [command argumentAtIndex:0];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)showWebPage:(CDVInvokedUrlCommand *)command
{	
    self.callbackId = command.callbackId;

    // objectAtIndex 0 is the callback id
    NSString *url = [command argumentAtIndex:0];
    
    if ([url hasPrefix:kOpenWebPageInBrowserPrefix])
    {
        url = [url substringFromIndex:[kOpenWebPageInBrowserPrefix length]];
    }
    
    NSURL *finalUrl = [NSURL URLWithString:url];
    
    if ([[finalUrl scheme] isEqualToString:@"tel"] || [[finalUrl scheme] isEqualToString:@"sms"])
    {
        [[UIApplication sharedApplication] openURL:finalUrl];
        return;
    }
    
    if (self.childBrowser == nil) {
#if __has_feature(objc_arc)
        self.childBrowser = [[ChildBrowserViewController alloc] initWithScale:NO];
#else
        self.childBrowser = [[[ChildBrowserViewController alloc] initWithScale:NO] autorelease];
#endif
        self.childBrowser.delegate = self;
        self.childBrowser.orientationDelegate = self.viewController;
    }
    
    NSDictionary *options = [command argumentAtIndex:1];
    
    if ([options objectForKey:@"navigationBarLogo"])
    {
        childBrowser.headerLogoUrl = [options objectForKey:@"navigationBarLogo"];
    }

    if ([options objectForKey:@"backButton"])
    {
        childBrowser.backButtonUrl = [options objectForKey:@"backButton"];
    }
    
    childBrowser.showAddress = [[options objectForKey:@"showAddress"] boolValue];
    childBrowser.showToolbar = [[options objectForKey:@"showToolbar"] boolValue];
    childBrowser.showHeader = [[options objectForKey:@"showHeader"] boolValue];
    childBrowser.canRotate = [[options objectForKey:@"canRotate"] boolValue];
    childBrowser.isImage = [[options objectForKey:@"isImage"] boolValue];
    
    [self.viewController presentViewController:self.childBrowser animated:YES completion:^{
        [self.childBrowser loadURL:url];
    }];
}

- (void)close:(CDVInvokedUrlCommand *)command
{
    [self.childBrowser closeBrowser];
}

- (void)onClose
{
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                            messageAsDictionary:[self dictionaryForEvent:CLOSE_EVENT]];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
//    [self writeJavascript:[result toSuccessCallbackString:self.callbackId]];
}

- (void)onOpenInSafari
{
	CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                            messageAsDictionary:[self dictionaryForEvent:OPEN_EXTERNAL_EVENT]];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
//    [self writeJavascript:[result toSuccessCallbackString:self.callbackId]];
}


- (void)onChildLocationChange:(NSString *)newLoc
{
	NSString *tempLoc = [NSString stringWithFormat:@"%@", newLoc];
	NSString *encUrl = [tempLoc stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryForEvent:LOCATION_CHANGE_EVENT]];

    [dict setObject:encUrl forKey:@"location"];

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                            messageAsDictionary:dict];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
//    [self writeJavascript:[result toSuccessCallbackString:self.callbackId]];
}

- (NSDictionary *)dictionaryForEvent:(NSNumber *)event
{
    return [NSDictionary dictionaryWithObject:event forKey:@"type"];
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    self.childBrowser = nil;

    [super dealloc];
}
#endif

@end
