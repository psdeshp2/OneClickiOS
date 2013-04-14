//
//  OneClick.h
//  OneClick
//
//  Created by Ignacio Dominguez on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneClick : NSObject

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *imageID;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *osType;
@property (nonatomic, strong) NSNumber *length;
@property BOOL autoLogin;
@property (nonatomic, strong) NSString *path;


+ (OneClick *)oneClickFromDictionary:(NSDictionary *)object;

+ (NSString *)minutesToString:(NSNumber *)minutes;

@end
