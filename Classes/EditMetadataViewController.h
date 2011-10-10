//
//  EditMetadataViewController.h
//  OpenStack
//
//  Created by Nik on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenStackViewController.h"
#import "OpenStackAccount.h"
#import "Container.h"
#import "Folder.h"
#import "StorageObject.h"
#import "ActivityIndicatorView.h"


@interface EditMetadataViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource,
UITextFieldDelegate> {
    
    OpenStackAccount *account;
    Container *container;
    StorageObject *object;
    
    NSString *metadataKey;
    NSString *metadataValue;
    NSString *newMetadataKey;
    NSString *newMetadataValue;
    IBOutlet UITableView *aTableView;
    
    ActivityIndicatorView *activityIndicatorView;
    id successObserver;
    id failureObserver;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) Container *container;
@property (nonatomic, retain) StorageObject *object;

@property (nonatomic, retain) NSString *metadataKey;
@property (nonatomic, retain) NSString *metadataValue;
@property (nonatomic, retain) NSString *newMetadataKey;
@property (nonatomic, retain) NSString *newMetadataValue;

@property (nonatomic, retain) IBOutlet UITableView *aTableView;

@end
