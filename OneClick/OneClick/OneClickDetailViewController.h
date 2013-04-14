//
//  DetailViewController.h
//  OneClick
//
//  Created by Ignacio Dominguez on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneClick.h"
#import "OneClickInputViewController.h"
#import "ReservationViewController.h"
#import "VCLXMLRPC.h"

@interface OneClickDetailViewController : UIViewController <OneClickInputViewControllerDelegate, ReservationViewControllerDelegate, VCLXMLRPCDelegate>

@property (strong, nonatomic) OneClick *oneClick;

- (void)clear;

@end
