//
//  RDPServer.m
//  OneClick
//
//  Created by Ignacio Dominguez on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RDPServer.h"

@interface RDPServer()

@property (nonatomic) UIBackgroundTaskIdentifier taskIdentifier;


@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) GCDAsyncSocket *httpServer;

- (void) beginBackgroundUpdateTask;

- (void) endBackgroundUpdateTask;

@end

@implementation RDPServer

@synthesize taskIdentifier = _taskIdentifier;

@synthesize host = _host;
@synthesize user = _user;
@synthesize password = _password;

@synthesize httpServer = _httpServer;

-(GCDAsyncSocket *)httpServer {
	if(!_httpServer) {
		_httpServer = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	}
	return _httpServer;
}

- (void)stopServe {
	[self.httpServer disconnect];
	
	[self performSelector:@selector(endBackgroundUpdateTask) withObject:nil afterDelay:30];
	//[self endBackgroundUpdateTask];
}

- (NSNumber *)serveRDPToHost:(NSString *)host forUser:(NSString *)user withPassword:(NSString *)password {
	self.host = host;
	self.user = user;
	self.password = password;
	
	
	NSNumber *port = [NSNumber numberWithInt:((arc4random() % 501) + 10000)];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		[self beginBackgroundUpdateTask];
		
		NSError *error;
		if([self.httpServer acceptOnInterface:@"localhost" port:[port intValue] error:&error])
		//if([self.httpServer acceptOnPort:[port intValue] error:&error])
		{
			NSLog(@"Started HTTP Server on port %@", port);
		}
		else
		{
			NSLog(@"Error starting HTTP Server: %@", error);
		}

		
	});
	
	return port;
}

- (void) beginBackgroundUpdateTask
{
    self.taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void) endBackgroundUpdateTask
{
    [[UIApplication sharedApplication] endBackgroundTask: self.taskIdentifier];
    self.taskIdentifier = UIBackgroundTaskInvalid;
}



#pragma mark GCDAsyncSocket delegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
	NSLog(@"Client connected");
	[newSocket setDelegate:self];
	[newSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	NSString *request = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSLog(@"didReadData: %@\n\n", request );
	
	NSString *requestData= [NSString stringWithFormat:@
						 "auto connect:i:1\n"
						 "autoreconnection enabled:i:1\n"
						 "full address:s:%@\n"
						 "username:s:%@\n"
						 "itap password:s:%@\n"
						 "pocketcloud password:s:%@\n"
						 //"blaze acceleration:i:0\n"
						 "html password:s:%@\n\n", self.host, self.user, self.password, self.password, self.password];
	
	NSString *RDPFile = [NSString stringWithFormat:@"HTTP/1.1 200 OK\n"
						 "Content-Type: application/rdp; charset=utf-8\n"
						 "Content-Length: %d\n"
						 "Content-Disposition: attachment; filename=rdp.rdp\n\n"
						 "%@", requestData.length, requestData];
	
	NSLog(@"didReadData Response: %@\n\n", RDPFile );
	
	[sock writeData:[RDPFile dataUsingEncoding:NSUTF8StringEncoding] withTimeout:30 tag:123];
	[sock disconnectAfterReadingAndWriting];
	[self stopServe];

}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
	NSLog(@"socketDidDisconnect: %@", err);
}

@end
