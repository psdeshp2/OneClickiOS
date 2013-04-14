//
//  OneClickInputViewController.h
//  OneClick
//
//  Created by Ignacio Dominguez on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneClick.h"
#import "ImageListViewController.h"
#import "DurationListViewController.h"

@class OneClickInputViewController;

@protocol OneClickInputViewControllerDelegate <NSObject>

- (void)oneClickInputCancel:(OneClickInputViewController *)sender;
- (void)oneClickInputDone:(OneClickInputViewController *)sender withResult:(OneClick *)oneClick;

@end

@interface OneClickInputViewController : UITableViewController <ImageListDelegate, DurationListDelegate>

@property (nonatomic, strong) id<OneClickInputViewControllerDelegate> delegate;
@property (nonatomic, strong) OneClick *oneClick;

@end
