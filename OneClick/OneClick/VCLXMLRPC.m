//
//  XMLRPCRequest.m
//  OneClick
//
//  Created by Ignacio Dominguez on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VCLXMLRPC.h"
#import "Reachability.h"
#import "KeychainItemWrapper.h"
#import "Constants.h"

@interface VCLXMLRPC()

@property (nonatomic, strong) XMLRPCRequest *request;
@property (nonatomic, strong) NSString *lastConnectionID;

- (void)makeRequest;

@end


@implementation VCLXMLRPC

@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize lastConnectionID = _lastConnectionID;

- (id)init {
	self = [super init];
	if(self) {
		NSURL *URL = [NSURL URLWithString:VCLURL];
		self.request = [[XMLRPCRequest alloc] initWithURL: URL];
		
		
		[self.request setHTTPHeader:@"X-APIVERSION" withValue:@"2"];
		
	}
	return self;
}

- (void)makeRequest {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	
	KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:keychainCredentialKey accessGroup:nil];
	
	NSString *login = [keychainWrapper objectForKey:(__bridge id)kSecAttrAccount];
	NSString *password = [keychainWrapper objectForKey:(__bridge id)kSecValueData];
	
	/*[self.request setHTTPHeader:@"X-User" withValue:@"admin"];
	[self.request setHTTPHeader:@"X-Pass" withValue:@"3sandboxpass2"];*/
	
	[self.request setHTTPHeader:@"X-User" withValue:login];
	[self.request setHTTPHeader:@"X-Pass" withValue:password];
	
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
	self.lastConnectionID = [manager spawnConnectionWithXMLRPCRequest:self.request delegate:self];
}

#pragma mark - XMLRPCDelegate

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	self.lastConnectionID = nil;
	[self.delegate request: request didReceiveResponse: response];
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	self.lastConnectionID = nil;
	[self.delegate request: request didFailWithError: error];
}

- (BOOL)request: (XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	//return NO;
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
	if ([challenge.protectionSpace.authenticationMethod isEqualToString: NSURLAuthenticationMethodServerTrust])
		//if ([trustedHosts containsObject:challenge.protectionSpace.host])
		[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
}

#pragma mark - Public methods

+ (BOOL)isConnectedToInternetShowMessage:(BOOL)showMessage {
	
	Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if(networkStatus == NotReachable) {
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
														  message:@"The VCL OneClick app requires that you have an active internet connection."
														 delegate:nil
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
		
		[message show];
		return NO;
	}
	return YES;
}

- (void)cancelCall {
	XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
	if(self.lastConnectionID) {
		[manager closeConnectionForIdentifier:self.lastConnectionID];
		self.lastConnectionID = nil;
		UIApplication* app = [UIApplication sharedApplication];
		app.networkActivityIndicatorVisible = NO;
	}
}

#pragma mark - VCL Methods

- (void)getIP {
	NSArray *parameters = [[NSArray alloc] initWithObjects: nil];
	[self.request setMethod:@"XMLRPCgetIP" withParameters:parameters];
	[self makeRequest];
}

- (void)getOneClicks {
	NSArray *parameters = [[NSArray alloc] initWithObjects:nil];
	[self.request setMethod:@"XMLRPCgetOneClicks" withParameters:parameters];
	[self makeRequest];
}

- (void)getOneClickParametersWithID:(NSNumber *)oneClickID {
		//[request setMethod: @"XMLRPCtest" withParameter: @"Sample test Ignacioxd"];*/
	NSArray *parameters = [[NSArray alloc] initWithObjects:oneClickID, nil];
	[self.request setMethod:@"XMLRPCgetOneClickParams" withParameters:parameters];
	[self makeRequest];
}

- (void)addOneClick:(NSString *)name withImage:(NSNumber *)imageID withDuration:(NSNumber *)length withAutologin:(BOOL)autologin {
	NSArray *parameters = [[NSArray alloc] initWithObjects:name, imageID, length, [NSNumber numberWithInt:(autologin ? 1 : 0)], nil];
	[self.request setMethod:@"XMLRPCaddOneClick" withParameters:parameters];
	[self makeRequest];
}

- (void)editOneClick:(NSNumber *)oneClickID withName:(NSString *)name withImage:(NSNumber *)imageID withDuration:(NSNumber *)length withAutologin:(BOOL)autologin {
	NSArray *parameters = [[NSArray alloc] initWithObjects:oneClickID, name, imageID, length, [NSNumber numberWithInt:(autologin ? 1 : 0)], nil];
	[self.request setMethod:@"XMLRPCeditOneClick" withParameters:parameters];
	[self makeRequest];
}

- (void)deleteOneClick:(NSNumber *)oneClickID {
	NSArray *parameters = [[NSArray alloc] initWithObjects:oneClickID, nil];
	[self.request setMethod:@"XMLRPCdeleteOneClick" withParameters:parameters];
	[self makeRequest];
}

- (void)getImages {
	NSArray *parameters = [[NSArray alloc] initWithObjects:nil];
	[self.request setMethod:@"XMLRPCgetImages" withParameters:parameters];
	[self makeRequest];
}

- (void)addRequestForImageID:(NSNumber *)imageID starting:(NSString *)start withDuration:(NSNumber *)length {
	NSArray *parameters = [[NSArray alloc] initWithObjects:imageID, start, length, nil];
	[self.request setMethod:@"XMLRPCaddRequest" withParameters:parameters];
	[self makeRequest];
}

- (void)endRequestWithID:(NSNumber *)requestID {
	NSArray *parameters = [[NSArray alloc] initWithObjects:requestID, nil];
	[self.request setMethod:@"XMLRPCendRequest" withParameters:parameters];
	[self makeRequest];
}

- (void)getRequests {
	NSArray *parameters = [[NSArray alloc] initWithObjects:nil];
	[self.request setMethod:@"XMLRPCgetRequestIds" withParameters:parameters];
	[self makeRequest];
}

- (void)getRequestStatus:(NSNumber *)requestID {
	NSArray *parameters = [[NSArray alloc] initWithObjects:requestID, nil];
	[self.request setMethod:@"XMLRPCgetRequestStatus" withParameters:parameters];
	[self makeRequest];
}

- (void)getRequestConnectData:(NSNumber *)requestID forIP:(NSString *)remoteIP {
	NSArray *parameters = [[NSArray alloc] initWithObjects:requestID, remoteIP, nil];
	[self.request setMethod:@"XMLRPCgetRequestConnectData" withParameters:parameters];
	[self makeRequest];
}

- (void)test:(NSString *)text {
	NSArray *parameters = [[NSArray alloc] initWithObjects:text, nil];
	[self.request setMethod:@"XMLRPCtest" withParameters:parameters];
	[self makeRequest];
}

@end
