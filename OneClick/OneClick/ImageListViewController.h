//
//  ImageListViewController.h
//  OneClick
//
//  Created by Ignacio Dominguez on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "VCLXMLRPC.h"

@class ImageListViewController;

@protocol ImageListDelegate <NSObject>

- (void)imageListViewController:(ImageListViewController *)sender didSelectImage: (NSString *)name withID:(NSNumber *)ID;

- (void)imageListViewController:(ImageListViewController *)sender didFailWithError: (NSError *)error;

@end

@interface ImageListViewController : PullRefreshTableViewController <VCLXMLRPCDelegate>

@property (nonatomic, strong) id<ImageListDelegate> delegate;
@property (nonatomic, strong) NSNumber *selectedImageID;

@end
