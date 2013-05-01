//
//  XMLRPCRequest.h
//  OneClick
//
//  Created by Ignacio Dominguez on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLRPC/XMLRPCConnection.h"
#import "XMLRPC/XMLRPCConnectionDelegate.h"
#import "XMLRPC/XMLRPCConnectionManager.h"
#import "XMLRPC/XMLRPCResponse.h"
#import "XMLRPC/XMLRPCRequest.h"


@protocol VCLXMLRPCDelegate <NSObject>

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response;

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error;

@end




@interface VCLXMLRPC : NSObject <XMLRPCConnectionDelegate>

@property (nonatomic, strong) id<VCLXMLRPCDelegate> delegate;

+ (BOOL)isConnectedToInternetShowMessage:(BOOL)showMessage;
- (void)cancelCall;
- (void)getIP;
- (void)getOneClicks;
- (void)getOneClickParametersWithID:(NSNumber *)oneClickID;
- (void)addOneClick:(NSString *)name withImage:(NSNumber *)imageID withDuration:(NSNumber *)length withAutologin:(BOOL)autologin withPath:(NSString *)path;
- (void)editOneClick:(NSNumber *)oneClickID withName:(NSString *)name withImage:(NSNumber *)imageID withDuration:(NSNumber *)length withAutologin:(BOOL)autologin withPath:(NSString *)path;

- (void)deleteOneClick:(NSNumber *)oneClickID;
- (void)getImages;
- (void)addRequestForImageID:(NSNumber *)imageID starting:(NSString *)start withDuration:(NSNumber *)length withOneClickID:(NSNumber *)oneClickId withFlag:(NSNumber *) existingReservation;
- (void)endRequestWithID:(NSNumber *)requestID;
- (void)extendRequest:(NSNumber *)requestID withDuration:(NSNumber *)length;
- (void)getRequests;
- (void)getRequestStatus:(NSNumber *)requestID;
- (void)getRequestConnectData:(NSNumber *)requestID forIP:(NSString *)remoteIP;
- (void)test:(NSString *)text;

@end
