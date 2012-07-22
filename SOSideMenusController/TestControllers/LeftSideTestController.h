//
//  LeftSideTestController.h
//  BLTNavigationController
//
//  Created by Stephen O'Connor on 2/7/12.
//  Copyright (c) 2012 Stephen O'Connor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftSideTestController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *table;

@end
