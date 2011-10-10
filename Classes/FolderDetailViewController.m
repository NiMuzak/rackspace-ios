//
//  FolderDetailViewController.m
//  OpenStack
//
//  Created by Nik on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FolderDetailViewController.h"
#import "EditMetadataViewController.h"

#define kOverview 0
#define kMetadata 1


@implementation FolderDetailViewController

@synthesize account, container, folder;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [folder release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kOverview)
        return 2;
    else 
        return 1 + [folder.metadata count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];

        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    }
    
    if (indexPath.section == kOverview) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = nil;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = folder.name;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Full Path";
            cell.detailTextLabel.text = [folder fullPath];
        }
    } else if (indexPath.section == kMetadata) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryView = nil;
        if (indexPath.row == [folder.metadata count]) {
            cell.textLabel.text = @"Add Metadata";
            cell.detailTextLabel.text = @"";
        } else {
            NSString *key = [[folder.metadata allKeys] objectAtIndex:indexPath.row];
            cell.textLabel.text = key;
            cell.detailTextLabel.text = [folder.metadata objectForKey:key];
        }
    }

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kMetadata) {
        EditMetadataViewController *vc = [[EditMetadataViewController alloc] initWithNibName:@"EditMetadataViewController" bundle:nil];
        NSString *metadataKey;
        NSString *metadataValue;
        
        if (indexPath.row == [self.folder.metadata count]) {
            metadataKey = @"";
            metadataValue = @"";
        }
        else {
            metadataKey = [[self.folder.metadata allKeys] objectAtIndex:indexPath.row];
            metadataValue = [self.folder.metadata objectForKey:metadataKey];
        }
        
        StorageObject *object = [[[StorageObject alloc] init] autorelease];
        object.name = folder.name;
        object.metadata = folder.metadata;
        object.fullPath = [folder fullPath];
        
        vc.metadataKey = metadataKey;
        vc.metadataValue = metadataValue;
        vc.account = account;
        vc.container = container;
        vc.object = object;

        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

@end
