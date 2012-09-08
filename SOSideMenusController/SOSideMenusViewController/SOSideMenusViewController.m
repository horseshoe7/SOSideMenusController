//
//  SOSideMenusViewController.m
//  SOSideMenusViewController
//
//  Created by Stephen O'Connor on 2/7/12.
//  Copyright (c) 2012 Stephen O'Connor. All rights reserved.
//  ocon.sc@gmail.com


/*  LICENSE - "Do whatever you want.  Just don't blame me or come after me with lawyers."
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "SOSideMenusViewController.h"
#import <QuartzCore/QuartzCore.h>


#define kBounceDistance 20.0f

static void drawShadowEdge(CGContextRef context, CGRect rect, ViewingPage edgeSide) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    UIColor *startColor = [UIColor colorWithRed:0.0
                                          green:0.0
                                           blue:0.0
                                          alpha:0.8];
    
    UIColor *endColor = [UIColor colorWithRed:0.0f
                                        green:0.0f
                                         blue:0.0f
                                        alpha:0.0f];
    
    CGColorRef start = CGColorRetain(startColor.CGColor);
    CGColorRef end = CGColorRetain(endColor.CGColor);
    
    CGColorRef borderGradientColors[] = {
        start,
        end
    };
    CFArrayRef colorsArray = CFArrayCreate(NULL, (const void**)borderGradientColors, sizeof(borderGradientColors) / sizeof(CGColorRef), &kCFTypeArrayCallBacks);
    CGFloat borderGradientLocations[] = { 0.0, 1.0 };
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colorsArray, borderGradientLocations);
    
    CFRelease(colorsArray);
    
    
    CGPoint startPoint;  // i.e where the less transparent color should start drawing
    CGPoint endPoint;  // where the full transparent color should end
    
    switch (edgeSide) {
        case ViewingPageTop:
            startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
            endPoint = CGPointMake(CGRectGetMidX(rect),CGRectGetMinY(rect));
            break;
        case ViewingPageBottom:
            startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
            endPoint = CGPointMake(CGRectGetMidX(rect),CGRectGetMaxY(rect));
            break;
        case ViewingPageLeft:
            startPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
            endPoint = CGPointMake(CGRectGetMinX(rect),CGRectGetMidY(rect));
            break;
        case ViewingPageRight:
            startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
            endPoint = CGPointMake(CGRectGetMaxX(rect),CGRectGetMidY(rect));
            break;
        default:
            break;
    }
    
    CGContextSaveGState(context);
    
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGContextRestoreGState(context);
    
    CGColorRelease(start);
    CGColorRelease(end);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@interface ShadowEdgeView : UIView {
@private
    
    ViewingPage _edgeSide;
}
@property ViewingPage edgeSide;  // i.e for which edge of a view do you attach this?

@end


@implementation ShadowEdgeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(ViewingPage)edgeSide { return _edgeSide;}
-(void)setEdgeSide:(ViewingPage)edgeSide
{
    _edgeSide = edgeSide;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    drawShadowEdge(context, self.bounds, _edgeSide);
    
}


@end


@implementation UIViewController (SOSideMenusController)

- (SOSideMenusViewController*)sideMenuController
{
    SOSideMenusViewController *sideMenuController = nil;
    UIViewController *parent = [self parentViewController];
    while (parent != nil) {
        // check if it's a tableviewcell
        if ([parent isKindOfClass:[SOSideMenusViewController class]]) {
            sideMenuController = (SOSideMenusViewController*)parent;
            break;
        }
        // if not, set parent = [parent parentViewController];
        parent = [parent parentViewController];
    }
    
    return sideMenuController;
    
}

@end


#pragma mark -
#pragma mark SOSideMenusViewController


@interface SOSideMenusViewController()
{
    ViewingPage currentPage;
    CGRect panStartRect;
    
    // rounded corners
    UIImageView *_topLeft, *_topRight, *_btmLeft, *_btmRight;
    
    
    // these should be created/destroyed when you add a controller at that side.
    ShadowEdgeView *_leftEdge;
    ShadowEdgeView *_rightEdge;
    ShadowEdgeView *_topEdge;
    ShadowEdgeView *_bottomEdge;
    
    BOOL _usesRoundedCorners;
    
    BOOL _canViewLeftController, _canViewRightController, _canViewTopController, _canViewBottomController;
    
    CGFloat _leftControllerWidth, _rightControllerWidth, _topControllerHeight, _bottomControllerHeight;
    
    
}

- (void)handlePan:(UIPanGestureRecognizer*)aRecognizer;
- (void)handleSwipe:(UISwipeGestureRecognizer*)aRecognizer;
- (void)moveToPage:(ViewingPage)toPage duration:(NSTimeInterval)duration;
- (void)moveToPage:(ViewingPage)toPage duration:(NSTimeInterval)duration bounces:(BOOL)bounces;


@end

@implementation SOSideMenusViewController
@synthesize mainController = _mainController;
@synthesize canViewRightController = _canViewRightController, canViewLeftController = _canViewLeftController, canViewTopController = _canViewTopController, canViewBottomController = _canViewBottomController;

@synthesize leftControllerWidth = _leftControllerWidth, rightControllerWidth = _rightControllerWidth, topControllerHeight = _topControllerHeight, bottomControllerHeight = _bottomControllerHeight;
@synthesize elasticity;

- (void)dealloc
{
    /* No longer listen for keyboard */
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    _mainController = nil;
    _leftController = nil;
    _rightController = nil;
    _topController = nil;
    _bottomController = nil;
}

