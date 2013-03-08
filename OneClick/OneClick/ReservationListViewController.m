//
//  MasterViewController.m
//  Request
//
//  Created by Ignacio Dominguez on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReservationListViewController.h"
#import "TabBarViewController.h"
#import "ReservationDetailViewController.h"
#import "Reservation.h"
#import "OneClickListViewController.h"

@interface ReservationListViewController () {
    NSMutableOrderedSet *_objects;
}

@property (nonatomic, strong) VCLXMLRPC *vclXMLRPC;

//- (void)loadRequests;
- (void)addRequest:(Reservation *)Request atIndex:(NSUInteger)index;

@end

@implementation ReservationListViewController

@synthesize detailViewController = _detailViewController;
@synthesize vclXMLRPC = _vclXMLRPC;

static id instance = nil;

+ (id)getInstance {
	return instance;
}

- (void)awakeFromNib
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    self.clearsSelectionOnViewWillAppear = NO;
	    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	}
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	instance = self;
	
	self.clearsSelectionOnViewWillAppear = YES;

	self.vclXMLRPC.delegate = self;
	[self startLoading];
	
	self.navigationItem.leftBarButtonItem = self.editButtonItem;

	//self.detailViewController = (ReservationDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Reservation *object = [_objects objectAtIndex:indexPath.row];
        [[segue destinationViewController] setReservation:object];
    }
}

- (void)insertNewObject:(id)sender
{
	Reservation *newRequest = [[Reservation alloc] init];
	//newRequest.name = [NSString stringWithFormat:@"%@", [NSDate date]];
    [self addRequest:newRequest atIndex:0];
	
	//if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	
	//[self performSegueWithIdentifier:@"AddRequest" sender:self];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

	Reservation *object = [_objects objectAtIndex:indexPath.row];
	cell.textLabel.text = [object imageName];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEE, MMM d, yyyy 'at' h:mm a"];
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Ends on %@", [dateFormatter stringFromDate:[object endDate]]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		Reservation *object = [_objects objectAtIndex:indexPath.row];
		if(object == self.detailViewController.reservation) {
			[self.detailViewController clear];
		}
		[self.vclXMLRPC endRequestWithID:object.ID];
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        Reservation *object = [_objects objectAtIndex:indexPath.row];
        self.detailViewController.reservation = object;
		
		[(TabBarViewController *)self.tabBarController hideMasterPopup];
    }
}

#pragma mark - Request

- (VCLXMLRPC *)vclXMLRPC {
	if(!_vclXMLRPC) {
		_vclXMLRPC = [[VCLXMLRPC alloc] init];
	}
	return _vclXMLRPC;
}

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	NSDictionary *result = (NSDictionary *)[response object];
	if(response.isFault) {
		if([[[result objectForKey:@"faultCode"] stringValue] isEqualToString:@"3"]) {
			[[OneClickListViewController getInstance] showLoginWithMessage:YES];
		}
	}
	else if([[result objectForKey:@"status"] isEqualToString:@"success"]) {
		if([request.method isEqualToString:@"XMLRPCgetRequestIds"]) {
			[_objects removeAllObjects];
			for(NSDictionary *object in (NSDictionary *)[result objectForKey:@"requests"]) {
				Reservation *newRequest = [[Reservation alloc] init];
				
				newRequest.ID = [NSNumber numberWithInt:[(NSString *)[object objectForKey:@"requestid"] intValue]];
				newRequest.imageID = [NSNumber numberWithInt:[(NSString *)[object objectForKey:@"imageid"] intValue]];
				newRequest.osType = (NSString *)[object objectForKey:@"ostype"];
				newRequest.imageName = (NSString *)[object objectForKey:@"imagename"];
				newRequest.start = [NSNumber numberWithInt:[(NSString *)[object objectForKey:@"start"] intValue]];
				newRequest.end = [NSNumber numberWithInt:[(NSString *)[object objectForKey:@"end"] intValue]];
				[self addRequest:newRequest atIndex:0];
			}
		}
		
	}
	
	[self stopLoading];
	NSLog(@"Result %@", [response object]);
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error {
	NSLog(@"Error %@", error);
	
	[self stopLoading];
}

- (void)refresh {
	if([VCLXMLRPC isConnectedToInternetShowMessage:YES]) {
		[_objects removeAllObjects];
		[self.tableView reloadData];

		[self.vclXMLRPC getRequests];
	}
	else {
		[self stopLoading];
	}
}


- (void)addRequest:(Reservation *)Request atIndex:(NSUInteger)index {
	if (!_objects) {
        _objects = [[NSMutableOrderedSet alloc] init];
    }
	
    [_objects insertObject:Request atIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end
