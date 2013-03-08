//
//  AppListViewController.h
//  OneClick
//
//  Created by Ignacio Dominguez on 7/29/12.
//
//

#import <UIKit/UIKit.h>

@class AppListViewController;

@protocol AppListDelegate <NSObject>

- (void)appListViewController:(AppListViewController *)sender didSelectApp: (NSString *)name;

@end

@interface AppListViewController : UITableViewController

@property (nonatomic, strong) id<AppListDelegate> delegate;
@property (nonatomic, strong) NSString *selectedApp;
@property (nonatomic, strong) NSDictionary *appList;

@end
