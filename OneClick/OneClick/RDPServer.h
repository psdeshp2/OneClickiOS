//
//  RDPServer.h
//  OneClick
//
//  Created by Ignacio Dominguez on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface RDPServer : NSObject <GCDAsyncSocketDelegate>

- (void)stopServe;

- (NSNumber *)serveRDPToHost:(NSString *)host forUser:(NSString *)user withPassword:(NSString *)password;

@end
