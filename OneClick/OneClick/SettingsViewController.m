//
//  SettingsViewController.m
//  OneClick
//
//  Created by Ignacio Dominguez on 7/28/12.
//
//

#import "SettingsViewController.h"
#import "KeychainItemWrapper.h"
#import "Constants.h"
#import "OneClickListViewController.h"

@interface SettingsViewController ()

@property (strong, nonatomic) IBOutlet UITableViewCell *sshCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *rdpCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *usernameCell;

@property (strong, nonatomic) NSDictionary *rdpAppList;
@property (strong, nonatomic) NSDictionary *sshAppList;

- (void)configureView;

@end

@implementation SettingsViewController
@synthesize sshCell;
@synthesize rdpCell;
@synthesize usernameCell;

@synthesize rdpAppList = _rdpAppList;
@synthesize sshAppList = _sshAppList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.rdpAppList = [NSDictionary dictionaryWithObjectsAndKeys:
					   @"PocketCloud",
					   @"pocketcloud",
					   @"iTap",
					   @"itaprdp",
					   @"Ericom AccessToGo",
					   @"ericom",
					   @"Jump",
					   @"jump",
					   nil];
	
	self.sshAppList = [NSDictionary dictionaryWithObjectsAndKeys:
					   @"SSH (iSSH)",
					   @"ssh",
					   nil];
	
	[self configureView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:keychainCredentialKey accessGroup:nil];
	
	NSString *login = [keychainWrapper objectForKey:(__bridge id)kSecAttrAccount];
	[self.usernameCell.detailTextLabel setText:login];
}

- (void)viewDidUnload
{
	[self setSshCell:nil];
	[self setRdpCell:nil];
	[self setUsernameCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSString *defaultRDPApp = [settings stringForKey: RDPAppKey];
	NSString *defaultSSHApp = [settings stringForKey: SSHAppKey];
    if([[segue identifier] isEqualToString:@"RDPAppList"]) {
		((AppListViewController *)[segue destinationViewController]).title = @"Default RDP App";
		((AppListViewController *)[segue destinationViewController]).delegate = self;
        ((AppListViewController *)[segue destinationViewController]).appList = self.rdpAppList;
        ((AppListViewController *)[segue destinationViewController]).selectedApp = defaultRDPApp;
    }
	else if([[segue identifier] isEqualToString:@"SSHAppList"]) {
		((AppListViewController *)[segue destinationViewController]).title = @"Default SSH App";
		((AppListViewController *)[segue destinationViewController]).delegate = self;
        ((AppListViewController *)[segue destinationViewController]).appList = self.sshAppList;
        ((AppListViewController *)[segue destinationViewController]).selectedApp = defaultSSHApp;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)signOut:(UIButton *)sender {
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Clear credentials?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Sign Out" otherButtonTitles:nil];
	
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showFromRect:sender.bounds inView:sender animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) { //Sign out
		KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:keychainCredentialKey accessGroup:nil];
		
		[keychainWrapper resetKeychainItem];
		[[OneClickListViewController getInstance] showLoginWithMessage:NO];
	} else if (buttonIndex == 1) {
	}
}

#pragma mark - OneClick


- (void)configureView {
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSString *defaultRDPApp = [settings stringForKey: RDPAppKey];
	NSString *defaultSSHApp = [settings stringForKey: SSHAppKey];
	
	self.rdpCell.detailTextLabel.text = [self.rdpAppList objectForKey:defaultRDPApp];
	self.sshCell.detailTextLabel.text = [self.sshAppList objectForKey:defaultSSHApp];
}

- (void)appListViewController:(AppListViewController *)sender didSelectApp: (NSString *)name {
	[self.navigationController popViewControllerAnimated:YES];
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	if(sender.appList == self.sshAppList) { //Update SSH default
		[settings setObject:name forKey:SSHAppKey];
	}
	else {
		[settings setObject:name forKey:RDPAppKey];
	}
	[settings synchronize];
	[self configureView];
}

@end
