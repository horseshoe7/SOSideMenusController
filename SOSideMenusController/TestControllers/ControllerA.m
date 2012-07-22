//
//  ControllerA.m
//  GJNavigationPrototype
//
//  Created by Stephen O'Connor on 11/23/11.
//  Copyright (c) 2011 Stephen O'Connor. All rights reserved.
//

#import "ControllerA.h"
#import "SOSideMenusViewController.h"


@implementation ControllerA
@synthesize aButton = _aButton;

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

- (void)pressedButton:(id)sender
{
    [self.sideMenuController showBottomControllerWithCompletionBlock:nil];
}

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor redColor];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame: self.view.bounds];
    imgView.image = [UIImage imageNamed:@"puppy01.jpg"];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view insertSubview:imgView atIndex:0];
    
    if (_aButton == nil) {
        _aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _aButton.frame = CGRectMake(80, 300, 160, 44);
        [_aButton setTitle:@"Open" forState:UIControlStateNormal];
        [self.view insertSubview: _aButton atIndex:1];
        [_aButton addTarget: self action: @selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}



@end
