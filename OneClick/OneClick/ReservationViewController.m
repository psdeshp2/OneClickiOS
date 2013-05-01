//
//  ReservationViewController.m
//  OneClick
//
//  Created by Ignacio Dominguez on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReservationViewController.h"
#import "ReservationListViewController.h"
#import "Constants.h"

typedef enum RequestPhases {
	GetParams,
	Request,
	GetStatus,
	GetRemoteIP,
	GetConnectData,
	CancelRequest,
    Ended
} RequestPhases;

@interface ReservationViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *progressIndicator;
@property (strong, nonatomic) IBOutlet UILabel *labelProgress;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;

@property (nonatomic, strong) VCLXMLRPC *xmlrpc;
@property (nonatomic, assign) RequestPhases currentPhase;

@property (nonatomic, strong) NSNumber *requestID;
@property (nonatomic, strong) NSString *osType;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) RDPServer *rdpServer;

- (void)configureView;

- (void)requestPhasesEnded;
- (void)connectToReservation;
@end

@implementation ReservationViewController
@synthesize progressIndicator = _progressIndicator;
@synthesize labelProgress = _labelProgress;
@synthesize labelName = _labelTitle;
@synthesize progressBar = _progressBar;

@synthesize delegate = _delegate;
@synthesize oneClick = _oneClick;
@synthesize reservation = _reservation;

@synthesize xmlrpc = _xmlrpc;
@synthesize currentPhase = _currentPhase;

@synthesize requestID = _requestID;
@synthesize osType = _osType;
@synthesize host = _host;
@synthesize user = _user;
@synthesize password = _password;

@synthesize rdpServer = _rdpServer;

-(VCLXMLRPC *)xmlrpc {
	if(!_xmlrpc) {
		_xmlrpc = [[VCLXMLRPC alloc] init];
	}
	return _xmlrpc;
}

- (void)setOneClick:(id)newOneClick
{
    if (_oneClick != newOneClick) {
        _oneClick = newOneClick;
        self.osType = _oneClick.osType;
        // Update the view.
        [self configureView];
    }      
}

- (void)setReservation:(Reservation *)reservation
{
    if (_reservation != reservation) {
        _reservation = reservation;
        self.osType = reservation.osType;
        // Update the view.
        [self configureView];
    }      
}

- (void)configureView
{
    // Update the user interface for the detail item.
	if (self.oneClick) {
		self.labelName.text = self.oneClick.name;
	}
	else if(self.reservation) {
		self.labelName.text = self.reservation.imageName;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self configureView];
	self.xmlrpc.delegate = self;
	[self.progressIndicator startAnimating];
	[self.progressBar setProgress:0];
	
	if(![VCLXMLRPC isConnectedToInternetShowMessage:NO]) {
		self.labelProgress.text = @"No internet connection.";
		[self requestPhasesEnded];
	}
	else if(self.oneClick) {
		
		self.labelProgress.text = @"Obtaining updated OneClick parameters...";
		self.currentPhase = GetParams;
		[self.xmlrpc getOneClickParametersWithID:self.oneClick.ID];
	}
	else if(self.reservation) {
		self.labelProgress.text = @"Getting the status of the reservation...";
		self.currentPhase = GetStatus;
		self.requestID = self.reservation.ID;
		[self.xmlrpc getRequestStatus:self.reservation.ID];
	}
	else {
		self.labelProgress.text = @"Invalid OneClick configuration.";
		[self requestPhasesEnded];
	}
}

