//
//  OneClickInputViewController.m
//  OneClick
//
//  Created by Ignacio Dominguez on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OneClickInputViewController.h"

@interface OneClickInputViewController ()

@property (strong, nonatomic) IBOutlet UITextField *textName;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellEnvironment;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDuration;
@property (strong, nonatomic) IBOutlet UISwitch *switchAutologin;
@property (strong, nonatomic) IBOutlet UITextField *textPath;

- (void)configureView;
- (void)validateOneClick;

@end

@implementation OneClickInputViewController

@synthesize textName = _textName;
@synthesize cellEnvironment = _cellEnvironment;
@synthesize cellDuration = _cellDuration;
@synthesize switchAutologin = _switchAutologin;
@synthesize textPath = _textPath;

@synthesize delegate = _delegate;
@synthesize oneClick = _oneClick;


-(OneClick *)oneClick {
	if(!_oneClick) {
		_oneClick = [[OneClick alloc] init];
		_oneClick.autoLogin = YES;
	}
	return _oneClick;
	
}

- (void)setOneClick:(OneClick *)oneClick {
	_oneClick = oneClick;
	self.title = @"Edit OneClick";
	[self configureView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self configureView];
}

- (void)viewDidUnload
{
	[self setCellEnvironment:nil];
	[self setCellDuration:nil];
	[self setSwitchAutologin:nil];
	[self setTextName:nil];
    [self setTextPath:nil];
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
    if([[segue identifier] isEqualToString:@"selectImage"]) {
		((ImageListViewController *)[segue destinationViewController]).delegate = self;
        ((ImageListViewController *)[segue destinationViewController]).selectedImageID = self.oneClick.imageID;
    }
	else if([[segue identifier] isEqualToString:@"selectDuration"]) {
		((DurationListViewController *)[segue destinationViewController]).delegate = self;
        ((DurationListViewController *)[segue destinationViewController]).selectedMinutes = self.oneClick.length;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


#pragma mark - OneClick

- (void)configureView {
	if(self.oneClick.name)
		[self.textName setText:self.oneClick.name];
	if(self.oneClick.imageName)
		[self.cellEnvironment.detailTextLabel setText:self.oneClick.imageName];
	if(self.oneClick.length)
		[self.cellDuration.detailTextLabel setText:[OneClick minutesToString:self.oneClick.length]];
	[self.switchAutologin setOn:self.oneClick.autoLogin];
    if(self.oneClick.path)
		[self.textPath setText:self.oneClick.path];
	
	[self validateOneClick];
}


- (void)validateOneClick {
	if(self.oneClick.name == nil || [self.oneClick.name isEqualToString:@""]) {
		[[self.navigationItem rightBarButtonItem] setEnabled:NO];
		return;
	}
	else if(self.oneClick.imageID == nil) {
		[[self.navigationItem rightBarButtonItem] setEnabled:NO];
		return;
	}
	else if(self.oneClick.length == nil) {
		[[self.navigationItem rightBarButtonItem] setEnabled:NO];
		return;
	}
	
	[[self.navigationItem rightBarButtonItem] setEnabled:YES];
}

- (IBAction)nameTextChanged:(UITextField *)sender {
	self.oneClick.name = sender.text;
	[self validateOneClick];
}

- (IBAction)pathTextChanged:(UITextField *)sender {
	self.oneClick.path = sender.text;
	[self validateOneClick];
}

- (IBAction)autologinSwitchChanged:(UISwitch *)sender {
	self.oneClick.autoLogin = sender.isOn;
}

#pragma mark - Navigation Bar Buttons

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
	[self.delegate oneClickInputCancel:self];
}

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
	[self.delegate oneClickInputDone:self withResult:self.oneClick];
}

#pragma mark - Image selection delegate

- (void)imageListViewController:(ImageListViewController *)sender didSelectImage: (NSString *)name withID:(NSNumber *)ID withOSType:(NSString *)ostype {
	self.oneClick.imageID = ID;
	self.oneClick.imageName = name;
	self.oneClick.osType = ostype;
	[self.navigationController popViewControllerAnimated:YES];
	[self configureView];
}

- (void)imageListViewController:(ImageListViewController *)sender didFailWithError: (NSError *)error {
	NSLog(@"Error %@", error);
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Duration selection delegate

- (void)durationListViewController:(DurationListViewController *)sender didSelectDuration: (NSString *)name withMinutes:(NSNumber *)minutes {
	self.oneClick.length = minutes;
	[self.navigationController popViewControllerAnimated:YES];
	[self configureView];
}


@end
