//
//  FolderDetailViewController.h
//  OpenStack
//
//  Created by Nik on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenStackAccount.h"
#import "Container.h"
#import "Folder.h"



@interface FolderDetailViewController : UITableViewController {
    OpenStackAccount *account;
    Container *container;
    Folder *folder;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) Container *container;
@property (nonatomic, retain) Folder *folder;

@end
