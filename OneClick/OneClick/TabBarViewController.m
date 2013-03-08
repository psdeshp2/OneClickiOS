//
//  TabBarViewController.m
//  OneClick
//
//  Created by Ignacio Dominguez on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TabBarViewController.h"
#import "OneClickListViewController.h"
#import "OneClickDetailViewController.h"
#import "ReservationListViewController.h"
#import "ReservationDetailViewController.h"

@interface TabBarViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation TabBarViewController

@synthesize masterPopoverController = _masterPopoverController;

- (void)viewDidLoad {
	self.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	if ([tabBarController selectedIndex] == 0) {
		UINavigationController *navController = (UINavigationController *)viewController;
		OneClickListViewController *listView = [navController.viewControllers objectAtIndex:0];
		/*if(!listView.detailViewController) {
			navController = [self.splitViewController.storyboard instantiateViewControllerWithIdentifier:@"OneClickDetailViewRoot"];
		}*/
		navController = [self.splitViewController.storyboard instantiateViewControllerWithIdentifier:@"OneClickDetailViewRoot"];
		
		NSMutableArray * viewControllers = [self.splitViewController.viewControllers mutableCopy];
		[viewControllers replaceObjectAtIndex:1 withObject:navController];
		self.splitViewController.viewControllers = [viewControllers copy];
		
		listView.detailViewController = [navController.viewControllers objectAtIndex:0];
	}
	else if ([tabBarController selectedIndex] == 1) {
		UINavigationController *navController = (UINavigationController *)viewController;
		ReservationListViewController *listView = [navController.viewControllers objectAtIndex:0];
		//if(!listView.detailViewController) {
			navController = [self.splitViewController.storyboard instantiateViewControllerWithIdentifier:@"ReservationDetailViewRoot"];
		//}
		
		NSMutableArray * viewControllers = [self.splitViewController.viewControllers mutableCopy];
		[viewControllers replaceObjectAtIndex:1 withObject:navController];
		self.splitViewController.viewControllers = [viewControllers copy];
		
		listView.detailViewController = [navController.viewControllers objectAtIndex:0];
	}
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
	UINavigationController *navigationController = [splitController.viewControllers lastObject];
	
    barButtonItem.title = NSLocalizedString(@"Menu", @"Menu");
    [navigationController.topViewController.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
	UINavigationController *navigationController = [splitController.viewControllers lastObject];

    [navigationController.topViewController.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)hideMasterPopup {
	if (self.masterPopoverController != nil) {
		[self.masterPopoverController dismissPopoverAnimated:YES];
	}
}

@end