- (id)initWithMainController:(UIViewController *)theMainController
{
    self = [super init];
    if (self) {
        // Custom initialization
        _mainController = nil;
        _leftController = nil;
        _rightController = nil;
        _topController = nil;
        _bottomController = nil;
        
        self.canViewLeftController = NO;
        self.canViewRightController = NO;
        self.canViewTopController = NO;
        self.canViewBottomController = NO;
        
        currentPage = ViewingPageCenter;
        
        if (theMainController == nil) {
            [NSException raise:NSInternalInconsistencyException format:@"You tried to instantiate a SlideNavigationMenuController without providing a mainController"];
        }
        
        _mainController = theMainController;
        [_mainController willMoveToParentViewController: self];
        [self addChildViewController:_mainController];
        
        
        
        _unloadedFrameTop = CGRectZero, _unloadedFrameBottom = CGRectZero, _unloadedFrameLeft = CGRectZero, _unloadedFrameRight = CGRectZero;
        
        
        self.elasticity = 100.0f;
        
        [_mainController didMoveToParentViewController: self];
        
        
        // we also need to care about when the keyboard is doing stuff
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        
    }
    return self;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    tapGesture.enabled = NO;
    rightSwipeGesture.enabled = NO;
    leftSwipeGesture.enabled = NO;
    panGesture.enabled = NO;
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    tapGesture.enabled = YES;
    rightSwipeGesture.enabled = YES;
    leftSwipeGesture.enabled = YES;
    panGesture.enabled = YES;
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(application.statusBarOrientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    
    CGRect newFrame;
    newFrame.origin = CGPointZero;
    newFrame.size = size;
    
    self.view = [[UIView alloc] initWithFrame:newFrame];
    self.view.autoresizesSubviews = YES;
    
    _unloadedFrameMain = self.view.bounds;
    
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // also move some of the self.view stuff from init... into here
    
    
    // here we need to restore any views if they exist.  You should check if they exist first so you know if you have to also add shadow edges, etc.  things that get called in the setter methods.
    
    if (self.mainController && !CGRectIsEmpty(_unloadedFrameMain)) {
        self.mainController.view.frame = _unloadedFrameMain;  // should be self.view.bounds
        
        _mainController.view.clipsToBounds = NO;
        
        _usesRoundedCorners = NO;
        self.usesRoundedCorners = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.delegate = self;
        [self.view addGestureRecognizer:pan];
        panGesture = pan;
        
        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        leftSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        leftSwipe.delegate = self;
        leftSwipeGesture = leftSwipe;
        
        UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        rightSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        rightSwipe.delegate = self;
        rightSwipeGesture = rightSwipe;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(tappedMainView:)];
        tap.delegate = self;
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        tap.cancelsTouchesInView = NO;
        tap.enabled = NO;
        tapGesture = tap;
        
        [self.view addGestureRecognizer:leftSwipeGesture];
        [self.view addGestureRecognizer:rightSwipeGesture];
        [self.view addGestureRecognizer:tapGesture];
        
        [self.view addSubview: _mainController.view];
        
    }
    
    if (self.topController && !CGRectIsEmpty(_unloadedFrameTop)) {
        self.topController.view.frame = _unloadedFrameTop;
        
        self.canViewTopController = _canViewTopController;
        
        if (_topEdge == nil) {
            _topEdge = [[ShadowEdgeView alloc] initWithFrame: CGRectMake(0.0f, -10.0f, self.view.frame.size.width, 10.f)];
            _topEdge.edgeSide = ViewingPageTop;
            [_mainController.view insertSubview:_topEdge atIndex:0];
        }
        
        _topController.view.hidden = YES; // we unhide him when we're about to show him.
        _topEdge.hidden = NO;
        
        [self.view insertSubview:self.topController.view belowSubview: _mainController.view];
        
    }
    
    if (self.leftController && !CGRectIsEmpty(_unloadedFrameLeft)) {
        self.leftController.view.frame = _unloadedFrameLeft;
        
        self.canViewLeftController = _canViewLeftController;
        
        if (_leftEdge == nil) {
            _leftEdge = [[ShadowEdgeView alloc] initWithFrame: CGRectMake(-10.0f, 0.0f, 10.f, self.view.frame.size.height)];
            _leftEdge.edgeSide = ViewingPageLeft;
            [_mainController.view insertSubview:_leftEdge atIndex:0];
        }
        
        _leftController.view.hidden = NO; // we unhide him when we're about to show him.
        _leftEdge.hidden = NO;
        
        
        [self.view insertSubview:self.leftController.view belowSubview: _mainController.view];
    }
    
    if (self.bottomController && !CGRectIsEmpty(_unloadedFrameBottom)) {
        self.bottomController.view.frame = _unloadedFrameBottom;
        
        self.canViewBottomController = _canViewBottomController;
        
        if (_bottomEdge == nil) {
            _bottomEdge = [[ShadowEdgeView alloc] initWithFrame: CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, 10.f)];
            _bottomEdge.edgeSide = ViewingPageBottom;
            [_mainController.view insertSubview:_bottomEdge atIndex:0];
        }
        
        _bottomController.view.hidden = YES; // we unhide him when we're about to show him.
        _bottomEdge.hidden = NO;
        
        
        [self.view insertSubview:self.bottomController.view belowSubview: _mainController.view];
    }
    
    if (self.rightController && !CGRectIsEmpty(_unloadedFrameRight)) {
        self.rightController.view.frame = _unloadedFrameRight;
        
        self.canViewRightController = _canViewRightController;
        
        if (_rightEdge == nil) {
            _rightEdge = [[ShadowEdgeView alloc] initWithFrame: CGRectMake(self.view.frame.size.width, 0.0f, 10.f, self.view.frame.size.height)];
            _rightEdge.edgeSide = ViewingPageRight;
            [_mainController.view insertSubview:_rightEdge atIndex:0];
        }
        
        _rightController.view.hidden = NO; // we unhide him when we're about to show him.
        _rightEdge.hidden = NO;
        
        [self.view insertSubview:self.rightController.view belowSubview: _mainController.view];
        
    }
    
    
    
    
    
    // then set the rects back to zero
    _unloadedFrameTop = CGRectZero, _unloadedFrameBottom = CGRectZero, _unloadedFrameLeft = CGRectZero, _unloadedFrameRight = CGRectZero;  // except main because it's frame should always be loaded
}


