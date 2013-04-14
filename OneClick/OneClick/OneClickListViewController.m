//
//  MasterViewController.m
//  OneClick
//
//  Created by Ignacio Dominguez on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OneClickListViewController.h"

#import "OneClickDetailViewController.h"
#import "ReservationDetailViewController.h"
#import "TabBarViewController.h"
#import "KeychainItemWrapper.h"
#import "Constants.h"

@interface OneClickListViewController () {
    NSMutableOrderedSet *_objects;
}

@property (strong, nonatomic) UIPopoverController *inputPopoverController;

@property (nonatomic, strong) VCLXMLRPC *vclXMLRPC;

- (void)addOneClick:(OneClick *)oneClick atIndex:(NSUInteger)index;

@end

@implementation OneClickListViewController

@synthesize inputPopoverController = _inputPopoverController;

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
	self.clearsSelectionOnViewWillAppear = YES;
	instance = self;
	self.vclXMLRPC.delegate = self;	
	self.detailViewController = (OneClickDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	//Verify if credentials are stored
	KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:keychainCredentialKey accessGroup:nil];
	
	NSString *login = [keychainWrapper objectForKey:(__bridge id)kSecAttrAccount];
	NSString *password = [keychainWrapper objectForKey:(__bridge id)kSecValueData];
	if(login == nil || password == nil || [login isEqualToString:@""] || [password isEqualToString:@""]) {
		
		[self performSelector:@selector(showLoginWithMessage:) withObject:nil afterDelay:0];
		//[self showLoginWithMessage:NO];
	}
	else {
		//Load OneButtons
		[self startLoading];
	}
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
        OneClick *object = [_objects objectAtIndex:indexPath.row];
        [[segue destinationViewController] setOneClick:object];
    }
	else if ([[segue identifier] isEqualToString:@"AddOneClick"]) {
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
	}
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

	OneClick *object = [_objects objectAtIndex:indexPath.row];
	cell.textLabel.text = [object name];
	cell.detailTextLabel.text = [object imageName];
	cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_cell.png", [object osType]]];
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
		OneClick *object = [_objects objectAtIndex:indexPath.row];
		[self.vclXMLRPC deleteOneClick:object.ID];
		if(object == self.detailViewController.oneClick) {
			[self.detailViewController clear];
		}
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        OneClick *object = [_objects objectAtIndex:indexPath.row];
        self.detailViewController.oneClick = object;
		
		[(TabBarViewController *)self.tabBarController hideMasterPopup];
    }
}

#pragma mark - OneClick

- (VCLXMLRPC *)vclXMLRPC {
	if(!_vclXMLRPC) {
		_vclXMLRPC = [[VCLXMLRPC alloc] init];
	}
	return _vclXMLRPC;
}

- (void)showLoginWithMessage:(BOOL)showMessage {
	if(showMessage) {
		[self showErrorAlert:@"Invalid login and password combination. Did you change your password recently?" withTitle:@"Invalid credentials"];
	}
	[self performSegueWithIdentifier:@"ShowLoginScreen" sender:self];
}

#pragma mark - Input delegate

- (void)oneClickInputCancel:(OneClickInputViewController *)sender {
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		[self.inputPopoverController dismissPopoverAnimated:YES];
	}
	else {
		[sender dismissModalViewControllerAnimated:YES];
	}
}

- (void)oneClickInputDone:(OneClickInputViewController *)sender withResult:(OneClick *)oneClick {
	[self.vclXMLRPC addOneClick:oneClick.name withImage:oneClick.imageID withDuration:oneClick.length withAutologin:oneClick.autoLogin withPath:oneClick.path];
	[self oneClickInputCancel:sender];
	[self addOneClick:oneClick atIndex:0];
}

#pragma mark - XMLRPC delegate

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response {
	
	NSDictionary *result = (NSDictionary *)[response object];
	if(response.isFault) {
		if([[[result objectForKey:@"faultCode"] stringValue] isEqualToString:@"3"]) {
			[self showLoginWithMessage:YES];
		}
	}
	else if([[result objectForKey:@"status"] isEqualToString:@"success"]) {
		if([request.method isEqualToString:@"XMLRPCgetOneClicks"]) {
			int i = 0;
			for(NSDictionary *object in (NSDictionary *)[result objectForKey:@"oneclicks"]) {
				OneClick *newOneClick = [OneClick oneClickFromDictionary:object];
				
				
				[self addOneClick:newOneClick atIndex:i];
				
				i++;
			}
		}
		else if([request.method isEqualToString:@"XMLRPCaddOneClick"]) {
		}
		else if([request.method isEqualToString:@"XMLRPCdeleteOneClick"]) {
		}
	}
	else if([[result objectForKey:@"status"] isEqualToString:@"error"]) {
		
		//TODO: detect login fail
		[self request:request didFailWithError:nil];
	}
	
	[self stopLoading];
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error {
	NSLog(@"Error %@", error);
	if([request.method isEqualToString:@"XMLRPCgetOneClicks"]) {
		//[self showErrorAlert:@"" withTitle:@"Operation Not Performed"];
	}
	else if([request.method isEqualToString:@"XMLRPCaddOneClick"]) {
		[self showErrorAlert:@"The OneClick could not be added. Please try again later." withTitle:@"Operation Not Performed"];
	}
	else if([request.method isEqualToString:@"XMLRPCdeleteOneClick"]) {
		[self startLoading];
		[self showErrorAlert:@"The OneClick could not be deleted." withTitle:@"Operation Not Performed"];
	}
	[self stopLoading];
}

- (void)refresh {
	if([VCLXMLRPC isConnectedToInternetShowMessage:YES]) {
		[_objects removeAllObjects];
		[self.tableView reloadData];
		[self.vclXMLRPC getOneClicks];
	}
	else {
		[self stopLoading];
	}
}


- (void)addOneClick:(OneClick *)oneClick atIndex:(NSUInteger)index {
	if (!_objects) {
        _objects = [[NSMutableOrderedSet alloc] init];
    }
	
    [_objects insertObject:oneClick atIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	if([self.detailViewController.oneClick.ID intValue] == [oneClick.ID intValue]) {
		[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
		self.detailViewController.oneClick = oneClick;
	}
	
}

- (void)showErrorAlert:(NSString *)message withTitle:(NSString *)title {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													  message:message
													 delegate:nil
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
	
	[alert show];
}


@end
