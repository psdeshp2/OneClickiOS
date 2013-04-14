//
//  ImageListViewController.m
//  OneClick
//
//  Created by Ignacio Dominguez on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageListViewController.h"

@interface ImageListViewController () {
    NSMutableOrderedSet *_objects;
}

@property (nonatomic, strong) VCLXMLRPC *vclXMLRPC;

- (void)addImage:(NSDictionary *)oneClick atIndex:(NSUInteger)index;

@end

@implementation ImageListViewController

@synthesize delegate = _delegate;
@synthesize vclXMLRPC = _vclXMLRPC;
@synthesize selectedImageID = _selectedImageID;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.vclXMLRPC.delegate = self;
	[self startLoading];
}

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
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	NSDictionary *object = [_objects objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [object objectForKey:@"name"];
	cell.detailTextLabel.text = [[object objectForKey:@"ostype"] stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[[object objectForKey:@"ostype"]  substringToIndex:1] capitalizedString]];
    if([NSNumber numberWithInt:[[object objectForKey:@"id"] intValue]] == self.selectedImageID) {
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
	NSDictionary *object = [_objects objectAtIndex:indexPath.row];
	[self.delegate imageListViewController:self didSelectImage:[object objectForKey:@"name"] withID:[NSNumber numberWithInt:[[object objectForKey:@"id"] intValue]] withOSType:[object objectForKey:@"ostype"]];
}

#pragma mark - OneClick

- (VCLXMLRPC *)vclXMLRPC {
	if(!_vclXMLRPC) {
		_vclXMLRPC = [[VCLXMLRPC alloc] init];
	}
	return _vclXMLRPC;
}

#pragma mark - XMLRPC delegate

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	NSArray *result = (NSArray *)[response object];
			
	int i = 0;
	for(NSDictionary *object in result) {
		[self addImage:object atIndex:i];
		i++;
	}
	NSLog(@"Result %@", [response object]);
	[self stopLoading];
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error {	
	[self stopLoading];
	[self.delegate imageListViewController:self didFailWithError:error];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)refresh {
	[_objects removeAllObjects];
	[self.tableView reloadData];
	if([VCLXMLRPC isConnectedToInternetShowMessage:YES]) {
		[self.vclXMLRPC getImages];
	}
	else {
		[self stopLoading];
	}
}

- (void)addImage:(NSDictionary *)image atIndex:(NSUInteger)index {
	if (!_objects) {
        _objects = [[NSMutableOrderedSet alloc] init];
    }
	
    [_objects insertObject:image atIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