- (void)viewWillUnload
{
    
    
    // we save the frames of any view controllers
    if (self.topController) {
        _unloadedFrameTop = self.topController.view.frame;
    }
    
    if (self.leftController) {
        _unloadedFrameLeft = self.leftController.view.frame;
        
    }
    
    if (self.bottomController) {
        _unloadedFrameBottom = self.bottomController.view.frame;
    }
    
    if (self.rightController) {
        _unloadedFrameRight = self.rightController.view.frame;
        
        
    }
    
    if (self.mainController) {
        _unloadedFrameMain = self.mainController.view.frame;
    }
    
    [super viewWillUnload];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    _leftEdge = nil;
    _rightEdge = nil;
    _topEdge = nil;
    _bottomEdge = nil;
    
    _topLeft = nil;
    _topRight = nil;
    _btmLeft = nil;
    _btmRight = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Accessors

- (BOOL)usesRoundedCorners { return _usesRoundedCorners; }
- (void)setUsesRoundedCorners:(BOOL)usesRoundedCorners
{
    
    if (usesRoundedCorners && _usesRoundedCorners == NO) {
        
        _topLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner-top-left.png"]];
        _topRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner-top-right.png"]];
        _btmLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner-bottom-left.png"]];
        _btmRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner-bottom-right.png"]];
        
        _topRight.frame = CGRectMake(_mainController.view.frame.size.width - _topRight.frame.size.width,
                                     0,
                                     _topRight.frame.size.width,
                                     _topRight.frame.size.height);
        
        _btmLeft.frame = CGRectMake( 0,
                                    _mainController.view.frame.size.height - _btmLeft.frame.size.height,
                                    _btmLeft.frame.size.width,
                                    _btmLeft.frame.size.height);
        
        _btmRight.frame = CGRectMake( _mainController.view.frame.size.width - _btmRight.frame.size.width,
                                     _mainController.view.frame.size.height - _btmRight.frame.size.height,
                                     _btmRight.frame.size.width,
                                     _btmRight.frame.size.height);
        
        _topLeft.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        _topRight.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        _btmLeft.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _btmRight.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        [_mainController.view addSubview: _topLeft];
        [_mainController.view addSubview: _topRight];
        [_mainController.view addSubview: _btmLeft];
        [_mainController.view addSubview: _btmRight];
    }
    else if (usesRoundedCorners == NO && _usesRoundedCorners){
        [_topLeft removeFromSuperview];
        [_topRight removeFromSuperview];
        [_btmLeft removeFromSuperview];
        [_btmRight removeFromSuperview];
        
        _topLeft = nil;
        _topRight = nil;
        _btmLeft = nil;
        _btmRight = nil;
    }
    _usesRoundedCorners = usesRoundedCorners;
    
}


- (UIViewController*)leftController { return _leftController;}
- (UIViewController*)rightController { return  _rightController;}
- (UIViewController*)topController { return  _topController;}
- (UIViewController*)bottomController { return  _bottomController;}



- (void)setLeftController:(UIViewController *)aController
{
    // if there is a _leftController, remove his view from superview
    // then nullify him
    if(_leftController)
    {
        [_leftController willMoveToParentViewController:nil];
        [_leftController.view removeFromSuperview];
        [_leftController removeFromParentViewController];
        _leftController = nil;
        
    }
    
    if (aController) {
        
        _leftController = aController;
        [_leftController willMoveToParentViewController:self];
        [self addChildViewController:aController];
        
        _leftControllerWidth = _leftController.view.frame.size.width;
        
        CGRect newFrame = self.view.bounds;
        newFrame.size.width = _leftControllerWidth;
        _leftController.view.frame = newFrame;
        
        
        [self.view insertSubview:aController.view belowSubview: _mainController.view];
        [_leftController didMoveToParentViewController:self];
        
        self.canViewLeftController = YES;
        
        if (_leftEdge == nil) {
            _leftEdge = [[ShadowEdgeView alloc] initWithFrame: CGRectMake(-10.0f, 0.0f, 10.f, self.view.frame.size.height)];
            _leftEdge.edgeSide = ViewingPageLeft;
            [_mainController.view insertSubview:_leftEdge atIndex:0];
        }
        
        _leftController.view.hidden = YES; // we unhide him when we're about to show him.
        _leftEdge.hidden = NO;
    }
    else
    {  // was nil
        self.canViewLeftController = NO;
        _leftControllerWidth = 0.0f;
        [_leftEdge removeFromSuperview];
        _leftEdge = nil;
    }
}

- (void)setRightController:(UIViewController *)aController
{
    // if there is a _leftController, remove his view from superview
    // then nullify him
    if(_rightController)
    {
        [_rightController willMoveToParentViewController:nil];
        [_rightController.view removeFromSuperview];
        [_rightController removeFromParentViewController];
        _rightController = nil;
    }
    
    if (aController) {
        _rightController = aController;
        [_rightController willMoveToParentViewController:self];
        [self addChildViewController:aController];
        
        _rightControllerWidth = _rightController.view.frame.size.width;
        
        CGRect newFrame = self.view.bounds;
        newFrame.origin.x = newFrame.size.width - _rightControllerWidth;
        newFrame.size.width = _rightControllerWidth;
        _rightController.view.frame = newFrame;
        
        [self.view insertSubview:aController.view belowSubview: _mainController.view];
        [_rightController didMoveToParentViewController:self];
        
        self.canViewRightController = YES;
        
        if (_rightEdge == nil) {
            _rightEdge = [[ShadowEdgeView alloc] initWithFrame: CGRectMake(self.view.frame.size.width, 0.0f, 10.f, self.view.frame.size.height)];
            _rightEdge.edgeSide = ViewingPageRight;
            [_mainController.view insertSubview:_rightEdge atIndex:0];
        }
        
        _rightController.view.hidden = YES; // we unhide him when we're about to show him.
        _rightEdge.hidden = NO;
    }
    else
    {  // was nil
        self.canViewRightController = NO;
        _rightControllerWidth = 0.0f;
        [_rightEdge removeFromSuperview];
        _rightEdge = nil;
    }
}

- (void)setTopController:(UIViewController *)aController
{
    // if there is a _leftController, remove his view from superview
    // then nullify him
    if(_topController)
    {
        [_topController willMoveToParentViewController:nil];
        [_topController.view removeFromSuperview];
        [_topController removeFromParentViewController];
        _topController = nil;
    }
    
    if (aController) {
        _topController = aController;
        [_topController willMoveToParentViewController:self];
        [self addChildViewController:aController];
        
        _topControllerHeight = _topController.view.frame.size.height;
        
        CGRect newFrame = self.view.bounds;
        newFrame.size.height = _topControllerHeight;
        _topController.view.frame = newFrame;
        
        [self.view insertSubview:aController.view belowSubview: _mainController.view];
        [_topController didMoveToParentViewController:self];
        
        self.canViewTopController = YES;
        
        if (_topEdge == nil) {
            _topEdge = [[ShadowEdgeView alloc] initWithFrame: CGRectMake(0.0f, -10.0f, self.view.frame.size.width, 10.f)];
            _topEdge.edgeSide = ViewingPageTop;
            [_mainController.view insertSubview:_topEdge atIndex:0];
        }
        
        _topController.view.hidden = YES; // we unhide him when we're about to show him.
        _topEdge.hidden = NO;
    }
    else
    {  // was nil
        self.canViewTopController = NO;
        _topControllerHeight = 0.0f;
        [_topEdge removeFromSuperview];
        _topEdge = nil;
    }
}

- (void)setBottomController:(UIViewController *)aController
{
    // if there is a _leftController, remove his view from superview
    // then nullify him
    if(_bottomController)
    {
        [_bottomController willMoveToParentViewController:nil];
        [_bottomController.view removeFromSuperview];
        [_bottomController removeFromParentViewController];
        _bottomController = nil;
    }
    
    if (aController) {
        _bottomController = aController;
        [_bottomController willMoveToParentViewController:self];
        [self addChildViewController:aController];
        
        _bottomControllerHeight = _bottomController.view.frame.size.height;
        
        CGRect newFrame = self.view.bounds;
        newFrame.origin.y = newFrame.size.height - _bottomControllerHeight;
        newFrame.size.height = _bottomControllerHeight;
        _bottomController.view.frame = newFrame;
        
        [self.view insertSubview:aController.view belowSubview: _mainController.view];
        [_bottomController didMoveToParentViewController:self];
        
        self.canViewBottomController = YES;
        
        if (_bottomEdge == nil) {
            _bottomEdge = [[ShadowEdgeView alloc] initWithFrame: CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, 10.f)];
            _bottomEdge.edgeSide = ViewingPageBottom;
            [_mainController.view insertSubview:_bottomEdge atIndex:0];
        }
        
        _bottomController.view.hidden = YES; // we unhide him when we're about to show him.
        _bottomEdge.hidden = NO;
    }
    else
    {  // was nil
        self.canViewBottomController = NO;
        _bottomControllerHeight = 0.0f;
        [_bottomEdge removeFromSuperview];
        _bottomEdge = nil;
    }
}

