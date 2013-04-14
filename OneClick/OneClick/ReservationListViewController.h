//
//  MasterViewController.h
//  OneClick
//
//  Created by Ignacio Dominguez on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "VCLXMLRPC.h"

@class ReservationDetailViewController;

@interface ReservationListViewController : PullRefreshTableViewController <VCLXMLRPCDelegate>

@property (strong, nonatomic) ReservationDetailViewController *detailViewController;

+ (id)getInstance;

@end