- (void)viewDidUnload
{
	[self setProgressIndicator:nil];
	[self setLabelProgress:nil];
	[self setProgressBar:nil];
	[self setLabelName:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark - OneClick

-(RDPServer *)rdpServer {
	if(!_rdpServer) {
		_rdpServer = [[RDPServer alloc] init];
	}
	return _rdpServer;
}

- (IBAction)cancelRequest {
	[self.xmlrpc cancelCall];
	[self.progressIndicator stopAnimating];
	//Delete reservation that was cancelled
	if(self.requestID != nil && self.currentPhase != Ended) {
		self.currentPhase = CancelRequest;
		[self.xmlrpc endRequestWithID:self.requestID];
	}
	[self.rdpServer stopServe];
	
	//Notify delegate we should be closed
	[self.delegate reservationCancel:self];
}


- (void)requestPhasesEnded {
	[self.progressIndicator stopAnimating];
	[self.navigationItem.rightBarButtonItem setTitle:@"Done"];
	//Enable displaying credentials if they are available
	if(self.currentPhase == Ended) {
		
	}
}

- (void)connectToReservation {
	
	UIApplication *ourApplication = [UIApplication sharedApplication];
	NSString *URLScheme;
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	if([self.osType isEqualToString:@"windows"]) {
		
		NSNumber *port = [self.rdpServer serveRDPToHost:self.host forUser:self.user withPassword:self.password];
				
		NSString *defaultRDPApp = [settings stringForKey: RDPAppKey];
		if([defaultRDPApp isEqualToString:@"pocketcloud"]) {
			URLScheme = [NSString stringWithFormat:@"pocketcloud://localhost:%@/rdp.rdp", port];
		}
		else if([defaultRDPApp isEqualToString:@"itaprdp"]) {
			URLScheme = [NSString stringWithFormat:@"itaprdp:http://localhost:%@/rdp.rdp", port];
		}
		else if([defaultRDPApp isEqualToString:@"ericom"]) {
			URLScheme = [NSString stringWithFormat:@"ericom://http://localhost:%@/rdp.rdp", port];
		}
		else if([defaultRDPApp isEqualToString:@"jump"]) {
			URLScheme = [NSString stringWithFormat:@"jump://?host=%@&username=%@&password=%@", self.host, self.user, self.password];
		}
	}
	else {
		//NSString *defaultSSHApp = [settings stringForKey: SSHAppKey];
		URLScheme = [NSString stringWithFormat:@"ssh://%@:%@@%@", self.user, self.password, self.host];
	}
	NSURL *URL = [NSURL URLWithString: URLScheme];
	
	if([ourApplication canOpenURL:URL]) {
		self.labelProgress.text = [NSString stringWithFormat:@"Connecting to your %@ reservation...", self.osType];
		
		[ourApplication performSelector:@selector(openURL:) withObject:URL afterDelay:3];
		
		//TODO: close popup?
	}
	else {
		self.labelProgress.text = [NSString stringWithFormat:@"You have not selected a default client to connect to your %@ reservation on this device, or the selected client is not available. Please choose one in Settings.", self.osType];
	}
}


#pragma mark - XMLRPC delegate

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response {
	NSDictionary * result = (NSDictionary *)[response object];
	NSString *status = [result objectForKey:@"status"];
	switch (self.currentPhase) {
		case GetParams:
		{
			NSDictionary *object = (NSDictionary *)[response object];
			
			OneClick *newOneClick = [OneClick oneClickFromDictionary:object];
			self.oneClick.name = newOneClick.name;
			self.oneClick.imageID = newOneClick.imageID;
			self.oneClick.imageName = newOneClick.imageName;
			self.oneClick.osType = newOneClick.osType;
			self.oneClick.length = newOneClick.length;
			self.oneClick.autoLogin = newOneClick.autoLogin;
			[self configureView];
			
			self.labelProgress.text = @"Requesting reservation...";
			self.currentPhase = Request;
			[self.xmlrpc addRequestForImageID:self.oneClick.imageID starting:@"now" withDuration:self.oneClick.length withOneClickID:self.oneClick.ID withFlag:self.existingReservation];
		}
			break;
		case Request:
			[self.progressBar setProgress:0.20];
			if([[result objectForKey:@"status"] isEqualToString:@"success"]) {
				self.labelProgress.text = @"The reservation was successfully requested.\n\n Getting the status of the reservation...";
				
				self.requestID = [NSNumber numberWithInt:[(NSString *)[result objectForKey:@"requestid"] intValue]];
				self.currentPhase = GetStatus;
				[self.xmlrpc getRequestStatus:self.requestID];
			}
			else if([[result objectForKey:@"status"] isEqualToString:@"notavailable"]) {
				self.labelProgress.text = @"There are no computers available for your reservation. Please try again later.";
				[self requestPhasesEnded];
			}
			else if([[result objectForKey:@"status"] isEqualToString:@"error"]) {
				self.labelProgress.text = [NSString stringWithFormat:@"An error occurred with message '%@'.", (NSString *)[result objectForKey:@"errormsg"]];
				[self requestPhasesEnded];
			}
			else {
				NSLog(@"%@", result);
				[self requestPhasesEnded];
			}
			break;
		case GetStatus:
			[self.progressBar setProgress:0.40];
			if([status isEqualToString:@"error"]) {
				self.labelProgress.text = @"Problem getting the status of the reservation.";
				[self requestPhasesEnded];
			}
			else if([status isEqualToString:@"failed"]) {
				self.labelProgress.text = @"The VCL reservation failed.";
				[self requestPhasesEnded];
			}
			else if([status isEqualToString:@"timedout"]) {
				self.labelProgress.text = @"The VCL reservation has timed out.";
				[self requestPhasesEnded];
			}
			else if([status isEqualToString:@"loading"]) {
				self.labelProgress.text = [NSString stringWithFormat:@"The VCL resource is being prepared for your reservation.\n\n This should take about %@ minute(s)...", [result objectForKey:@"time"]];
				[self.xmlrpc performSelector:@selector(getRequestStatus:) withObject:self.requestID afterDelay:5];
			}
			else if([status isEqualToString:@"future"]) {
				self.labelProgress.text = @"The start time for this reservation has not been reached yet.";
				[self.xmlrpc performSelector:@selector(getRequestStatus:) withObject:self.requestID afterDelay:5];
			}
			else if([status isEqualToString:@"ready"]) {
				self.labelProgress.text = @"The reservation is ready. Obtaining your device's IP...";
				/*id master = [ReservationListViewController getInstance];
				if(master)
					[(ReservationListViewController *)master refresh];*/
								
				self.currentPhase = GetRemoteIP;
				[self.xmlrpc getIP];
			}
			
			
			break;
		case GetRemoteIP: {
			[self.progressBar setProgress:0.60];
			self.labelProgress.text = @"Your device's IP was successfully retrieved.\n\n Obtaining connection parameters for your reservation...";
			NSString *remoteIP = [result objectForKey:@"ip"];
			self.currentPhase = GetConnectData;
			[self.xmlrpc getRequestConnectData:self.requestID forIP:remoteIP];
		}
			break;
		case GetConnectData:
		{
			[self.progressBar setProgress:0.80];
			self.host = [result objectForKey:@"serverIP"];
			self.user = [result objectForKey:@"user"];
			self.password = [result objectForKey:@"password"];
			
			
			self.currentPhase = Ended;
			[self.progressBar setProgress:1];
			[self requestPhasesEnded];
			
			[self connectToReservation];
		}
			break;
		default:
			break;
	}
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error {
	NSLog(@"Error %@", error);
	self.labelProgress.text = @"There was a problem with your reservation.";
	[self requestPhasesEnded];
}

@end