#pragma mark Explicit Actions

- (void)showTopControllerWithCompletionBlock:(void(^)(SOSideMenusViewController *controller, ViewingPage fromPage, ViewingPage toPage))completionBlock
{
    if (self.canViewTopController == NO) {
        return;
    }
    [self moveToPage:ViewingPageTop duration:0.4f bounces:YES completionBlock:completionBlock];
}

- (void)showBottomControllerWithCompletionBlock:(void(^)(SOSideMenusViewController *controller, ViewingPage fromPage, ViewingPage toPage))completionBlock
{
    if (self.canViewBottomController == NO) {
        return;
    }
    [self moveToPage:ViewingPageBottom duration:0.4f bounces:YES completionBlock:completionBlock];
}

- (void)showRightControllerWithCompletionBlock:(void(^)(SOSideMenusViewController *controller, ViewingPage fromPage, ViewingPage toPage))completionBlock
{
    if (self.canViewRightController == NO) {
        return;
    }
    [self moveToPage:ViewingPageRight duration:0.4f bounces:YES completionBlock:completionBlock];
}

- (void)showLeftControllerWithCompletionBlock:(void(^)(SOSideMenusViewController *controller, ViewingPage fromPage, ViewingPage toPage))completionBlock
{
    if (self.canViewLeftController == NO) {
        return;
    }
    [self moveToPage:ViewingPageLeft duration:0.4f bounces:YES completionBlock:completionBlock];
}


