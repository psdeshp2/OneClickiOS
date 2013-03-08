//
//  ReservationDetailViewController.h
//  OneClick
//
//  Created by Ignacio Dominguez on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"
#import "ReservationViewController.h"

@interface ReservationDetailViewController : UIViewController <ReservationViewControllerDelegate, UIActionSheetDelegate, VCLXMLRPCDelegate>

@property (strong, nonatomic) Reservation *reservation;

- (void)clear;

@end
