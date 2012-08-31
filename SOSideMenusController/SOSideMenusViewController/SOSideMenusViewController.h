//
//  SOSideMenusViewController.h
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


/*
 ABOUT THIS CLASS:
 
 This is a container view controller which would make a good foundation for an application controller in your app.  
 
 Once initialized with a main controller (typically a UINavigationController), you can use pan/swipe gestures to slide the main controller left or right to reveal a side menu controller (you have to set that property first).
 
 This class was designed for left-right pan/swipe, and was extended for top-bottom controllers, but the intention there was to use those for things like notifications and so there is no pan-swipe functionality there, as that may have also introduced some complexity when dealing with tableviews or scrollviews.
 
 INSTALLATION and USAGE:
 
 - Just import this class' containing folder with the .h/.m and the rounded_corner_overlays folder if you want to use rounded corners on your mainController.
 
 - Initialize the object with a mainController.  Then assign any one of the top/left/bottom/rightController objects.  It will figure out how to set up the side menus based on that view controller's view size.
 
 - you can explicitly show the side controllers (if they exist and have been assigned to that property) with show...Controller... methods.
 
 - you can disable being able to pan/swipe to a controller (without having to set him to nil) by using the BOOL properties canView...Controller.  It's a nice way to temporarily disable using the side menus.
 
 */


#import <UIKit/UIKit.h>


typedef enum {
    ViewingPageLeft = 1,
    ViewingPageCenter,
    ViewingPageRight,
    ViewingPageBottom,
    ViewingPageTop
}ViewingPage;

@class SOSideMenusViewController;

@interface UIViewController (SOSideMenusController)

- (SOSideMenusViewController*)sideMenuController;

@end


@interface SOSideMenusViewController : UIViewController<UIGestureRecognizerDelegate>
{

    UIViewController *_mainController;
    UIViewController *_leftController;
    UIViewController *_rightController;
    UIViewController *_topController;
    UIViewController *_bottomController;
    
    __weak UIPanGestureRecognizer *panGesture;  // they get retained by the view, and released by the view
    __weak UISwipeGestureRecognizer *leftSwipeGesture;
    __weak UISwipeGestureRecognizer *rightSwipeGesture;  // opposite to finger movement, it is the direction you want the content to move.  i.e. viewing the right page involves swiping to the left.
    
    __weak UITapGestureRecognizer *tapGesture;  // enabled on the _mainController.view only when viewing another page.
    
    // this stuff is for dealing with memory warnings and reloading a view
    CGRect _unloadedFrameLeft, _unloadedFrameRight, _unloadedFrameTop, _unloadedFrameBottom, _unloadedFrameMain;
    
    @protected
        
}

@property (nonatomic, readonly) UIViewController *mainController;  // here  your subclasses can override this and return a UIViewController subclass.
@property (nonatomic, strong) UIViewController *leftController;  // if non-nil, will set canViewLeftController to YES.
@property (nonatomic, strong) UIViewController *rightController;  // etc.
@property (nonatomic, strong) UIViewController *topController;
@property (nonatomic, strong) UIViewController *bottomController;

@property (readonly) CGFloat leftControllerWidth;
@property (readonly) CGFloat rightControllerWidth;
@property (readonly) CGFloat topControllerHeight;
@property (readonly) CGFloat bottomControllerHeight;

// this is if you want to disable swiping without removing the controller
@property BOOL canViewRightController;  
@property BOOL canViewLeftController;
@property BOOL canViewTopController;
@property BOOL canViewBottomController;

// Whether the mainController should use rounded corners (similar to an iPad app).  defaults to YES. 
@property BOOL usesRoundedCorners;  


// defaults to 100.0f (in points).  It means if you pull the main controller past the edge of a side controller, at what maximum distance past that edge can you pull no more?   once you pull past the width of the side controller, the input to output curve follows y(x) = 1 - 1/(x+1)
@property CGFloat elasticity;  

- (id)initWithMainController:(UIViewController*)theMainController;  // subclasses override this

// these ultimately are convenience methods for the moveToPage: ... method.  Provides the controller object in case you need to access one of his side controllers in your completion block.
- (void)showRightControllerWithCompletionBlock:(void(^)(SOSideMenusViewController *controller, 
                                                        ViewingPage fromPage, 
                                                        ViewingPage toPage))completionBlock;

- (void)showLeftControllerWithCompletionBlock:(void(^)(SOSideMenusViewController *controller, 
                                                       ViewingPage fromPage, 
                                                       ViewingPage toPage))completionBlock;

- (void)showMainControllerWithCompletionBlock:(void(^)(SOSideMenusViewController *controller, 
                                                       ViewingPage fromPage, 
                                                       ViewingPage toPage))completionBlock;

- (void)showTopControllerWithCompletionBlock:(void(^)(SOSideMenusViewController *controller, 
                                                      ViewingPage fromPage, 
                                                      ViewingPage toPage))completionBlock;

- (void)showBottomControllerWithCompletionBlock:(void(^)(SOSideMenusViewController *controller, 
                                                         ViewingPage fromPage, 
                                                         ViewingPage toPage))completionBlock;


// should this be private?  You should generally use the methods above, unless you have some special requirement.
- (void)moveToPage:(ViewingPage)toPage 
          duration:(NSTimeInterval)duration
           bounces:(BOOL)bounces
   completionBlock:(void(^)(SOSideMenusViewController *controller, 
                            ViewingPage fromPage, 
                            ViewingPage toPage))completionBlock;


@end