- (void)showMainControllerWithCompletionBlock:(void(^)(SOSideMenusViewController *controller, ViewingPage fromPage, ViewingPage toPage))completionBlock
{
    [self moveToPage:ViewingPageCenter duration:0.4f bounces:YES completionBlock:completionBlock];
}


- (void)moveToPage:(ViewingPage)toPage duration:(NSTimeInterval)duration bounces:(BOOL)bounces
{
    [self moveToPage:toPage duration:duration bounces:bounces completionBlock: nil];
}

- (void)moveToPage:(ViewingPage)toPage duration:(NSTimeInterval)duration
{
    [self moveToPage:toPage duration:duration bounces:YES completionBlock: nil];
}

// you call this method at the end of a handlePan:, handleSwipe: and show...Controller.
- (void)moveToPage:(ViewingPage)toPage
          duration:(NSTimeInterval)duration
           bounces:(BOOL)bounces
   completionBlock:(void(^)(SOSideMenusViewController*, ViewingPage, ViewingPage))completionBlock
{
    
    CGRect finalRect = self.view.bounds;  // would be for the center page.
    CGPoint bouncePoint;  // intermediate point if bouncing.
    
    // need to set the finalRect of the _mainController, and also set the layer.hidden properties, as well as the currentPage.  Need to disable interaction during animation
    
    
    switch (toPage) {
        case ViewingPageCenter:
            //finalRect = finalRect;  // written for completeness
            if (currentPage == ViewingPageLeft) {
                bouncePoint = CGPointMake(-kBounceDistance, 0.0f);
            }
            else if(currentPage == ViewingPageRight){
                bouncePoint = CGPointMake(kBounceDistance, 0.0f);
            }
            break;
            
        case ViewingPageLeft:
            finalRect.origin = CGPointMake(_leftControllerWidth, 0.0f);
            bouncePoint = CGPointMake(_leftControllerWidth + kBounceDistance, 0.0f);
            _leftController.view.hidden = NO;
            _rightController.view.hidden = YES;
            _topController.view.hidden = YES;
            _bottomController.view.hidden = YES;
            
            break;
            
        case ViewingPageRight:
            finalRect.origin = CGPointMake(-_rightControllerWidth, 0.0f);
            bouncePoint = CGPointMake(-_rightControllerWidth - kBounceDistance , 0.0f);
            _leftController.view.hidden = YES;
            _rightController.view.hidden = NO;
            _topController.view.hidden = YES;
            _bottomController.view.hidden = YES;
            
            break;
            
        case ViewingPageTop:
            finalRect.origin = CGPointMake(0.0f, _topControllerHeight);
            bouncePoint = CGPointMake(0.0f, _topControllerHeight + kBounceDistance);
            _topController.view.hidden = NO;
            _rightController.view.hidden = YES;
            _leftController.view.hidden = YES;
            _bottomController.view.hidden = YES;
            
            break;
            
        case ViewingPageBottom:
            finalRect.origin = CGPointMake(0.0f, -_bottomControllerHeight);
            bouncePoint = CGPointMake(0.0f, -_bottomControllerHeight - kBounceDistance);
            _topController.view.hidden = YES;
            _rightController.view.hidden = YES;
            _leftController.view.hidden = YES;
            _bottomController.view.hidden = NO;
            break;
            
            
        default:
            break;
    }
    
    if (bounces) {
        CGRect bounceRect = finalRect;
        bounceRect.origin = bouncePoint;
        
        [UIView animateWithDuration:duration*2.0f/4.0f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _mainController.view.frame = bounceRect;
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:duration/2.0f
                                                   delay:0.0f
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _mainController.view.frame = finalRect;
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  if (toPage == ViewingPageCenter) {
                                                      _rightController.view.hidden = YES;
                                                      _leftController.view.hidden = YES;
                                                      _topController.view.hidden = YES;
                                                      _bottomController.view.hidden = YES;
                                                      tapGesture.enabled = NO;
                                                      
                                                      _mainController.view.userInteractionEnabled = YES;
                                                  }
                                                  else
                                                  {
                                                      tapGesture.enabled = YES;
                                                      _mainController.view.userInteractionEnabled = NO;  // so that you can't manipulate anything in the mainController
                                                  }
                                                  
                                                  if (toPage == ViewingPageBottom || toPage == ViewingPageTop) {
                                                      panGesture.enabled = NO;
                                                      leftSwipeGesture.enabled = NO;
                                                      rightSwipeGesture.enabled = NO;
                                                  }
                                                  else {
                                                      panGesture.enabled = YES;
                                                      leftSwipeGesture.enabled = YES;
                                                      rightSwipeGesture.enabled = YES;
                                                  }
                                                  
                                                  
                                                  // will crash if completion block is nil
                                                  if(completionBlock)
                                                      completionBlock(self, currentPage, toPage);
                                                  
                                                  currentPage = toPage;
                                                  
                                              }
                              ];
                         }
         ];
    }
    else
    {
        [UIView animateWithDuration:duration
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _mainController.view.frame = finalRect;
                         }
                         completion:^(BOOL finished) {
                             
                             
                             if (toPage == ViewingPageCenter) {
                                 _rightController.view.hidden = YES;
                                 _leftController.view.hidden = YES;
                                 _topController.view.hidden = YES;
                                 _bottomController.view.hidden = YES;
                                 tapGesture.enabled = NO;
                                 _mainController.view.userInteractionEnabled = YES;
                             }
                             else
                             {
                                 tapGesture.enabled = YES;
                                 _mainController.view.userInteractionEnabled = NO;
                             }
                             
                             if (toPage == ViewingPageBottom || toPage == ViewingPageTop) {
                                 panGesture.enabled = NO;
                                 leftSwipeGesture.enabled = NO;
                                 rightSwipeGesture.enabled = NO;
                             }
                             else {
                                 panGesture.enabled = YES;
                                 leftSwipeGesture.enabled = YES;
                                 rightSwipeGesture.enabled = YES;
                             }
                             
                             // will crash if completion block is nil
                             if(completionBlock)
                                 completionBlock(self, currentPage, toPage);
                             
                             currentPage = toPage;
                             
                         }
         ];
    }
}

