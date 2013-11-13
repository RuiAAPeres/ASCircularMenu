//
//  ASCircularMenu.m
//
//  Created by André Silva on 06/06/13.
//

#import "ASCircularMenu.h"
#import <QuartzCore/QuartzCore.h>

#define kBottomMargin 10.0
#define kMainButtonSize 41.0
#define kOpenAnimationTime 0.25
#define kCloseAnimationTime 0.2
#define kBigCircularOverlayWidth 210.0
#define kSmallCircularOverlayWidth 100.0
#define kMenuButtonsWidth 35.0
#define kMenuArc 180

@class FXBlurView;

@interface ASCircularMenu () {
    BOOL isAnimating;
}

@property (nonatomic,weak) UIWindow *appWindow;
@property (nonatomic,strong) UIButton *mainButton;
@property (nonatomic,strong) UIView *overlaysContainer;
@property (nonatomic,strong) UIView *blockerView;
@property (nonatomic,strong) NSMutableArray *buttons;

-(void)initialize;
-(CGRect)visibleMainButtonFrame;
-(CGRect)hidenMainButtonFrame;

@end


@implementation ASCircularMenu

-(id)init {
    if ((self = [super init]))
    {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initialize];
        [self didMoveToWindow];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initialize];
    }
    return self;
}

