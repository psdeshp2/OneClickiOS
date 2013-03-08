//
//  ReservationDetailViewController.m
//  OneClick
//
//  Created by Ignacio Dominguez on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReservationDetailViewController.h"
#import "ReservationListViewController.h"

@interface ReservationDetailViewController ()

@property (strong, nonatomic) IBOutlet UIView *defaultView;

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelPlatform;
@property (strong, nonatomic) IBOutlet UILabel *labelStart;
@property (strong, nonatomic) IBOutlet UILabel *labelEnd;
@property (strong, nonatomic) IBOutlet UIImageView *platformLogo;

@property (strong, nonatomic) VCLXMLRPC *vclXMLRPC;

@end

@implementation ReservationDetailViewController

@synthesize labelName = _labelName;
@synthesize labelPlatform = _labelPlatform;
@synthesize labelStart = _labelStart;
@synthesize labelEnd = _labelEnd;
@synthesize platformLogo = _platformLogo;

@synthesize reservation = _reservation;
@synthesize defaultView = _defaultView;
@synthesize vclXMLRPC = _vclXMLRPC;

- (void)setReservation:(id)newReservation
{
    if (_reservation != newReservation) {
        _reservation = newReservation;
        // Update the view.
    }
	[self configureView];
	
    
}

- (void)configureView
{
    // Update the user interface for the detail item.
	if(self.reservation) {
		NSLog(@"%@", self.labelName.text);
		self.labelName.text = [self.reservation imageName];
		//[self.labelName sizeToFit];
		self.labelPlatform.text = [self.reservation osType];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"EEEE, MMMM d, yyyy 'at' h:mm a"];

		
		
		self.labelStart.text = [dateFormatter stringFromDate:[self.reservation startDate]];
		self.labelEnd.text = [dateFormatter stringFromDate:[self.reservation endDate]];
		
		self.platformLogo.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [self.reservation osType]]];
		
		[self.defaultView setHidden:YES];
		
		[[self.navigationItem rightBarButtonItem] setEnabled:YES];
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	self.vclXMLRPC.delegate = self;
    [super viewDidLoad];
	[self configureView];
}

- (void)viewDidUnload
{
	[self setLabelEnd:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([segue.identifier isEqualToString:@"ConnectToReservation"]) {
		
		ReservationViewController *destination = (ReservationViewController *)segue.destinationViewController;
		destination.delegate = self;
		destination.reservation = self.reservation;
		
	}
}

- (void)clear {
	[self.defaultView setHidden:NO];
	[[self.navigationItem rightBarButtonItem] setEnabled:NO];
}

- (IBAction)endReservation:(UIBarButtonItem *)sender {
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"End Reservation" otherButtonTitles:nil];
	
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showFromBarButtonItem:sender animated:YES];
}

- (VCLXMLRPC *)vclXMLRPC {
	if(!_vclXMLRPC) {
		_vclXMLRPC = [[VCLXMLRPC alloc] init];
	}
	return _vclXMLRPC;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) { //End Reservation
		[self.vclXMLRPC endRequestWithID:self.reservation.ID];
	} else if (buttonIndex == 1) {
	}
}


- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response {
	
	NSDictionary * result = (NSDictionary *)[response object];
	if([[result objectForKey:@"status"] isEqualToString:@"success"]) {
		//refresh master
		id master = [ReservationListViewController getInstance];
		if(master) {
			[(ReservationListViewController *)master refresh];
		}
		
		if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			[self clear];
		}
		else {
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
	else {
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Operation failed"
														  message:@"The reservation could not be ended."
														 delegate:nil
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
		
		[message show];
	}
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error {
	UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Operation failed"
													  message:@"The reservation could not be ended."
													 delegate:nil
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
	
	[message show];
}

#pragma mark - ReservationViewController delegate

- (void)reservationCancel:(ReservationViewController *)sender {
	[sender dismissModalViewControllerAnimated:YES];
}

- (void)reservationDone:(ReservationViewController *)sender withResult:(OneClick *)oneClick {
	[sender dismissModalViewControllerAnimated:YES];
}



@end
