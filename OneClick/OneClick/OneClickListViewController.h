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
#import "OneClickInputViewController.h"

@class OneClickDetailViewController;

@interface OneClickListViewController : PullRefreshTableViewController <OneClickInputViewControllerDelegate, VCLXMLRPCDelegate>

@property (strong, nonatomic) OneClickDetailViewController *detailViewController;

+ (id)getInstance;

- (void)showLoginWithMessage:(BOOL)showMessage;

- (void)showErrorAlert:(NSString *)message withTitle:(NSString *)title;

@end
