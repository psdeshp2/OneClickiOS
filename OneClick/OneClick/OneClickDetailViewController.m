//
//  DetailViewController.m
//  OneClick
//
//  Created by Ignacio Dominguez on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OneClickDetailViewController.h"
#import "ReservationViewController.h"
#import "OneClickListViewController.h"

@interface OneClickDetailViewController ()
@property (strong, nonatomic) UIPopoverController *inputPopoverController;

@property (strong, nonatomic) IBOutlet UIView *defaultView;

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelEnvironment;
@property (strong, nonatomic) IBOutlet UILabel *labelPlatform;
@property (strong, nonatomic) IBOutlet UILabel *labelDuration;
@property (strong, nonatomic) IBOutlet UIImageView *platformLogo;

@property (strong, nonatomic) VCLXMLRPC *vclXMLRPC;

- (void)configureView;

@end

@implementation OneClickDetailViewController

@synthesize oneClick = _oneClick;
@synthesize labelName = _labelName;
@synthesize labelEnvironment = _labelEnvironment;
@synthesize labelPlatform = _labelPlatform;
@synthesize labelDuration = _labelDuration;
@synthesize platformLogo = _platformLogo;

@synthesize inputPopoverController = _inputPopoverController;
@synthesize defaultView = _defaultView;
@synthesize vclXMLRPC = _vclXMLRPC;

#pragma mark - Managing the detail item

- (void)setOneClick:(id)newOneClick
{
    if (_oneClick != newOneClick) {
        _oneClick = newOneClick;
        // Update the view.
    }
	[self configureView];
	
}

- (void)configureView
{
    // Update the user interface for the detail item.
	if (self.oneClick) {		
		self.labelName.text = [self.oneClick name];
		[self.labelName sizeToFit];
	    self.labelEnvironment.text = [self.oneClick imageName];
		self.labelPlatform.text = [self.oneClick osType];
		self.labelDuration.text = [OneClick minutesToString:self.oneClick.length];
		
		self.platformLogo.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [self.oneClick osType]]];
		
		[self.defaultView setHidden:YES];
		
		[[self.navigationItem rightBarButtonItem] setEnabled:YES];
	}
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.vclXMLRPC.delegate = self;
	[self configureView];
}

- (void)viewDidUnload
{
	[self setLabelEnvironment:nil];
	[self setLabelPlatform:nil];
	[self setLabelDuration:nil];
	[self setLabelName:nil];
	[self setPlatformLogo:nil];
	[self setDefaultView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.labelEnvironment = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([segue.identifier isEqualToString:@"EditOneClick"]) {
		
		if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			if(self.inputPopoverController)
				[self.inputPopoverController dismissPopoverAnimated:NO];
			self.inputPopoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
			/*self.inputPopoverController.delegate = (id <UIPopoverControllerDelegate>)self;*/
		}
		else {
			self.inputPopoverController = segue.destinationViewController;
		}
		
		OneClickInputViewController *destination = (OneClickInputViewController *)[segue.destinationViewController topViewController];
		destination.delegate = self;
		destination.oneClick = [self.oneClick copy];

	}
	else if([segue.identifier isEqualToString:@"MakeReservation"]) {
				
		ReservationViewController *destination = (ReservationViewController *)segue.destinationViewController;
		destination.delegate = self;
		destination.oneClick = self.oneClick;
		
	}
}

- (void)clear {
	[self.defaultView setHidden:NO];
	[[self.navigationItem rightBarButtonItem] setEnabled:NO];
}

#pragma mark - OneClick

- (VCLXMLRPC *)vclXMLRPC {
	if(!_vclXMLRPC) {
		_vclXMLRPC = [[VCLXMLRPC alloc] init];
	}
	return _vclXMLRPC;
}

- (void)oneClickInputCancel:(OneClickInputViewController *)sender {
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		[self.inputPopoverController dismissPopoverAnimated:YES];
	}
	else {
		[sender dismissModalViewControllerAnimated:YES];
	}
}

- (void)oneClickInputDone:(OneClickInputViewController *)sender withResult:(OneClick *)oneClick {
	[self.vclXMLRPC editOneClick:oneClick.ID withName:oneClick.name withImage:oneClick.imageID withDuration:oneClick.length withAutologin:oneClick.autoLogin];
	[self oneClickInputCancel:sender];
}

- (void)reservationCancel:(ReservationViewController *)sender {
	
	[sender dismissModalViewControllerAnimated:YES];
}

- (void)reservationDone:(ReservationViewController *)sender withResult:(OneClick *)oneClick {
}

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response {
	//NSLog(@"%@", [response object]);
	
	NSDictionary * result = (NSDictionary *)[response object];
	if([[result objectForKey:@"status"] isEqualToString:@"success"]) {
		NSDictionary *object = (NSDictionary *)[response object];
		
		OneClick *newOneClick = [OneClick oneClickFromDictionary:object];
		
		self.oneClick.name = newOneClick.name;
		self.oneClick.imageID = newOneClick.imageID;
		self.oneClick.imageName = newOneClick.imageName;
		self.oneClick.osType = newOneClick.osType;
		self.oneClick.length = newOneClick.length;
		self.oneClick.autoLogin = newOneClick.autoLogin;
		[self configureView];

		//refresh master
		if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			/*UITabBarController *tabs = (UITabBarController *)[self.splitViewController.viewControllers objectAtIndex:0];
			UINavigationController *listTab = (UINavigationController *)[tabs.viewControllers objectAtIndex:0];
			[(OneClickListViewController *)listTab.topViewController refresh];*/
			id master = [OneClickListViewController getInstance];
			if(master) {
				[(OneClickListViewController *)master refresh];
			}
		}
		else {
			//[sender dismissModalViewControllerAnimated:YES];
			id master = [OneClickListViewController getInstance];
			if(master) {
				[(OneClickListViewController *)master refresh];
			}
		}

	}
	else {
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Update failed"
														  message:@"The OneClick configuration could not be updated."
														 delegate:nil
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
		
		[message show];
	}
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error {
	UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Update failed"
													  message:@"The OneClick configuration could not be updated."
													 delegate:nil
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
	
	[message show];
}

@end
