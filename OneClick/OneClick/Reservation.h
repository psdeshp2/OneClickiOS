//
//  Request.h
//  OneClick
//
//  Created by Ignacio Dominguez on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reservation : NSObject

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSNumber *imageID;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *osType;
@property (nonatomic, strong) NSNumber *start;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSNumber *end;
@property (nonatomic, strong) NSDate *endDate;


@end
