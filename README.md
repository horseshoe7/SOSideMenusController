# SOSideMenusController

A flexible, generic, side menus view controller with a powerfully simple API, similar to the Facebook and Path 2.0 Apps

## Yes, another Facebook-style side menus controller.  It's the API that makes it unique.

I wanted to make a very simple API that made plain english desires an easy task:  
  
 *   Slide the main controller back because I touched the main controller again to go back.
 *   Don't make me set anything other than which controller I want to be on which side.
 *   Let me temporarily disable sliding to a certain side
 *   Give me callback blocks for when the animation is finished
 *   Make it easy to slide left/right, whether pan or swipe
 *   Make my main controller look a bit more modern (rounded corners)

## Easy API

```objc
@interface SOSideMenusViewController : UIViewController<UIGestureRecognizerDelegate>

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

//////////////////////////////////////////////////////////////////////  THE ONLY METHODS YOU'LL NEED

- (id)initWithMainController:(UIViewController*)theMainController;  // subclasses override this
- (void)moveToPage:(ViewingPage)toPage 
          duration:(NSTimeInterval)duration
           bounces:(BOOL)bounces
   completionBlock:(void(^)(SOSideMenusViewController *controller, 
                            ViewingPage fromPage, 
                            ViewingPage toPage))completionBlock;

//////////////////////////////////////////////////////////////////////  CONVENIENCE METHODS

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

@end
```

## Known Issues

 * The top-bottom functionality may need some further work.  I wrote this initially for left-right, and recently extended it if you want to use top-bottom for internal messaging / help, but swiping up-down was not implemented as this would most likely conflict with table views and scroll views.

## Feedback

Is always welcome!  Feel free to create a github issue.

Thanks

Stephen O'Connor
