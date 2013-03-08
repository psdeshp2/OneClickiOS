//
//  DurationListViewController.m
//  OneClick
//
//  Created by Ignacio Dominguez on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DurationListViewController.h"
#import "OneClick.h"

@interface DurationListViewController () {
	NSMutableOrderedSet *_objects;
}
@end

@implementation DurationListViewController

@synthesize delegate = _delegate;
@synthesize selectedMinutes = _selectedMinutes;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
	int minutes = 0;
	if(indexPath.row  == 0) {
		minutes = 30;
	}
	else if(indexPath.row  ==  1) {
		minutes = 60;
	}
	else if(indexPath.row >= 2 && indexPath.row <= 23) {
		minutes = 60 * indexPath.row;
	}
	else {
		minutes = 60 * 24 * (indexPath.row - 23);
	}
	
	if (!_objects) {
        _objects = [[NSMutableOrderedSet alloc] init];
    }
	
	[_objects addObject:[NSNumber numberWithInt:minutes]];
	cell.textLabel.text = [OneClick minutesToString:[NSNumber numberWithInt:minutes]];
	if([self.selectedMinutes intValue] == minutes) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	NSNumber *object = [_objects objectAtIndex:indexPath.row];
	[self.delegate durationListViewController:self didSelectDuration:cell.textLabel.text withMinutes:object];
	_objects = nil;
	//[self.navigationController popViewControllerAnimated:YES];
}

@end
