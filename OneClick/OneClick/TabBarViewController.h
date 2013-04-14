//
//  TabBarViewController.h
//  OneClick
//
//  Created by Ignacio Dominguez on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarViewController : UITabBarController <UISplitViewControllerDelegate, UITabBarControllerDelegate>

- (void)hideMasterPopup;

@end