-(void)initialize {
    
        // get the app window so we can acess it faster
    _appWindow = [[UIApplication sharedApplication] keyWindow];
    NSAssert(_appWindow!=nil, @"Can only be inited after makeKeyAndVisible because it needs the app window");
    
    self.frame = _appWindow.bounds;
    
        // init the main button
    _mainButton = [[UIButton alloc]init];
    [_mainButton setImage:[UIImage imageNamed:@"main-menu-close-button"] forState:UIControlStateSelected];
    [_mainButton setImage:[UIImage imageNamed:@"main-menu-closed"] forState:UIControlStateNormal];
    [_mainButton addTarget:self action:@selector(mainButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        // set it with visible frame
    _mainButton.frame = [self visibleMainButtonFrame];
    
    
        // init the blocker view
        // https://github.com/nicklockwood/FXBlurView
        // if FXBlurView exists in target use that to create our blocker view, otherwise create a simple view.
    
        // simple blocker view
    _blockerView = [[UIView alloc]initWithFrame:self.bounds];
    _blockerView.hidden = YES;
    _blockerView.backgroundColor = [UIColor blackColor];
    
        // init the circular overlay container
    _overlaysContainer = [[UIView alloc]initWithFrame:CGRectMake((_appWindow.bounds.size.width/2)-(kBigCircularOverlayWidth/2),
                                                                 _appWindow.bounds.size.height-kBottomMargin-(kBigCircularOverlayWidth/2)-kMainButtonSize/2,
                                                                 kBigCircularOverlayWidth,
                                                                 kBigCircularOverlayWidth)];
    
    CGRect smallFrame = CGRectMake((kBigCircularOverlayWidth/2.0)-(kSmallCircularOverlayWidth/2.0),
                                   (kBigCircularOverlayWidth/2.0)-(kSmallCircularOverlayWidth/2.0),
                                   kSmallCircularOverlayWidth,
                                   kSmallCircularOverlayWidth);
    
        // small cicular Overlay
    ASCircularOverlayView *smallOverlay = [[ASCircularOverlayView alloc]initWithFrame:smallFrame];
    smallOverlay.alpha = 0.8;
    [_overlaysContainer addSubview:smallOverlay];
        //big circular Overlay
    ASCircularOverlayView *bigOverlay = [[ASCircularOverlayView alloc]initWithFrame:_overlaysContainer.bounds];
    bigOverlay.alpha = 0.7;
    [_overlaysContainer addSubview:bigOverlay];
    
    [self addSubview:_overlaysContainer];
    
    [self reloadButtons];
    
    [self closeMenu:NO];
    
        // add the main button to menu
    [self addSubview:_mainButton];
        // add the menu to the window
    [_appWindow addSubview:self];
}

-(void)reloadButtons {
    
        // without delegate we can't do anything here
    if (!_delegate) return;
    
        // lazy init the array
    if (!_buttons) {
        self.buttons = [NSMutableArray arrayWithCapacity:1];
    }
    
        // remove the actual buttons
    [_buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_buttons removeAllObjects];
    
    NSInteger numberOfItems = 0;
    if ([_delegate respondsToSelector:@selector(numberOfItemsInCircularMenu)]) {
        numberOfItems = [_delegate numberOfItemsInCircularMenu];
        
    }else {
            //  NSAssert(0, @"Implement delegate methods!");
    }
        // NSAssert(numberOfItems==0||numberOfItems>6, @"Menu needs to have at least one item and less than 6!");
    
    if ([_delegate respondsToSelector:@selector(circularMenu:buttonForMenuItemAtIndex:)]) {
        for (int i=0 ; i<numberOfItems ; i++) {
            UIButton *button = [_delegate circularMenu:self buttonForMenuItemAtIndex:i];
            button.clipsToBounds = YES;
            [button addTarget:self action:@selector(menuButtonItemSelected:) forControlEvents:UIControlEventTouchUpInside];
            [_buttons addObject:button];
        }
    }
    [self addButtonsToView];
}

- (void)addButtonsToView {
    
	NSInteger itemCount = _buttons.count;
    if (itemCount == 0) {
            //without any items to display there's nothing todo
		return;
	}
    
    NSLog(@"%f",((kBigCircularOverlayWidth-kSmallCircularOverlayWidth)/2));
    
	int radius = (kBigCircularOverlayWidth/2) - 28; // radius of the circle
    
    int start = kMenuArc;
    float angle;
    
        // diferente algoritm for less than 4 buttons because we don't need the full circunference
    if (itemCount <= 3) {
        start = kMenuArc + (kMenuArc/(itemCount*2));
        angle = kMenuArc/(itemCount);
    }else {
        angle = kMenuArc/(itemCount-1);
    }
    
    
	int centerX = _mainButton.center.x;
	int centerY = _mainButton.center.y;
	
    
	int currentItem = 1;
	UIButton *menuButtonItem;
	while (currentItem <= itemCount) {
        menuButtonItem = [_buttons objectAtIndex:currentItem-1];
		float radians = (angle * (currentItem - 1) + start) * (M_PI/180);
		
		int x = round (centerX + radius * cos(radians));
		int y = round (centerY + radius * sin(radians));
		
		CGRect frame = CGRectMake(centerX - (kMenuButtonsWidth/2),
                                  centerY - (kMenuButtonsWidth/2),
                                  kMenuButtonsWidth,
                                  kMenuButtonsWidth);
		
		CGPoint final = CGPointMake(x, y);
		
		
		menuButtonItem.frame = frame;
        menuButtonItem.center = final;
        
        if (_isMenuOpen) {
            menuButtonItem.alpha = 1.0;
            menuButtonItem.hidden = NO;
        }else {
            menuButtonItem.alpha = 0.0;
            menuButtonItem.hidden = YES;
        }
		
		[self insertSubview:menuButtonItem belowSubview:_mainButton];
        [menuButtonItem bringSubviewToFront:_overlaysContainer];
		currentItem++;
	}
}

-(CGRect)visibleMainButtonFrame {
    
        // portrait
    return CGRectMake((_appWindow.bounds.size.width/2)-(kMainButtonSize/2),
                      _appWindow.bounds.size.height-kBottomMargin-kMainButtonSize,
                      kMainButtonSize,
                      kMainButtonSize);
}

-(CGRect)hidenMainButtonFrame {
    
        // portrait
    return CGRectMake((_appWindow.bounds.size.width/2)-(kMainButtonSize/2),
                      _appWindow.bounds.size.height+kBottomMargin,
                      kMainButtonSize,
                      kMainButtonSize);
}

-(void)showMenu:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:kOpenAnimationTime animations:^{
            _mainButton.frame = [self visibleMainButtonFrame];
        } completion:nil];
    }else {
        _mainButton.frame = [self visibleMainButtonFrame];
    }
}

-(void)hideMenu:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:kCloseAnimationTime animations:^{
            _mainButton.frame = [self hidenMainButtonFrame];
        } completion:nil];
    }else {
        _mainButton.frame = [self hidenMainButtonFrame];
    }
}

-(void)fadeInMenuButtonItem:(UIButton*)menuItem {
    [UIView animateWithDuration:0.2 animations:^{
        menuItem.hidden = NO;
        [menuItem setAlpha:1.0];
    } completion:^(BOOL finished) {
    }];
}

