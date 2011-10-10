//
//  EditMetadataViewController.m
//  OpenStack
//
//  Created by Nik on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditMetadataViewController.h"
#import "AccountManager.h"
#import "UIViewController+Conveniences.h"




@implementation EditMetadataViewController


@synthesize container, account, object;

@synthesize metadataKey;
@synthesize metadataValue;
@synthesize newMetadataKey;
@synthesize newMetadataValue;
@synthesize aTableView;


- (void)dealloc
{
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
    newMetadataKey = metadataKey;
    newMetadataValue = metadataValue;

    [super viewWillAppear:animated];
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

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:  return @"Metadata Name";
        case 1:  return @"Metadata Value";
    }
    
    return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.section < 2) {
        CGRect bounds = [cell.contentView bounds];
        CGRect rect = CGRectInset(bounds, 20.0, 10.0);
        UITextField *textField = [[UITextField alloc] initWithFrame:rect];
        
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [textField setBackgroundColor:[UIColor whiteColor]];
        [textField setOpaque:YES];
        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [textField setDelegate:self];
        
        switch (indexPath.section) {
            case 0:
                [textField setReturnKeyType:UIReturnKeyNext];
                textField.text = metadataKey;
                textField.tag = 0;
                break;
            case 1:
                textField.text = metadataValue;
                textField.tag = 1;
                break;
        }
        
        [cell.contentView addSubview:textField];
        [textField release];
    }
    
    switch (indexPath.section) {
        case 0: 
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 1: 
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 2: 
            cell.textLabel.text = @"Save metadata";
            break;
        case 3: 
            cell.textLabel.text = @"Delete metadata";
            break;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *activityMessage;
    switch (indexPath.section) {
        case 2:
            activityMessage = @"Saving metadata";
            NSCharacterSet *invalidCharactersSet = [NSCharacterSet characterSetWithCharactersInString:@" =,"];
            
            BOOL metadataKeyIsValid = TRUE;
            if ([[newMetadataKey componentsSeparatedByCharactersInSet:invalidCharactersSet] count] > 1)
                metadataKeyIsValid = FALSE;
              
            BOOL metadataValueIsValid = TRUE;
            if ([[newMetadataValue componentsSeparatedByCharactersInSet:invalidCharactersSet] count] > 1)
                metadataValueIsValid = FALSE;
            
            if (!metadataKeyIsValid || !metadataValueIsValid) {
                [self alert:@"Invalid format" message:@"Metadata names and values cannot contains whitespace, ',' and '=' characters"];
                [self.aTableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
            }
            
            activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:activityMessage] text:activityMessage];
            [activityIndicatorView addToView:self.view];

            [object.metadata removeObjectForKey:metadataKey];
            [object.metadata setObject:newMetadataValue forKey:newMetadataKey];
            [self.account.manager writeObjectMetadata:container object:object];
            successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"writeObjectMetadataSucceeded"
                                                                                object:object
                                                                                 queue:[NSOperationQueue mainQueue]
                                                                            usingBlock:^(NSNotification *notification)
                               {
                                   metadataKey = newMetadataKey;
                                   metadataValue = newMetadataValue;
                                   
                                   [activityIndicatorView removeFromSuperviewAndRelease];
                                   [self.aTableView deselectRowAtIndexPath:indexPath animated:YES];
                                   [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
                               }];
            
            failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"writeObjectMetadataFailed" 
                                                                                object:object 
                                                                                 queue:[NSOperationQueue mainQueue] 
                                                                            usingBlock:^(NSNotification *notification)
                               {
                                   [object.metadata removeObjectForKey:newMetadataKey];
                                   [object.metadata setObject:metadataValue forKey:metadataKey];
                                   [activityIndicatorView removeFromSuperviewAndRelease];
                                   [self.aTableView deselectRowAtIndexPath:indexPath animated:YES];
                                   [self alert:@"There was a problem saving the metadata." request:[notification.userInfo objectForKey:@"request"]];
                                   
                                   [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
                               }];
            
            break;
        case 3:
            activityMessage = @"Deleting metadata";
            activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:activityMessage] text:activityMessage];
            [activityIndicatorView addToView:self.view];

            [object.metadata removeObjectForKey:metadataKey];
            [self.account.manager writeObjectMetadata:container object:object];
            successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"writeObjectMetadataSucceeded"
                                                                                object:object
                                                                                 queue:[NSOperationQueue mainQueue]
                                                                            usingBlock:^(NSNotification *notification)
                               {
                                   [activityIndicatorView removeFromSuperviewAndRelease];
                                   [self.aTableView deselectRowAtIndexPath:indexPath animated:YES];
                                   metadataKey = @"";
                                   metadataValue = @"";
                                   [newMetadataKey release];
                                   [newMetadataValue release];

                                   [self.aTableView reloadData];
                                   [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
                               }];
            
            failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"writeObjectMetadataFailed" 
                                                                                object:object 
                                                                                 queue:[NSOperationQueue mainQueue] 
                                                                            usingBlock:^(NSNotification *notification)
                               {
                                   [object.metadata setObject:metadataValue forKey:metadataKey];
                                   [activityIndicatorView removeFromSuperviewAndRelease];
                                   [self.aTableView deselectRowAtIndexPath:indexPath animated:YES];
                                   [self alert:@"There was a problem saving the metadata." request:[notification.userInfo objectForKey:@"request"]];
                                   
                                   [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
                               }];

            break;
    }
}

#pragma mark - Textfield delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if ([textField tag] == 0) 
        self.newMetadataKey = textField.text;
    else 
        self.newMetadataValue = textField.text;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if ([textField returnKeyType] == UIReturnKeyNext)
    {
        NSInteger nextTag = [textField tag] + 1;
        UIView *nextTextField = [self.aTableView viewWithTag:nextTag];
        [nextTextField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