#pragma mark Gesture Recognizer Handlers
- (void)tappedMainView:(UITapGestureRecognizer*)recognizer
{
    // have to check if the tap's location is inside of the _mainController.view
    CGRect intersection = CGRectIntersection(self.view.bounds, _mainController.view.frame);
    
    BOOL tappedInsideMainController = CGRectContainsPoint(intersection, [recognizer locationInView: self.view]);
    
    if (tappedInsideMainController) {
        [self moveToPage:ViewingPageCenter duration:0.2f bounces:NO];
    }
}


- (void)handlePan:(UIPanGestureRecognizer*)aRecognizer
{
    
    if (aRecognizer.state == UIGestureRecognizerStateBegan) {
        panStartRect = _mainController.view.frame;  // keep track of the rect where the _mainController started, so we can put him back to that if need be.
    }
    
    CGPoint translation = [aRecognizer translationInView:self.view];  // this is for the entire touch sequence.
    
    // need to clamp the translation value if we prohibit movement in that direction.
    if (currentPage == ViewingPageCenter && (self.canViewRightController == NO || self.rightController == nil)) {
        translation.x = MAX(0, translation.x);
    }
    
    if (currentPage == ViewingPageCenter && (self.canViewLeftController == NO || self.leftController == nil)) {
        translation.x = MIN(0, translation.x);
    }
    
    CGRect panRect = CGRectMake(panStartRect.origin.x + translation.x, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    // now we can add some elasticity to prevent linear panning past the width of the left or right controller.
    if (panRect.origin.x > 0) {
        // trying to view left controller
        
        // panRect.origin.x is linear up until the leftController's frame width.
        if (panRect.origin.x > _leftController.view.frame.size.width) {
            
            CGFloat delta = panRect.origin.x - self.leftController.view.frame.size.width;
            CGFloat deltaPct = MIN(delta/self.elasticity, 1.0f);
            
            // I want a curve of general form x' = y(x) = 1 - 1/(x+1)   (plot that curve to see what i mean)
            CGFloat transformedDelta = 1.0f - (1.0f/(deltaPct+1.0f));
            transformedDelta = transformedDelta * self.elasticity;
            
            panRect.origin.x = _leftController.view.frame.size.width + transformedDelta;
        }
        
    }
    else if (panRect.origin.x < 0){
        // trying to view right controller
        
        if (fabsf(panRect.origin.x) > _rightController.view.frame.size.width) {
            
            CGFloat delta = fabsf(panRect.origin.x + self.rightController.view.frame.size.width);
            CGFloat deltaPct = MIN(delta/self.elasticity, 1.0f);
            
            // I want a curve of general form x' = y(x) = 1 - 1/(x+1)   (plot that curve to see what i mean)
            CGFloat transformedDelta = 1.0f - (1.0f/(deltaPct+1.0f));
            transformedDelta = transformedDelta * self.elasticity;
            
            panRect.origin.x = -1.0f*(_rightController.view.frame.size.width +transformedDelta);
        }
    }
    
    _mainController.view.frame = panRect;
    
    if (_mainController.view.frame.origin.x >= 0) {
        // it's moving right, exposing the leftController
        
        self.rightController.view.hidden = YES;
        self.leftController.view.hidden = NO;
        self.bottomController.view.hidden = YES;
        self.topController.view.hidden = YES;
    }
    else
    {
        // it's moving left, exposing the rightController
        self.rightController.view.hidden = NO;
        self.leftController.view.hidden = YES;
        self.bottomController.view.hidden = YES;
        self.topController.view.hidden = YES;
        
    }
    
    if (aRecognizer.state == UIGestureRecognizerStateEnded) {
        
        
        if (_mainController.view.frame.origin.x > _leftController.view.frame.size.width *3.0f/4.0f) {
            [self moveToPage:ViewingPageLeft duration:0.3f];
        }
        else if (_mainController.view.frame.origin.x < -_rightController.view.frame.size.width *3.0f/ 4.0f){
            [self moveToPage:ViewingPageRight duration:0.3f];
        }
        else{
            if (currentPage == ViewingPageCenter) {
                [self moveToPage:ViewingPageCenter duration:0.3f bounces:NO];
            }
            else
            {
                [self moveToPage:ViewingPageCenter duration:0.3f];
            }
        }
        
    }
}
- (void)handleSwipe:(UISwipeGestureRecognizer*)aRecognizer
{
    panGesture.enabled = NO;  // because we want to swipe.  Just stop recognizing the panGesture while this is allowed to complete.  It will cancel the touch sequence of the panGesture.
    
    // i.e. your finger swiped from left to right, meaning you want to move the transitionalViewController to the left so to reveal the rightController underneath.
    if (aRecognizer == leftSwipeGesture) {
        
        switch (currentPage) {
            case ViewingPageLeft:
                // don't do anything!
                break;
                
            case ViewingPageCenter:
                if (self.canViewLeftController)
                    [self moveToPage:ViewingPageLeft duration:0.3f];
                
                // else do nothing
                break;
            case ViewingPageRight:
                [self moveToPage:ViewingPageCenter duration:0.3f];
                break;
            default:
                break;
        }
        
    }
    else if (aRecognizer == rightSwipeGesture)
    {
        switch (currentPage) {
            case ViewingPageLeft:
                [self moveToPage:ViewingPageCenter duration:0.3f];
                break;
                
            case ViewingPageCenter:
                if (self.canViewRightController)
                    [self moveToPage:ViewingPageRight duration:0.3f];
                
                // else do nothing
                break;
            case ViewingPageRight:
                // don't do anything!
                break;
            default:
                break;
        }
        
    }    
    
    panGesture.enabled = YES;  // mustn't forget to reenable him
}



@end
