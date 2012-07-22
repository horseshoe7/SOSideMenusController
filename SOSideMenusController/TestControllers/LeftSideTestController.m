//
//  LeftSideTestController.m
//  BLTNavigationController
//
//  Created by Stephen O'Connor on 2/7/12.
//  Copyright (c) 2012 Stephen O'Connor. All rights reserved.
//

#import "LeftSideTestController.h"
#import "SOSideMenusViewController.h"
#import "ControllerA.h"
#import "ControllerB.h"
#import "BaseController.h"

@implementation LeftSideTestController
@synthesize table;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.table = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark TableViewDelegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Choice Num %i", indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BaseController *newController;
    
    if ([[(UINavigationController*) self.sideMenuController.mainController topViewController] isKindOfClass:[ControllerA class]]) {
        newController = [[ControllerB alloc] init];
    }
    else
    {
        newController = [[ControllerA alloc] init];
    }
    
    [(UINavigationController*)self.sideMenuController.mainController pushViewController:newController animated:YES];
    
    [self.sideMenuController showMainControllerWithCompletionBlock:^(SOSideMenusViewController *controller, ViewingPage fromPage, ViewingPage toPage) {
            
        
    }];
    
    
    
        
}

@end
