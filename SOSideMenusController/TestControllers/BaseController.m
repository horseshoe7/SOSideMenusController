//
//  BaseController.m
//  GJNavigationPrototype
//
//  Created by Stephen O'Connor on 12/1/11.
//  Copyright (c) 2011 Stephen O'Connor. All rights reserved.
//

#import "BaseController.h"
#import <QuartzCore/QuartzCore.h>

@implementation BaseController
@synthesize label;

- (void)dealloc
{
    NSLog(@"Dealloc'd %@", NSStringFromClass([self class]));

}

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

-(NSString*)description
{
    //return [NSString stringWithFormat:@"%@ - %@", [super description], self.view];
    return [NSString stringWithFormat:@"%@", [super description]];
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    // i could use parentViewController but then would have to ensure that this controller
    // was added to that one before the view gets called for the first time.
    self.view = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    self.view.layer.borderWidth = 2.0f;
    self.view.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGRect labelFrame = self.view.bounds;
    labelFrame.size.height = 40.0f;
    
    label = [[UILabel alloc] initWithFrame:labelFrame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:30];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = UITextAlignmentCenter;
    label.shadowColor = [UIColor darkGrayColor];
    label.shadowOffset = CGSizeMake(0, 2);
    label.tag = 99;
    [self.view addSubview: label];
    
    label.text = [NSString stringWithFormat: @"I am a %@", NSStringFromClass([self class])];
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = self.view.bounds;
//    [button addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview: button];
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
    NSLog(@"ViewDidUnload");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    label.text = [NSString stringWithFormat: @"willRotateToInterfaceOrientation: %i with frame: %@", toInterfaceOrientation, NSStringFromCGRect(self.view.frame)];
//    NSLog(@"willRotateToInterfaceOrientation: %i with frame: %@", toInterfaceOrientation, NSStringFromCGRect(self.view.frame));
//}
//
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    self.view.frame = [[UIScreen mainScreen] bounds];
//    label.text = [NSString stringWithFormat: @"willAnimateRotationToInterfaceOrientation: %i with frame: %@", toInterfaceOrientation, NSStringFromCGRect(self.view.frame)];
//    NSLog(@"willAnimateRotationToInterfaceOrientation: %i with frame: %@", toInterfaceOrientation, NSStringFromCGRect(self.view.frame));
//}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    self.view.frame = [[UIScreen mainScreen] bounds];
//    label.text = [NSString stringWithFormat: @"didRotateFromInterfaceOrientation: %i with frame: %@", fromInterfaceOrientation, NSStringFromCGRect(self.view.frame)];
//    NSLog(@"willRotateToInterfaceOrientation: %i with frame: %@", fromInterfaceOrientation, NSStringFromCGRect(self.view.frame));
//}


//- (BOOL)isEqual:(id)object
//{
//    if (self.view.tag == ((UIViewController*)object).view.tag) {
//        return YES;
//    }
//    else
//        return NO;
//}

@end
