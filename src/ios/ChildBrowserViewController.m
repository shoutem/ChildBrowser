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
@synthesize closeBtn, refreshBtn, backBtn, fwdBtn, safariBtn;
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

	self.webView.delegate = self;
	self.webView.scalesPageToFit = TRUE;
	self.webView.backgroundColor = [UIColor whiteColor];
    
    self.customNavigationBar = [[[CustomNavigationView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, NavigationViewHeight()) andHeaderLogoUrl:self.headerLogoUrl] autorelease];
    self.customNavigationBar.delegate = self;
    [self.view addSubview:self.customNavigationBar];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	NSLog(@"View did UN-load");
}


- (void)dealloc {
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
    
	[super dealloc];
#endif
}

-(void)closeBrowser
{
	
	if (self.delegate != NULL)
	{
		[self.delegate onClose];
	}
    if ([self respondsToSelector:@selector(presentingViewController)]) { 
        //Reference UIViewController.h Line:179 for update to iOS 5 difference - @RandyMcMillan
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    } else {
        [[self parentViewController] dismissModalViewControllerAnimated:YES];
    }
}

-(IBAction) onDoneButtonPress:(id)sender
{
    [self.webView stopLoading];
	[self closeBrowser];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
    [self.webView loadRequest:request];
}


-(IBAction) onSafariButtonPress:(id)sender
{
	
	if (self.delegate != nil)
	{
		[self.delegate onOpenInSafari];
	}
	
	if(isImage)
	{
		NSURL* pURL = [[ [NSURL alloc] initWithString:imageURL ] autorelease];
		[ [ UIApplication sharedApplication ] openURL:pURL  ];
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
	 
	if( [url hasSuffix:@".png" ]  || 
	    [url hasSuffix:@".jpg" ]  || 
		[url hasSuffix:@".jpeg" ] || 
		[url hasSuffix:@".bmp" ]  || 
		[url hasSuffix:@".gif" ]  )
	{
		self.imageURL = nil;
		self.imageURL = url;
		self.isImage = YES;
		NSString* htmlText = @"<html><body style='background-color:#333;margin:0px;padding:0px;'><img style='min-height:200px;margin:0px;padding:0px;width:100%;height:auto;' alt='' src='IMGSRC'/></body></html>";
		htmlText = [ htmlText stringByReplacingOccurrencesOfString:@"IMGSRC" withString:url ];

		[webView loadHTMLString:htmlText baseURL:[NSURL URLWithString:@""]];
		
	}
	else
	{
		imageURL = @"";
		isImage = NO;
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
		[self.webView loadRequest:request];
	}
	self.webView.hidden = NO;
}


- (void)webViewDidStartLoad:(UIWebView *)sender {
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
	
	if (self.delegate != NULL) {
		[self.delegate onChildLocationChange:request.URL.absoluteString];
	}
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
    NSLog (@"webView:didFailLoadWithError");
    NSLog (@"%@", [error localizedDescription]);
    NSLog (@"%@", [error localizedFailureReason]);

    [spinner stopAnimating];
    addressLabel.text = @"Failed";
}

#pragma mark - Disaplying Controls

- (void)resetControls
{
    
    CGRect rect = addressLabel.frame;
    rect.origin.y = self.view.frame.size.height-(44.0f+26.0f);
    [addressLabel setFrame:rect];
    rect=webView.frame;
    rect.size.height= self.view.frame.size.height-(44.0f+NavigationViewHeight()-45.0f);
    rect.origin.y = NavigationViewHeight();
    [webView setFrame:rect];
    [addressLabel setHidden:NO];
    [toolbar setHidden:NO];
}

- (void)showLocationBar:(BOOL)isShow
{
    self.showingNavigation = isShow;
    
    //the addreslabel heigth 21 toolbar 44
    CGRect rect = webView.frame;
    rect.size.height+=(-44.0f*isShow);
    [webView setFrame:rect];
    if(isShow)
        return;
    
    [addressLabel setHidden:YES];
    [toolbar setHidden:YES];
    [self.view setNeedsLayout];
}

- (void)showAddress:(BOOL)isShow
{
    if(isShow)
        return;
    CGRect rect = webView.frame;
    rect.size.height+=(0);
    [webView setFrame:rect];
    [addressLabel setHidden:YES];
    
}

- (void)showNavigationBar:(BOOL)isShow
{
    if(isShow)
        return;
    CGRect rect = webView.frame;
    rect.size.height+=(0);
    [webView setFrame:rect];
    [toolbar setHidden:YES];
    rect = addressLabel.frame;
    rect.origin.y+=0;
    [addressLabel setFrame:rect];
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

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}

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
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(shouldAutorotate)]) {
        return [self.orientationDelegate shouldAutorotate];
    }
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [self.orientationDelegate supportedInterfaceOrientations];
    }

    // return UIInterfaceOrientationMaskPortrait; // NO - is IOS 6 only
    return (1 << UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ((self.orientationDelegate != nil) && [self.orientationDelegate respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)]) {
        return [self.orientationDelegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }

    return YES;
}

@end
