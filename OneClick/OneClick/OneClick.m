//
//  OneClick.m
//  OneClick
//
//  Created by Ignacio Dominguez on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OneClick.h"

@implementation OneClick

@synthesize ID = _ID;
@synthesize name = _name;
@synthesize imageID = _imageID;
@synthesize imageName = _imageName;
@synthesize osType = _osType;
@synthesize length = _length;
@synthesize autoLogin = _autoLogin;


+ (OneClick *)oneClickFromDictionary:(NSDictionary *)object {
	OneClick *newOneClick = [[OneClick alloc] init];
	
	newOneClick.ID = [NSNumber numberWithInt:[(NSString *)[object objectForKey:@"oneclickid"] intValue]];
	newOneClick.name = (NSString *)[object objectForKey:@"name"];
	newOneClick.imageID = [NSNumber numberWithInt:[(NSString *)[object objectForKey:@"imageid"] intValue]];
	newOneClick.imageName = (NSString *)[object objectForKey:@"imagename"];
	newOneClick.osType = (NSString *)[object objectForKey:@"ostype"];
	newOneClick.length = [NSNumber numberWithInt:[(NSString *)[object objectForKey:@"duration"] intValue]];
	newOneClick.autoLogin = [[NSString stringWithFormat:@"%@", [object objectForKey:@"autologin"]] isEqualToString:@"1"];
	
	return newOneClick;
}

- (NSString *)description {
	return self.name;
}

-(id)copyWithZone:(NSZone *)zone {
	OneClick *copy = [[OneClick alloc] init];
	copy.ID = [self.ID copyWithZone:zone];
	copy.name = [self.name copyWithZone:zone];
	copy.imageID = [self.imageID copyWithZone:zone];
	copy.imageName = [self.imageName copyWithZone:zone];
	copy.osType = [self.osType copyWithZone:zone];
	copy.length = [self.length copyWithZone:zone];
	copy.autoLogin = self.autoLogin;
	return copy;
}


+ (NSString *)minutesToString:(NSNumber *)minutes {
	if([minutes intValue] == 1) {
		return @"1 minute";
	}
	if([minutes intValue] < 60) {
		return [NSString stringWithFormat:@"%@ minutes", minutes];
	}
	else if([minutes intValue] == 60) {
		return  @"1 hour";
	}
	else if([minutes intValue] > 60 && [minutes intValue] < 24 * 60) {
		NSNumber *hours = [NSNumber numberWithInt:[minutes intValue] / 60];
		return  [NSString stringWithFormat:@"%@ hours", hours];
	}
	else if([minutes intValue] == 24 * 60) {
		return @"1 day";
	}
	else {
		NSNumber *days = [NSNumber numberWithInt:[minutes intValue] / 60 / 24];
		return  [NSString stringWithFormat:@"%@ days", days];
	}
	
}

@end
