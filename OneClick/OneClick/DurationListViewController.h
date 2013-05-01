//
//  DurationListViewController.h
//  OneClick
//
//  Created by Ignacio Dominguez on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DurationListViewController;

@protocol DurationListDelegate <NSObject>

- (void)durationListViewController:(DurationListViewController *)sender didSelectDuration: (NSString *)name withMinutes:(NSNumber *)minutes;

@end

@interface DurationListViewController : UITableViewController 

@property (nonatomic, strong) id<DurationListDelegate> delegate;
@property (nonatomic, strong) NSNumber *selectedMinutes;

@end
