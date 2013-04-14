//
//  Request.m
//  OneClick
//
//  Created by Ignacio Dominguez on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Reservation.h"

@implementation Reservation

@synthesize ID = _ID;
@synthesize imageID = _imageID;
@synthesize imageName = _imageName;
@synthesize osType = _osType;
@synthesize start = _start;
@synthesize startDate = _startDate;
@synthesize end = _end;
@synthesize endDate = _endDate;

- (void)setStart:(NSNumber *)start {
	_start = start;
    self.startDate = [NSDate dateWithTimeIntervalSince1970:[start doubleValue]];
}

- (void)setEnd:(NSNumber *)end {
	_end = end;
    self.endDate = [NSDate dateWithTimeIntervalSince1970:[end doubleValue]];
}

@end
