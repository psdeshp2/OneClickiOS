//
//  LoginViewController.m
//  OneClick
//
//  Created by Ignacio Dominguez on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "OneClickListViewController.h"
#import "KeychainItemWrapper.h"
#import "Constants.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *textLogin;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;
@property (strong, nonatomic) IBOutlet UIButton *buttonLogin;
@property (strong, nonatomic) IBOutlet UIView *viewLoading;
@property (nonatomic, strong) VCLXMLRPC *vclXMLRPC;

- (void)setEnabledControls:(BOOL)enabled;

@end

@implementation LoginViewController

@synthesize textLogin = _textLogin;
@synthesize textPassword = _textPassword;
@synthesize buttonLogin = _buttonLogin;
@synthesize viewLoading = _viewLoading;
@synthesize vclXMLRPC = _vclXMLRPC;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	//[self dismissModalViewControllerAnimated:YES];
	self.vclXMLRPC.delegate = self;
	[self setEnabledControls:YES];
	[self validateLogin];
}

- (void)viewDidUnload
{
	[self setTextLogin:nil];
	[self setTextPassword:nil];
	[self setButtonLogin:nil];
	[self setViewLoading:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)inputTextChanged:(UITextField *)sender {
	[self validateLogin];
}

- (IBAction)signInActivated:(UIButton *)sender {
	
	KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:keychainCredentialKey accessGroup:nil];
	
	[keychainWrapper resetKeychainItem];
	[keychainWrapper setObject:self.textLogin.text forKey:(__bridge id)kSecAttrAccount];
	[keychainWrapper setObject:@"VCL OneClick" forKey:(__bridge id)kSecAttrService];
	[keychainWrapper setObject:self.textPassword.text forKey:(__bridge id)kSecValueData];
	
	//Use credentials in keychain to make XMLRPC request to test.
	[self setEnabledControls:NO];
	[self.vclXMLRPC getOneClicks];
	
	//Remove credentials from keychain in case they are invalid.
	//Add them again when they are verified
	[keychainWrapper resetKeychainItem];
	keychainWrapper = nil;
}

#pragma mark - XMLRPC delegate

- (VCLXMLRPC *)vclXMLRPC {
	if(!_vclXMLRPC) {
		_vclXMLRPC = [[VCLXMLRPC alloc] init];
	}
	return _vclXMLRPC;
}

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response {
	OneClickListViewController *listView = [OneClickListViewController getInstance];
	NSDictionary *result = (NSDictionary *)[response object];
	if(response.isFault) {
		if([[[result objectForKey:@"faultCode"] stringValue] isEqualToString:@"3"]) {
			[listView showErrorAlert:@"The username and password combination is invalid. Please try again." withTitle:@"Invalid credentials"];
		}
		else {
			[listView showErrorAlert:@"There was a problem validating your credentials. Please try again in a few minutes." withTitle:@"Validation error"];
		}
	}
	else if([[result objectForKey:@"status"] isEqualToString:@"error"]) {
		NSLog(@"%@", result);
		[listView showErrorAlert:@"You are not allowed to use OneClick functionality." withTitle:@"Validation error"];
	}
	else if([[result objectForKey:@"status"] isEqualToString:@"success"]) {
		//Add credentials into keychain
		KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:keychainCredentialKey accessGroup:nil];
		
		[keychainWrapper resetKeychainItem];
		[keychainWrapper setObject:self.textLogin.text forKey:(__bridge id)kSecAttrAccount];
		[keychainWrapper setObject:@"VCL OneClick" forKey:(__bridge id)kSecAttrService];
		[keychainWrapper setObject:self.textPassword.text forKey:(__bridge id)kSecValueData];
		keychainWrapper = nil;
		
		[listView request:request didReceiveResponse:response];
		
		[self dismissModalViewControllerAnimated:YES];
	}
	else {
		[listView showErrorAlert:@"There was a problem validating your credentials. Please try again in a few minutes." withTitle:@"Validation error"];
	}
	[self setEnabledControls:YES];
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error {
	[self setEnabledControls:YES];
	OneClickListViewController *listView = [OneClickListViewController getInstance];
	[listView showErrorAlert:@"There was a problem validating your credentials. Please try again in a few minutes." withTitle:@"Validation error"];
}


- (void)validateLogin {
	if(self.textLogin.text == nil || [self.textLogin.text isEqualToString:@""]) {
		[self.buttonLogin setEnabled:NO];
		return;
	}
	else if(self.textPassword.text == nil || [self.textPassword.text isEqualToString:@""]) {
		[self.buttonLogin setEnabled:NO];
		return;
	}
	[self.buttonLogin setEnabled:YES];
}


- (void)setEnabledControls:(BOOL)enabled {
	[self.viewLoading setHidden:enabled];
	[self.textLogin setEnabled:enabled];
	[self.textPassword setEnabled:enabled];
	[self.buttonLogin setEnabled:enabled];
}


@end