-(void)openMenu:(BOOL)animated {
    _isMenuOpen = YES;
        // insert the blockerview
    _blockerView.alpha = 0.0;
    _blockerView.hidden = NO;
    [self insertSubview:_blockerView belowSubview:_overlaysContainer];
    [_mainButton setSelected:YES];
    if (animated) {
        isAnimating = YES;
        [UIView animateWithDuration:kOpenAnimationTime animations:^{
            _overlaysContainer.transform = CGAffineTransformIdentity;
            _blockerView.alpha = 0.20;
        } completion:^(BOOL finished) {
            
                // now animate the buttons in
            float delay = 0.0;
            for (UIButton *btn in _buttons) {
                [self performSelector:@selector(fadeInMenuButtonItem:) withObject:btn afterDelay:delay];
                delay += 0.08;
            }
            
            isAnimating = NO;
            
        }];
    }else {
        _overlaysContainer.transform = CGAffineTransformIdentity;
    }
}

-(void)closeMenu:(BOOL)animated {
    _isMenuOpen = NO;
    if (animated) {
        isAnimating = YES;
            // animate the buttons out first
        [_mainButton setSelected:NO];
        [UIView animateWithDuration:0.2 animations:^{
            for (UIButton *btn in _buttons) {
                btn.alpha = 0.0;
            }
        } completion:^(BOOL finished) {
            [_buttons makeObjectsPerformSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES]];
                // now close the menu
            [UIView animateWithDuration:kCloseAnimationTime animations:^{
                _overlaysContainer.transform = CGAffineTransformMakeScale(0.0,0.0);
                _blockerView.alpha = 0.0;
            } completion:^(BOOL finished) {
                _blockerView.hidden = YES;
                [_blockerView removeFromSuperview];
                isAnimating = NO;
            }];
        }];
        
    }else {
        [_buttons makeObjectsPerformSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES]];
        [_buttons makeObjectsPerformSelector:@selector(setAlpha:) withObject:[NSNumber numberWithFloat:0.0]];
        
        _blockerView.alpha = 0.0;
        _blockerView.hidden = YES;
        [_blockerView removeFromSuperview];
        _overlaysContainer.transform = CGAffineTransformMakeScale(0.0,0.0);
    }
}

-(void)mainButtonTouched {
    
    if (isAnimating) return;
    
    if (_isMenuOpen) {
        [self closeMenu:YES];
    }else {
        [self openMenu:YES];
    }
}

-(void)menuButtonItemSelected:(UIButton*)button {
    if (_delegate && [_delegate respondsToSelector:@selector(circularMenu:didSelectMenuItemAtIndex:)]) {
        [_delegate circularMenu:self didSelectMenuItemAtIndex:[_buttons indexOfObject:button]];
    }
}

    // send the touch events to the app
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    [super hitTest:point withEvent:event];
    if (isAnimating) return nil;
    
        // test if the touch is in main button
    UIView *mainButtonMaybe = [_mainButton hitTest:[_mainButton convertPoint:point fromView:self] withEvent:event];
    if (mainButtonMaybe) {
        return mainButtonMaybe;
    }
    
        // test if the touch is in the menu or buttons
    if (_isMenuOpen) {
        
        UIView *menuOverlay = [_overlaysContainer hitTest:[_overlaysContainer convertPoint:point fromView:self] withEvent:event];
        if (menuOverlay) {
                // the touh was inside the menu overlay, now check if was in any button
            __block UIView *hitView = menuOverlay;
            [_buttons enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
                CGPoint thePoint = [self convertPoint:point toView:obj];
                UIView *theSubHitView = [obj hitTest:thePoint withEvent:event];
                if (theSubHitView != nil) {
                    hitView = theSubHitView;
                    *stop = YES;
                }
                
            }];
            
            return hitView;
        }
    }
    
        // test if the touch is in blocker view
    if (_isMenuOpen && _blockerView.superview) {
        UIView *blockerView = [_blockerView hitTest:[_blockerView convertPoint:point fromView:self] withEvent:event];
        if (blockerView) {
                // close menu and don't send the touch to back views
            [self closeMenu:YES];
            return blockerView;
        }
    }else if ([_appWindow subviews].count>0) {
            // send the touchs to the app root controller
        UIView *appView = (UIView*)[[_appWindow subviews]objectAtIndex:0];
        return [appView hitTest:[appView convertPoint:point fromView:self]withEvent:event];
    }
    
    return self;
}

@end
