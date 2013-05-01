//
//  ReservationViewController.h
//  OneClick
//
//  Created by Ignacio Dominguez on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCLXMLRPC.h"
#import "OneClick.h"
#import "Reservation.h"
#import "RDPServer.h"

@class ReservationViewController;

@protocol ReservationViewControllerDelegate <NSObject>

- (void)reservationCancel:(ReservationViewController *)sender;
- (void)reservationDone:(ReservationViewController *)sender withResult:(OneClick *)oneClick;

@end

@interface ReservationViewController : UIViewController <VCLXMLRPCDelegate>

@property (nonatomic, strong) id<ReservationViewControllerDelegate> delegate;
@property (nonatomic, strong) OneClick *oneClick;
@property (nonatomic, strong) Reservation *reservation;

@property (nonatomic, strong) NSNumber *existingReservation;

@end
