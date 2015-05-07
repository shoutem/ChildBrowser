//
//  ChildBrowserViewController.h
//
//  Created by Jesse MacFadyen on 21/07/09.
//  Copyright 2009 Nitobi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationView.h"

@protocol ChildBrowserDelegate<NSObject>

/*
 *  onChildLocationChanging:newLoc
 *  
 *  Discussion:
 *    Invoked when a new page has loaded
 */
- (void)onChildLocationChange:(NSString *)newLoc;
- (void)onOpenInSafari;
- (void)onClose;

@end

@protocol CDVOrientationDelegate <NSObject>

- (NSUInteger)supportedInterfaceOrientations;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)shouldAutorotate;

@end

@interface ChildBrowserViewController : UIViewController <UIWebViewDelegate, UIGestureRecognizerDelegate, CustomNavigationViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *closeBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *refreshBtn;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *fwdBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *safariBtn;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;

@property (nonatomic, strong) CustomNavigationView *customNavigationBar;

@property (nonatomic, unsafe_unretained) id <ChildBrowserDelegate> delegate;
@property (nonatomic, unsafe_unretained) id orientationDelegate;

@property (copy) NSString *imageURL;
@property (assign) BOOL isImage;
@property (assign) BOOL scaleEnabled;
@property (nonatomic, copy) NSString *headerLogoUrl;
@property (nonatomic, copy) NSString *backButtonUrl;
@property (assign) BOOL showingNavigation;

@property (nonatomic, assign) BOOL showAddress;
@property (nonatomic, assign) BOOL showToolbar;
@property (nonatomic, assign) BOOL showHeader;
@property (nonatomic, assign) BOOL canRotate;

- (ChildBrowserViewController *)initWithScale:(BOOL)enabled;
- (IBAction)onDoneButtonPress:(id)sender;
- (IBAction)onSafariButtonPress:(id)sender;
- (void)loadURL:(NSString *)url;
- (void)closeBrowser;

@end
