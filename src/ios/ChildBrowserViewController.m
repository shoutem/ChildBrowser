//
//  ChildBrowserViewController.m
//
//  Created by Jesse MacFadyen on 21/07/09.
//  Copyright 2009 Nitobi. All rights reserved.
//  Copyright (c) 2011, IBM Corporation
//  Copyright 2011, Randy McMillan
//

#import "ChildBrowserViewController.h"

@interface ChildBrowserViewController()

//Gesture Recognizer
- (void)addGestureRecognizer;

@end

@implementation ChildBrowserViewController

@synthesize imageURL, isImage, scaleEnabled;
@synthesize delegate, orientationDelegate;
@synthesize spinner, webView, addressLabel, toolbar;
@synthesize closeBtn, refreshBtn, backBtn, fwdBtn, safariBtn, closeButton;
@synthesize customNavigationBar, headerLogoUrl, backButtonUrl;

- (ChildBrowserViewController*)initWithScale:(BOOL)enabled
{
    self = [super init];
	if(self!=nil)
    {
        [self addGestureRecognizer];
    }
	
	self.scaleEnabled = enabled;
	
	return self;	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.refreshBtn.image = [UIImage imageNamed:@"ChildBrowser.bundle/but_refresh"];
    self.backBtn.image = [UIImage imageNamed:@"ChildBrowser.bundle/arrow_left.png"];
	self.fwdBtn.image = [UIImage imageNamed:@"ChildBrowser.bundle/arrow_right.png"];
	self.safariBtn.image = [UIImage imageNamed:@"ChildBrowser.bundle/compass.png"];
    
    self.spinner.center = self.view.center;

	self.webView.delegate = self;
	self.webView.scalesPageToFit = YES;
	self.webView.backgroundColor = [UIColor whiteColor];
    
    self.customNavigationBar = [[[CustomNavigationView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, NavigationViewHeight()) andHeaderLogoUrl:self.headerLogoUrl] autorelease];
    self.customNavigationBar.delegate = self;
    [self.view addSubview:self.customNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    CGRect webViewFrame = self.view.frame;
    webViewFrame.origin = CGPointZero;
    
    // Header
    [self.customNavigationBar setHidden:!self.showHeader];
    [self.closeButton setHidden:self.showHeader];
    if (self.showHeader) {
        webViewFrame.origin.y = NavigationViewHeight();
        webViewFrame.size.height -= NavigationViewHeight();
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
    // Toolbar
    [self.toolbar setHidden:!self.showToolbar];
    if (self.showToolbar) {
        webViewFrame.size.height -= self.toolbar.frame.size.height;
    }
    
    // Address
    [self.addressLabel setHidden:!self.showAddress];
    
    [self.webView setFrame:webViewFrame];
    [self.view setNeedsLayout];
}

- (void)dealloc
{
	self.webView.delegate = nil;
    self.delegate = nil;
    self.orientationDelegate = nil;
	
#if !__has_feature(objc_arc)
	[self.webView release];
	[self.closeBtn release];
	[self.refreshBtn release];
	[self.addressLabel release];
	[self.backBtn release];
	[self.fwdBtn release];
	[self.safariBtn release];
	[self.spinner release];
    [self.toolbar release];
    [self.customNavigationBar release];
    [self.headerLogoUrl release];
    [self.backButtonUrl release];
    [self.closeButton release];
    
	[super dealloc];
#endif
}

- (void)closeBrowser
{
	if (self.delegate != nil)
	{
		[self.delegate onClose];
	}
    
    // Show status bar on close
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    if ([self respondsToSelector:@selector(presentingViewController)])
    {
        //Reference UIViewController.h Line:179 for update to iOS 5 difference - @RandyMcMillan
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)onDoneButtonPress:(id)sender
{
    [self.webView stopLoading];
	[self closeBrowser];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
    [self.webView loadRequest:request];
}


- (IBAction)onSafariButtonPress:(id)sender
{
	if (self.delegate != nil)
	{
		[self.delegate onOpenInSafari];
	}
	
	if (isImage)
	{
		NSURL* pURL = [[[NSURL alloc] initWithString:imageURL] autorelease];
		[[UIApplication sharedApplication] openURL:pURL];
	}
	else
	{
		NSURLRequest *request = webView.request;
		[[UIApplication sharedApplication] openURL:request.URL];
	}
}

- (void)loadURL:(NSString*)url
{
	NSLog(@"Opening Url : %@",url);
	 
	if (self.isImage)
	{
		self.imageURL = url;
        self.webView.backgroundColor = [UIColor blackColor];
        
		NSString *htmlText = [NSString stringWithFormat:@"<html style='width:100%%;height:100%%'><body style='background-image:url(%@);background-size:contain;background-position:center;background-repeat:no-repeat;background-color:black;'></body></html>", url];
		[webView loadHTMLString:htmlText baseURL:[NSURL URLWithString:@""]];
	}
	else
	{
		imageURL = @"";
        self.webView.backgroundColor = [UIColor whiteColor];
        
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
		[self.webView loadRequest:request];
	}
	self.webView.hidden = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeReload && self.isImage) {
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)sender
{
	self.addressLabel.text = @"Loading...";
	self.backBtn.enabled = webView.canGoBack;
	self.fwdBtn.enabled = webView.canGoForward;
	
	[self.spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)sender 
{
	NSURLRequest *request = self.webView.request;
	NSLog(@"New Address is : %@",request.URL.absoluteString);

	self.addressLabel.text = request.URL.absoluteString;
	self.backBtn.enabled = webView.canGoBack;
	self.fwdBtn.enabled = webView.canGoForward;
	[self.spinner stopAnimating];
	
	if (self.delegate != nil)
    {
		[self.delegate onChildLocationChange:request.URL.absoluteString];
	}
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    NSLog (@"webView:didFailLoadWithError");
    NSLog (@"%@", [error localizedDescription]);
    NSLog (@"%@", [error localizedFailureReason]);

    [spinner stopAnimating];
    addressLabel.text = @"Failed";
}

#pragma mark - CustomNavigationViewDelegate

- (void)backButtonPressed
{
    [self onDoneButtonPress:self];
}

- (void)setHeaderLogoUrl:(NSString *)newHeaderLogoUrl
{
    if (headerLogoUrl == newHeaderLogoUrl || [newHeaderLogoUrl isKindOfClass:[NSNull class]] || newHeaderLogoUrl == nil)
        return;
    
    headerLogoUrl = [newHeaderLogoUrl copy];
    [self.customNavigationBar setHeaderLogo:headerLogoUrl];
}

- (void)setBackButtonUrl:(NSString *)newBackButtonUrl
{
    if (backButtonUrl == newBackButtonUrl || [newBackButtonUrl isKindOfClass:[NSNull class]] || newBackButtonUrl == nil)
        return;
    
    backButtonUrl = [newBackButtonUrl copy];
    [self.customNavigationBar setBackButton:backButtonUrl];
}

#pragma mark - Gesture Recognizer

- (void)addGestureRecognizer
{
    UISwipeGestureRecognizer* closeRG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeBrowser)];
    closeRG.direction = UISwipeGestureRecognizerDirectionLeft;
    closeRG.delegate=self;
    [self.view addGestureRecognizer:closeRG];
    [closeRG release];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma mark CDVOrientationDelegate

- (BOOL)shouldAutorotate
{
    if (self.canRotate) return YES;
    
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(shouldAutorotate)]) {
        return [self.orientationDelegate shouldAutorotate];
    }
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (self.canRotate) return UIInterfaceOrientationMaskAll;
    
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [self.orientationDelegate supportedInterfaceOrientations];
    }

    // return UIInterfaceOrientationMaskPortrait; // NO - is IOS 6 only
    return (1 << UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.canRotate) return YES;
    
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)]) {
        return [self.orientationDelegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }

    return YES;
}

@end
